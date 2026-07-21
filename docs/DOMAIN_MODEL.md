# DOMAIN MODEL — Knowledge Graph Schema

---

## 1. Filosofi Domain Model

SCIE tidak hanya menyimpan teks — ia menyimpan **hubungan**.

Perbedaan mendasar:

```
Sistem Biasa:
  Post { id, text, likes, timestamp, author_id }

SCIE Knowledge Graph:
  (User)-[:WROTE { at: timestamp }]->(Post)
  (Post)-[:ABOUT]->(Topic)
  (Post)-[:MENTIONS]->(Person)
  (Post)-[:MENTIONS]->(Organization)
  (Post)-[:TAGGED_WITH]->(Hashtag)
  (User)-[:REPOSTED]->(Post)-[:ORIGINATED_FROM]->(Post)
  (User)-[:MEMBER_OF]->(Community)
  (Post)-[:PUBLISHED_ON]->(Platform)
  (Person)-[:AFFILIATED_WITH]->(Organization)
  (Organization)-[:LOCATED_IN]->(Location)
  (Event)-[:HAPPENED_IN]->(Location)
  (Post)-[:REFERENCES]->(Event)
```

---

## 2. Node Types (Entities)

### 2.1 User / Account
```
User {
  id              : String (platform-specific)
  platform        : Enum (twitter, instagram, tiktok, ...)
  username        : String
  display_name    : String
  bio             : String?
  follower_count  : Int
  following_count : Int
  verified        : Boolean
  bot_score       : Float          ← probabilitas akun bot (0-1)
  influence_score : Float          ← skor pengaruh di jaringan
  account_age     : Int (days)
  language        : String
  location        : String?
  created_at      : DateTime
  updated_at      : DateTime
}
```

### 2.2 Post / Content
```
Post {
  id              : String
  platform        : Enum
  type            : Enum (post, comment, reply, repost, article)
  text            : String
  url             : String
  language        : String
  timestamp       : DateTime
  
  # Engagement Metrics
  likes           : Int
  comments        : Int
  shares          : Int
  views           : Int?
  
  # NLP Enrichment
  sentiment_label : Enum (positive, negative, neutral)
  sentiment_score : Float (-1 to 1)
  emotions        : JSON  { anger, fear, joy, sadness, surprise }
  summary         : String?
  virality_score  : Float
  
  # Status
  is_original     : Boolean
  is_deleted      : Boolean
  collected_at    : DateTime
}
```

### 2.3 Topic
```
Topic {
  id              : String
  name            : String
  slug            : String
  description     : String?
  parent_topic    : Topic?        ← hierarki topik
  category        : Enum (politics, technology, health, ...)
  emergence_date  : DateTime
  trend_score     : Float
  post_count      : Int
}
```

### 2.4 Entity (Named Entity)
```
Entity {
  id              : String
  name            : String
  type            : Enum (PERSON, ORGANIZATION, LOCATION, EVENT, PRODUCT, ...)
  aliases         : [String]      ← nama-nama alternatif
  description     : String?
  importance_score: Float
  mention_count   : Int
  sentiment_avg   : Float         ← rata-rata sentimen ketika entity disebut
  first_seen      : DateTime
  last_seen       : DateTime
}
```

### 2.5 Hashtag
```
Hashtag {
  id              : String
  text            : String        ← tanpa simbol #
  platform        : Enum
  post_count      : Int
  trend_score     : Float
  peak_date       : DateTime?
  first_seen      : DateTime
}
```

### 2.6 Community
```
Community {
  id              : String
  name            : String?       ← bisa auto-generated
  detection_method: Enum (louvain, leiden, ...)
  member_count    : Int
  cohesion_score  : Float
  main_topics     : [Topic]
  dominant_sentiment: Enum
  detected_at     : DateTime
}
```

### 2.7 Platform
```
Platform {
  id              : String
  name            : String        ← twitter, instagram, dll
  type            : Enum (social_media, news, forum, blog)
  reach_score     : Float
}
```

### 2.8 Location
```
Location {
  id              : String
  name            : String
  type            : Enum (country, city, region, ...)
  country_code    : String?
  latitude        : Float?
  longitude       : Float?
}
```

### 2.9 Event (Real-world Event)
```
Event {
  id              : String
  name            : String
  description     : String?
  type            : Enum (political, economic, disaster, cultural, ...)
  start_date      : DateTime
  end_date        : DateTime?
  location        : Location?
  significance_score: Float
}
```

