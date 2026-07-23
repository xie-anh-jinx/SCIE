"""
Map API Router — Serves geocoded Indonesian events and spatial telemetry layers for the Situational Awareness Command Center.
"""
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
    limit: int = Query(250, ge=1, le=1000),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> dict[str, Any]:
    """
    Get geocoded events in Indonesia categorized by situational awareness layers.
    """
    query = select(Post).where(Post.is_deleted == False)

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
        # Fallback to default Jakarta/Indonesia coords if none present
        lat = p.latitude if p.latitude is not None else -6.2088
        lon = p.longitude if p.longitude is not None else 106.8456
        loc_name = p.location_name or "Indonesia"
        prov = p.province or "Nasional"
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
            "virality_score": p.virality_score or 0.0,
            "topics": p.topics or [],
            "url": p.url,
            "timestamp": p.timestamp.isoformat() if p.timestamp else (p.collected_at.isoformat() if p.collected_at else None),
        })

    return {
        "total_events": len(events),
        "region": "Indonesia",
        "events": events,
    }


@router.get("/summary", response_model=dict[str, Any])
async def get_map_summary(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> dict[str, Any]:
    """
    Get summary metrics for all 7 Indonesian situational layers and province threat counts.
    """
    # 1. Layer statistics
    layer_res = await db.execute(
        sa_text(
            "SELECT COALESCE(layer_category, 'hotspot') as layer, COUNT(*) as count "
            "FROM posts WHERE is_deleted = false GROUP BY layer_category"
        )
    )
    layer_counts = {row[0]: row[1] for row in layer_res.fetchall()}

    # 2. Province density statistics
    prov_res = await db.execute(
        sa_text(
            "SELECT COALESCE(province, 'Nasional') as prov, COUNT(*) as count "
            "FROM posts WHERE is_deleted = false GROUP BY province ORDER BY count DESC LIMIT 10"
        )
    )
    top_provinces = [{"province": row[0], "count": row[1]} for row in prov_res.fetchall()]

    return {
        "region": "Indonesia",
        "layers": {
            "konflik": layer_counts.get("konflik", 0),
            "hotspot": layer_counts.get("hotspot", 0),
            "pangkalan": layer_counts.get("pangkalan", 0),
            "infrastruktur": layer_counts.get("infrastruktur", 0),
            "ekonomi": layer_counts.get("ekonomi", 0),
            "perairan": layer_counts.get("perairan", 0),
            "bencana": layer_counts.get("bencana", 0),
        },
        "top_provinces": top_provinces,
    }
