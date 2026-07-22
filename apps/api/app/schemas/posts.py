"""
Pydantic schemas for Posts and Content querying.
"""
from datetime import datetime
from typing import Any
from pydantic import BaseModel


class SocialAccountResponse(BaseModel):
    id: str
    platform: str
    platform_id: str
    username: str | None
    display_name: str | None
    bio: str | None
    follower_count: int
    following_count: int
    is_verified: bool
    bot_score: float
    influence_score: float
    community_id: str | None
    collected_at: datetime

    model_config = {"from_attributes": True}


class PostResponse(BaseModel):
    id: str
    platform: str
    platform_id: str
    type: str
    text: str | None
    text_cleaned: str | None
    language: str | None
    url: str | None
    author_id: str | None
    parent_post_id: str | None
    original_post_id: str | None
    timestamp: datetime | None
    likes: int
    comments: int
    shares: int
    views: int
    sentiment_label: str | None
    sentiment_score: float | None
    emotions: dict[str, Any] | None
    topics: list[str]
    keywords: list[str]
    summary: str | None
    virality_score: float
    is_original: bool
    collected_at: datetime
    processed_at: datetime | None

    model_config = {"from_attributes": True}


class PostListFilter(BaseModel):
    platform: str | None = None
    sentiment_label: str | None = None
    topic: str | None = None
    keyword: str | None = None
    search: str | None = None
    start_date: datetime | None = None
    end_date: datetime | None = None
    page: int = 1
    limit: int = 50


class PostStatsResponse(BaseModel):
    total_posts: int
    platform_breakdown: dict[str, int]
    sentiment_breakdown: dict[str, int]
    top_topics: list[dict[str, Any]]
    top_keywords: list[dict[str, Any]]
