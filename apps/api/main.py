"""
SCIE API — FastAPI Application Entry Point
"""
import structlog
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware

from app.core.config import get_settings
from app.core.database import close_redis, close_neo4j, verify_connections
from app.routers import alerts, analytics, auth, chat, graph, health, map, posts, reports, sources

log = structlog.get_logger()
settings = get_settings()



@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup and shutdown events."""
    log.info(
        "Starting SCIE API",
        env=settings.app_env,
        version="0.1.0",
    )

    # Check all connections on startup
    status = await verify_connections()
    for service, ok in status.items():
        level = log.info if ok else log.warning
        level(f"Service {'connected' if ok else 'UNAVAILABLE'}", service=service)

    yield  # ← application runs here

    # Cleanup
    log.info("Shutting down SCIE API...")
    await close_redis()
    await close_neo4j()


app = FastAPI(
    title="SCIE API",
    description="Social Intelligence Engine — REST API",
    version="0.1.0",
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json",
    lifespan=lifespan,
)

# ─── Middleware ───────────────────────────────────────────────────────────────

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.add_middleware(GZipMiddleware, minimum_size=1000)

# ─── Routers ──────────────────────────────────────────────────────────────────

app.include_router(health.router)
app.include_router(auth.router, prefix="/api/v1")
app.include_router(sources.router, prefix="/api/v1")
app.include_router(posts.router, prefix="/api/v1")
app.include_router(graph.router, prefix="/api/v1")
app.include_router(analytics.router, prefix="/api/v1")
app.include_router(chat.router, prefix="/api/v1")
app.include_router(alerts.router, prefix="/api/v1")
app.include_router(reports.router, prefix="/api/v1")
app.include_router(map.router, prefix="/api/v1")
app.include_router(search.router, prefix="/api/v1")







@app.get("/", include_in_schema=False)
async def root() -> dict:
    return {
        "name": "SCIE API",
        "version": "0.1.0",
        "docs": "/docs",
        "health": "/health",
    }
