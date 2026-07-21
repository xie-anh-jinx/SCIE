"""
Database connections: PostgreSQL (async SQLAlchemy) + Neo4j + Redis
"""
from typing import AsyncGenerator

import redis.asyncio as aioredis
import structlog
from neo4j import AsyncGraphDatabase, AsyncDriver
from sqlalchemy.ext.asyncio import (
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)
from sqlalchemy.orm import DeclarativeBase

from app.core.config import get_settings

log = structlog.get_logger()
settings = get_settings()

# ─── SQLAlchemy (PostgreSQL) ──────────────────────────────────────────────────

engine = create_async_engine(
    settings.database_url,
    echo=settings.app_debug,
    pool_size=10,
    max_overflow=20,
    pool_pre_ping=True,
)

AsyncSessionLocal = async_sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autoflush=False,
    autocommit=False,
)


class Base(DeclarativeBase):
    pass


async def get_db() -> AsyncGenerator[AsyncSession, None]:
    """Dependency: yields an async DB session."""
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()


# ─── Redis ────────────────────────────────────────────────────────────────────

_redis_client: aioredis.Redis | None = None


async def get_redis() -> aioredis.Redis:
    """Get the Redis client (singleton)."""
    global _redis_client
    if _redis_client is None:
        _redis_client = aioredis.from_url(
            settings.redis_url,
            encoding="utf-8",
            decode_responses=True,
        )
    return _redis_client


async def close_redis() -> None:
    global _redis_client
    if _redis_client:
        await _redis_client.aclose()
        _redis_client = None


# ─── Neo4j ───────────────────────────────────────────────────────────────────

_neo4j_driver: AsyncDriver | None = None


def get_neo4j_driver() -> AsyncDriver:
    """Get Neo4j async driver (singleton)."""
    global _neo4j_driver
    if _neo4j_driver is None:
        _neo4j_driver = AsyncGraphDatabase.driver(
            settings.neo4j_uri,
            auth=(settings.neo4j_user, settings.neo4j_password),
            max_connection_pool_size=50,
        )
    return _neo4j_driver


async def close_neo4j() -> None:
    global _neo4j_driver
    if _neo4j_driver:
        await _neo4j_driver.close()
        _neo4j_driver = None


async def verify_connections() -> dict[str, bool]:
    """Check all database connections on startup."""
    status: dict[str, bool] = {}

    # PostgreSQL
    try:
        async with engine.connect() as conn:
            await conn.execute(__import__("sqlalchemy").text("SELECT 1"))
        status["postgresql"] = True
        log.info("PostgreSQL connection OK")
    except Exception as e:
        status["postgresql"] = False
        log.error("PostgreSQL connection FAILED", error=str(e))

    # Redis
    try:
        r = await get_redis()
        await r.ping()
        status["redis"] = True
        log.info("Redis connection OK")
    except Exception as e:
        status["redis"] = False
        log.error("Redis connection FAILED", error=str(e))

    # Neo4j
    try:
        driver = get_neo4j_driver()
        await driver.verify_connectivity()
        status["neo4j"] = True
        log.info("Neo4j connection OK")
    except Exception as e:
        status["neo4j"] = False
        log.error("Neo4j connection FAILED", error=str(e))

    return status
