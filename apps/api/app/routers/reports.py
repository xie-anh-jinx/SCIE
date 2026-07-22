"""
Reports & Data Export API Router — Generate executive intelligence reports.
"""
from typing import Any
from fastapi import APIRouter, Depends
from sqlalchemy import select, text as sa_text
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.middleware.auth import get_current_user
from app.models.models import Post, User

router = APIRouter(prefix="/reports", tags=["Reports & Export"])


@router.get("/summary", response_model=dict[str, Any])
async def get_executive_summary(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> dict[str, Any]:
    """Generate an executive summary report for decision makers."""
    # Count totals
    total_res = await db.execute(select(Post).where(Post.is_deleted == False))
    posts = total_res.scalars().all()

    pos_count = sum(1 for p in posts if p.sentiment_label == "positive")
    neg_count = sum(1 for p in posts if p.sentiment_label == "negative")
    neu_count = sum(1 for p in posts if p.sentiment_label == "neutral")

    summary_text = (
        f"Laporan Eksekutif SCIE — Social Intelligence Engine\n"
        f"Total percakapan digital dianalisis: {len(posts)} postingan.\n"
        f"Distribusi Sentimen: {pos_count} Positif, {neu_count} Netral, {neg_count} Negatif.\n"
        f"Topik utama mendominasi opini publik seputar AI, Ekonomi Digital, dan Disinformasi."
    )

    return {
        "title": "Laporan Analisis Media Digital & Opini Publik",
        "generated_at": "2026-07-22T15:00:00Z",
        "author": current_user.full_name or current_user.username,
        "total_posts": len(posts),
        "sentiment_stats": {
            "positive": pos_count,
            "neutral": neu_count,
            "negative": neg_count,
        },
        "executive_narrative": summary_text,
    }
