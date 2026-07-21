"""
Authentication middleware — validates JWT and API keys from requests.
"""
import hashlib
from typing import Annotated

import structlog
from fastapi import Depends, HTTPException, Security, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer, APIKeyHeader
from jose import JWTError
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.security import decode_token
from app.models.models import User, ApiKey

log = structlog.get_logger()

bearer_scheme = HTTPBearer(auto_error=False)
api_key_header = APIKeyHeader(name="X-API-Key", auto_error=False)


async def get_current_user(
    credentials: Annotated[HTTPAuthorizationCredentials | None, Security(bearer_scheme)],
    db: AsyncSession = Depends(get_db),
) -> User:
    """
    Validates Bearer JWT token and returns the current user.
    Raises 401 if token is invalid or expired.
    """
    if not credentials:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication required",
            headers={"WWW-Authenticate": "Bearer"},
        )

    try:
        payload = decode_token(credentials.credentials)
        user_id: str = payload.get("sub")
        token_type: str = payload.get("type", "")
        if not user_id or token_type != "access":
            raise ValueError("Invalid token payload")
    except (JWTError, ValueError) as e:
        log.warning("Token validation failed", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
            headers={"WWW-Authenticate": "Bearer"},
        )

    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()

    if not user or not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found or inactive",
        )

    return user


async def get_current_user_or_api_key(
    credentials: Annotated[HTTPAuthorizationCredentials | None, Security(bearer_scheme)],
    api_key: Annotated[str | None, Security(api_key_header)],
    db: AsyncSession = Depends(get_db),
) -> User:
    """
    Accepts either Bearer JWT OR X-API-Key header.
    API key grants only 'read' access by default.
    """
    # Try API key first
    if api_key:
        key_hash = hashlib.sha256(api_key.encode()).hexdigest()
        result = await db.execute(
            select(ApiKey).where(
                ApiKey.key_hash == key_hash,
                ApiKey.is_active == True,  # noqa
            )
        )
        key_obj = result.scalar_one_or_none()
        if key_obj:
            # Update last_used_at
            from datetime import UTC, datetime
            key_obj.last_used_at = datetime.now(UTC)
            await db.commit()
            # Load user
            user_result = await db.execute(select(User).where(User.id == key_obj.user_id))
            user = user_result.scalar_one_or_none()
            if user and user.is_active:
                return user

    # Fall back to Bearer JWT
    if credentials:
        return await get_current_user(credentials, db)

    raise HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Authentication required (Bearer token or X-API-Key)",
    )


# ─── Role Guards ─────────────────────────────────────────────────────────────

class RequireRole:
    """Dependency factory for role-based access control."""
    def __init__(self, *allowed_roles: str):
        self.allowed_roles = set(allowed_roles)

    async def __call__(
        self,
        current_user: User = Depends(get_current_user),
    ) -> User:
        if current_user.role not in self.allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Role '{current_user.role}' is not allowed. Required: {self.allowed_roles}",
            )
        return current_user


require_admin = RequireRole("admin")
require_analyst = RequireRole("admin", "analyst")
require_any_role = RequireRole("admin", "analyst", "viewer")
