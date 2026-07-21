# ARCHITECTURE — Social Intelligence Engine (SCIE)

---

## 1. Gambaran Besar

SCIE dibangun sebagai sistem berlapis (**layered system**) di mana setiap lapisan mengubah data menjadi bentuk yang lebih bermakna.

```
┌─────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                │
│          Dashboard · API · Reports · Alerts         │
└─────────────────────────────────────────────────────┘
                           ↑
┌─────────────────────────────────────────────────────┐
│                   INTELLIGENCE LAYER                │
│    LLM Insights · Predictions · Anomaly Detection   │
└─────────────────────────────────────────────────────┘
                           ↑
┌─────────────────────────────────────────────────────┐
│                    ANALYTICS LAYER                  │
│   Network Analysis · Community Detection · Trends   │
└─────────────────────────────────────────────────────┘
                           ↑
┌─────────────────────────────────────────────────────┐
│                  KNOWLEDGE GRAPH LAYER              │
│    Entity Resolution · Relationship Building        │
└─────────────────────────────────────────────────────┘
                           ↑
┌─────────────────────────────────────────────────────┐
│                    PROCESSING LAYER                 │
│   NLP Pipeline · Sentiment · NER · Topic Modeling   │
└─────────────────────────────────────────────────────┘
                           ↑
┌─────────────────────────────────────────────────────┐
│                    INGESTION LAYER                  │
│      Scrapers · Connectors · Stream Processing      │
└─────────────────────────────────────────────────────┘
                           ↑
┌─────────────────────────────────────────────────────┐
│                     DATA SOURCES                    │
│  Twitter/X · Instagram · TikTok · News · Forums     │
└─────────────────────────────────────────────────────┘
```

---

## 2. Layer Detail

### Layer 1 — Data Sources

Sumber data yang dikumpulkan:

| Kategori | Sumber |
|---|---|
| **Media Sosial** | Twitter/X, Instagram, TikTok, Facebook, LinkedIn |
| **Forum & Komunitas** | Reddit, Kaskus, Discord, Telegram public channel |
| **Berita Digital** | RSS feeds, web scraping media nasional/internasional |
| **Video Platform** | YouTube (komentar, metadata) |
| **Blog & Opinion** | Medium, Kompasiana, personal blogs |

---

### Layer 2 — Ingestion Layer

Tugas: Mengumpulkan, membersihkan, dan menormalisasi data mentah.

```
Data Sources
     ↓
┌────────────────────────────────────────┐
│           INGESTION PIPELINE           │
│                                        │
│  Connectors   →  Raw Queue             │
│  (API/Scrape)     (Message Broker)     │
│                                        │
│  Validators   →  Clean Queue           │
│  (Dedup/Filter)   (Normalized Data)    │
│                                        │
│  Storage      →  Raw Data Lake         │
│  (Archival)       (Object Storage)     │
└────────────────────────────────────────┘
```

**Komponen:**
- **Connectors**: Adapter untuk setiap sumber data
- **Rate Limiter**: Mengelola batas API
- **Deduplication**: Menghilangkan konten duplikat
- **Normalization**: Menyeragamkan format data
- **Message Broker**: Antrian untuk stream processing

---

### Layer 3 — Processing Layer (NLP Pipeline)

Tugas: Mengekstrak makna dari teks.

```
Raw Content
     ↓
┌────────────────────────────────────────────────────┐
│               NLP PROCESSING PIPELINE              │
│                                                    │
│  Language Detection → Preprocessing                │
│                           ↓                        │
│  Sentiment Analysis  ← → NER (Named Entity)        │
│                           ↓                        │
│  Emotion Detection   ← → Topic Modeling            │
│                           ↓                        │
│  Keyword Extraction  ← → Summarization             │
│                           ↓                        │
│              Enriched Content Record               │
└────────────────────────────────────────────────────┘
```

**Output per konten:**
```json
{
  "id": "...",
  "text": "...",
  "language": "id",
  "sentiment": { "label": "negative", "score": -0.72 },
  "emotions": { "anger": 0.4, "fear": 0.3, "joy": 0.1 },
  "entities": [
    { "text": "Jokowi", "type": "PERSON" },
    { "text": "Jakarta", "type": "LOCATION" }
  ],
  "topics": ["politik", "infrastruktur"],
  "keywords": ["pembangunan", "ibu kota", "anggaran"],
  "summary": "..."
}
```

---

### Layer 4 — Knowledge Graph Layer

Tugas: Membangun representasi hubungan antar entitas.

```
Enriched Content
     ↓
┌────────────────────────────────────────────────────┐
│             KNOWLEDGE GRAPH ENGINE                 │
│                                                    │
│  Entity Extraction  →  Entity Resolution           │
│  (from NLP output)     (merge duplicates)          │
│                                ↓                   │
│  Relationship      →  Graph Database               │
│  Builder               (Neo4j / ArangoDB)          │
│                                ↓                   │
│  Schema Enforcement  →  Graph Validation           │
└────────────────────────────────────────────────────┘
```

