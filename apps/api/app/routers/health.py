"""
Health check endpoints — checks all service connections.
"""
import time

import structlog
from fastapi import APIRouter
from pydantic import BaseModel

from app.core.database import verify_connections
from app.core.config import get_settings

log = structlog.get_logger()
settings = get_settings()
router = APIRouter(tags=["Health"])


class ServiceHealth(BaseModel):
    status: str          # ok | degraded | down
    latency_ms: float | None = None
    message: str | None = None


class HealthResponse(BaseModel):
    status: str          # ok | degraded | down
    version: str
    environment: str
    services: dict[str, ServiceHealth]
    timestamp: float


@router.get("/health", response_model=HealthResponse)
async def health_check() -> dict:
    """Comprehensive health check for all connected services."""
    start = time.time()
    services = {}

    db_status = await verify_connections()

    services["postgresql"] = ServiceHealth(
        status="ok" if db_status.get("postgresql") else "down",
        message="TimescaleDB connected" if db_status.get("postgresql") else "Connection failed",
    )

    services["redis"] = ServiceHealth(
        status="ok" if db_status.get("redis") else "down",
        message="Redis Streams available" if db_status.get("redis") else "Connection failed",
    )

    services["neo4j"] = ServiceHealth(
        status="ok" if db_status.get("neo4j") else "down",
        message="Graph database connected" if db_status.get("neo4j") else "Connection failed",
    )

    # Check Ollama (Llama)
    try:
        import httpx
        async with httpx.AsyncClient(timeout=3.0) as client:
            t0 = time.time()
            r = await client.get(f"{settings.ollama_base_url}/api/tags")
            latency = (time.time() - t0) * 1000
            if r.status_code == 200:
                models = [m["name"] for m in r.json().get("models", [])]
                services["ollama"] = ServiceHealth(
                    status="ok",
                    latency_ms=round(latency, 2),
                    message=f"Models loaded: {', '.join(models) if models else 'none yet'}",
                )
            else:
                services["ollama"] = ServiceHealth(status="degraded", message="Ollama reachable but no models")
    except Exception as e:
        services["ollama"] = ServiceHealth(status="down", message=str(e))

    # Check Elasticsearch
    try:
        import httpx
        async with httpx.AsyncClient(timeout=3.0) as client:
            t0 = time.time()
            r = await client.get(f"{settings.elasticsearch_url}/_cluster/health")
            latency = (time.time() - t0) * 1000
            health_status = r.json().get("status", "unknown")
            services["elasticsearch"] = ServiceHealth(
                status="ok" if health_status in ("green", "yellow") else "down",
                latency_ms=round(latency, 2),
                message=f"Cluster status: {health_status}",
            )
    except Exception as e:
        services["elasticsearch"] = ServiceHealth(status="down", message=str(e))

    # Check Qdrant
    try:
        import httpx
        async with httpx.AsyncClient(timeout=3.0) as client:
            t0 = time.time()
            r = await client.get(f"{settings.qdrant_url}/healthz")
            latency = (time.time() - t0) * 1000
            services["qdrant"] = ServiceHealth(
                status="ok" if r.status_code == 200 else "down",
                latency_ms=round(latency, 2),
            )
    except Exception as e:
        services["qdrant"] = ServiceHealth(status="down", message=str(e))

    # Overall status
    statuses = [s.status for s in services.values()]
    if all(s == "ok" for s in statuses):
        overall = "ok"
    elif any(s == "down" for s in ["postgresql", "redis"] if services.get(s, ServiceHealth(status="down")).status == "down"):
        overall = "down"
    else:
        overall = "degraded"

    return {
        "status": overall,
        "version": "0.1.0",
        "environment": settings.app_env,
        "services": services,
        "timestamp": time.time(),
    }


@router.get("/health/live")
async def liveness() -> dict:
    """Simple liveness probe — just confirms the API process is running."""
    return {"status": "ok"}


@router.get("/health/ready")
async def readiness() -> dict:
    """Readiness probe — confirms critical services are available."""
    db_status = await verify_connections()
    if db_status.get("postgresql") and db_status.get("redis"):
        return {"status": "ready"}
    return {"status": "not_ready"}, 503
