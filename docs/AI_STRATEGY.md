# AI STRATEGY — Penggunaan AI di SCIE

---

## 1. Overview

AI bukan ornamen di SCIE — AI adalah **inti dari sistem**.

Setiap lapisan arsitektur menggunakan AI dengan peran yang berbeda:

```
Layer               AI yang Digunakan          Fungsi Utama
─────────────────────────────────────────────────────────────
Ingestion           Rule-based + ML            Dedup, filtering
Processing          NLP Models                 Extract meaning
Graph Building      Entity Resolution ML       Merge identities
Analytics           Graph ML + Classical ML    Network analysis
Intelligence        LLM + Anomaly Detection    Insight generation
Presentation        LLM (RAG)                  Q&A interface
```

---

## 2. NLP Layer

### 2.1 Language Detection
- Library: `langdetect`, `fasttext`
- Fungsi: Menentukan bahasa teks sebelum processing
- Penting: Karena konten Indonesia bisa campuran Bahasa Indonesia + daerah + Inggris

### 2.2 Sentiment Analysis

**Pipeline:**
```
Text → Preprocessing → Sentiment Model → Score + Label
                                          ↓
                              (positive/negative/neutral)
                              (score: -1.0 to +1.0)
```

**Model yang relevan:**
- `IndoBERT` — BERT pre-trained untuk Bahasa Indonesia
- `IndoNLU` — benchmark suite untuk NLP Indonesia
- `mBERT` — multilingual BERT sebagai fallback
- Custom fine-tuned model untuk domain spesifik (politik, bisnis, dll)

**Granularitas:**
- Sentiment per post
- Sentiment per entity yang disebutkan dalam post
- Sentiment per topik

### 2.3 Emotion Analysis

