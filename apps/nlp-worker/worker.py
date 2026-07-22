"""
NLP Worker Consumer — Reads raw posts from stream:raw_posts, enriches them, saves to PostgreSQL, and publishes to stream:enriched_posts.
"""
import asyncio
import json
import os
import uuid
from datetime import datetime, UTC
import redis.asyncio as aioredis
import structlog
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from pipeline import enrich_post

log = structlog.get_logger()

REDIS_URL = os.getenv("REDIS_URL", "redis://localhost:6379/0")
STREAM_RAW = os.getenv("REDIS_STREAM_RAW_POSTS", "stream:raw_posts")
STREAM_ENRICHED = os.getenv("REDIS_STREAM_ENRICHED_POSTS", "stream:enriched_posts")
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql+asyncpg://scie:scie_secret_password@localhost:5432/scie")
CONSUMER_GROUP = "nlp_workers_group"
CONSUMER_NAME = f"worker_{os.getpid()}"

# Setup DB engine
engine = create_async_engine(DATABASE_URL, echo=False)
AsyncSessionLocal = async_sessionmaker(bind=engine, class_=AsyncSession, expire_on_commit=False)


async def save_to_database(db: AsyncSession, enriched: dict):
    """Save enriched post, author account, and entities to PostgreSQL/TimescaleDB."""
    platform = enriched.get("platform", "unknown")
    platform_id = str(enriched.get("platform_id", uuid.uuid4()))

    author_username = enriched.get("author_username", "anonymous")
    author_display_name = enriched.get("author_display_name", author_username)

    # 1. Upsert Social Account
    account_id = None
    res = await db.execute(
        select(sa_text("id FROM social_accounts WHERE platform = :p AND platform_id = :pid"))
        .params(p=platform, pid=author_username)
    )
    account_row = res.first()
    if account_row:
        account_id = str(account_row[0])
    else:
        account_id = str(uuid.uuid4())
        await db.execute(
            sa_text(
                "INSERT INTO social_accounts (id, platform, platform_id, username, display_name, collected_at, updated_at) "
                "VALUES (:id, :platform, :pid, :uname, :dname, NOW(), NOW())"
            ).params(
                id=account_id,
                platform=platform,
                pid=author_username,
                uname=author_username,
                dname=author_display_name,
            )
        )

    # 2. Insert or Update Post
    metrics = enriched.get("metrics", {})
    post_id = str(uuid.uuid4())

    await db.execute(
        sa_text(
            "INSERT INTO posts (id, platform, platform_id, type, text, text_cleaned, url, author_id, "
            "timestamp, likes, comments, shares, views, sentiment_label, sentiment_score, topics, keywords, "
            "virality_score, collected_at, processed_at) "
            "VALUES (:id, :platform, :platform_id, :type, :text, :text_cleaned, :url, :author_id, "
            "NOW(), :likes, :comments, :shares, :views, :sentiment_label, :sentiment_score, :topics, :keywords, "
            ":virality_score, NOW(), NOW()) "
            "ON CONFLICT (platform, platform_id) DO UPDATE SET "
            "likes = EXCLUDED.likes, comments = EXCLUDED.comments, shares = EXCLUDED.shares, "
            "sentiment_label = EXCLUDED.sentiment_label, sentiment_score = EXCLUDED.sentiment_score, "
            "topics = EXCLUDED.topics, keywords = EXCLUDED.keywords, virality_score = EXCLUDED.virality_score, "
            "processed_at = NOW()"
        ).params(
            id=post_id,
            platform=platform,
            platform_id=platform_id,
            type=enriched.get("type", "post"),
            text=enriched.get("text"),
            text_cleaned=enriched.get("text_cleaned"),
            url=enriched.get("url"),
            author_id=account_id,
            likes=metrics.get("likes", 0),
            comments=metrics.get("comments", 0),
            shares=metrics.get("shares", 0),
            views=metrics.get("views", 0),
            sentiment_label=enriched.get("sentiment_label"),
            sentiment_score=enriched.get("sentiment_score"),
            topics=enriched.get("topics", []),
            keywords=enriched.get("keywords", []),
            virality_score=enriched.get("virality_score", 0.0),
        )
    )

    # 3. Upsert Entities & Link
    entities = enriched.get("entities", [])
    for ent in entities:
        ent_name = ent["name"]
        ent_type = ent["type"]
        ent_id = str(uuid.uuid4())

        # Insert entity if not exists
        await db.execute(
            sa_text(
                "INSERT INTO entities (id, name, normalized_name, type, mention_count, first_seen, last_seen) "
                "VALUES (:id, :name, :norm, :type, 1, NOW(), NOW()) "
                "ON CONFLICT (normalized_name, type) DO UPDATE SET "
                "mention_count = entities.mention_count + 1, last_seen = NOW()"
            ).params(id=ent_id, name=ent_name, norm=ent_name, type=ent_type)
        )

    await db.commit()


async def process_stream():
    redis = aioredis.from_url(REDIS_URL, encoding="utf-8", decode_responses=True)
    log.info("NLP Worker listening to stream", stream=STREAM_RAW, group=CONSUMER_GROUP)

    # Create consumer group if not existing
    try:
        await redis.xgroup_create(STREAM_RAW, CONSUMER_GROUP, id="0", mkstream=True)
    except Exception:
        pass  # Group already exists

    while True:
        try:
            entries = await redis.xreadgroup(
                groupname=CONSUMER_GROUP,
                consumername=CONSUMER_NAME,
                streams={STREAM_RAW: ">"},
                count=10,
                block=2000,
            )

            if not entries:
                await asyncio.sleep(0.5)
                continue

            for stream_name, messages in entries:
                for msg_id, data in messages:
                    payload_raw = data.get("payload")
                    if not payload_raw:
                        await redis.xack(STREAM_RAW, CONSUMER_GROUP, msg_id)
                        continue

                    try:
                        raw_post = json.loads(payload_raw)
                        # Check if message is a command
                        if raw_post.get("event") == "trigger_collection":
                            await redis.xack(STREAM_RAW, CONSUMER_GROUP, msg_id)
                            continue

                        # Enrich post
                        enriched = enrich_post(raw_post)

                        # Save to PostgreSQL
                        async with AsyncSessionLocal() as db:
                            await save_to_database(db, enriched)

                        # Publish to stream:enriched_posts
                        await redis.xadd(
                            STREAM_ENRICHED,
                            fields={"payload": json.dumps(enriched)},
                            maxlen=100000,
                            approximate=True,
                        )

                        # Acknowledge Redis message
                        await redis.xack(STREAM_RAW, CONSUMER_GROUP, msg_id)
                        log.info(
                            "Processed & enriched post",
                            msg_id=msg_id,
                            platform=enriched.get("platform"),
                            sentiment=enriched.get("sentiment_label"),
                        )
                    except Exception as e:
                        log.error("Failed processing message", msg_id=msg_id, error=str(e))
                        await redis.xack(STREAM_RAW, CONSUMER_GROUP, msg_id)

        except Exception as e:
            log.error("Error in stream loop", error=str(e))
            await asyncio.sleep(2)


# Import sa_text helper
from sqlalchemy import text as sa_text

if __name__ == "__main__":
    asyncio.run(process_stream())
