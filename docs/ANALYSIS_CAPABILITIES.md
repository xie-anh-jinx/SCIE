# ANALYSIS CAPABILITIES — Kemampuan Analisis SCIE

---

## Overview

SCIE menyediakan 5 kategori analisis utama:

```
┌─────────────────────────────────────────────────────────┐
│                  SCIE ANALYSIS SUITE                    │
│                                                         │
│  1. Analisis Konten    ─ Apa yang dikatakan?            │
│  2. Analisis Tren      ─ Apa yang sedang naik?          │
│  3. Analisis Jaringan  ─ Siapa yang terhubung?          │
│  4. Analisis Perubahan ─ Bagaimana evolusinya?          │
│  5. Analisis Prediktif ─ Apa yang akan terjadi?         │
└─────────────────────────────────────────────────────────┘
```

---

## 1. Analisis Konten

### 1.1 Sentiment Analysis

**Pertanyaan yang dijawab:**
- Apa sentimen publik terhadap topik X?
- Bagaimana perbedaan sentimen antar platform?
- Segmen pengguna mana yang paling positif/negatif?

**Output:**
```
Topik: "Kenaikan BBM"
─────────────────────────────────────────────
Sentimen Keseluruhan:  Negatif (-0.68)
  Positif:  12%
  Netral:   18%
  Negatif:  70%

Per Platform:
  Twitter:   -0.72 (sangat negatif)
  Instagram: -0.45 (moderat negatif)
  Reddit:    -0.61 (negatif)

Per Demografi:
  Komunitas A: -0.85 (mahasiswa)
  Komunitas B: -0.32 (pelaku bisnis)
```

**Visualisasi:** Gauge chart, bar chart per platform, heatmap waktu.

---

### 1.2 Emotion Analysis

**Pertanyaan yang dijawab:**
- Emosi dominan apa yang mewarnai percakapan?
- Apakah ada pergeseran dari marah ke takut?

**Output:**
```
Distribusi Emosi:
  Anger:        45% ████████████████████
  Fear:         20% █████████
  Sadness:      18% ████████
  Disgust:      12% █████
  Joy:           3% █
  Others:        2%

Insight: Emosi "anger" mendominasi, mengindikasikan
  reaksi reaktif daripada diskusi deliberatif.
```

---

### 1.3 Topic Modeling

**Pertanyaan yang dijawab:**
- Apa topik-topik utama yang sedang dibicarakan?
- Subtopik apa yang ada dalam sebuah isu besar?

**Output:**
```
Topik-topik dalam percakapan "Pemilu 2024":
  1. Debat Capres       (32% volume)
  2. Kecurangan Pemilu  (28% volume)
  3. Kampanye Digital   (15% volume)
  4. Logistik Pemilu     (12% volume)
  5. Lainnya            (13% volume)
```

---

### 1.4 Named Entity Recognition (NER)

**Pertanyaan yang dijawab:**
- Tokoh siapa yang paling banyak disebutkan?
- Organisasi mana yang jadi sorotan?
- Lokasi mana yang relevan?

**Output:**
```
Top Entities dalam 24 jam terakhir:
  Persons:
    1. Nama Tokoh A    (2,341 mentions, sentiment: -0.4)
    2. Nama Tokoh B    (1,892 mentions, sentiment: +0.2)
  
  Organizations:
    1. KPU             (3,120 mentions, sentiment: -0.6)
    2. Bawaslu         (1,234 mentions, sentiment: -0.3)
  
  Locations:
    1. Jakarta         (5,431 mentions)
    2. Surabaya        (2,100 mentions)
```

---

### 1.5 Ringkasan Otomatis

**Output:** Narasi 150-300 kata yang merangkum situasi berdasarkan semua analisis konten.

---

## 2. Analisis Tren

### 2.1 Trending Topic

**Pertanyaan yang dijawab:**
- Apa yang sedang trending sekarang?
- Seberapa cepat sebuah topik naik?

**Algoritma:**
```
Trend Score = (Volume_sekarang / Volume_baseline) × Velocity
  Velocity = rate of change per hour
  Baseline = 7-day rolling average
```

