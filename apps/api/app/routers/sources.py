"""
Data Sources API Router — Manage data connectors and trigger manual collection.
"""
import json
from datetime import UTC, datetime
from typing import Annotated

import structlog
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db, get_redis
from app.core.config import get_settings
from app.middleware.auth import require_analyst, get_current_user
from app.models.models import DataSource, User
from app.schemas.sources import (
    DataSourceCreate,
    DataSourceResponse,
    DataSourceUpdate,
)

log = structlog.get_logger()
settings = get_settings()
router = APIRouter(prefix="/sources", tags=["Data Sources"])


@router.post("", response_model=DataSourceResponse, status_code=status.HTTP_201_CREATED)
async def create_data_source(
    payload: DataSourceCreate,
    current_user: User = Depends(require_analyst),
    db: AsyncSession = Depends(get_db),
) -> DataSource:
    """Create a new Data Source connector."""
    source = DataSource(
        organization_id=current_user.organization_id,
        name=payload.name,
        platform=payload.platform,
        config=payload.config,
        keywords=payload.keywords,
        is_active=payload.is_active,
        status="idle",
    )
    db.add(source)
    await db.commit()
    await db.refresh(source)
    log.info("Data source created", source_id=source.id, name=source.name)
    return source


@router.get("", response_model=list[DataSourceResponse])
async def list_data_sources(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> list[DataSource]:
    """List all Data Sources for current organization."""
    query = select(DataSource)
    if current_user.organization_id:
        query = query.where(DataSource.organization_id == current_user.organization_id)
    result = await db.execute(query)
    return list(result.scalars().all())


@router.get("/{source_id}", response_model=DataSourceResponse)
async def get_data_source(
    source_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> DataSource:
    """Get single Data Source by ID."""
    result = await db.execute(select(DataSource).where(DataSource.id == source_id))
    source = result.scalar_one_or_none()
    if not source:
        raise HTTPException(status_code=404, detail="Data source not found")
    return source


@router.patch("/{source_id}", response_model=DataSourceResponse)
async def update_data_source(
    source_id: str,
    payload: DataSourceUpdate,
    current_user: User = Depends(require_analyst),
    db: AsyncSession = Depends(get_db),
) -> DataSource:
    """Update Data Source configuration."""
    result = await db.execute(select(DataSource).where(DataSource.id == source_id))
    source = result.scalar_one_or_none()
    if not source:
        raise HTTPException(status_code=404, detail="Data source not found")

    update_data = payload.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(source, field, value)

    await db.commit()
    await db.refresh(source)
    return source


@router.delete("/{source_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_data_source(
    source_id: str,
    current_user: User = Depends(require_analyst),
    db: AsyncSession = Depends(get_db),
) -> None:
    """Delete a Data Source."""
    result = await db.execute(select(DataSource).where(DataSource.id == source_id))
    source = result.scalar_one_or_none()
    if not source:
        raise HTTPException(status_code=404, detail="Data source not found")

    await db.delete(source)
    await db.commit()


@router.post("/{source_id}/trigger", status_code=status.HTTP_202_ACCEPTED)
async def trigger_collection(
    source_id: str,
    current_user: User = Depends(require_analyst),
    db: AsyncSession = Depends(get_db),
) -> dict:
    """Trigger manual data collection job for a specific Data Source."""
    result = await db.execute(select(DataSource).where(DataSource.id == source_id))
    source = result.scalar_one_or_none()
    if not source:
        raise HTTPException(status_code=404, detail="Data source not found")

    if not source.is_active:
        raise HTTPException(status_code=400, detail="Data source is inactive")

    # Publish collection event to Redis stream or pub/sub
    r = await get_redis()
    event_data = {
        "event": "trigger_collection",
        "source_id": source.id,
        "platform": source.platform,
        "name": source.name,
        "config": json.dumps(source.config),
        "keywords": json.dumps(source.keywords),
        "triggered_at": datetime.now(UTC).isoformat(),
    }
    await r.xadd(settings.redis_stream_raw_posts, {"payload": json.dumps(event_data)})

    source.status = "running"
    source.last_run_at = datetime.now(UTC)
    await db.commit()

    log.info("Collection triggered", source_id=source.id, platform=source.platform)
    return {"message": "Data collection job queued", "source_id": source.id}
