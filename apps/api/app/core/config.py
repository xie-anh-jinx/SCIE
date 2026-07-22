"""
SCIE API — Application Configuration
All settings loaded from environment variables or .env file.
"""
from functools import lru_cache
from typing import Literal
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )

    # ── Application ────────────────────────────────────────────────────────────
    app_name: str = "SCIE"
    app_env: Literal["development", "staging", "production"] = "development"
    app_debug: bool = False
    app_secret_key: str = "change-me-in-production"
    app_frontend_url: str = "http://localhost:3000"
    app_api_url: str = "http://localhost:8000"

    # ── JWT ───────────────────────────────────────────────────────────────────
    jwt_secret_key: str = "change-me-jwt-secret"
    jwt_algorithm: str = "HS256"
    jwt_access_token_expire_minutes: int = 60
    jwt_refresh_token_expire_days: int = 30

    # ── Database ──────────────────────────────────────────────────────────────
    database_url: str = "postgresql+asyncpg://scie:scie_secret_password@localhost:5432/scie"

    # ── Redis ─────────────────────────────────────────────────────────────────
    redis_url: str = "redis://localhost:6379/0"
    redis_stream_raw_posts: str = "stream:raw_posts"
    redis_stream_enriched_posts: str = "stream:enriched_posts"
    redis_stream_graph_events: str = "stream:graph_events"
    redis_stream_max_len: int = 100000

    # ── Neo4j ─────────────────────────────────────────────────────────────────
    neo4j_uri: str = "bolt://localhost:7687"
    neo4j_user: str = "neo4j"
    neo4j_password: str = "scie_neo4j_password"
    neo4j_database: str = "scie"

    # ── MinIO ─────────────────────────────────────────────────────────────────
    minio_endpoint: str = "localhost:9000"
    minio_access_key: str = "scie_minio_access"
    minio_secret_key: str = "scie_minio_secret_key"
    minio_bucket_raw: str = "scie-raw-data"
    minio_bucket_reports: str = "scie-reports"
    minio_bucket_models: str = "scie-models"
    minio_secure: bool = False

    # ── Elasticsearch ─────────────────────────────────────────────────────────
    elasticsearch_url: str = "http://localhost:9200"
    elasticsearch_index_posts: str = "scie_posts"

    # ── Qdrant ────────────────────────────────────────────────────────────────
    qdrant_url: str = "http://localhost:6333"
    qdrant_collection_posts: str = "scie_posts_embeddings"

    # ── Ollama / Llama ────────────────────────────────────────────────────────
    ollama_base_url: str = "http://localhost:11434"
    ollama_model: str = "llama3.1:8b"
    ollama_embedding_model: str = "nomic-embed-text"

    # ── CORS ──────────────────────────────────────────────────────────────────
    cors_origins: str = "http://localhost:3000,http://127.0.0.1:3000,http://0.0.0.0:3000,*"

    @property
    def cors_origins_list(self) -> list[str]:
        return [origin.strip() for origin in self.cors_origins.split(",")]


    @property
    def is_production(self) -> bool:
        return self.app_env == "production"


@lru_cache()
def get_settings() -> Settings:
    return Settings()
