"""
Pydantic schemas for Auth endpoints.
"""
from datetime import datetime
from typing import Literal

from pydantic import BaseModel, EmailStr, Field, field_validator


# ─── User Schemas ─────────────────────────────────────────────────────────────

class UserBase(BaseModel):
    email: EmailStr
    username: str = Field(..., min_length=3, max_length=50, pattern=r"^[a-zA-Z0-9_-]+$")
    full_name: str | None = None


class UserCreate(UserBase):
    password: str = Field(..., min_length=8, max_length=100)

    @field_validator("password")
    @classmethod
    def password_strength(cls, v: str) -> str:
        if len(v) < 8:
            raise ValueError("Password must be at least 8 characters")
        return v


class UserResponse(UserBase):
    id: str
    role: str
    is_active: bool
    is_verified: bool
    organization_id: str | None
    created_at: datetime

    model_config = {"from_attributes": True}


class UserMe(UserResponse):
    last_login: datetime | None


# ─── Auth Schemas ─────────────────────────────────────────────────────────────

class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int  # seconds


class RefreshRequest(BaseModel):
    refresh_token: str


class AccessTokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    expires_in: int


# ─── API Key Schemas ──────────────────────────────────────────────────────────

class ApiKeyCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    permissions: list[Literal["read", "write", "admin"]] = ["read"]
    expires_days: int | None = Field(None, ge=1, le=3650)


class ApiKeyResponse(BaseModel):
    id: str
    name: str
    key_prefix: str
    permissions: list[str]
    is_active: bool
    last_used_at: datetime | None
    expires_at: datetime | None
    created_at: datetime

    model_config = {"from_attributes": True}


class ApiKeyCreated(ApiKeyResponse):
    """Returned only once when key is first created. Includes the raw key."""
    raw_key: str  # shown once, never stored
