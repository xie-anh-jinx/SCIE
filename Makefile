# =============================================================================
# SCIE — Social Intelligence Engine
# Developer Makefile
# Usage: make <target>
# =============================================================================

.PHONY: help dev up down logs ps install install-api install-frontend \
        migrate migrate-create test lint clean pull-models

# Colors
CYAN  := \033[0;36m
GREEN := \033[0;32m
RESET := \033[0m

## help: Show this help message
help:
	@echo ""
	@echo "$(CYAN)SCIE — Social Intelligence Engine$(RESET)"
	@echo ""
	@echo "$(GREEN)Usage:$(RESET) make <target>"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf ""} /^[a-zA-Z_-]+:.*?##/ { printf "  $(CYAN)%-20s$(RESET) %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
	@echo ""

# ─── Environment ─────────────────────────────────────────────────────────────

## setup: First-time setup (copy .env, install deps, start services)
setup: .env install
	@echo "$(GREEN)✓ Setup complete. Run 'make dev' to start.$(RESET)"

.env:
	@echo "$(CYAN)Creating .env from .env.example...$(RESET)"
	@cp .env.example .env
	@echo "$(GREEN)✓ .env created. Edit it with your credentials.$(RESET)"

# ─── Services ─────────────────────────────────────────────────────────────────

## up: Start all infrastructure services (Docker)
up:
	@echo "$(CYAN)Starting SCIE infrastructure...$(RESET)"
	docker compose up -d
	@echo "$(GREEN)✓ Services started. Run 'make logs' to view output.$(RESET)"
	@echo ""
	@echo "  PostgreSQL:    localhost:5432"
	@echo "  Neo4j Browser: http://localhost:7474"
	@echo "  Redis:         localhost:6379"
	@echo "  MinIO Console: http://localhost:9001"
	@echo "  Elasticsearch: http://localhost:9200"
	@echo "  Qdrant:        http://localhost:6333"
	@echo "  Ollama:        http://localhost:11434"
	@echo ""

## down: Stop all services
down:
	docker compose down

## down-v: Stop all services and remove volumes (DESTROYS DATA)
down-v:
	@echo "$(CYAN)WARNING: This will destroy all data!$(RESET)"
	docker compose down -v

## restart: Restart a specific service (usage: make restart SERVICE=postgres)
restart:
	docker compose restart $(SERVICE)

## logs: Follow logs from all services
logs:
	docker compose logs -f

## logs-api: Follow API logs
logs-api:
	docker compose logs -f postgres redis neo4j

## ps: Show running services status
ps:
	docker compose ps

## pull-models: Pull Llama models into Ollama (run after 'make up')
pull-models:
	@echo "$(CYAN)Pulling Llama3.1:8b model (this will take a while)...$(RESET)"
	docker compose exec ollama ollama pull llama3.1:8b
	@echo "$(CYAN)Pulling nomic-embed-text for embeddings...$(RESET)"
	docker compose exec ollama ollama pull nomic-embed-text
	@echo "$(GREEN)✓ Models ready.$(RESET)"

SHELL := /bin/bash

# ─── Development ──────────────────────────────────────────────────────────────

## dev: Start all development servers (API + Frontend)
dev:
	@echo "$(CYAN)Starting SCIE development servers...$(RESET)"
	@make -j2 dev-api dev-frontend

## dev-api: Start FastAPI development server
dev-api:
	@cd apps/api && /home/kotaromiyabi/.local/bin/poetry run uvicorn main:app --host 0.0.0.0 --port 8000 --reload --reload-dir app

## dev-frontend: Start Next.js development server
dev-frontend:
	@cd apps/frontend && npm run dev

## workers: Start all background workers (Ingestion + NLP Worker + Graph Service)
workers:
	@echo "$(CYAN)Starting SCIE background processing workers...$(RESET)"
	@make -j3 worker-ingestion worker-nlp worker-graph

## worker-ingestion: Start Data Ingestion Runner
worker-ingestion:
	@PYTHONPATH=/home/kotaromiyabi/SCIE/apps/ingestion /home/kotaromiyabi/.local/bin/poetry --directory /home/kotaromiyabi/SCIE/apps/api run python /home/kotaromiyabi/SCIE/apps/ingestion/main.py

## worker-nlp: Start NLP Worker Consumer
worker-nlp:
	@PYTHONPATH=/home/kotaromiyabi/SCIE/apps/nlp-worker /home/kotaromiyabi/.local/bin/poetry --directory /home/kotaromiyabi/SCIE/apps/api run python /home/kotaromiyabi/SCIE/apps/nlp-worker/worker.py

## worker-graph: Start Knowledge Graph Service Consumer
worker-graph:
	@PYTHONPATH=/home/kotaromiyabi/SCIE/apps/graph-service /home/kotaromiyabi/.local/bin/poetry --directory /home/kotaromiyabi/SCIE/apps/api run python /home/kotaromiyabi/SCIE/apps/graph-service/worker.py

## upload-hf: Upload local data/dataset to Hugging Face Bucket
upload-hf:
	@PYTHONPATH=/home/kotaromiyabi/SCIE /home/kotaromiyabi/.local/bin/poetry --directory /home/kotaromiyabi/SCIE/apps/api run python /home/kotaromiyabi/SCIE/upload_to_hf.py





# ─── Installation ─────────────────────────────────────────────────────────────

## install: Install all dependencies
install: install-api install-frontend

## install-api: Install Python API dependencies
install-api:
	@echo "$(CYAN)Installing API dependencies...$(RESET)"
	@cd apps/api && poetry install
	@echo "$(GREEN)✓ API dependencies installed.$(RESET)"

## install-nlp: Install NLP Worker dependencies
install-nlp:
	@echo "$(CYAN)Installing NLP Worker dependencies...$(RESET)"
	@cd apps/nlp-worker && poetry install
	@echo "$(GREEN)✓ NLP Worker dependencies installed.$(RESET)"

## install-frontend: Install frontend dependencies
install-frontend:
	@echo "$(CYAN)Installing frontend dependencies...$(RESET)"
	@cd apps/frontend && pnpm install
	@echo "$(GREEN)✓ Frontend dependencies installed.$(RESET)"

# ─── Database ─────────────────────────────────────────────────────────────────

## migrate: Run database migrations
migrate:
	@cd apps/api && alembic upgrade head

## migrate-create: Create a new migration (usage: make migrate-create MSG="add users table")
migrate-create:
	@cd apps/api && alembic revision --autogenerate -m "$(MSG)"

## db-reset: Reset database (WARNING: destroys data)
db-reset:
	docker compose exec postgres psql -U scie -d scie -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
	@make migrate

# ─── Testing ──────────────────────────────────────────────────────────────────

## test: Run all tests
test:
	@cd apps/api && poetry run pytest -v --cov=app tests/

## test-api: Run API tests only
test-api:
	@cd apps/api && poetry run pytest -v tests/

# ─── Code Quality ─────────────────────────────────────────────────────────────

## lint: Run all linters
lint:
	@cd apps/api && poetry run ruff check app/
	@cd apps/api && poetry run mypy app/ --ignore-missing-imports

## format: Auto-format all code
format:
	@cd apps/api && poetry run ruff format app/

# ─── Utilities ────────────────────────────────────────────────────────────────

## clean: Remove generated files and caches
clean:
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".mypy_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -name "*.pyc" -delete 2>/dev/null || true
	@echo "$(GREEN)✓ Cleaned.$(RESET)"

## health: Check health of all services
health:
	@curl -s http://localhost:8000/health | python3 -m json.tool 2>/dev/null || echo "API not running"
