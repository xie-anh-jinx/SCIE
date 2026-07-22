"""
Posts & Analytics API Router — Query social posts, filters, full-text search, and summary statistics.
"""
from typing import Annotated, Any
from fastapi import APIRouter, Depends, Query
from sqlalchemy import func, select, text as sa_text
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.middleware.auth import get_current_user
from app.models.models import Post, SocialAccount, User
from app.schemas.posts import PostResponse, PostStatsResponse

router = APIRouter(prefix="/posts", tags=["Posts & Content"])


@router.get("", response_model=dict[str, Any])
async def list_posts(
    platform: str | None = Query(None, description="Filter by platform (twitter, rss, etc)"),
    sentiment: str | None = Query(None, description="Filter by sentiment (positive, negative, neutral)"),
    topic: str | None = Query(None, description="Filter by topic"),
    keyword: str | None = Query(None, description="Filter by keyword"),
    search: str | None = Query(None, description="Full text search query"),
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> dict[str, Any]:
    """List social posts with filtering, full-text search, and pagination."""
    query = select(Post).where(Post.is_deleted == False)

    if platform:
        query = query.where(Post.platform == platform)
    if sentiment:
        query = query.where(Post.sentiment_label == sentiment)
    if topic:
        query = query.where(Post.topics.contains([topic]))
    if keyword:
        query = query.where(Post.keywords.contains([keyword]))
    if search:
        # PostgreSQL full-text search or ILIKE fallback
        query = query.where(Post.text.ilike(f"%{search}%"))

    # Count total
    count_query = select(func.count()).select_from(query.subquery())
    total_result = await db.execute(count_query)
    total = total_result.scalar_one()

    # Pagination & Ordering
    query = query.order_by(Post.collected_at.desc()).offset((page - 1) * limit).limit(limit)
    result = await db.execute(query)
    posts = result.scalars().all()

    return {
        "items": [PostResponse.model_validate(p) for p in posts],
        "total": total,
        "page": page,
        "limit": limit,
        "pages": (total + limit - 1) // limit if total > 0 else 0,
    }


@router.get("/stats", response_model=PostStatsResponse)
async def get_posts_stats(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> dict[str, Any]:
    """Get aggregated statistics across collected posts."""
    # Total count
    total_result = await db.execute(select(func.count(Post.id)).where(Post.is_deleted == False))
    total_posts = total_result.scalar_one() or 0

    # Platform breakdown
    platform_res = await db.execute(
        select(Post.platform, func.count(Post.id))
        .where(Post.is_deleted == False)
        .group_by(Post.platform)
    )
    platform_breakdown = {row[0]: row[1] for row in platform_res.all()}

    # Sentiment breakdown
    sentiment_res = await db.execute(
        select(Post.sentiment_label, func.count(Post.id))
        .where(Post.is_deleted == False)
        .group_by(Post.sentiment_label)
    )
    sentiment_breakdown = {row[0] or "unprocessed": row[1] for row in sentiment_res.all()}

    # Top topics
    topic_res = await db.execute(
        sa_text(
            "SELECT unnest(topics) as topic, count(*) as count "
            "FROM posts WHERE is_deleted = false AND topics IS NOT NULL "
            "GROUP BY topic ORDER BY count DESC LIMIT 10"
        )
    )
    top_topics = [{"topic": row[0], "count": row[1]} for row in topic_res.all()]

    # Top keywords
    kw_res = await db.execute(
        sa_text(
            "SELECT unnest(keywords) as keyword, count(*) as count "
            "FROM posts WHERE is_deleted = false AND keywords IS NOT NULL "
            "GROUP BY keyword ORDER BY count DESC LIMIT 10"
        )
    )
    top_keywords = [{"keyword": row[0], "count": row[1]} for row in kw_res.all()]

    return {
        "total_posts": total_posts,
        "platform_breakdown": platform_breakdown,
        "sentiment_breakdown": sentiment_breakdown,
        "top_topics": top_topics,
        "top_keywords": top_keywords,
    }


@router.get("/{post_id}", response_model=PostResponse)
async def get_post_detail(
    post_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> Post:
    """Get single post details by ID."""
    result = await db.execute(select(Post).where(Post.id == post_id))
    post = result.scalar_one_or_none()
    if not post:
        from fastapi import HTTPException
        raise HTTPException(status_code=404, detail="Post not found")
    return post
