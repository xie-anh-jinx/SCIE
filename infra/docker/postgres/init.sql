-- =============================================================================
-- SCIE PostgreSQL Initialization Script
-- Runs once when container is first created
-- =============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";    -- fuzzy text search
CREATE EXTENSION IF NOT EXISTS "timescaledb"; -- time-series (from image)

-- =============================================================================
-- CORE TABLES
-- =============================================================================

-- Organizations (multi-tenant support)
CREATE TABLE IF NOT EXISTS organizations (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name        TEXT NOT NULL,
    slug        TEXT UNIQUE NOT NULL,
    plan        TEXT NOT NULL DEFAULT 'free', -- free | pro | enterprise
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Users
CREATE TABLE IF NOT EXISTS users (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    email           TEXT UNIQUE NOT NULL,
    username        TEXT UNIQUE NOT NULL,
    hashed_password TEXT NOT NULL,
    full_name       TEXT,
    role            TEXT NOT NULL DEFAULT 'analyst', -- admin | analyst | viewer
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    is_verified     BOOLEAN NOT NULL DEFAULT FALSE,
    last_login      TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- API Keys
CREATE TABLE IF NOT EXISTS api_keys (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    name            TEXT NOT NULL,
    key_hash        TEXT UNIQUE NOT NULL,  -- store hashed key, never raw
    key_prefix      TEXT NOT NULL,         -- first 8 chars for identification
    permissions     TEXT[] NOT NULL DEFAULT ARRAY['read'],
    last_used_at    TIMESTAMPTZ,
    expires_at      TIMESTAMPTZ,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Refresh Tokens
CREATE TABLE IF NOT EXISTS refresh_tokens (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash  TEXT UNIQUE NOT NULL,
    expires_at  TIMESTAMPTZ NOT NULL,
    is_revoked  BOOLEAN NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    user_agent  TEXT,
    ip_address  TEXT
);

-- =============================================================================
-- SOCIAL DATA TABLES
-- =============================================================================

-- Social Media Users/Accounts
CREATE TABLE IF NOT EXISTS social_accounts (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    platform        TEXT NOT NULL,        -- twitter | instagram | reddit | ...
    platform_id     TEXT NOT NULL,        -- native ID from platform
    username        TEXT,
    display_name    TEXT,
    bio             TEXT,
    follower_count  INT DEFAULT 0,
    following_count INT DEFAULT 0,
    post_count      INT DEFAULT 0,
    is_verified     BOOLEAN DEFAULT FALSE,
    profile_image   TEXT,
    location        TEXT,
    language        TEXT,
    account_age_days INT,
    bot_score       FLOAT DEFAULT 0.0,    -- 0=human, 1=bot (filled by Fase 4)
    influence_score FLOAT DEFAULT 0.0,    -- filled by graph analytics
    community_id    TEXT,                 -- from Louvain detection
    collected_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(platform, platform_id)
);

-- Posts / Content
CREATE TABLE IF NOT EXISTS posts (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    platform        TEXT NOT NULL,
    platform_id     TEXT NOT NULL,
    type            TEXT NOT NULL DEFAULT 'post', -- post|comment|reply|repost|article
    text            TEXT,
    text_cleaned    TEXT,
    language        TEXT,
    url             TEXT,
    author_id       UUID REFERENCES social_accounts(id),
    parent_post_id  UUID REFERENCES posts(id),   -- for replies/quotes
    original_post_id UUID REFERENCES posts(id),  -- for reposts
    timestamp       TIMESTAMPTZ,

    -- Engagement Metrics
    likes           INT DEFAULT 0,
    comments        INT DEFAULT 0,
    shares          INT DEFAULT 0,
    views           INT DEFAULT 0,
    bookmarks       INT DEFAULT 0,

    -- NLP Enrichment (filled by NLP worker)
    sentiment_label TEXT,                -- positive | negative | neutral
    sentiment_score FLOAT,              -- -1.0 to 1.0
    emotions        JSONB,              -- {anger:0.4, fear:0.2, joy:0.1, ...}
    topics          TEXT[],
    keywords        TEXT[],
    summary         TEXT,
    virality_score  FLOAT DEFAULT 0.0,

    -- Status
    is_original     BOOLEAN DEFAULT TRUE,
    is_deleted      BOOLEAN DEFAULT FALSE,
    collected_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    processed_at    TIMESTAMPTZ,
    UNIQUE(platform, platform_id)
);

-- Entities (Named Entities: PERSON, ORG, LOCATION, etc.)
CREATE TABLE IF NOT EXISTS entities (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name            TEXT NOT NULL,
    normalized_name TEXT NOT NULL,
    type            TEXT NOT NULL,   -- PERSON|ORG|LOCATION|EVENT|PRODUCT|...
    aliases         TEXT[] DEFAULT '{}',
    description     TEXT,
    wikidata_id     TEXT,            -- link to Wikidata if available
    mention_count   INT DEFAULT 0,
    sentiment_avg   FLOAT DEFAULT 0.0,
    importance_score FLOAT DEFAULT 0.0,
    first_seen      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_seen       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(normalized_name, type)
);

-- Post ↔ Entity mentions (many-to-many)
CREATE TABLE IF NOT EXISTS post_entities (
    post_id     UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    entity_id   UUID NOT NULL REFERENCES entities(id) ON DELETE CASCADE,
    confidence  FLOAT NOT NULL DEFAULT 1.0,
    PRIMARY KEY (post_id, entity_id)
);

-- Hashtags
CREATE TABLE IF NOT EXISTS hashtags (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    text        TEXT NOT NULL,
    platform    TEXT NOT NULL,
    post_count  INT DEFAULT 0,
    trend_score FLOAT DEFAULT 0.0,
    first_seen  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(text, platform)
);

-- Data Source Connectors config
CREATE TABLE IF NOT EXISTS data_sources (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    name            TEXT NOT NULL,
    platform        TEXT NOT NULL,
    config          JSONB NOT NULL DEFAULT '{}', -- encrypted credentials & settings
    keywords        TEXT[] DEFAULT '{}',         -- tracking keywords/hashtags
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    last_run_at     TIMESTAMPTZ,
    posts_collected INT DEFAULT 0,
    status          TEXT DEFAULT 'idle',  -- idle | running | error
    error_message   TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- TIME-SERIES TABLES (TimescaleDB)
-- =============================================================================

-- Volume metrics per topic per time
CREATE TABLE IF NOT EXISTS topic_volume (
    time            TIMESTAMPTZ NOT NULL,
    topic           TEXT NOT NULL,
    platform        TEXT,
    count           INT NOT NULL DEFAULT 0,
    sentiment_avg   FLOAT,
    engagement_sum  INT DEFAULT 0
);
SELECT create_hypertable('topic_volume', 'time', if_not_exists => TRUE);

-- Entity mentions over time
CREATE TABLE IF NOT EXISTS entity_mentions_ts (
    time            TIMESTAMPTZ NOT NULL,
    entity_id       UUID NOT NULL,
    entity_name     TEXT NOT NULL,
    platform        TEXT,
    mention_count   INT NOT NULL DEFAULT 0,
    sentiment_avg   FLOAT
);
SELECT create_hypertable('entity_mentions_ts', 'time', if_not_exists => TRUE);

-- Platform activity metrics
CREATE TABLE IF NOT EXISTS platform_metrics (
    time            TIMESTAMPTZ NOT NULL,
    platform        TEXT NOT NULL,
    posts_count     INT DEFAULT 0,
    unique_users    INT DEFAULT 0,
    avg_engagement  FLOAT DEFAULT 0
);
SELECT create_hypertable('platform_metrics', 'time', if_not_exists => TRUE);

-- =============================================================================
-- INDEXES
-- =============================================================================

CREATE INDEX IF NOT EXISTS idx_posts_timestamp ON posts(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_posts_platform ON posts(platform);
CREATE INDEX IF NOT EXISTS idx_posts_sentiment ON posts(sentiment_label);
CREATE INDEX IF NOT EXISTS idx_posts_author ON posts(author_id);
CREATE INDEX IF NOT EXISTS idx_posts_topics ON posts USING GIN(topics);
CREATE INDEX IF NOT EXISTS idx_posts_keywords ON posts USING GIN(keywords);
CREATE INDEX IF NOT EXISTS idx_posts_text_search ON posts USING GIN(to_tsvector('indonesian', coalesce(text, '')));
CREATE INDEX IF NOT EXISTS idx_social_accounts_platform ON social_accounts(platform, platform_id);
CREATE INDEX IF NOT EXISTS idx_entities_name_trgm ON entities USING GIN(normalized_name gin_trgm_ops);

-- =============================================================================
-- SEED DATA (Default admin user & org)
-- Password: admin123 (bcrypt hash, CHANGE IN PRODUCTION)
-- =============================================================================

INSERT INTO organizations (id, name, slug, plan)
VALUES ('00000000-0000-0000-0000-000000000001', 'SCIE Admin', 'scie-admin', 'enterprise')
ON CONFLICT DO NOTHING;

INSERT INTO users (id, organization_id, email, username, hashed_password, full_name, role, is_active, is_verified)
VALUES (
    '00000000-0000-0000-0000-000000000002',
    '00000000-0000-0000-0000-000000000001',
    'admin@scie.local',
    'admin',
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewjwC8qQ5Hv.QeGy', -- admin123
    'SCIE Administrator',
    'admin',
    TRUE,
    TRUE
)
ON CONFLICT DO NOTHING;

RAISE NOTICE 'SCIE database initialized successfully!';
