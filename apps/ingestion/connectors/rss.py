"""
RSS / News Feed Connector — Fetches articles from news feeds and RSS sources.
"""
from datetime import datetime, UTC
from typing import Any
import feedparser
import httpx
import structlog

log = structlog.get_logger()

DEFAULT_INDONESIAN_RSS_FEEDS = [
    {"name": "Antara News", "url": "https://www.antaranews.com/rss/terkini.xml", "platform": "news"},
    {"name": "CNBC Indonesia", "url": "https://www.cnbcindonesia.com/news/rss", "platform": "news"},
    {"name": "CNN Indonesia", "url": "https://www.cnnindonesia.com/nasional/rss", "platform": "news"},
]



async def fetch_rss_feed(feed_url: str, source_name: str = "RSS") -> list[dict[str, Any]]:
    """Fetch and parse an RSS feed URL returning standardized raw post items."""
    log.info("Fetching RSS feed", url=feed_url, source=source_name)
    posts: list[dict[str, Any]] = []

    try:
        async with httpx.AsyncClient(timeout=15.0, follow_redirects=True) as client:
            resp = await client.get(feed_url, headers={"User-Agent": "SCIE-Bot/1.0"})
            if resp.status_code != 200:
                log.warning("Failed to fetch RSS feed", status=resp.status_code, url=feed_url)
                return posts
            content = resp.text
    except Exception as e:
        log.error("RSS fetch error", url=feed_url, error=str(e))
        return posts

    parsed = feedparser.parse(content)
    for entry in parsed.entries[:30]:
        title = getattr(entry, "title", "")
        summary = getattr(entry, "summary", "") or getattr(entry, "description", "")
        published = getattr(entry, "published", "") or getattr(entry, "updated", "")
        link = getattr(entry, "link", "")
        author = getattr(entry, "author", "") or source_name

        text = f"{title}\n\n{summary}".strip()
        if not text:
            continue

        item_id = link or f"rss_{hash(title)}"

        posts.append({
            "platform": "rss",
            "platform_id": item_id,
            "type": "article",
            "text": text,
            "url": link,
            "author_username": author,
            "author_display_name": source_name,
            "timestamp": published or datetime.now(UTC).isoformat(),
            "metrics": {
                "likes": 0,
                "comments": 0,
                "shares": 0,
                "views": 0,
            },
            "source_name": source_name,
        })

    log.info("Parsed RSS entries", count=len(posts), source=source_name)
    return posts
