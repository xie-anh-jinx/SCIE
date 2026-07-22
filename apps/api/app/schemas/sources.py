"""
Pydantic schemas for Data Sources management.
"""
from datetime import datetime
from typing import Any
from pydantic import BaseModel, Field


class DataSourceBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=255)
    platform: str = Field(..., description="rss | twitter | news | instagram | reddit")
    config: dict[str, Any] = Field(default_factory=dict, description="Platform credentials / RSS URL / rules")
    keywords: list[str] = Field(default_factory=list, description="Target search keywords/hashtags")
    is_active: bool = True


class DataSourceCreate(DataSourceBase):
    pass


class DataSourceUpdate(BaseModel):
    name: str | None = None
    config: dict[str, Any] | None = None
    keywords: list[str] | None = None
    is_active: bool | None = None


class DataSourceResponse(DataSourceBase):
    id: str
    organization_id: str | None
    last_run_at: datetime | None
    posts_collected: int
    status: str
    error_message: str | None
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}
