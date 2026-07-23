"""
SCIE Data Ingestion Runner — Runs scheduled RSS & Twitter collection jobs and publishes to Redis Streams.
"""
import asyncio
import os
import structlog
from apscheduler.schedulers.asyncio import AsyncIOScheduler

from connectors.rss import DEFAULT_INDONESIAN_RSS_FEEDS, fetch_rss_feed
from connectors.twitter import fetch_twitter_posts
from scrapers.tiktok_research_scraper import TikTokResearchScraper
from pipeline.producer import RedisStreamProducer

log = structlog.get_logger()
REDIS_URL = os.getenv("REDIS_URL", "redis://127.0.0.1:6381/0")
STREAM_RAW = os.getenv("REDIS_STREAM_RAW_POSTS", "stream:raw_posts")

TIKTOK_APP_ID = os.getenv("TIKTOK_APP_ID", "7665669886001235989")
TIKTOK_ORG_ID = os.getenv("TIKTOK_ORG_ID", "7665678484718552085")


async def run_rss_job(producer: RedisStreamProducer):
    """Fetch all default RSS feeds and produce to Redis stream."""
    log.info("Starting RSS Collection Job")
    for feed in DEFAULT_INDONESIAN_RSS_FEEDS:
        try:
            posts = await fetch_rss_feed(feed["url"], feed["name"])
            if posts:
                await producer.publish_batch(posts)
        except Exception as e:
            log.error("Failed collecting feed", feed=feed["name"], error=str(e))


async def run_twitter_job(producer: RedisStreamProducer):
    """Fetch Twitter posts (or demo posts) and produce to Redis stream."""
    log.info("Starting Twitter Collection Job")
    try:
        bearer = os.getenv("TWITTER_BEARER_TOKEN")
        posts = await fetch_twitter_posts(bearer)
        if posts:
            await producer.publish_batch(posts)
    except Exception as e:
        log.error("Failed collecting Twitter posts", error=str(e))


async def run_tiktok_job(producer: RedisStreamProducer):
    """Fetch TikTok Research API posts and produce to Redis stream."""
    log.info("Starting TikTok Research API Collection Job", app_id=TIKTOK_APP_ID, org_id=TIKTOK_ORG_ID)
    try:
        scraper = TikTokResearchScraper(app_id=TIKTOK_APP_ID, org_id=TIKTOK_ORG_ID)
        posts = await scraper.fetch_south_sulawesi_videos()
        if posts:
            await producer.publish_batch(posts)
            log.info("Successfully published TikTok Research API posts to Redis Stream", count=len(posts))
    except Exception as e:
        log.error("Failed collecting TikTok Research API posts", error=str(e))


async def main():
    log.info("Starting SCIE Ingestion Runner", redis_url=REDIS_URL)
    producer = RedisStreamProducer(redis_url=REDIS_URL, stream_key=STREAM_RAW)
    await producer.connect()

    # Initial execution on startup
    await run_rss_job(producer)
    await run_twitter_job(producer)
    await run_tiktok_job(producer)

    # Schedule recurring job every 15 minutes
    scheduler = AsyncIOScheduler()
    scheduler.add_job(run_rss_job, "interval", minutes=15, args=[producer])
    scheduler.add_job(run_twitter_job, "interval", minutes=15, args=[producer])
    scheduler.add_job(run_tiktok_job, "interval", minutes=15, args=[producer])
    scheduler.start()

    log.info("Ingestion scheduler active (running every 15 mins)")


    try:
        while True:
            await asyncio.sleep(3600)
    except (KeyboardInterrupt, SystemExit):
        log.info("Stopping Ingestion Runner")
        scheduler.shutdown()
        await producer.close()

if __name__ == "__main__":
    asyncio.run(main())
