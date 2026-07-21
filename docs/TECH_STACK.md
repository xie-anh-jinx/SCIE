# TECH STACK — Rekomendasi Teknologi SCIE

---

## 1. Prinsip Pemilihan Teknologi

```
1. Battle-tested     ─ Terbukti di production
2. Scalable          ─ Mampu tumbuh seiring volume data
3. Open Source       ─ Hindari vendor lock-in
4. Ecosystem Rich    ─ Library & komunitas yang mature
5. Team-friendly     ─ Kurva belajar yang reasonable
```

---

## 2. Tech Stack Overview

```
┌───────────────────────────────────────────────────────┐
│                  SCIE TECH STACK                      │
│                                                       │
│  Frontend       │  Next.js + TypeScript               │
│  Backend API    │  FastAPI (Python)                   │
│  NLP/AI Worker  │  Python (Celery workers)            │
│  Streaming      │  Apache Kafka / Redis Streams       │
│                 │                                     │
│  Graph DB       │  Neo4j                              │
│  Relational DB  │  PostgreSQL                         │
│  Time-series    │  TimescaleDB (PostgreSQL extension) │
│  Cache          │  Redis                              │
│  Search         │  Elasticsearch                      │
│  Vector Store   │  Qdrant / Weaviate                  │
│  Object Storage │  MinIO (S3-compatible)              │
│                 │                                     │
│  Orchestration  │  Docker + Kubernetes                │
│  CI/CD          │  GitHub Actions                     │
│  Monitoring     │  Prometheus + Grafana               │
│  ML Tracking    │  MLflow                             │
└───────────────────────────────────────────────────────┘
```

---

## 3. Detail Per Layer

### 3.1 Data Ingestion

| Komponen | Teknologi | Alasan |
|---|---|---|
| Twitter/X Connector | Twitter API v2 | Official API |
| Web Scraper | Scrapy + Playwright | JS-rendered sites |
| News Scraper | newspaper3k + RSS | Structured parsing |
| Stream Processing | Apache Kafka | High-throughput, durable |
| Task Queue | Celery + Redis | Distributed workers |
| Scheduler | APScheduler / Celery Beat | Cron-like scheduling |

**Catatan:** Untuk tahap awal, bisa mulai dengan **Redis Streams** yang lebih sederhana daripada Kafka, lalu migrasi ke Kafka saat volume bertambah.

---

### 3.2 NLP / AI Processing

| Komponen | Teknologi | Alasan |
|---|---|---|
| NLP Framework | HuggingFace Transformers | Ekosistem terlengkap |
| BERT Indonesia | IndoBERT (indobenchmark) | State-of-the-art untuk Bahasa Indonesia |
| Topic Modeling | BERTopic | BERT-based, no need to specify k |
| Sentiment | Fine-tuned IndoBERT | Akurasi tinggi untuk Indonesia |
| NER | Fine-tuned IndoBERT | Mendukung entitas Indonesia |
| Keyword | KeyBERT | BERT-based, akurat |
| Language Detection | fasttext | Fast, accurate, 170+ bahasa |
| Summarization | mBART / IndoBART | Multilingual summarization |
| Graph ML | PyG (PyTorch Geometric) | Graph neural networks |
| Classical ML | scikit-learn, XGBoost | Untuk tabular features |
| Time Series | Prophet, statsmodels | Trend forecasting |
| LLM | OpenAI GPT-4 / Claude / Gemini | Insight generation + RAG |
| Embeddings | sentence-transformers | Semantic similarity |
| Model Serving | BentoML / TorchServe | Production ML serving |

---

### 3.3 Databases

#### Graph Database — Neo4j
```
Mengapa Neo4j:
  ✓ Mature, enterprise-ready
  ✓ Cypher query language yang ekspresif
  ✓ Native graph storage (bukan relational yang dibuat graph)
  ✓ APOC library untuk analisis graph lanjutan
  ✓ Graph Data Science (GDS) library built-in
    → PageRank, Louvain, Betweenness Centrality, dll

Alternatif:
  ─ ArangoDB (multi-model: graph + document + key-value)
  ─ Amazon Neptune (managed, tapi vendor lock-in)
  ─ TigerGraph (lebih scalable, tapi lebih kompleks)
```

#### Relational Database — PostgreSQL
```
Digunakan untuk:
  ─ User accounts & authentication
  ─ Project/workspace management
  ─ Configuration & settings
  ─ Audit logs
  ─ Report metadata
```

#### Time-Series — TimescaleDB
```
Extension PostgreSQL untuk time-series data.

Digunakan untuk:
  ─ Volume metrics per topik per waktu
  ─ Sentiment trend over time
  ─ Engagement metrics history
  ─ Platform activity metrics

Keunggulan vs InfluxDB:
  ✓ Tetap menggunakan SQL (familiar)
  ✓ Hypertable (automatic partitioning by time)
  ✓ Continuous aggregates (materialized views)
  ✓ Compression built-in
```

