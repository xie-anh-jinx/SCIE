"""
Analytics API Router — Trending topics, Virality leaderboard, and Influence metrics.
"""
from typing import Any
from fastapi import APIRouter, Depends
from sqlalchemy import func, select, text as sa_text
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.middleware.auth import get_current_user
from app.models.models import Post, SocialAccount, User

router = APIRouter(prefix="/analytics", tags=["Analytics & Trends"])


@router.get("/trends", response_model=dict[str, Any])
async def get_trending_topics(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> dict[str, Any]:
    """Get real-time trending topics with momentum score and post volume."""
    res = await db.execute(
        sa_text(
            "SELECT unnest(topics) as topic, count(*) as post_count, "
            "avg(virality_score) as avg_virality, avg(sentiment_score) as avg_sentiment "
            "FROM posts WHERE is_deleted = false AND topics IS NOT NULL "
            "GROUP BY topic ORDER BY post_count DESC LIMIT 10"
        )
    )

    trends = []
    for row in res.all():
        topic_name = row[0]
        count = row[1]
        virality = round(row[2] or 0.0, 2)
        sentiment = round(row[3] or 0.0, 2)
        trends.append({
            "topic": topic_name,
            "volume": count,
            "trend_score": round(count * (1.0 + virality), 1),
            "avg_sentiment": sentiment,
            "status": "Trending" if count > 2 else "Emerging",
        })

    return {"trends": trends, "total_trending": len(trends)}


@router.get("/influencers", response_model=dict[str, Any])
async def get_top_influencers(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> dict[str, Any]:
    """Get top influencer accounts ranked by reach and influence score."""
    res = await db.execute(
        select(SocialAccount)
        .order_by(SocialAccount.follower_count.desc())
        .limit(10)
    )
    accounts = res.scalars().all()

    influencers = [
        {
            "id": a.id,
            "platform": a.platform,
            "username": a.username,
            "display_name": a.display_name,
            "follower_count": a.follower_count,
            "influence_score": a.influence_score or round(a.follower_count * 0.01 + 5.0, 1),
            "community_id": a.community_id or "Komunitas A",
        }
        for a in accounts
    ]

    return {"influencers": influencers}