**Output:**
```
Trending Topics (1 jam terakhir):
  1. #PemiluDamai        Score: 9.2  ↑ +340%
  2. Kenaikan Harga      Score: 7.8  ↑ +210%
  3. Gempa Sulawesi      Score: 6.1  ↑ +890% (breaking)
```

---

### 2.2 Emerging Topic Detection

Mendeteksi topik yang mulai muncul sebelum viral:
```
Metode:
  ─ Monitoring cluster kecil yang tumbuh cepat
  ─ Anomaly detection pada volume kecil
  ─ Early warning jika growth rate melewati threshold

Kegunaan:
  ─ Early crisis detection
  ─ Opportunity identification
  ─ Competitive intelligence
```

---

### 2.3 Event Detection

Mendeteksi kejadian nyata dari pola percakapan:
```
Sinyal Event:
  ─ Volume spike mendadak
  ─ Diversifikasi sumber (bukan hanya satu komunitas)
  ─ Media mulai meliput
  ─ Entitas baru muncul secara signifikan

Output:
  Event Terdeteksi: "Gempa Sulawesi"
  Waktu deteksi:    14:23 WIB
  Confidence:       0.94
  Volume spike:     +890% dalam 15 menit
  First source:     @BMKG
  Media involved:   5 media nasional
```

---

### 2.4 Virality Detection

```
Faktor Virality:
  ─ Share velocity
  ─ Cross-community spread
  ─ Influencer amplification
  ─ Media pickup

Virality Score (0-10):
  0-3: Organik, terbatas
  4-6: Sedang menyebar
  7-9: Viral
  10:  Massive viral event
```

---

## 3. Analisis Jaringan

### 3.1 Social Network Analysis

**Visualisasi:**
- Network graph interaktif
- Node = user, ukuran = influence score
- Edge = interaksi, ketebalan = frekuensi
- Warna = komunitas

**Metrics:**
```
Network-level:
  ─ Density
  ─ Average path length
  ─ Clustering coefficient
  ─ Diameter

Node-level:
  ─ Degree centrality
  ─ Betweenness centrality
  ─ PageRank
  ─ HITS score
```

---

### 3.2 Community Detection

**Output:**
```
Komunitas Terdeteksi: 8 komunitas

Komunitas 1 (2,341 anggota):
  Topik Dominan:  Politik Oposisi
  Sentimen:       Negatif (-0.71)
  Key Accounts:   @A, @B, @C
  Platform:       Twitter (87%), Facebook (13%)

Komunitas 2 (1,892 anggota):
  Topik Dominan:  Pendukung Pemerintah
  Sentimen:       Positif (+0.54)
  Key Accounts:   @X, @Y, @Z
  Platform:       Instagram (62%), Twitter (38%)

Interaksi antar komunitas:
  C1 ↔ C2: 234 cross-interactions (mostly hostile)
  C1 ↔ C3: 89 cross-interactions (mostly neutral)
```

---

### 3.3 Influencer Analysis

```
Tipe Influencer:
  
  Content Creator (Authorities)
  ─ Membuat konten original
  ─ Authority score tinggi
  ─ Diikuti oleh banyak orang
  
  Information Bridge (Hubs)
  ─ Menghubungkan komunitas berbeda
  ─ Betweenness centrality tinggi
  ─ Penting untuk information diffusion
  
  Echo Chamber Leader
  ─ Dominan di dalam satu komunitas
  ─ Low cross-community reach
  ─ Tinggi PageRank dalam komunitas

Output per influencer:
  @username
    Influence Score:    8.7 / 10
    Tipe:               Information Bridge
    Reach:              45,000 unique accounts
    Avg Engagement:     3.2%
    Communities:        3 komunitas
    Topic Expertise:    Politik, Ekonomi
    Bot Score:          0.02 (human)
```

---

### 3.4 Information Diffusion