Emosi yang dideteksi (berdasarkan Ekman's basic emotions):
```
anger     (marah)
fear      (takut)
joy       (senang)
sadness   (sedih)
surprise  (terkejut)
disgust   (jijik)
trust     (percaya)
anticipation (antisipasi)
```

**Output:** Probability distribution across emotions per post.

### 2.4 Named Entity Recognition (NER)

**Entitas yang dideteksi:**
```
PERSON       ─ Tokoh publik, politisi, selebriti
ORGANIZATION ─ Partai, perusahaan, lembaga, media
LOCATION     ─ Negara, kota, wilayah
EVENT        ─ Pemilu, bencana, peluncuran produk
PRODUCT      ─ Merek, produk
DATE/TIME    ─ Referensi waktu
MONEY        ─ Nilai uang, anggaran
```

**Model:**
- Fine-tuned `IndoBERT` untuk NER Indonesia
- Linked Entity Recognition: menghubungkan ke knowledge base (Wikidata)

### 2.5 Topic Modeling

**Pendekatan:**

1. **BERTopic** (recommended)
   - Menggunakan embeddings dari transformer
   - Dinamis dan tidak perlu menentukan jumlah topik di awal
   - Mendukung incremental update (topic baru bisa ditambah tanpa retrain penuh)

2. **LDA** (sebagai baseline)
   - Interpretable
   - Lebih cepat untuk volume besar

3. **Zero-shot Classification**
   - Menggunakan predefined topic taxonomy
   - Berguna untuk kategorisasi yang sudah terstruktur

### 2.6 Keyword Extraction
- **KeyBERT**: BERT-based keyword extraction
- **YAKE**: Unsupervised, language-agnostic
- Fungsi: Merepresentasikan konten utama setiap post

### 2.7 Summarization
- **Model**: IndoBART, mBART, atau GPT-based summarizer
- **Fungsi**: Membuat ringkasan otomatis dari kumpulan post bertopik sama

---

## 3. Graph Analytics Layer

### 3.1 Community Detection

**Algoritma:**
```
Louvain Algorithm
  ─ Fast, scalable
  ─ Optimize modularity
  ─ State of the art untuk large graphs

Leiden Algorithm
  ─ Improved version of Louvain
  ─ Guarantees well-connected communities

Label Propagation
  ─ Very fast
  ─ Useful for initial rough clustering
```

**Output:** Setiap user/entity mendapat label komunitas. Komunitas dapat dikarakterisasi berdasarkan:
- Topik dominan
- Sentimen rata-rata
- Aktor kunci

### 3.2 Influencer Analysis

**Centrality Metrics:**
```
Degree Centrality       ─ Banyaknya koneksi langsung
Betweenness Centrality  ─ Seberapa sering menjadi "jembatan"
PageRank                ─ Pengaruh berdasarkan kualitas koneksi
HITS (Hub/Authority)    ─ Membedakan penyebar vs pembuat konten
Eigenvector Centrality  ─ Pengaruh dari node yang berpengaruh
```

**Influence Score:** Kombinasi weighted dari metrik-metrik di atas, disesuaikan dengan:
- Engagement rate
- Follower quality (bukan sekadar kuantitas)
- Cross-community reach

### 3.3 Information Diffusion

**Model Diffusion:**
```
Independent Cascade Model
  ─ Memodelkan penyebaran seperti virus
  ─ Setiap node memiliki probabilitas menginfeksi neighbor

Linear Threshold Model
  ─ Node ter-activate jika threshold pengaruh tercapai
  ─ Lebih realistis untuk opini
```

**Analisis yang dihasilkan:**
- **Diffusion tree**: Siapa yang meretweet siapa?
- **Viral path**: Jalur penyebaran tercepat
- **Super-spreaders**: Node dengan dampak diffusion terbesar
- **Time to peak**: Berapa lama topik mencapai volume tertinggi

---

## 4. Machine Learning Layer

### 4.1 Bot Detection

**Features:**
```
Account Features:
  ─ Rasio follower/following
  ─ Account age
  ─ Profile completeness
  ─ Username pattern (random chars?)

Behavioral Features:
  ─ Posting frequency
  ─ Posting time pattern (jam-jaman sama setiap hari?)
  ─ Content similarity (posting konten yang persis sama)
  ─ Response latency (too fast?)

Network Features:
  ─ Clustering coefficient
  ─ Mutual follows ratio
  ─ Co-activity dengan akun lain
```

**Model:** Gradient Boosting (XGBoost/LightGBM) + Isolation Forest untuk anomaly.

### 4.2 Coordinated Campaign Detection

Mendeteksi kelompok akun yang bergerak secara terkoordinasi:
```
Signals:
  ─ Posting konten serupa dalam waktu bersamaan
  ─ Hashtag bombing
  ─ Sudden follower spikes
  ─ Network structure yang tidak natural
  
Method:
  ─ Co-hashtag network analysis
  ─ Temporal correlation clustering
  ─ Content similarity clustering (MinHash/LSH)
```

### 4.3 Trend Prediction

**Fitur:**
```
Volume trajectory (time series)
Engagement rate trend
Cross-platform spread
Influencer amplification
Media coverage correlation
Historical pattern similarity
```

**Model:**
- **ARIMA / Prophet**: Time-series forecasting untuk volume
- **LSTM / Transformer**: Deep learning untuk complex patterns
- **Hawkes Process**: Event-driven virality modeling

### 4.4 Anomaly Detection

Mendeteksi lonjakan tidak wajar:
```
Isolation Forest   ─ Unsupervised anomaly detection
DBSCAN             ─ Density-based, tidak perlu label
Z-score analysis   ─ Statistical baseline deviation
```

---

## 5. LLM Layer

### 5.1 Insight Generation

LLM digunakan untuk mengubah output analitik (angka, graf) menjadi **narasi yang dapat dipahami manusia**.

**Contoh:**
```
Input ke LLM:
{
  "topic": "Pemilu 2024",
  "volume_spike": "300% increase",
  "sentiment": "shifting from neutral to negative",
  "key_accounts": ["@media_A", "@tokoh_B"],
  "community": "Community X - mostly opposition supporters",
  "event": "Debat capres 3 hari lalu"
}

Output LLM:
"Lonjakan percakapan tentang Pemilu 2024 sebesar 300% 
 dalam 3 hari terakhir dipicu oleh debat capres yang 
 berlangsung pada [tanggal]. Sentimen publik bergeser 
 negatif, terutama di kalangan pendukung oposisi yang 
 tergabung dalam komunitas X. Akun-akun seperti @media_A 
 dan @tokoh_B menjadi penyebar informasi terbesar. 
 Tren ini berpotensi berlanjut menuju hari pemilihan."
```

### 5.2 Q&A Interface (RAG)

Pengguna dapat bertanya dalam bahasa natural:
```
User: "Siapa yang paling banyak menyebarkan isu ini?"
User: "Kapan sentimen mulai berubah?"
User: "Apakah ada kampanye terkoordinasi?"
User: "Bagaimana perkembangan narasi dalam seminggu terakhir?"
```

**Arsitektur RAG:**
```
Question
  ↓
Query Understanding (LLM)
  ↓
Retrieval from:
  ─ Graph Database (Neo4j)
  ─ Time-series Data
  ─ Vector Store (embeddings)
  ↓
Context Assembly
  ↓
LLM Answer Generation
  ↓
Answer + Citations
```

### 5.3 Report Generation

Laporan otomatis yang dapat:
- Diekspor ke PDF/Word
- Dikustomisasi per template
- Dijadwalkan (daily/weekly brief)
- Disesuaikan per target pembaca (eksekutif vs analis)

---

## 6. Model Registry & MLOps

```
Model Lifecycle:
  Training → Evaluation → Registry → Deployment → Monitoring

Tools:
  MLflow       ─ Experiment tracking, model registry
  BentoML      ─ Model serving
  Prometheus   ─ Model performance monitoring
  
Retraining Strategy:
  ─ Scheduled: weekly/monthly
  ─ Triggered: performance degradation detected
  ─ Continuous: online learning untuk trend models
```

---

*SCIE Project — Dokumen AI Strategy v1.0*
