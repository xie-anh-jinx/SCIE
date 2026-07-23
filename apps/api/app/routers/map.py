"""
Map API Router — Serves geocoded Indonesian events and spatial telemetry layers for the Situational Awareness Command Center.
Restricts results by default to the past 7 days (1 week).
"""
from datetime import datetime, timedelta, UTC
from typing import Any, Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy import select, text as sa_text
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.middleware.auth import get_current_user
from app.models.models import Post, User

router = APIRouter(prefix="/map", tags=["Geospatial Intelligence Map"])


@router.get("/events", response_model=dict[str, Any])
async def get_map_events(
    layers: Optional[str] = Query(None, description="Comma separated layer names e.g. 'konflik,hotspot,bencana'"),
    province: Optional[str] = Query(None, description="Filter by Indonesian province"),
    days: int = Query(7, ge=1, le=30, description="Filter news & social posts within last N days (default 7 days / 1 week)"),
    limit: int = Query(250, ge=1, le=1000),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> dict[str, Any]:
    """
    Get geocoded events in Indonesia categorized by situational awareness layers within the last 7 days.
    """
    cutoff_date = datetime.now(UTC) - timedelta(days=days)
    query = select(Post).where(Post.is_deleted == False).where(Post.collected_at >= cutoff_date)

    if layers:
        layer_list = [l.strip().lower() for l in layers.split(",") if l.strip()]
        if layer_list:
            query = query.where(Post.layer_category.in_(layer_list))

    if province:
        query = query.where(Post.province.ilike(f"%{province}%"))

    query = query.order_by(Post.collected_at.desc()).limit(limit)

    res = await db.execute(query)
    posts = res.scalars().all()

    events = []
    for p in posts:
        lat = p.latitude if p.latitude is not None else -5.1477
        lon = p.longitude if p.longitude is not None else 119.4327
        loc_name = p.location_name or "Makassar"
        prov = p.province or "Sulawesi Selatan"
        layer = p.layer_category or "hotspot"

        events.append({
            "id": p.id,
            "title": (p.text or "")[:100] + ("..." if len(p.text or "") > 100 else ""),
            "full_text": p.text,
            "platform": p.platform,
            "latitude": lat,
            "longitude": lon,
            "location_name": loc_name,
            "province": prov,
            "layer_category": layer,
            "sentiment_label": p.sentiment_label or "neutral",
            "sentiment_score": p.sentiment_score or 0.0,
            "virality_score": p.virality_score or 5.0,
            "collected_at": p.collected_at.isoformat() if p.collected_at else datetime.now(UTC).isoformat(),
        })

    return {
        "time_range": f"{days} days",
        "total_events": len(events),
        "events": events,
    }


@router.get("/summary", response_model=dict[str, Any])
async def get_map_summary(
    province: Optional[str] = Query(None, description="Filter by Indonesian province"),
    days: int = Query(7, ge=1, le=30, description="Filter summary within last N days (default 7 days)"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> dict[str, Any]:
    """
    Get summary stats of active layers and sentiment breakdown for the past 7 days.
    """
    cutoff_date = datetime.now(UTC) - timedelta(days=days)
    query = select(Post).where(Post.is_deleted == False).where(Post.collected_at >= cutoff_date)
    if province:
        query = query.where(Post.province.ilike(f"%{province}%"))

    res = await db.execute(query)
    posts = res.scalars().all()

    layer_counts: dict[str, int] = {
        "konflik": 0,
        "hotspot": 0,
        "pangkalan": 0,
        "infrastruktur": 0,
        "ekonomi": 0,
        "perairan": 0,
        "bencana": 0,
    }

    sentiment_counts = {"positive": 0, "neutral": 0, "negative": 0}

    for p in posts:
        cat = p.layer_category or "hotspot"
        if cat in layer_counts:
            layer_counts[cat] += 1
        else:
            layer_counts["hotspot"] += 1

        sent = p.sentiment_label or "neutral"
        if sent in sentiment_counts:
            sentiment_counts[sent] += 1
        else:
            sentiment_counts["neutral"] += 1

    return {
        "time_range": f"1 Minggu Terakhir ({days} Hari)",
        "province_filter": province or "Semua Wilayah",
        "total_active_events": len(posts),
        "layers": layer_counts,
        "sentiment": sentiment_counts,
    }