**Diffusion Tree Visualization:**
```
@origin_account (T=0)
  ├── @spreader_A (T+2min)
  │     ├── @user_1 (T+5min)
  │     └── @user_2 (T+7min)
  ├── @media_X (T+15min) ← KEY AMPLIFIER
  │     ├── @user_3 (T+16min)
  │     ├── ...1,234 more accounts
  └── @influencer_B (T+45min)
        └── ...890 more accounts

Summary:
  Origin:        @origin_account
  Time to 1000:  47 minutes
  Key Amplifier: @media_X (caused 70% of spread)
  Total Reach:   28,000 unique accounts
```

---

## 4. Analisis Perubahan

### 4.1 Timeline Analysis

Visualisasi lengkap kronologi sebuah isu:
```
Timeline: "Kenaikan BBM"

[Hari -7]  Isu mulai muncul di forum Kaskus
[Hari -5]  Mulai masuk Twitter, volume kecil
[Hari -3]  Influencer A memperkuat → spike pertama
[Hari -1]  Media nasional mulai meliput
[Hari  0]  Pengumuman resmi → volume peak (+850%)
[Hari +1]  Sentimen ternegatif (-0.82)
[Hari +3]  Volume menurun, diskusi bergeser ke dampak
[Hari +7]  Topik masuk background noise
```

---

### 4.2 Narrative Evolution

Melacak bagaimana sebuah narasi berubah:
```
Evolusi Narasi "Kenaikan BBM":

Fase 1 (Hari -7 sd -3): "Rumor kenaikan"
  ─ Sentimen: Netral (spekulasi)
  ─ Aktor: Netizen biasa

Fase 2 (Hari -3 sd 0): "Antisipasi & kekhawatiran"
  ─ Sentimen: Negatif (ketakutan)
  ─ Aktor: Influencer + media

Fase 3 (Hari 0 sd +2): "Reaksi masif"
  ─ Sentimen: Sangat negatif (kemarahan)
  ─ Aktor: Seluruh komunitas

Fase 4 (Hari +2 sd +7): "Adaptasi & narasi baru"
  ─ Sentimen: Moderat negatif (penerimaan)
  ─ Narasi baru: Cara menghemat, dampak bisnis
```

---

### 4.3 Sentiment Shift Detection

Alert otomatis ketika sentimen berubah signifikan:
```
ALERT: Pergeseran Sentimen Terdeteksi
  Topik:      "Brand X"
  Dari:       Positif (+0.45) — kemarin
  Ke:         Negatif (-0.38) — hari ini
  Perubahan:  -0.83 dalam 6 jam
  
  Kemungkinan penyebab:
  ─ 3 jam lalu: Viral video tentang Brand X
  ─ Media pickup: 12 artikel dalam 2 jam
  
  Rekomendasi: Segera response monitoring
```

---

## 5. Analisis Prediktif

### 5.1 Trend Forecasting

```
Prediksi Volume "Pemilu 2024" (7 hari ke depan):

Hari 1:  ████████████   12,400 posts (±15%)
Hari 2:  █████████████  13,100 posts (±18%)
Hari 3:  ██████████████ 14,200 posts (±20%) ← Debat capres
Hari 4:  ████████       9,800 posts (±25%)
...

Confidence: 78%
Model: Prophet + ARIMA Ensemble
Key Driver: Jadwal debat capres pada Hari 3
```

---

### 5.2 Virality Prediction

```
Konten Berpotensi Viral (dalam 24 jam):

Post dari @influencer_A
  Virality Score Prediksi: 8.2 / 10
  Estimated Reach:         120,000 - 180,000
  Confidence:              72%
  Faktor:
    ─ Engagement rate awal tinggi (12%)
    ─ Di-share oleh 3 influencer dalam 30 menit
    ─ Topik sedang trending
    ─ Waktu posting optimal
```

---

### 5.3 Influence Prediction

Memprediksi siapa yang akan menjadi influencer berikutnya:
```
Rising Influencers:

@username_new
  Current Score:    4.2 / 10
  Predicted Score:  7.1 / 10 (dalam 30 hari)
  Growth Rate:      +68% per minggu
  Faktor:
    ─ Content quality tinggi
    ─ Engagement rate naik konsisten
    ─ Mulai di-follow influencer besar
```

---

*SCIE Project — Dokumen Analysis Capabilities v1.0*
