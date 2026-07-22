---
language:
- id
- en
license: mit
task_categories:
- text-classification
- feature-extraction
tags:
- social-intelligence
- indonesian-nlp
- sentiment-analysis
- ner
- knowledge-graph
pretty_name: SCIE — Social Intelligence Engine Full Dataset & Database Dump
size_categories:
- n<10K
---

# 🧠 SCIE — Social Intelligence Engine Full Dataset & Database Dump

Repositori resmi dataset dan snapshot database penuh dari platform **Social Intelligence Engine (SCIE)**.

## 📊 Berkas yang Tersedia dalam Repositori Ini:

1. **`scie_full_database.sql`** (400 KB PostgreSQL SQL Dump)
   - Snapshot struktur tabel dan data penuh database PostgreSQL + TimescaleDB (Users, DataSources, Posts, RefreshTokens, ApiKeys, Alerts).
   - Dapat di-restore langsung ke PostgreSQL dengan `psql -U scie -d scie < scie_full_database.sql`.

2. **`scie_posts_full.json` & `scie_dataset.json`**
   - Teks berita mentah (Antara News, CNBC Indonesia, CNN Indonesia) dan percakapan sosial media.
   - Hasil anotasi **Skor Sentimen (-1.0 hingga +1.0)** & **Label Sentimen** (positive, neutral, negative).
   - Anotasi **NER Entities** (ORGANIZATION, PERSON, LOCATION).
   - Pengelompokan **Taksonomi Topik** (AI, Ekonomi Digital, Pemerintahan, Disinformasi, dll).
   - Skor Risiko Viralitas (*Virality Score*).

3. **`scie_graph_network.json`**
   - Node dan Edge relasi sosial dari Neo4j Knowledge Graph (`User`, `Post`, `Topic`, `Entity` nodes dan `WROTE`, `HAS_TOPIC`, `MENTIONS` edges).

4. **`scie_sentiment_distribution.json` & `scie_trending_topics.json`**
   - Ringkasan statistik distribusi sentimen dan pemeringkatan tren topik terkini.

---

### 💻 Cara Menggunakan di Python / Pandas:

```python
import json
import pandas as pd

# Load dataset postingan
with open('scie_posts_full.json', 'r', encoding='utf-8') as f:
    posts = json.load(f)

df = pd.DataFrame(posts)
print(df[['text', 'sentiment_label', 'topics', 'virality_score']].head())
```
