"""
Authentication Router — Register, Login, Refresh, Logout, API Keys.
"""
import hashlib
from datetime import UTC, datetime, timedelta
from typing import Annotated

import structlog
from fastapi import APIRouter, Depends, HTTPException, Request, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db, get_redis
from app.core.security import (
    create_access_token,
    create_refresh_token,
    decode_token,
    generate_api_key,
    hash_password,
    verify_password,
)
from app.core.config import get_settings
from app.middleware.auth import get_current_user, require_analyst
from app.models.models import ApiKey, RefreshToken, User
from app.schemas.auth import (
    AccessTokenResponse,
    ApiKeyCreate,
    ApiKeyCreated,
    ApiKeyResponse,
    LoginRequest,
    RefreshRequest,
    TokenResponse,
    UserCreate,
    UserMe,
    UserResponse,
)

log = structlog.get_logger()
settings = get_settings()
router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def register(
    payload: UserCreate,
    db: AsyncSession = Depends(get_db),
) -> User:
    """Register a new user account."""
    # Check if email already exists
    existing = await db.execute(select(User).where(User.email == payload.email))
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="Email already registered")

    # Check if username already exists
    existing_username = await db.execute(
        select(User).where(User.username == payload.username)
    )
    if existing_username.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="Username already taken")

    user = User(
        email=payload.email,
        username=payload.username,
        hashed_password=hash_password(payload.password),
        full_name=payload.full_name,
        role="analyst",
        is_active=True,
        is_verified=False,
    )
    db.add(user)
    await db.commit()
    await db.refresh(user)

    log.info("User registered", user_id=user.id, email=user.email)
    return user


@router.post("/login", response_model=TokenResponse)
async def login(
    payload: LoginRequest,
    request: Request,
    db: AsyncSession = Depends(get_db),
) -> dict:
    """Login with email and password. Returns JWT access + refresh tokens."""
    result = await db.execute(select(User).where(User.email == payload.email))
    user = result.scalar_one_or_none()

    if not user or not verify_password(payload.password, user.hashed_password):
        log.warning("Failed login attempt", email=payload.email)
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
        )

    if not user.is_active:
        raise HTTPException(status_code=403, detail="Account is disabled")

    # Create tokens
    token_data = {"sub": user.id, "email": user.email, "role": user.role}
    access_token = create_access_token(token_data)
    refresh_token = create_refresh_token(token_data)

    # Store refresh token hash
    token_hash = hashlib.sha256(refresh_token.encode()).hexdigest()
    expires_at = datetime.now(UTC).replace(tzinfo=None) + timedelta(days=settings.jwt_refresh_token_expire_days)

    db.add(RefreshToken(
        user_id=user.id,
        token_hash=token_hash,
        expires_at=expires_at,
        user_agent=request.headers.get("user-agent"),
        ip_address=request.client.host if request.client else None,
    ))

    # Update last login
    user.last_login = datetime.now(UTC).replace(tzinfo=None)
    await db.commit()


    log.info("User logged in", user_id=user.id)
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer",
        "expires_in": settings.jwt_access_token_expire_minutes * 60,
    }


@router.post("/refresh", response_model=AccessTokenResponse)
async def refresh_token(
    payload: RefreshRequest,
    db: AsyncSession = Depends(get_db),
) -> dict:
    """Exchange a valid refresh token for a new access token."""
    try:
        token_data = decode_token(payload.refresh_token)
        if token_data.get("type") != "refresh":
            raise ValueError("Not a refresh token")
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid refresh token")

    token_hash = hashlib.sha256(payload.refresh_token.encode()).hexdigest()
    result = await db.execute(
        select(RefreshToken).where(
            RefreshToken.token_hash == token_hash,
            RefreshToken.is_revoked == False,  # noqa
        )
    )
    stored_token = result.scalar_one_or_none()

    if not stored_token or stored_token.expires_at < datetime.now(UTC):
        raise HTTPException(status_code=401, detail="Refresh token expired or revoked")

    # Issue new access token
    user_result = await db.execute(select(User).where(User.id == token_data["sub"]))
    user = user_result.scalar_one_or_none()
    if not user or not user.is_active:
        raise HTTPException(status_code=401, detail="User not found")

    new_access_token = create_access_token(
        {"sub": user.id, "email": user.email, "role": user.role}
    )
    return {
        "access_token": new_access_token,
        "token_type": "bearer",
        "expires_in": settings.jwt_access_token_expire_minutes * 60,
    }


@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
async def logout(
    payload: RefreshRequest,
    db: AsyncSession = Depends(get_db),
) -> None:
    """Revoke the provided refresh token."""
    token_hash = hashlib.sha256(payload.refresh_token.encode()).hexdigest()
    result = await db.execute(
        select(RefreshToken).where(RefreshToken.token_hash == token_hash)
    )
    stored_token = result.scalar_one_or_none()
    if stored_token:
        stored_token.is_revoked = True
        await db.commit()


@router.get("/me", response_model=UserMe)
async def get_me(
    current_user: User = Depends(get_current_user),
) -> User:
    """Get the currently authenticated user's profile."""
    return current_user


# ─── API Keys ────────────────────────────────────────────────────────────────

@router.post("/api-keys", response_model=ApiKeyCreated, status_code=status.HTTP_201_CREATED)
async def create_api_key(
    payload: ApiKeyCreate,
    current_user: User = Depends(require_analyst),
    db: AsyncSession = Depends(get_db),
) -> dict:
    """Generate a new API key. The raw key is shown only once."""
    raw_key, key_hash, key_prefix = generate_api_key()

    expires_at = None
    if payload.expires_days:
        expires_at = datetime.now(UTC) + timedelta(days=payload.expires_days)

    key_obj = ApiKey(
        user_id=current_user.id,
        organization_id=current_user.organization_id,
        name=payload.name,
        key_hash=key_hash,
        key_prefix=key_prefix,
        permissions=payload.permissions,
        expires_at=expires_at,
    )
    db.add(key_obj)
    await db.commit()
    await db.refresh(key_obj)

    log.info("API key created", key_id=key_obj.id, user_id=current_user.id)

    return {
        "id": key_obj.id,
        "name": key_obj.name,
        "key_prefix": key_obj.key_prefix,
        "raw_key": raw_key,  # ← shown once only
        "permissions": key_obj.permissions,
        "is_active": key_obj.is_active,
        "last_used_at": key_obj.last_used_at,
        "expires_at": key_obj.expires_at,
        "created_at": key_obj.created_at,
    }


@router.get("/api-keys", response_model=list[ApiKeyResponse])
async def list_api_keys(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> list[ApiKey]:
    """List all API keys for the current user."""
    result = await db.execute(
        select(ApiKey).where(
            ApiKey.user_id == current_user.id,
            ApiKey.is_active == True,  # noqa
        )
    )
    return list(result.scalars().all())


@router.delete("/api-keys/{key_id}", status_code=status.HTTP_204_NO_CONTENT)
async def revoke_api_key(
    key_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> None:
    """Revoke (deactivate) an API key."""
    result = await db.execute(
        select(ApiKey).where(ApiKey.id == key_id, ApiKey.user_id == current_user.id)
    )
    key_obj = result.scalar_one_or_none()
    if not key_obj:
        raise HTTPException(status_code=404, detail="API key not found")
    key_obj.is_active = False
    await db.commit()