**Graph Schema:**
```
(User)-[:WROTE]->(Post)
(Post)-[:MENTIONS]->(Entity)
(Post)-[:HAS_TOPIC]->(Topic)
(Post)-[:TAGGED_WITH]->(Hashtag)
(User)-[:FOLLOWS]->(User)
(User)-[:REPOSTED]->(Post)
(Post)-[:PUBLISHED_BY]->(Platform)
(Entity)-[:AFFILIATED_WITH]->(Organization)
(Organization)-[:LOCATED_IN]->(Location)
(Post)-[:OCCURRED_DURING]->(Event)
```

---

### Layer 5 — Analytics Layer

Tugas: Menganalisis data dan graf untuk menghasilkan insight.

```
Knowledge Graph + Time-Series Data
          ↓
┌──────────────────────────────────────────────┐
│              ANALYTICS ENGINE                │
│                                              │
│  ┌──────────────┐  ┌──────────────────────┐  │
│  │ Network      │  │ Trend Analytics      │  │
│  │ Analysis     │  │ ─ Volume Trend       │  │
│  │ ─ Community  │  │ ─ Emerging Topics    │  │
│  │ ─ Influencer │  │ ─ Event Detection    │  │
│  │ ─ Diffusion  │  │ ─ Virality Score     │  │
│  └──────────────┘  └──────────────────────┘  │
│                                              │
│  ┌──────────────┐  ┌──────────────────────┐  │
│  │ Temporal     │  │ Predictive           │  │
│  │ Analysis     │  │ Analytics            │  │
│  │ ─ Timeline   │  │ ─ Trend Forecast     │  │
│  │ ─ Narrative  │  │ ─ Virality Predict   │  │
│  │   Evolution  │  │ ─ Influence Predict  │  │
│  └──────────────┘  └──────────────────────┘  │
└──────────────────────────────────────────────┘
```

---

### Layer 6 — Intelligence Layer

Tugas: Mengubah hasil analisis menjadi insight yang dapat dipahami.

```
Analytics Results
      ↓
┌────────────────────────────────────────┐
│          INTELLIGENCE ENGINE           │
│                                        │
│  LLM Interpretation                    │
│  ─ "Mengapa topik ini viral?"          │
│  ─ "Siapa aktor utamanya?"             │
│  ─ "Apa implikasi dari temuan ini?"    │
│                                        │
│  Anomaly Detection                     │
│  ─ Bot Detection                       │
│  ─ Coordinated Campaign Detection      │
│  ─ Unusual Spike Detection             │
│                                        │
│  Auto Report Generation                │
│  ─ Executive Summary                   │
│  ─ Narrative Report                    │
│  ─ Alert & Notification                │
└────────────────────────────────────────┘
```

---

### Layer 7 — Presentation Layer

Tugas: Menyajikan insight kepada pengguna.

```
┌─────────────────────────────────────────────────┐
│               PRESENTATION LAYER                │
│                                                 │
│  ┌──────────────┐  ┌────────────┐  ┌─────────┐  │
│  │  Dashboard   │  │  REST API  │  │ Reports │  │
│  │  (Web UI)    │  │  GraphQL   │  │  (PDF)  │  │
│  └──────────────┘  └────────────┘  └─────────┘  │
│                                                 │
│  ┌──────────────┐  ┌────────────────────────┐   │
│  │  AI Chat     │  │  Alerts & Webhooks     │   │
│  │  Interface   │  │  (Real-time notif)     │   │
│  └──────────────┘  └────────────────────────┘   │
└─────────────────────────────────────────────────┘
```

---

## 3. Data Flow Overview

```
[Social Media APIs / Web Scrapers]
           ↓ raw data
[Message Broker - Kafka / Redis Streams]
           ↓ queued events
[NLP Workers - Python / FastAPI]
           ↓ enriched records
[Graph Ingester]
           ↓ nodes & edges
[Graph Database - Neo4j]     [Time-Series DB - InfluxDB / TimescaleDB]
           ↓                              ↓
[Analytics Engine]           [Trend Engine]
           ↓─────────────────────────────↓
[Intelligence Layer - LLM + ML Models]
           ↓
[API Layer - FastAPI / GraphQL]
           ↓
[Frontend Dashboard]
```

---

## 4. Deployment Architecture

```
                    ┌─────────────────────┐
                    │    Load Balancer     │
                    └─────────────────────┘
                             ↓
          ┌─────────────────────────────────┐
          │         API Gateway              │
          └─────────────────────────────────┘
          ↓              ↓               ↓
    [Frontend]    [Backend API]   [Analytics API]
                       ↓
          ┌────────────────────────────┐
          │      Service Mesh          │
          │  Ingestion · NLP · Graph   │
          │  Analytics · Intelligence  │
          └────────────────────────────┘
                    ↓
          ┌────────────────────────────┐
          │      Data Layer            │
          │  PostgreSQL · Neo4j        │
          │  Redis · Kafka             │
          │  InfluxDB · MinIO          │
          └────────────────────────────┘
```

---

*SCIE Project — Dokumen Arsitektur v1.0*
