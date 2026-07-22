"""
Twitter / X Connector — Fetches tweets via API v2 or generates realistic social posts for testing.
"""
from datetime import datetime, UTC
import random
from typing import Any
import httpx
import structlog

log = structlog.get_logger()

# Realistic Indonesian sample tweets for demo & pipeline testing
DEMO_TWEETS = [
    {
        "text": "Teknologi AI berkembang sangat pesat di Indonesia. Banyak startup lokal yang mulai memanfaatkan LLM dan Knowledge Graph untuk analisis data bisnis.",
        "username": "tech_indo",
        "display_name": "Tech Indonesia",
        "likes": 342,
        "shares": 89,
        "keywords": ["AI", "LLM", "Knowledge Graph", "Indonesia"],
    },
    {
        "text": "Diskusi publik mengenai kebijakan ekonomi nasional semakin hangat. Komunitas akademisi menyarankan pendekatan berbasis data real-time.",
        "username": "ekonomi_kita",
        "display_name": "Pengamat Ekonomi",
        "likes": 1205,
        "shares": 450,
        "keywords": ["ekonomi", "kebijakan", "data"],
    },
    {
        "text": "Pentingnya transparansi dan pengolahan informasi digital di media sosial agar masyarakat tidak terjerat isu hoaks dan disinformasi.",
        "username": "cyber_watch",
        "display_name": "Cyber Watch ID",
        "likes": 560,
        "shares": 210,
        "keywords": ["disinformasi", "hoaks", "media sosial"],
    },
    {
        "text": "Sistem Social Intelligence Engine (SCIE) mampu memetakan hubungan antar entitas dan komunitas pengguna di berbagai jaringan digital.",
        "username": "scie_official",
        "display_name": "SCIE Platform",
        "likes": 890,
        "shares": 312,
        "keywords": ["SCIE", "Social Intelligence", "Analytics"],
    },
    {
        "text": "Layanan publik digital di tingkat pemerintah daerah kini semakin terintegrasi dengan teknologi AI dan analisis sentimen warga.",
        "username": "gov_tech_id",
        "display_name": "GovTech Indonesia",
        "likes": 415,
        "shares": 105,
        "keywords": ["GovTech", "analisis sentimen", "layanan publik"],
    },
]


async def fetch_twitter_posts(bearer_token: str | None = None, keywords: list[str] | None = None) -> list[dict[str, Any]]:
    """Fetch tweets using Twitter API v2 or generate demo posts if bearer token is missing."""
    if bearer_token and bearer_token != "your_twitter_bearer_token":
        log.info("Fetching real tweets from Twitter API v2")
        headers = {"Authorization": f"Bearer {bearer_token}"}
        query = " OR ".join(keywords) if keywords else "Indonesia"
        url = f"https://api.twitter.com/2/tweets/search/recent?query={query}&tweet.fields=created_at,public_metrics,lang&expansions=author_id"

        try:
            async with httpx.AsyncClient(timeout=15.0) as client:
                resp = await client.get(url, headers=headers)
                if resp.status_code == 200:
                    data = resp.json()
                    tweets = data.get("data", [])
                    return [
                        {
                            "platform": "twitter",
                            "platform_id": t["id"],
                            "type": "post",
                            "text": t["text"],
                            "timestamp": t.get("created_at", datetime.now(UTC).isoformat()),
                            "metrics": {
                                "likes": t.get("public_metrics", {}).get("like_count", 0),
                                "comments": t.get("public_metrics", {}).get("reply_count", 0),
                                "shares": t.get("public_metrics", {}).get("retweet_count", 0),
                            },
                        }
                        for t in tweets
                    ]
        except Exception as e:
            log.error("Twitter API error", error=str(e))

    # Demo fallback
    log.info("Generating demo Twitter posts for stream pipeline")
    results = []
    for item in random.sample(DEMO_TWEETS, k=min(4, len(DEMO_TWEETS))):
        post_id = f"tw_{random.randint(1000000, 9999999)}"
        results.append({
            "platform": "twitter",
            "platform_id": post_id,
            "type": "post",
            "text": item["text"],
            "url": f"https://x.com/{item['username']}/status/{post_id}",
            "author_username": item["username"],
            "author_display_name": item["display_name"],
            "timestamp": datetime.now(UTC).isoformat(),
            "metrics": {
                "likes": item["likes"] + random.randint(0, 50),
                "comments": random.randint(5, 40),
                "shares": item["shares"] + random.randint(0, 20),
                "views": random.randint(1000, 10000),
            },
        })
    return results