---

## 3. Relationship Types (Edges)

### User → Post
```
(User)-[:WROTE { at: DateTime }]->(Post)
(User)-[:LIKED { at: DateTime }]->(Post)
(User)-[:REPOSTED { at: DateTime }]->(Post)
(User)-[:REPLIED_TO { at: DateTime }]->(Post)
(User)-[:QUOTED { at: DateTime }]->(Post)
```

### Post → Entity / Topic / Hashtag
```
(Post)-[:MENTIONS { confidence: Float }]->(Entity)
(Post)-[:HAS_TOPIC { confidence: Float, weight: Float }]->(Topic)
(Post)-[:TAGGED_WITH]->(Hashtag)
(Post)-[:REFERENCES]->(Event)
(Post)-[:PUBLISHED_ON]->(Platform)
```

### Post → Post (Diffusion Chain)
```
(Post)-[:REPLY_TO]->(Post)
(Post)-[:QUOTE_OF]->(Post)
(Post)-[:REPOST_OF]->(Post)
(Post)-[:INSPIRED_BY { similarity: Float }]->(Post)
```

### User → User (Social Graph)
```
(User)-[:FOLLOWS]->(User)
(User)-[:INTERACTED_WITH { 
  interaction_count: Int, 
  last_interaction: DateTime 
}]->(User)
(User)-[:MEMBER_OF { role: Enum, joined_at: DateTime }]->(Community)
```

### Entity → Entity
```
(Entity)-[:AFFILIATED_WITH { role: String? }]->(Entity)
(Entity)-[:LOCATED_IN]->(Location)
(Entity)-[:PARTICIPATED_IN]->(Event)
(Entity)-[:RELATED_TO { strength: Float }]->(Entity)
```

### Topic → Topic
```
(Topic)-[:SUBTOPIC_OF]->(Topic)
(Topic)-[:RELATED_TO { co_occurrence: Float }]->(Topic)
(Topic)-[:EVOLVED_FROM { at: DateTime }]->(Topic)
```

---

## 4. Entity Resolution

Tantangan: entitas yang sama bisa muncul dalam banyak bentuk.

```
"Jokowi" = "Joko Widodo" = "Pak Jokowi" = "@jokowi"
```

**Strategi Entity Resolution:**

```
Step 1: Candidate Generation
  ─ Fuzzy string matching
  ─ Alias lookup dari knowledge base

Step 2: Feature Extraction
  ─ Name similarity
  ─ Context similarity (topik yang sama)
  ─ Co-mention pattern
  ─ Platform username linkage

Step 3: Classification
  ─ ML model: entity pair → same/different
  ─ Threshold-based merging

Step 4: Graph Merge
  ─ Canonical node dibuat
  ─ Semua alias → alias list
  ─ Semua edge dari alias → canonical node
```

---

## 5. Contoh Subgraph

### Contoh: Analisis Viral Topik

```
(@user_A) ─[WROTE]─→ (Post: "Breaking: ...")
                              ↓ [HAS_TOPIC]
                         (Topic: "Pemilu 2024")
                              ↓ [MENTIONS]
                         (Entity: "KPU") ─[AFFILIATED_WITH]─→ (Org: "Pemerintah")
                              
(@user_B) ─[REPOSTED]─→ (Post dari @user_A)
(@user_C) ─[REPOSTED]─→ (Post dari @user_A)
(@media_X) ─[QUOTED]─→ (Post dari @user_A)

Hasil analisis:
  - Post dari @user_A = titik awal diffusion
  - @user_A = potential influencer
  - Topik "Pemilu 2024" trending
  - KPU mendapat sentimen negatif (-0.65 avg)
```

---

## 6. Temporal Dimension

Setiap node dan edge memiliki dimensi waktu:

```
Snapshot pada T1:
  Community A ─[member: 1000, topic: "ekonomi"]

Snapshot pada T2 (+7 days):
  Community A ─[member: 2500, topic: "ekonomi + politik"]

Delta Analysis:
  - Community growth: +150%
  - Topic shift detected: ekonomi → politik
  - Trigger: Event X pada T1 + 3 days
```

Ini memungkinkan **Narrative Evolution Analysis** dan **Community Growth Tracking**.

---

*SCIE Project — Dokumen Domain Model v1.0*