#### Cache — Redis
```
Digunakan untuk:
  ─ Session management
  ─ API response caching
  ─ Rate limiting
  ─ Pub/Sub untuk real-time updates
  ─ Celery broker
  ─ Leaderboard (sorted sets untuk influencer ranking)
```

#### Search — Elasticsearch
```
Digunakan untuk:
  ─ Full-text search across posts
  ─ Advanced filter combinations
  ─ Aggregation queries
  ─ Near real-time indexing
```

#### Vector Store — Qdrant
```
Digunakan untuk:
  ─ Semantic search (cari post dengan makna serupa)
  ─ RAG (Retrieval Augmented Generation) untuk LLM
  ─ Similar entity matching
  
Alternatif: Weaviate, Pinecone, pgvector
```

#### Object Storage — MinIO
```
Digunakan untuk:
  ─ Raw data archival
  ─ Model artifacts
  ─ Generated reports (PDF)
  ─ Media files (gambar, video metadata)
  
MinIO = Self-hosted S3-compatible storage
```

---

### 3.4 Backend API

| Komponen | Teknologi | Alasan |
|---|---|---|
| API Framework | FastAPI | Async, fast, auto-docs |
| API Schema | Pydantic v2 | Validation + serialization |
| GraphQL | Strawberry | Python-native GraphQL |
| Auth | JWT + OAuth2 | Industry standard |
| Rate Limiting | slowapi | FastAPI-compatible |
| Background Jobs | Celery | Distributed task queue |
| WebSocket | FastAPI WebSocket | Real-time updates |

---

### 3.5 Frontend

| Komponen | Teknologi | Alasan |
|---|---|---|
| Framework | Next.js 14+ | SSR + SSG, App Router |
| Language | TypeScript | Type safety |
| State | Zustand / TanStack Query | Lightweight, cache-aware |
| Charts | Recharts + D3.js | Flexibility untuk network viz |
| Network Graph | Sigma.js / Cytoscape.js | Graph visualization |
| Map | Mapbox GL / Leaflet | Geospatial visualization |
| Tables | TanStack Table | High-performance |
| UI | Shadcn/ui + custom CSS | Headless + customizable |
| Animations | Framer Motion | Smooth transitions |

---

### 3.6 Infrastructure

| Komponen | Teknologi | Alasan |
|---|---|---|
| Container | Docker | Portability |
| Orchestration | Kubernetes (K8s) | Production scaling |
| Service Mesh | Istio (optional) | Traffic management |
| CI/CD | GitHub Actions | Free, integrated |
| IaC | Terraform | Infrastructure as Code |
| Monitoring | Prometheus + Grafana | Metrics + dashboards |
| Logging | Loki + Grafana | Log aggregation |
| Tracing | Jaeger / OpenTelemetry | Distributed tracing |
| Secrets | HashiCorp Vault | Secrets management |

---

## 4. Deployment Strategy

### Development
```
Docker Compose
  ─ Semua services di satu mesin
  ─ Hot reload untuk development
  ─ Seed data untuk testing
```

### Staging
```
Single-node Kubernetes (K3s atau MicroK8s)
  ─ Mirip production topology
  ─ Automated testing
  ─ Preview deployments
```

### Production
```
Multi-node Kubernetes
  ─ High Availability setup
  ─ Horizontal Pod Autoscaling
  ─ Database clustering (Neo4j Cluster, PostgreSQL HA)
  ─ CDN untuk frontend assets
```

---

## 5. Estimasi Resources

### Minimum (Development / Small Scale)
```
CPU:     8 cores
RAM:     32 GB
Storage: 500 GB SSD
Network: 100 Mbps
```

### Production (Medium Scale — ~10M posts/month)
```
Kubernetes Cluster:
  ─ 3 master nodes: 4 vCPU, 8 GB RAM each
  ─ 5 worker nodes: 8 vCPU, 32 GB RAM each
  
Managed Databases:
  ─ Neo4j: 16 vCPU, 64 GB RAM, 2 TB SSD
  ─ PostgreSQL: 8 vCPU, 32 GB RAM, 1 TB SSD
  ─ Redis: 4 vCPU, 16 GB RAM
  ─ Elasticsearch: 3 nodes, 8 vCPU, 32 GB RAM each

Storage:
  ─ Object Storage (MinIO): 10 TB
```

---

## 6. Open Source Alternatives vs Commercial

| Kategori | Open Source | Commercial |
|---|---|---|
| Graph DB | Neo4j Community | Neo4j Enterprise / TigerGraph |
| Vector DB | Qdrant (self-hosted) | Pinecone |
| Object Storage | MinIO | AWS S3 / GCS |
| LLM | Llama3 / Mistral (self-hosted) | OpenAI / Claude / Gemini |
| Search | Elasticsearch (self-hosted) | Elastic Cloud / Algolia |
| Monitoring | Prometheus + Grafana | Datadog / New Relic |

**Rekomendasi:** Mulai dengan fully open-source stack untuk kontrol penuh dan efisiensi biaya. Adopt commercial/managed jika tim tidak memiliki capacity untuk ops.

---

*SCIE Project — Dokumen Tech Stack v1.0*
