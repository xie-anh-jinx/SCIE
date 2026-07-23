pg_dump: warning: there are circular foreign-key constraints on this table:
pg_dump: detail: continuous_agg
pg_dump: hint: You might not be able to restore the dump without using --disable-triggers or temporarily dropping the constraints.
pg_dump: hint: Consider using a full dump instead of a --data-only dump to avoid this problem.
--
-- PostgreSQL database dump
--

\restrict idxD4CC0E91mnSN4mRkUC34mthLBc1IiY62HfNdwY0Z4bU0qzcCZiaGCJOoZ8g4

-- Dumped from database version 16.14
-- Dumped by pg_dump version 16.14

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: timescaledb; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS timescaledb WITH SCHEMA public;


--
-- Name: EXTENSION timescaledb; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION timescaledb IS 'Enables scalable inserts and complex queries for time-series data (Community Edition)';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: api_keys; Type: TABLE; Schema: public; Owner: scie
--

CREATE TABLE public.api_keys (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    organization_id uuid,
    name text NOT NULL,
    key_hash text NOT NULL,
    key_prefix text NOT NULL,
    permissions text[] DEFAULT ARRAY['read'::text] NOT NULL,
    last_used_at timestamp with time zone,
    expires_at timestamp with time zone,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.api_keys OWNER TO scie;

--
-- Name: data_sources; Type: TABLE; Schema: public; Owner: scie
--

CREATE TABLE public.data_sources (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    organization_id uuid,
    name text NOT NULL,
    platform text NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    keywords text[] DEFAULT '{}'::text[],
    is_active boolean DEFAULT true NOT NULL,
    last_run_at timestamp with time zone,
    posts_collected integer DEFAULT 0,
    status text DEFAULT 'idle'::text,
    error_message text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.data_sources OWNER TO scie;

--
-- Name: entities; Type: TABLE; Schema: public; Owner: scie
--

CREATE TABLE public.entities (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name text NOT NULL,
    normalized_name text NOT NULL,
    type text NOT NULL,
    aliases text[] DEFAULT '{}'::text[],
    description text,
    wikidata_id text,
    mention_count integer DEFAULT 0,
    sentiment_avg double precision DEFAULT 0.0,
    importance_score double precision DEFAULT 0.0,
    first_seen timestamp with time zone DEFAULT now() NOT NULL,
    last_seen timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.entities OWNER TO scie;

--
-- Name: entity_mentions_ts; Type: TABLE; Schema: public; Owner: scie
--

CREATE TABLE public.entity_mentions_ts (
    "time" timestamp with time zone NOT NULL,
    entity_id uuid NOT NULL,
    entity_name text NOT NULL,
    platform text,
    mention_count integer DEFAULT 0 NOT NULL,
    sentiment_avg double precision
);


ALTER TABLE public.entity_mentions_ts OWNER TO scie;

--
-- Name: hashtags; Type: TABLE; Schema: public; Owner: scie
--

CREATE TABLE public.hashtags (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    text text NOT NULL,
    platform text NOT NULL,
    post_count integer DEFAULT 0,
    trend_score double precision DEFAULT 0.0,
    first_seen timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.hashtags OWNER TO scie;

--
-- Name: organizations; Type: TABLE; Schema: public; Owner: scie
--

CREATE TABLE public.organizations (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name text NOT NULL,
    slug text NOT NULL,
    plan text DEFAULT 'free'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.organizations OWNER TO scie;

--
-- Name: platform_metrics; Type: TABLE; Schema: public; Owner: scie
--

CREATE TABLE public.platform_metrics (
    "time" timestamp with time zone NOT NULL,
    platform text NOT NULL,
    posts_count integer DEFAULT 0,
    unique_users integer DEFAULT 0,
    avg_engagement double precision DEFAULT 0
);


ALTER TABLE public.platform_metrics OWNER TO scie;

--
-- Name: post_entities; Type: TABLE; Schema: public; Owner: scie
--

CREATE TABLE public.post_entities (
    post_id uuid NOT NULL,
    entity_id uuid NOT NULL,
    confidence double precision DEFAULT 1.0 NOT NULL
);


ALTER TABLE public.post_entities OWNER TO scie;

--
-- Name: posts; Type: TABLE; Schema: public; Owner: scie
--

CREATE TABLE public.posts (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    platform text NOT NULL,
    platform_id text NOT NULL,
    type text DEFAULT 'post'::text NOT NULL,
    text text,
    text_cleaned text,
    language text,
    url text,
    author_id uuid,
    parent_post_id uuid,
    original_post_id uuid,
    "timestamp" timestamp with time zone,
    likes integer DEFAULT 0,
    comments integer DEFAULT 0,
    shares integer DEFAULT 0,
    views integer DEFAULT 0,
    bookmarks integer DEFAULT 0,
    sentiment_label text,
    sentiment_score double precision,
    emotions jsonb,
    topics text[],
    keywords text[],
    summary text,
    virality_score double precision DEFAULT 0.0,
    is_original boolean DEFAULT true,
    is_deleted boolean DEFAULT false,
    collected_at timestamp with time zone DEFAULT now() NOT NULL,
    processed_at timestamp with time zone
);


ALTER TABLE public.posts OWNER TO scie;

--
-- Name: refresh_tokens; Type: TABLE; Schema: public; Owner: scie
--

CREATE TABLE public.refresh_tokens (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    token_hash text NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    is_revoked boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_agent text,
    ip_address text
);


ALTER TABLE public.refresh_tokens OWNER TO scie;

--
-- Name: social_accounts; Type: TABLE; Schema: public; Owner: scie
--

CREATE TABLE public.social_accounts (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    platform text NOT NULL,
    platform_id text NOT NULL,
    username text,
    display_name text,
    bio text,
    follower_count integer DEFAULT 0,
    following_count integer DEFAULT 0,
    post_count integer DEFAULT 0,
    is_verified boolean DEFAULT false,
    profile_image text,
    location text,
    language text,
    account_age_days integer,
    bot_score double precision DEFAULT 0.0,
    influence_score double precision DEFAULT 0.0,
    community_id text,
    collected_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.social_accounts OWNER TO scie;

--
-- Name: topic_volume; Type: TABLE; Schema: public; Owner: scie
--

CREATE TABLE public.topic_volume (
    "time" timestamp with time zone NOT NULL,
    topic text NOT NULL,
    platform text,
    count integer DEFAULT 0 NOT NULL,
    sentiment_avg double precision,
    engagement_sum integer DEFAULT 0
);


ALTER TABLE public.topic_volume OWNER TO scie;

--
-- Name: users; Type: TABLE; Schema: public; Owner: scie
--

CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    organization_id uuid,
    email text NOT NULL,
    username text NOT NULL,
    hashed_password text NOT NULL,
    full_name text,
    role text DEFAULT 'analyst'::text NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    is_verified boolean DEFAULT false NOT NULL,
    last_login timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.users OWNER TO scie;

--
-- Data for Name: hypertable; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: scie
--

COPY _timescaledb_catalog.hypertable (id, schema_name, table_name, associated_schema_name, associated_table_prefix, num_dimensions, chunk_sizing_func_schema, chunk_sizing_func_name, chunk_target_size, compression_state, compressed_hypertable_id, status) FROM stdin;
1	public	topic_volume	_timescaledb_internal	_hyper_1	1	_timescaledb_functions	calculate_chunk_interval	0	0	\N	0
2	public	entity_mentions_ts	_timescaledb_internal	_hyper_2	1	_timescaledb_functions	calculate_chunk_interval	0	0	\N	0
3	public	platform_metrics	_timescaledb_internal	_hyper_3	1	_timescaledb_functions	calculate_chunk_interval	0	0	\N	0
\.


--
-- Data for Name: bgw_job; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: scie
--

COPY _timescaledb_catalog.bgw_job (id, application_name, schedule_interval, max_runtime, max_retries, retry_period, proc_schema, proc_name, owner, scheduled, fixed_schedule, initial_start, hypertable_id, config, check_schema, check_name, timezone) FROM stdin;
\.


--
-- Data for Name: chunk; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: scie
--

COPY _timescaledb_catalog.chunk (id, hypertable_id, schema_name, table_name, compressed_chunk_id, status, osm_chunk, creation_time) FROM stdin;
\.


--
-- Data for Name: chunk_column_stats; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: scie
--

COPY _timescaledb_catalog.chunk_column_stats (id, hypertable_id, chunk_id, column_name, range_start, range_end, valid) FROM stdin;
\.


--
-- Data for Name: compression_chunk_size; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: scie
--

COPY _timescaledb_catalog.compression_chunk_size (chunk_id, compressed_chunk_id, uncompressed_heap_size, uncompressed_toast_size, uncompressed_index_size, compressed_heap_size, compressed_toast_size, compressed_index_size, numrows_pre_compression, numrows_post_compression, numrows_frozen_immediately) FROM stdin;
\.


--
-- Data for Name: compression_settings; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: scie
--

COPY _timescaledb_catalog.compression_settings (relid, compress_relid, segmentby, orderby, orderby_desc, orderby_nullsfirst, index) FROM stdin;
\.


--
-- Data for Name: continuous_agg; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: scie
--

COPY _timescaledb_catalog.continuous_agg (mat_hypertable_id, raw_hypertable_id, parent_mat_hypertable_id, user_view_schema, user_view_name, partial_view_schema, partial_view_name, direct_view_schema, direct_view_name, materialized_only, schema_change_timestamp) FROM stdin;
\.


--
-- Data for Name: continuous_aggs_bucket_function; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: scie
--

COPY _timescaledb_catalog.continuous_aggs_bucket_function (mat_hypertable_id, bucket_func, bucket_width, bucket_origin, bucket_offset, bucket_timezone, bucket_fixed_width) FROM stdin;
\.


--
-- Data for Name: continuous_aggs_hypertable_invalidation_log; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: scie
--

COPY _timescaledb_catalog.continuous_aggs_hypertable_invalidation_log (hypertable_id, lowest_modified_value, greatest_modified_value) FROM stdin;
\.


--
-- Data for Name: continuous_aggs_invalidation_threshold; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: scie
--

COPY _timescaledb_catalog.continuous_aggs_invalidation_threshold (hypertable_id, watermark) FROM stdin;
\.


--
-- Data for Name: continuous_aggs_jobs_refresh_ranges; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: scie
--

COPY _timescaledb_catalog.continuous_aggs_jobs_refresh_ranges (materialization_id, start_range, end_range, pid, job_id, created_at) FROM stdin;
\.


--
-- Data for Name: continuous_aggs_materialization_invalidation_log; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: scie
--

COPY _timescaledb_catalog.continuous_aggs_materialization_invalidation_log (materialization_id, lowest_modified_value, greatest_modified_value) FROM stdin;
\.


--
-- Data for Name: continuous_aggs_materialization_ranges; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: scie
--

COPY _timescaledb_catalog.continuous_aggs_materialization_ranges (materialization_id, lowest_modified_value, greatest_modified_value) FROM stdin;
\.


--
-- Data for Name: continuous_aggs_watermark; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: scie
--

COPY _timescaledb_catalog.continuous_aggs_watermark (mat_hypertable_id, watermark) FROM stdin;
\.


--
-- Data for Name: dimension; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: scie
--

COPY _timescaledb_catalog.dimension (id, hypertable_id, column_name, column_type, aligned, num_slices, partitioning_func_schema, partitioning_func, interval_length, compress_interval_length, integer_now_func_schema, integer_now_func) FROM stdin;
1	1	time	timestamp with time zone	t	\N	\N	\N	604800000000	\N	\N	\N
2	2	time	timestamp with time zone	t	\N	\N	\N	604800000000	\N	\N	\N
3	3	time	timestamp with time zone	t	\N	\N	\N	604800000000	\N	\N	\N
\.


--
-- Data for Name: dimension_slice; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: scie
--

COPY _timescaledb_catalog.dimension_slice (id, chunk_id, dimension_id, range_start, range_end) FROM stdin;
\.


--
-- Data for Name: metadata; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: scie
--

COPY _timescaledb_catalog.metadata (key, value, include_in_telemetry) FROM stdin;
install_timestamp	2026-07-21 17:23:11.804623+00	t
timescaledb_version	2.28.3	f
exported_uuid	128ba47f-5666-4f90-98ad-e88178fd4498	t
\.


--
-- Data for Name: tablespace; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: scie
--

COPY _timescaledb_catalog.tablespace (id, hypertable_id, tablespace_name) FROM stdin;
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: scie
--

COPY public.api_keys (id, user_id, organization_id, name, key_hash, key_prefix, permissions, last_used_at, expires_at, is_active, created_at) FROM stdin;
\.


--
-- Data for Name: data_sources; Type: TABLE DATA; Schema: public; Owner: scie
--

COPY public.data_sources (id, organization_id, name, platform, config, keywords, is_active, last_run_at, posts_collected, status, error_message, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: entities; Type: TABLE DATA; Schema: public; Owner: scie
--

COPY public.entities (id, name, normalized_name, type, aliases, description, wikidata_id, mention_count, sentiment_avg, importance_score, first_seen, last_seen) FROM stdin;
65dc9aeb-43db-4091-a75f-bfbaff054c25	Kemkomdigi	kemkomdigi	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.566978+00	2026-07-21 17:28:03.566978+00
1816a41a-7ad4-4c6e-a3bf-3b30ef4d74b7	Deklarasi Sekolah Cakap Digital	deklarasi sekolah cakap digital	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.566978+00	2026-07-21 17:28:03.566978+00
fd44c6d2-fd85-4d5b-8945-43b6c6b9e626	Tunas	tunas	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.566978+00	2026-07-21 17:28:03.566978+00
ca110117-61ea-47f6-8666-eaaf97cb4699	Kementerian Komunikasi	kementerian komunikasi	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.566978+00	2026-07-21 17:28:03.566978+00
021c86c3-bc27-4c23-82b1-6c4df90f8564	Direktorat Jenderal Pajak	direktorat jenderal pajak	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.600834+00	2026-07-21 17:28:03.600834+00
86966a67-2789-4864-be02-36f408d38452	Menkes	menkes	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.613319+00	2026-07-21 17:28:03.613319+00
f6df58af-7e07-498c-ab61-7c7e3f56982c	Rokok	rokok	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.613319+00	2026-07-21 17:28:03.613319+00
90d0bd5a-2a5e-4d15-bd3e-896b80e8ab24	Menteri Kesehatan	menteri kesehatan	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.613319+00	2026-07-21 17:28:03.613319+00
8a962e72-85c3-449a-af6b-f225cf6cea92	Budi Gunadi Sadikin	budi gunadi sadikin	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.613319+00	2026-07-21 17:28:03.613319+00
e2d121c3-41e3-4543-980b-d0c9b5d359f7	Quartararo	quartararo	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.623215+00	2026-07-21 17:28:03.623215+00
236b896a-cc1f-4d81-a362-fc25da1f806d	Honda	honda	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.623215+00	2026-07-21 17:28:03.623215+00
0575b7e0-eef3-44b5-a313-16afb274f5c2	Sebanyak	sebanyak	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.623215+00	2026-07-21 17:28:03.623215+00
d2e15344-2fab-40d8-a9ad-8fab98e71cd6	Fabio Quartararo	fabio quartararo	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.623215+00	2026-07-21 17:28:03.623215+00
64aff37c-7a61-45af-b2ad-e8ef6f13aad7	Yamaha	yamaha	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.623215+00	2026-07-21 17:28:03.623215+00
5058b7c9-eed8-4c84-9037-ea0a7b3fee8d	Indonesia	indonesia	LOCATION	{}	\N	\N	22	0	0	2026-07-21 17:28:03.658754+00	2026-07-21 17:28:05.352994+00
0811126e-4a83-463b-9ad8-aee293a868f6	Bea Cukai	bea cukai	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.634097+00	2026-07-21 17:28:03.634097+00
dea43b56-265a-45b4-94d9-fc464209863f	Menteri Keuangan	menteri keuangan	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:03.600834+00	2026-07-21 17:28:03.634097+00
8c7b1f38-547a-46dd-8fbe-23256df848e9	Menkeu	menkeu	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:03.600834+00	2026-07-21 17:28:03.634097+00
ce30c78c-0aef-403c-acef-f40a4bb9f44f	Purbaya Yudhi Sadewa	purbaya yudhi sadewa	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:03.600834+00	2026-07-21 17:28:03.634097+00
9b31aec6-6e84-45e9-a336-d2b8745e8444	Amazon	amazon	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.647233+00	2026-07-21 17:28:03.647233+00
c53ba588-4290-48d3-9ded-6f3d85a56ba3	Bahrain	bahrain	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.647233+00	2026-07-21 17:28:03.647233+00
a60d160d-fa9e-461f-bc10-0b1a5afa43d1	Korps Garda Revolusi Islam Iran	korps garda revolusi islam iran	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.647233+00	2026-07-21 17:28:03.647233+00
6a6a3711-49be-4487-ab36-73aac188d6cb	Anggota Unit Kerja Koordinasi	anggota unit kerja koordinasi	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.658754+00	2026-07-21 17:28:03.658754+00
cdd38ef6-9842-4bb2-bd01-31b376655b23	Tumbuh Kembang	tumbuh kembang	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.658754+00	2026-07-21 17:28:03.658754+00
e6c2374e-be6c-4a1c-9cd0-7e2df0abe817	Pediatri Sosial Ikatan Dokter Anak Indonesia Dr	pediatri sosial ikatan dokter anak indonesia dr	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.658754+00	2026-07-21 17:28:03.658754+00
139c5926-bb02-4853-b45b-504a08748ed8	Angga	angga	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.658754+00	2026-07-21 17:28:03.658754+00
12f417e2-c67a-488e-815c-f3d02c6ebb3e	Menteri Sekretaris Negara Prasetyo Hadi	menteri sekretaris negara prasetyo hadi	PERSON	{}	\N	\N	5	0	0	2026-07-21 17:28:03.708219+00	2026-07-21 17:28:05.236302+00
099b5f22-91f4-476d-81b2-e1886be22740	Menteri Luar Negeri Indonesia Sugiono	menteri luar negeri indonesia sugiono	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.671285+00	2026-07-21 17:28:03.671285+00
280d4762-3a74-4a48-8641-802559707521	Mendikdasmen	mendikdasmen	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.68165+00	2026-07-21 17:28:03.68165+00
dbd523fb-3091-41bf-a6a2-dea09a6ef5bd	Sekolah Nasional Terintegrasi	sekolah nasional terintegrasi	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.68165+00	2026-07-21 17:28:03.68165+00
30080684-c5ca-4e6e-ae7d-de57119664e6	Pegawai	pegawai	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.68165+00	2026-07-21 17:28:03.68165+00
4dd9e7a2-68f4-4753-aeec-0b8051da55ea	Menteri Bahlil	menteri bahlil	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.694152+00	2026-07-21 17:28:03.694152+00
c072590a-feb0-47e3-9cc2-0d3eb009bd79	Impor	impor	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.694152+00	2026-07-21 17:28:03.694152+00
2a67e606-0b73-4be6-a733-65860271ce80	Menteri Energi	menteri energi	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:03.694152+00	2026-07-21 17:28:03.835245+00
0fd344f3-e4ef-4999-8447-4914e2347a7f	Bali	bali	LOCATION	{}	\N	\N	1	0	0	2026-07-21 17:28:03.719566+00	2026-07-21 17:28:03.719566+00
50dab869-88f5-4ff6-8616-d1f6ff8138fa	Pelabuhan Benoa Denpasar	pelabuhan benoa denpasar	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.719566+00	2026-07-21 17:28:03.719566+00
f93cf765-4def-4f1b-938f-dacb9e3190ba	Bali Maritime Tourism Hub	bali maritime tourism hub	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.719566+00	2026-07-21 17:28:03.719566+00
844ee4d7-dd41-47b8-873a-c8e72673b01e	Petugas	petugas	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.719566+00	2026-07-21 17:28:03.719566+00
d31a9aab-7a8d-4b38-a7e0-110993c5dc5f	Zona Marina	zona marina	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.719566+00	2026-07-21 17:28:03.719566+00
bfb722d0-dc9f-4faa-ab7b-36cdcfc815cc	Purbaya	purbaya	PERSON	{}	\N	\N	3	0	0	2026-07-21 17:28:03.600834+00	2026-07-21 17:28:03.733618+00
15dc913f-acd0-4b9d-a97e-a9c2e166f9ee	Rusia	rusia	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:03.694152+00	2026-07-21 17:28:05.393795+00
3d981afd-f4ef-4993-9848-7750be8f060b	Direktorat Jenderal Bea	direktorat jenderal bea	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:03.634097+00	2026-07-21 17:28:05.33812+00
a9de2b08-ab41-42ac-98b3-6feb96904b94	Sumber Daya Mineral	sumber daya mineral	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:03.694152+00	2026-07-21 17:28:03.835245+00
0a8e02ce-1ec6-4845-ac5a-ab5ad15ec088	Kemendikdasmen	kemendikdasmen	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:03.68165+00	2026-07-21 17:28:03.848893+00
ba57ed58-a85b-44ee-b207-289e69d5e3db	Kementerian Pendidikan Dasar	kementerian pendidikan dasar	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:03.68165+00	2026-07-21 17:28:03.848893+00
d684b1f2-d1fa-4c64-9e0c-4600bf6edca0	Menengah	menengah	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:03.68165+00	2026-07-21 17:28:03.848893+00
db47edf1-2469-4789-aaaa-322a66bac854	Digital	digital	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:03.566978+00	2026-07-21 17:28:04.560193+00
23aa6f46-cea1-456e-a4e0-1300f4050a9d	Iran	iran	PERSON	{}	\N	\N	4	0	0	2026-07-21 17:28:03.647233+00	2026-07-21 17:28:04.951844+00
a4662cf8-feed-41e6-b2ec-752c6f12cc52	Cukai	cukai	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:03.634097+00	2026-07-21 17:28:05.33812+00
6c92d917-7c72-4626-acb3-d67467677e37	Pemerintah	pemerintah	ORG	{}	\N	\N	16	0	0	2026-07-21 17:28:03.694152+00	2026-07-21 17:28:05.384278+00
bfd3c51c-ebe8-4ff5-8273-a4ba6c31a291	Bahlil Lahadalia	bahlil lahadalia	PERSON	{}	\N	\N	3	0	0	2026-07-21 17:28:03.694152+00	2026-07-21 17:28:05.414144+00
a12adc89-3666-44f9-a34a-7a42e5bb774f	Panggah Susanto	Panggah Susanto	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:00.90827+00	2026-07-22 09:57:00.90827+00
2441f8f9-3069-4e47-8522-0ad283982361	Esports Nations Cup	Esports Nations Cup	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:00.935564+00	2026-07-22 09:57:00.935564+00
8803bc38-5804-4751-977a-c85ebe0e3e45	Permohonan	Permohonan	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:00.964066+00	2026-07-22 09:57:00.964066+00
718809a4-eb1b-40bd-8340-9f5bbb5a110f	Wakil Ketua Komisi	Wakil Ketua Komisi	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:00.90827+00	2026-07-22 09:57:01.153066+00
c4f40a10-0681-441c-a31f-710a7d075616	Denpasar	denpasar	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.719566+00	2026-07-21 17:28:03.719566+00
1e0cf877-24ef-49bf-917f-e6cf5b1eb1ef	Menteri Keuangan Purbaya Yudhi Sadewa	menteri keuangan purbaya yudhi sadewa	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.733618+00	2026-07-21 17:28:03.733618+00
9e508839-d535-4d81-b9c9-fcad681ec19b	Anggaran Pendapatan	anggaran pendapatan	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.733618+00	2026-07-21 17:28:03.733618+00
4d429b38-36fb-4bdc-85a8-cd6f2200aa4f	Belanja Negara	belanja negara	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.733618+00	2026-07-21 17:28:03.733618+00
ecbaa990-a22e-469b-b5a4-d4e2ecac71b4	Keppres	keppres	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.745068+00	2026-07-21 17:28:03.745068+00
83530e05-42e5-4690-802d-337b0040cf93	Jampidsus	jampidsus	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.745068+00	2026-07-21 17:28:03.745068+00
049aa081-08d8-4a44-b901-7eb974a51c42	Keputusan	keputusan	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.745068+00	2026-07-21 17:28:03.745068+00
c7e17785-42e3-4560-a3f9-4be0ae81dcd7	Rupiah	rupiah	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.758296+00	2026-07-21 17:28:03.758296+00
10ac1a5f-27eb-400a-abe1-eb98804dc3db	Nilai	nilai	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.758296+00	2026-07-21 17:28:03.758296+00
fa7b880e-9168-4322-af91-a682b2bd5625	Korban	korban	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.770875+00	2026-07-21 17:28:03.770875+00
e72f91a6-b9b6-411b-ba27-e7a9f7d9f326	Venezuela	venezuela	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.770875+00	2026-07-21 17:28:03.770875+00
69349297-4c03-46f4-b0a8-081ad2173966	Jumlah	jumlah	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.770875+00	2026-07-21 17:28:03.770875+00
6c2d3848-7681-42e0-bd7f-df2d27b331c9	Juni	juni	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:03.733618+00	2026-07-21 17:28:03.770875+00
256ece39-0a39-468c-a85e-025a18c8bd84	Perhimpunan Bangsa	perhimpunan bangsa	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.783429+00	2026-07-21 17:28:03.783429+00
cea109c7-6b38-4d54-afa5-87e450304235	Bangsa Asia Tenggara	bangsa asia tenggara	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.783429+00	2026-07-21 17:28:03.783429+00
39db5f41-80ad-45c4-bd76-6d27c14f10cc	Amerika Serikat	amerika serikat	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.783429+00	2026-07-21 17:28:03.783429+00
5412b7db-a6ac-46ad-8876-867010736a2e	Macet	macet	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.796102+00	2026-07-21 17:28:03.796102+00
89d546ba-4cfe-4bf7-97fe-8808b2fe0b31	Cakung	cakung	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.796102+00	2026-07-21 17:28:03.796102+00
066be5a6-3850-4e19-a7e4-471a1618291a	Cilincing	cilincing	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.796102+00	2026-07-21 17:28:03.796102+00
aa8fbc36-7447-41db-bfe7-2cc5adb4b47d	Satuan Lalu Lintas	satuan lalu lintas	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.796102+00	2026-07-21 17:28:03.796102+00
6c811845-1e51-4973-991c-4475d932ad15	Satlantas	satlantas	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.796102+00	2026-07-21 17:28:03.796102+00
304118f6-984d-45ce-8b34-e502a1912867	Polres Metro Jakarta Timur	polres metro jakarta timur	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.796102+00	2026-07-21 17:28:03.796102+00
e1b4a383-6c64-4737-beb9-2c33cd877bec	Jalan Raya	jalan raya	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.796102+00	2026-07-21 17:28:03.796102+00
3464567f-7f05-49f7-8e1d-511c2d88f645	Qatar	qatar	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.812185+00	2026-07-21 17:28:03.812185+00
3ce94ffd-a89d-493a-8119-e084d7adf80e	Mitra Dialog Sektoral	mitra dialog sektoral	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.812185+00	2026-07-21 17:28:03.812185+00
df83d680-dd29-4539-9a04-df0387a43fa0	MPR	mpr	ORG	{}	\N	\N	1	0	0	2026-07-21 17:28:03.82217+00	2026-07-21 17:28:03.82217+00
a9166bbc-0f9f-43c8-8cff-6c34521690ee	Waka	waka	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.82217+00	2026-07-21 17:28:03.82217+00
e0c90321-c539-4cc4-87a8-a1c9f4d61b38	Program Kompor Listrik Bergulir	program kompor listrik bergulir	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.82217+00	2026-07-21 17:28:03.82217+00
e6f021b8-3317-4e6e-a1f8-f5a1f0ef12c4	Eddy Soeparno	eddy soeparno	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.82217+00	2026-07-21 17:28:03.82217+00
50f82ba1-4c23-4a84-9544-0ac7e81c1ee5	Gubernur	gubernur	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.835245+00	2026-07-21 17:28:03.835245+00
01e537dd-e8a2-4f72-a557-deaf35f51017	Pengumuman	pengumuman	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.848893+00	2026-07-21 17:28:03.848893+00
cfa3cd20-feb1-4a5b-9868-672c5fe7f311	Sekolah Terintegrasi	sekolah terintegrasi	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.848893+00	2026-07-21 17:28:03.848893+00
fc00106c-bfa2-4c79-8f86-5f1674e36b93	Sistem Penerimaan Murid Baru	sistem penerimaan murid baru	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.848893+00	2026-07-21 17:28:03.848893+00
b61c27ec-3064-49c4-bffa-2d853f27cd46	Sekolah	sekolah	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.848893+00	2026-07-21 17:28:03.848893+00
e329b9be-d7d3-458a-b307-439e31944e9d	Presdir	presdir	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.86399+00	2026-07-21 17:28:03.86399+00
eda15bfd-c1c7-489a-8aed-a53246a0f5ea	Tokyo Mochamad Harun	tokyo mochamad harun	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.86399+00	2026-07-21 17:28:03.86399+00
204e0cb1-929f-4214-b2d7-c2b4138ee282	Presiden Direktur	presiden direktur	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.86399+00	2026-07-21 17:28:03.86399+00
e469179c-9eb5-4192-b951-86d8eeac6215	Energy Trading	energy trading	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.86399+00	2026-07-21 17:28:03.86399+00
9fcd519c-7709-4232-98df-195c30e5823a	Menkum	menkum	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.878239+00	2026-07-21 17:28:03.878239+00
f594f97d-20f3-412e-94b3-61ac1ba026bc	Menteri Hukum Supratman Andi Agtas	menteri hukum supratman andi agtas	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.878239+00	2026-07-21 17:28:03.878239+00
7f14b35e-12df-4208-8d30-81520619db03	Menko	menko	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.88671+00	2026-07-21 17:28:03.88671+00
24f23395-4a4d-4bd2-8a22-2f509262637b	Pelabuhan Benoa	pelabuhan benoa	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:03.719566+00	2026-07-21 17:28:03.88671+00
bbdae080-496b-4edc-a588-b21ae0bb297b	Menteri Koordinator	menteri koordinator	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.88671+00	2026-07-21 17:28:03.88671+00
3abfd186-6085-4561-b699-c7755e5da1f2	Bidang Infrastruktur	bidang infrastruktur	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.88671+00	2026-07-21 17:28:03.88671+00
e352793b-9899-4a7d-a34c-9a328d761246	Pembangunan Kewilayahan Agus Harimurti Yudhoyono	pembangunan kewilayahan agus harimurti yudhoyono	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.88671+00	2026-07-21 17:28:03.88671+00
478224de-ab9d-458b-8897-25274be440a9	Selasa	selasa	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:03.719566+00	2026-07-21 17:28:04.196624+00
26abcaef-40a5-4c91-829e-d1ea77e2173b	KPK	kpk	ORG	{}	\N	\N	9	0	0	2026-07-21 17:28:03.86399+00	2026-07-21 17:28:04.758026+00
5f5b34fb-e0a8-4638-a501-3be1a6dbd490	Wakil Ketua	wakil ketua	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:03.82217+00	2026-07-21 17:28:04.711531+00
32073514-4b3f-4afc-b983-961a8f69e54b	Jakarta	jakarta	LOCATION	{}	\N	\N	3	0	0	2026-07-21 17:28:03.796102+00	2026-07-21 17:28:04.576767+00
cf734115-2900-49a9-aa2a-63eea53d307e	Rabu	rabu	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:03.758296+00	2026-07-21 17:28:04.259317+00
68643498-919e-4289-998e-eb30dfd1db69	Bahlil	bahlil	PERSON	{}	\N	\N	3	0	0	2026-07-21 17:28:03.835245+00	2026-07-21 17:28:05.393795+00
3edcd83f-b67e-4c73-8bdd-287d9de3a565	Prabowo	prabowo	PERSON	{}	\N	\N	5	0	0	2026-07-21 17:28:03.745068+00	2026-07-21 17:28:04.271814+00
3fc773bb-5bdf-432c-8f37-b3b736e61343	Agustus	agustus	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:03.848893+00	2026-07-21 17:28:04.961828+00
4a74b104-854e-4fc8-902b-6e2bd6f68708	Menteri	menteri	PERSON	{}	\N	\N	4	0	0	2026-07-21 17:28:03.812185+00	2026-07-21 17:28:05.414144+00
c151b97c-81b7-4e50-aade-6167f9fdfbf9	Indonesia Center	Indonesia Center	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:00.911975+00	2026-07-22 09:57:00.911975+00
2425da54-fa6a-43c2-b92b-7046a6e37e5c	Jerman	jerman	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:03.812185+00	2026-07-21 17:28:05.299918+00
ab914b48-5808-4d93-81aa-bbd014c0bc7f	Presiden Prabowo Subianto	presiden prabowo subianto	PERSON	{}	\N	\N	7	0	0	2026-07-21 17:28:03.745068+00	2026-07-21 17:28:05.33812+00
05a520e2-cdb3-4b26-8195-ffde878858da	Sumatera	sumatera	LOCATION	{}	\N	\N	1	0	0	2026-07-21 17:28:03.898215+00	2026-07-21 17:28:03.898215+00
bbff82e6-f1ab-4231-adc6-2d4d44c7dbc2	BPK	bpk	ORG	{}	\N	\N	1	0	0	2026-07-21 17:28:03.898215+00	2026-07-21 17:28:03.898215+00
c561482e-c473-46e8-a1a2-563011a72f9a	Perwakilan Sumsel Rio Tirta	perwakilan sumsel rio tirta	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.898215+00	2026-07-21 17:28:03.898215+00
61bed073-43d2-4369-8ace-fbb81ac850fe	Kepala Badan Pemeriksa Keuangan	kepala badan pemeriksa keuangan	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.898215+00	2026-07-21 17:28:03.898215+00
ce117e57-3536-4985-8901-0673b0ce731c	Perwakilan Provinsi Sumatera Selatan	perwakilan provinsi sumatera selatan	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.898215+00	2026-07-21 17:28:03.898215+00
b8bffd1b-c337-40dd-9b85-ed28c6ec86e4	Organisasi Kesehatan Dunia	organisasi kesehatan dunia	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.913704+00	2026-07-21 17:28:03.913704+00
7145f0c0-5b72-421b-b204-0176f51abeb8	Mirae	mirae	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.925575+00	2026-07-21 17:28:03.925575+00
b8667cf7-ec4d-45ce-9527-43c781e6e523	Mirae Asset Sekuritas Indonesia	mirae asset sekuritas indonesia	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.925575+00	2026-07-21 17:28:03.925575+00
3e7ad485-539e-43a0-bb96-8a1ee7ab766f	Bupati Langkat	bupati langkat	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.939673+00	2026-07-21 17:28:03.939673+00
37913a33-1929-4470-83c1-b42d507455cc	Syah Afandin	syah afandin	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.939673+00	2026-07-21 17:28:03.939673+00
38df4cca-bd41-4201-b984-d7da151b8177	Kepala	kepala	PERSON	{}	\N	\N	3	0	0	2026-07-21 17:28:03.898215+00	2026-07-21 17:28:04.932232+00
38514ec2-5a2f-40d4-a278-396be2860a9a	Bupati	bupati	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.939673+00	2026-07-21 17:28:03.939673+00
96ff30da-d71f-47fd-b2bf-7fac16285e88	Kemenkes	kemenkes	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.955856+00	2026-07-21 17:28:03.955856+00
b935fa59-7146-4249-a36a-222e2c6b6ff1	Wakil Menteri Kesehatan	wakil menteri kesehatan	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.955856+00	2026-07-21 17:28:03.955856+00
6a2eb4fb-81a6-495f-a87a-e792aa95a512	Wamenkes	wamenkes	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.955856+00	2026-07-21 17:28:03.955856+00
52d03566-4eb7-497b-8615-91921b6f5282	Benjamin Paulus Octavianus	benjamin paulus octavianus	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.955856+00	2026-07-21 17:28:03.955856+00
afa2ca26-f690-43da-87bb-63ce8e3b547d	Berikut	berikut	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.972589+00	2026-07-21 17:28:03.972589+00
6c076a01-86e9-4e59-abeb-5f9c43de7a78	Ratu	ratu	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.972589+00	2026-07-21 17:28:03.972589+00
463dc75c-a9be-450f-971c-ae665bcf4ca5	Wiranto	wiranto	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.989084+00	2026-07-21 17:28:03.989084+00
8372d0d8-4977-484f-82e4-416397b77c0b	Rugaiya Usman	rugaiya usman	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.989084+00	2026-07-21 17:28:03.989084+00
51952cbd-3e71-4e7c-85ca-af31d46dbb2b	Keluarga	keluarga	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.989084+00	2026-07-21 17:28:03.989084+00
3b9ca4e8-1aa7-46d7-b9b3-b91242c80cf8	Jenderal	jenderal	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:03.989084+00	2026-07-21 17:28:03.989084+00
df485fe4-b609-4b42-a040-6fddffc58525	Raja Yordania Abdullah	raja yordania abdullah	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.010067+00	2026-07-21 17:28:04.010067+00
7aac42ae-2cf2-4283-92e1-0b471b7f62ba	Kilas	kilas	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.030904+00	2026-07-21 17:28:04.030904+00
4513e908-9130-4a34-9ff2-b593fdb41f21	Raja Yordania	raja yordania	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.030904+00	2026-07-21 17:28:04.030904+00
327930ac-63ee-4084-bdd4-c27bc6dbd07b	Raja Yordania Abdullah Bin Al	raja yordania abdullah bin al	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:04.010067+00	2026-07-21 17:28:04.030904+00
1267c2d4-f3bf-4749-a932-5a25c0ff26f2	Hussein	hussein	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:04.010067+00	2026-07-21 17:28:04.030904+00
de6d5fa1-064e-4603-9402-aa9fd6e4cd98	Abdullah	abdullah	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:04.010067+00	2026-07-21 17:28:04.030904+00
27e7911b-a769-4bf2-92b8-aaa726bf5985	Jumat	jumat	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:04.010067+00	2026-07-21 17:28:04.030904+00
aba9e3b5-805b-471a-ae01-52eb7ca86faf	Profil Sari Yuliati	profil sari yuliati	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.05164+00	2026-07-21 17:28:04.05164+00
2a2d7f61-a581-4275-8bf2-f818b930e604	Mukhtarudin	mukhtarudin	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.05164+00	2026-07-21 17:28:04.05164+00
b43d567c-e5f2-42a9-a928-e46fc4401956	Golkar	golkar	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.05164+00	2026-07-21 17:28:04.05164+00
3899dd7c-6415-4919-b6f0-7b47cf80912f	Nama Sari Yuliati	nama sari yuliati	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.05164+00	2026-07-21 17:28:04.05164+00
0fe06c28-9781-4da4-866f-3bea00f89d92	Sekretaris Fraksi Partai Golkar	sekretaris fraksi partai golkar	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.05164+00	2026-07-21 17:28:04.05164+00
05f6866f-75fb-4e33-a035-d5ed83111dde	Sosok Marsinah	sosok marsinah	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.068771+00	2026-07-21 17:28:04.068771+00
2769a749-8c60-456a-bd02-9e43661299d4	Setiap	setiap	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:04.116443+00	2026-07-21 17:28:04.484968+00
7a51e8c2-5d55-435b-8d21-ecf39565ad8a	Istana Negara Jakarta	istana negara jakarta	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.068771+00	2026-07-21 17:28:04.068771+00
c41c9c62-17fc-47f2-bfe4-0a59093773e2	Riwayat Mochtar Kusumaatmadja	riwayat mochtar kusumaatmadja	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.093672+00	2026-07-21 17:28:04.093672+00
810b327c-b98f-4978-b3e4-b0f66c9d4252	Profil	profil	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:03.989084+00	2026-07-21 17:28:04.116443+00
4a0ce989-e88c-4a29-bdc8-e01dd602ae3f	November	november	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.116443+00	2026-07-21 17:28:04.116443+00
1d04df8b-76ac-4417-90e6-63bd67b914a1	Hari Pahlawan	hari pahlawan	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:04.068771+00	2026-07-21 17:28:04.116443+00
b51c9b3b-9920-4476-9bd1-a9219b444c95	Sosok Zainal Abidin Syah	sosok zainal abidin syah	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.137821+00	2026-07-21 17:28:04.137821+00
79df5210-4eea-4a06-b119-825df06bd3b4	Irian Barat	irian barat	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.137821+00	2026-07-21 17:28:04.137821+00
a1c91273-eb68-4aa4-9deb-d92981eed11e	Komisi Pemberantasan Korupsi	komisi pemberantasan korupsi	PERSON	{}	\N	\N	8	0	0	2026-07-21 17:28:03.86399+00	2026-07-21 17:28:04.758026+00
369969f0-fc49-4b39-85d0-f38d81c4a4ce	Purn	purn	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:03.989084+00	2026-07-21 17:28:04.292945+00
85fc386d-30d0-4cd0-b7b6-be6cf475b727	Senin	senin	PERSON	{}	\N	\N	3	0	0	2026-07-21 17:28:03.972589+00	2026-07-21 17:28:04.430068+00
b379f5e1-b492-4126-a94d-287c2559fe16	Pengamat	Pengamat	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:00.840877+00	2026-07-22 09:57:00.911975+00
eaf8ef25-658d-4ac8-b56b-b379083894b0	Tuan Rondahaim Saragih	tuan rondahaim saragih	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.154095+00	2026-07-21 17:28:04.154095+00
0900114f-0f4b-47b9-8518-46479c126892	Napoleon	napoleon	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.154095+00	2026-07-21 17:28:04.154095+00
80549f6a-7e40-4bea-8fb5-14a63bd7b165	Presiden	presiden	PERSON	{}	\N	\N	5	0	0	2026-07-21 17:28:04.093672+00	2026-07-21 17:28:04.722992+00
f4ce35c2-ef7f-43e6-88d4-c2e795987a4c	Prabowo Subianto	prabowo subianto	PERSON	{}	\N	\N	5	0	0	2026-07-21 17:28:04.093672+00	2026-07-21 17:28:04.722992+00
23bc621a-45e8-468b-991f-00c76d46d0a6	Pahlawan Nasional	pahlawan nasional	PERSON	{}	\N	\N	3	0	0	2026-07-21 17:28:04.093672+00	2026-07-21 17:28:04.154095+00
d07b5fed-6cab-4b33-b0e9-1a6f786000d8	Hari	hari	PERSON	{}	\N	\N	3	0	0	2026-07-21 17:28:04.093672+00	2026-07-21 17:28:04.154095+00
558ccbdd-b6a2-4580-a60b-96b5ffdebb5e	DPR	dpr	ORG	{}	\N	\N	3	0	0	2026-07-21 17:28:04.05164+00	2026-07-21 17:28:04.664644+00
31288946-de59-4ac1-91bb-80f8a2729d1f	Direktur	Direktur	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:00.840877+00	2026-07-22 09:57:00.911975+00
dbb1f846-67b2-4db6-8da2-d710263c0b62	Indonesia Center Herry Gunawan	Indonesia Center Herry Gunawan	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:00.840877+00	2026-07-22 09:57:00.911975+00
64de06b9-6f8a-4059-824e-8a5c80c3f78e	Iran	Iran	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:00.958355+00	2026-07-22 09:57:00.958355+00
461a0156-54b0-40a2-9f53-312f413871c6	Batak	batak	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.154095+00	2026-07-21 17:28:04.154095+00
c57a2b37-7aaf-4804-9568-e5a3e52d5c38	Mengenal	mengenal	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.16872+00	2026-07-21 17:28:04.16872+00
eb0b65aa-c584-4613-98a8-8c47ac5596dc	Wakil Gubernur Riau	wakil gubernur riau	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.182669+00	2026-07-21 17:28:04.182669+00
267d04ec-e827-43cb-93bd-568683d339b2	Hariyanto	hariyanto	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.182669+00	2026-07-21 17:28:04.182669+00
cfb4c46c-eb98-4a53-840f-46316a79bd72	Nama Wakil Gubernur Riau Sofyan Franyata	nama wakil gubernur riau sofyan franyata	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.182669+00	2026-07-21 17:28:04.182669+00
756b0ef9-92cd-4afe-9ade-7451f412b2bd	Gubernur Riau Abdul Wahid	gubernur riau abdul wahid	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.182669+00	2026-07-21 17:28:04.182669+00
bd739677-8f19-4ca7-93f6-45005a898a82	Profil Dini Yuliani	profil dini yuliani	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.196624+00	2026-07-21 17:28:04.196624+00
0b1b4365-f000-466e-9fa7-42ff68be5bae	Bupati Purwakarta Om Zein	bupati purwakarta om zein	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.196624+00	2026-07-21 17:28:04.196624+00
8a241928-58eb-4a8f-8a5b-b1da8df95ed9	Dini Yuliani	dini yuliani	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.196624+00	2026-07-21 17:28:04.196624+00
cee6792e-f511-40a3-a012-167477c63013	Bupati Purwakarta Saepul Bahri	bupati purwakarta saepul bahri	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.196624+00	2026-07-21 17:28:04.196624+00
3a022a53-9861-4860-b54f-e934d16ced23	Om Zein	om zein	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.196624+00	2026-07-21 17:28:04.196624+00
ab69bb01-be83-4043-8fb1-d948388a1727	Donald Trump	donald trump	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.209056+00	2026-07-21 17:28:04.209056+00
7a487d8f-7892-4cbd-92d5-8a227a00a51b	Perdamaian Gaza	perdamaian gaza	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.209056+00	2026-07-21 17:28:04.209056+00
428e6f35-ac95-43bb-8532-43360cd8f1d7	Presiden Amerika Serikat Donald Trump	presiden amerika serikat donald trump	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.209056+00	2026-07-21 17:28:04.209056+00
3de4e4b9-1452-44f4-88e8-73d8e0064f63	Paruh Waktu	paruh waktu	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.219463+00	2026-07-21 17:28:04.219463+00
b793d20c-fb1e-4dbc-9877-8674b0bb07bf	Pegawai Negeri Sipil	pegawai negeri sipil	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.219463+00	2026-07-21 17:28:04.219463+00
48126b29-12aa-4940-8d04-dc671f1b3552	Ini Profil Astrid Widayani	ini profil astrid widayani	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.23138+00	2026-07-21 17:28:04.23138+00
9de74791-6e59-44a1-bfb0-18ff13f0b4bc	Wakil Wali Kota Solo	wakil wali kota solo	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.23138+00	2026-07-21 17:28:04.23138+00
9a2721f3-e168-44f9-9a54-5f478d2ad269	Ketua	ketua	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.23138+00	2026-07-21 17:28:04.23138+00
77187280-4b28-4865-aa9b-959643d06b18	Solo	solo	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.23138+00	2026-07-21 17:28:04.23138+00
f6fafd35-2b0c-4d0a-a4b3-881599280c49	Sosok Wakil Wali Kota Solo Astrid Widayani	sosok wakil wali kota solo astrid widayani	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.23138+00	2026-07-21 17:28:04.23138+00
72ff1a85-7e8f-4139-ae4a-56314178d106	Profil Dirgayuza	profil dirgayuza	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.247516+00	2026-07-21 17:28:04.247516+00
41c35b22-a174-4e72-be9e-eb394ae3a169	Komunikasi Analis Kebijakan	komunikasi analis kebijakan	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.247516+00	2026-07-21 17:28:04.247516+00
56eabf28-74a3-4749-b79f-5340beb02dd6	Untuk	untuk	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.247516+00	2026-07-21 17:28:04.247516+00
bf296d47-88d6-4f1a-927c-29057d789da5	Istana Kepresidenan	istana kepresidenan	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.247516+00	2026-07-21 17:28:04.247516+00
d7996878-6e0c-4ff8-a475-786268715ddf	Profil Agung Gumilar	profil agung gumilar	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.259317+00	2026-07-21 17:28:04.259317+00
906ce987-e7b0-49d3-9552-7d08244674af	Asisten	asisten	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:04.247516+00	2026-07-21 17:28:04.259317+00
069512b5-9c58-4e8d-9d55-9f10c633f69c	Analis Data Strategis	analis data strategis	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.259317+00	2026-07-21 17:28:04.259317+00
7fbdbadc-ec2b-4226-8839-87f469160b15	Agung Gumilar Saputra	agung gumilar saputra	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.259317+00	2026-07-21 17:28:04.259317+00
be2bfe79-9392-4746-94b3-a2478c480e82	Asisten Khusus Presiden Bidang Analisis Data Strategis	asisten khusus presiden bidang analisis data strategis	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.259317+00	2026-07-21 17:28:04.259317+00
3a80124b-0334-4dac-9f7b-ee541220175e	Dubes	dubes	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.271814+00	2026-07-21 17:28:04.271814+00
df52dd4b-4617-4f8c-be7c-9763ad0a4e78	Oktober	oktober	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.271814+00	2026-07-21 17:28:04.271814+00
8a152f14-0f83-4e78-90fe-8da981674e7e	Duta Besar	duta besar	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.271814+00	2026-07-21 17:28:04.271814+00
88788136-e99a-4196-80ba-d9387e5d266a	Luar Biasa	luar biasa	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.271814+00	2026-07-21 17:28:04.271814+00
b00877de-7e03-4147-8dea-3d71e0c01e30	Berkuasa Penuh	berkuasa penuh	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.271814+00	2026-07-21 17:28:04.271814+00
66fcdb92-83f9-4d19-9a30-fca9459cc991	Profil Akhmad Wiyagus	profil akhmad wiyagus	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.292945+00	2026-07-21 17:28:04.292945+00
90a2441b-1287-487a-8a35-5bcf672c6c96	Dari	dari	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.292945+00	2026-07-21 17:28:04.292945+00
86a71a5f-3083-461e-a7ca-cc2fe11222f5	Polri	polri	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.292945+00	2026-07-21 17:28:04.292945+00
641bda24-99c9-4b7d-a0df-faaef94932ad	Wamendagri	wamendagri	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.292945+00	2026-07-21 17:28:04.292945+00
baa946df-821d-451e-8984-b3f344265cd2	Komjen Polisi	komjen polisi	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.292945+00	2026-07-21 17:28:04.292945+00
051073ee-b768-4eda-909a-e78f1b24098c	Akhmad Wiyagus	akhmad wiyagus	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.292945+00	2026-07-21 17:28:04.292945+00
42e0f548-62ac-4eba-a3e4-869a5e2e462e	Wakil Menteri Dalam Negeri	wakil menteri dalam negeri	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.292945+00	2026-07-21 17:28:04.292945+00
155e3f95-1f0d-4f46-8035-3898ae2afa88	Kabinet Merah	kabinet merah	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.292945+00	2026-07-21 17:28:04.292945+00
0cc3bc34-a5e8-4af4-b441-15aff1d2887f	Apakah	apakah	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.309718+00	2026-07-21 17:28:04.309718+00
582dc0c3-d96d-43ba-9e00-5224d3fcb9e5	Klaim	klaim	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.309718+00	2026-07-21 17:28:04.309718+00
0eef5be7-8b2f-4130-9e9c-5cfa3fd611c6	Mata	mata	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.322986+00	2026-07-21 17:28:04.322986+00
e2d54c21-1f56-4729-b612-27c458f6c831	Jenis	jenis	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.33153+00	2026-07-21 17:28:04.33153+00
9b13c553-a10f-4bed-9885-93c63a8ea988	Selain	selain	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.33153+00	2026-07-21 17:28:04.33153+00
62308461-862c-4e6b-bfd3-e3e48afffb71	Ketahui	ketahui	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:04.219463+00	2026-07-21 17:28:04.34407+00
5d075a3d-50a7-4742-a28e-ab966e2aefe2	Ingin	ingin	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.356743+00	2026-07-21 17:28:04.356743+00
5d496e0a-737f-46ab-9672-388e18bdae7c	Selama	selama	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.356743+00	2026-07-21 17:28:04.356743+00
5dd8420e-14fb-44cf-9389-9fee6fbb72ca	Dalam	dalam	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:04.16872+00	2026-07-21 17:28:04.369788+00
6bf822a8-56e6-493a-907e-cc3cdcca7e3f	Investasi	investasi	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:04.34407+00	2026-07-21 17:28:04.410149+00
af5f9a8d-7f58-47ed-abc3-d3f0b149cb0f	Daftar	daftar	PERSON	{}	\N	\N	4	0	0	2026-07-21 17:28:04.271814+00	2026-07-21 17:28:04.732739+00
73f6a983-ef77-4992-87d3-878598b72275	Yordania	Yordania	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:00.958355+00	2026-07-22 09:57:00.958355+00
1c7df00d-a608-4928-99ed-4e899c8c758d	Segini	segini	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:04.182669+00	2026-07-21 17:28:04.758026+00
f185f02a-decd-477e-9e55-bab0864dcb81	Simak	simak	PERSON	{}	\N	\N	3	0	0	2026-07-21 17:28:04.356743+00	2026-07-21 17:28:05.168545+00
3d7b53de-7225-49f3-8593-59b64f9ba7d9	Sosok Brigitte Bardot	sosok brigitte bardot	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.369788+00	2026-07-21 17:28:04.369788+00
19991523-5d0a-426f-a49e-75755c84a1ff	Aktris	aktris	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.369788+00	2026-07-21 17:28:04.369788+00
8b5ec335-f0b7-42c3-be9e-352d54a2d6ac	Prancis	prancis	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.369788+00	2026-07-21 17:28:04.369788+00
a461bf6a-732d-4ed9-aeaf-afd3b0f070e0	Brigitte Bardot	brigitte bardot	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.369788+00	2026-07-21 17:28:04.369788+00
284b839a-b998-43e7-acc8-4ce25ff2dd9f	Minggu	minggu	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.369788+00	2026-07-21 17:28:04.369788+00
150e836d-8d36-45a4-ae41-ea3f61ebc3b7	Sering	sering	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.386833+00	2026-07-21 17:28:04.386833+00
80d5738c-a411-40fe-bde3-c97a87cebb41	Menjelang	menjelang	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:04.386833+00	2026-07-21 17:28:04.398461+00
e5f3e628-7b8f-4213-87b8-b8dc4450bbad	Bolehkah	bolehkah	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.420752+00	2026-07-21 17:28:04.420752+00
d9a37fed-0c73-406f-a32d-bf057e58c274	Kebijakan	kebijakan	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.420752+00	2026-07-21 17:28:04.420752+00
43bfe606-4876-49cf-b4dd-246552f911d4	Mengenal Bank Syariah Nasional	mengenal bank syariah nasional	ORG	{}	\N	\N	1	0	0	2026-07-21 17:28:04.430068+00	2026-07-21 17:28:04.430068+00
81c1f37f-ddeb-4e2c-971f-0a286c240eea	Bank Syariah Nasional	bank syariah nasional	ORG	{}	\N	\N	1	0	0	2026-07-21 17:28:04.430068+00	2026-07-21 17:28:04.430068+00
7f58de96-a52d-44f0-ac34-bfca2d81438b	Bank Tabungan	bank tabungan	ORG	{}	\N	\N	1	0	0	2026-07-21 17:28:04.430068+00	2026-07-21 17:28:04.430068+00
1de40127-3736-419a-a550-807dbda2af18	Bank Syariah	bank syariah	ORG	{}	\N	\N	1	0	0	2026-07-21 17:28:04.441672+00	2026-07-21 17:28:04.441672+00
33f5c00f-56cc-4f4d-985a-ca64910eb973	Pahami	pahami	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.441672+00	2026-07-21 17:28:04.441672+00
5d99f7dc-d43c-491f-8fa7-a4213d6750df	Bagi	bagi	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.441672+00	2026-07-21 17:28:04.441672+00
bef695a9-ffdc-45a1-9f1c-32b3ab320dc0	Muslim	muslim	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.441672+00	2026-07-21 17:28:04.441672+00
735d695e-1629-44e0-9f0e-029babe83292	Susunan	susunan	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.454033+00	2026-07-21 17:28:04.454033+00
d38e2b89-bd79-41e4-ad55-1cf397fcd7a0	Rapat Umum	rapat umum	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.454033+00	2026-07-21 17:28:04.454033+00
4eafa782-f00d-4e90-9f23-7feeb1e64973	Sumatra Nataru	sumatra nataru	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.467029+00	2026-07-21 17:28:04.467029+00
3db650f4-a352-4369-a102-ad4fd0c151eb	Menyambut	menyambut	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.467029+00	2026-07-21 17:28:04.467029+00
3b3b2270-251d-4828-b100-6aeee58ca063	Natal	natal	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.467029+00	2026-07-21 17:28:04.467029+00
048e004a-d6f4-41f4-8264-afafd57051e9	Tahun Baru	tahun baru	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:04.398461+00	2026-07-21 17:28:04.467029+00
4b1583b6-df64-4e6c-930d-56982a41a751	Nataru	nataru	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.467029+00	2026-07-21 17:28:04.467029+00
59b77a80-c4ac-44ad-ad77-399dbbbbe546	Jasa Marga	jasa marga	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.467029+00	2026-07-21 17:28:04.467029+00
feabbbf5-8233-47b1-ad6d-69997fad5eab	Namun	namun	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:04.356743+00	2026-07-21 17:28:04.643147+00
406b56db-63df-4aa0-b7bc-6d7b2f5ef1a8	Desember	desember	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:04.454033+00	2026-07-21 17:28:04.484968+00
b265bf3b-eba5-4ce7-95f9-8adf25fe14e3	Bank Rakyat Indonesia	bank rakyat indonesia	ORG	{}	\N	\N	2	0	0	2026-07-21 17:28:04.454033+00	2026-07-21 17:28:04.484968+00
e09acad6-5380-4ecc-b407-8c730f5c9c73	Bahrain	Bahrain	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:00.958355+00	2026-07-22 09:57:00.958355+00
fb6c6e8a-d1f7-48fb-9d6a-c6d357c58da9	Spesifikasi	spesifikasi	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.498764+00	2026-07-21 17:28:04.498764+00
fc2facc3-332e-4f2b-b6b5-5cdd6d352483	Honda All New Vario	honda all new vario	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.498764+00	2026-07-21 17:28:04.498764+00
2825501b-5e9c-4f60-b5a2-3d7246cc2019	Shell Super	shell super	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.512422+00	2026-07-21 17:28:04.512422+00
31781bb8-d7d5-4ce6-901f-7d703d942b84	Power	power	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.512422+00	2026-07-21 17:28:04.512422+00
f45b5916-050b-4d23-945e-fbeca816ac53	Memilih	memilih	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.512422+00	2026-07-21 17:28:04.512422+00
0f9c802d-c948-4fad-82d5-96ea4d76d4c7	Panduan	panduan	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.523673+00	2026-07-21 17:28:04.523673+00
bb641656-b84b-4d26-a5e9-e4531699f39d	Shell	shell	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.523673+00	2026-07-21 17:28:04.523673+00
67504186-d123-48cd-a5f0-2199a7506bfc	Mengenali	mengenali	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.523673+00	2026-07-21 17:28:04.523673+00
5f01a05f-f219-4870-9f41-18bfef22b3c8	Shell Indonesia	shell indonesia	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.523673+00	2026-07-21 17:28:04.523673+00
d1a5fcfd-e336-4763-93c1-f0e763ddf4c1	Sejarah	sejarah	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:04.484968+00	2026-07-21 17:28:04.537814+00
3956bb82-db01-4631-b430-759f70b04f5e	Sarang	sarang	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.537814+00	2026-07-21 17:28:04.537814+00
5f0f46ae-c941-44f4-8842-0060370e3cc8	Mengenal Bobibos	mengenal bobibos	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.549666+00	2026-07-21 17:28:04.549666+00
07a7e6f8-41e3-427f-b45b-0e0ef2966d41	Bobibos	bobibos	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.549666+00	2026-07-21 17:28:04.549666+00
84eb923b-ffaa-4ef6-ad6b-802a0d02eb2d	Belakangan	belakangan	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:04.410149+00	2026-07-21 17:28:04.749276+00
ab090156-be91-42f7-8639-45124d86d7c3	Pengendara	pengendara	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.560193+00	2026-07-21 17:28:04.560193+00
79c37a13-58ac-4b62-858e-999beef774d3	Cara	cara	PERSON	{}	\N	\N	3	0	0	2026-07-21 17:28:04.398461+00	2026-07-21 17:28:04.568205+00
e74eb241-a330-4668-9224-ebc505a549f3	Proses	proses	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.568205+00	2026-07-21 17:28:04.568205+00
6081f031-2aae-480d-98be-f27bc23cffa7	Profil Laras Faizati	profil laras faizati	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.576767+00	2026-07-21 17:28:04.576767+00
168ebd07-709e-405e-a6ca-325c0b9f28a8	Majelis Hakim Pengadilan Negeri Jakarta Selatan	majelis hakim pengadilan negeri jakarta selatan	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.576767+00	2026-07-21 17:28:04.576767+00
b6f03e95-cf9d-4cc3-bdf0-6f3bf871b7c2	Kamis	kamis	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.576767+00	2026-07-21 17:28:04.576767+00
4eb1e8af-2c5d-4452-9569-b8b7c1489a45	Laras	laras	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.576767+00	2026-07-21 17:28:04.576767+00
71ad75ba-9993-4055-8e69-e1d5458e05c2	Profil Yaqut Cholil Qoumas	profil yaqut cholil qoumas	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.587166+00	2026-07-21 17:28:04.587166+00
6a8a66f6-9d46-4d98-b4b3-a84c838b4794	Menag	menag	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.587166+00	2026-07-21 17:28:04.587166+00
64836c6a-25a6-46e0-8a6f-dad171af28a6	Menteri Agama	menteri agama	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.587166+00	2026-07-21 17:28:04.587166+00
2d7e5eae-0523-4934-b7ef-841669bf8030	Persero	persero	PERSON	{}	\N	\N	4	0	0	2026-07-21 17:28:04.454033+00	2026-07-21 17:28:05.005098+00
84f1af12-439e-4460-9a5c-209676893dbf	Pasukan Iran	Pasukan Iran	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:00.958355+00	2026-07-22 09:57:00.958355+00
22dbe249-1581-4635-9bfa-44b563f8394f	Sulawesi	Sulawesi	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:00.986213+00	2026-07-22 09:57:00.986213+00
1209e61b-3b29-44db-8452-df806ed799cb	Kementerian Energi	Kementerian Energi	ORG	{}	\N	\N	1	0	0	2026-07-22 09:57:00.986213+00	2026-07-22 09:57:00.986213+00
cdd9d7dc-fac6-4745-99a6-d47f8bfd23c3	Sumber Daya Mineral	Sumber Daya Mineral	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:00.986213+00	2026-07-22 09:57:00.986213+00
4d171862-ab71-49b1-810a-c6751f28c0f6	Green Smart Industrial Park	Green Smart Industrial Park	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.010732+00	2026-07-22 09:57:01.010732+00
e7973428-55f7-47e7-9fad-90b91099d1d3	Kementerian	Kementerian	ORG	{}	\N	\N	3	0	0	2026-07-22 09:57:00.986213+00	2026-07-22 10:19:04.440066+00
0efa3312-c5eb-4f1d-8713-481a15d0997a	Yaqut Cholil Qoumas	yaqut cholil qoumas	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.587166+00	2026-07-21 17:28:04.587166+00
0874b6c2-a2c9-44fe-a06c-dd789be5597b	Kemenham	kemenham	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.599484+00	2026-07-21 17:28:04.599484+00
6e924429-6d49-4a38-8461-f4d6fb456e30	Syarat	syarat	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.599484+00	2026-07-21 17:28:04.599484+00
9bf1f4ec-fd83-477f-9059-274191eb5fff	Kementerian Hak Asasi Manusia	kementerian hak asasi manusia	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.599484+00	2026-07-21 17:28:04.599484+00
96989d6a-7437-435d-bfac-536f3732ade5	Rincian	rincian	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.609908+00	2026-07-21 17:28:04.609908+00
96fa3cd4-2294-4885-843e-e5bb6f0ab05a	Bupati Bekasi Ade Kuswara Kunang	bupati bekasi ade kuswara kunang	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.609908+00	2026-07-21 17:28:04.609908+00
c6d7e8d8-6aa6-4993-bd61-8509ea8ec0cc	Profil Ade Kuswara Kunang	profil ade kuswara kunang	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.621512+00	2026-07-21 17:28:04.621512+00
efc31eca-1880-43ef-8d32-cfc4ca2af278	Bupati Bekasi	bupati bekasi	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.621512+00	2026-07-21 17:28:04.621512+00
fd680216-e39b-4244-93a4-9c07204324e3	Ade Kuswara Kunang	ade kuswara kunang	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.621512+00	2026-07-21 17:28:04.621512+00
8fbc81cf-d45a-4eba-a79f-ee2596a2ca09	Profil Komjen Suyudi Ario Seto	profil komjen suyudi ario seto	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.631754+00	2026-07-21 17:28:04.631754+00
5221955a-2e0c-4c0a-8fe3-dd19ca704c18	Interpol	interpol	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.631754+00	2026-07-21 17:28:04.631754+00
8a06debc-6425-4476-8c75-b4c0813c5dc8	Komjen Pol Suyudi Ario Seto	komjen pol suyudi ario seto	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.631754+00	2026-07-21 17:28:04.631754+00
becb92d8-ae7b-4c61-b2a7-d71be819352a	Kepala Badan Narkotika Nasional	kepala badan narkotika nasional	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.631754+00	2026-07-21 17:28:04.631754+00
f9013399-5141-45ae-9926-9002230dfb40	Eropa	eropa	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.643147+00	2026-07-21 17:28:04.643147+00
6331e9d1-8f8c-41c1-a94c-8514f705583c	Mengunjungi	mengunjungi	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.643147+00	2026-07-21 17:28:04.643147+00
b920d46d-b550-4662-b5f8-346818bad9ac	Schengen	schengen	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.643147+00	2026-07-21 17:28:04.643147+00
645a01f9-ab37-4393-b665-47dd0ef81257	Sosok Ira Puspadewi	sosok ira puspadewi	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.653802+00	2026-07-21 17:28:04.653802+00
73042626-b6b7-4932-84e1-a7bb59deb0df	Ira Puspadewi	ira puspadewi	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.653802+00	2026-07-21 17:28:04.653802+00
870cad4d-2de6-416b-a411-6f5ca2985dcc	Angkutan	angkutan	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.653802+00	2026-07-21 17:28:04.653802+00
a0410018-703c-4ea6-83ed-7e8f7deac190	Apa Itu	apa itu	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.664644+00	2026-07-21 17:28:04.664644+00
72d838f9-be77-440c-b604-0cb1c7ea661d	Dewan Perwakilan Rakyat Republik Indonesia	dewan perwakilan rakyat republik indonesia	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.664644+00	2026-07-21 17:28:04.664644+00
8bcae891-5e5c-4d89-88ce-b4c582b5ea41	Rancangan Kitab Undang	rancangan kitab undang	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.664644+00	2026-07-21 17:28:04.664644+00
4a3e3983-bf7d-4b6d-90d5-630faa6b8adc	Undang Hukum Acara Pidana	undang hukum acara pidana	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.664644+00	2026-07-21 17:28:04.664644+00
9ca2dc70-1867-42a0-be8e-517848c567af	Profil Arsul Sani	profil arsul sani	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.679677+00	2026-07-21 17:28:04.679677+00
f1e821ca-22e6-4e45-abfd-747d931334f7	Hakim Konstitusi	hakim konstitusi	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.679677+00	2026-07-21 17:28:04.679677+00
b3fa2981-154c-47b1-9d6a-bebb16cbf717	Arsul Sani	arsul sani	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.679677+00	2026-07-21 17:28:04.679677+00
79f133c3-33d5-4f1b-b0cb-c66e2b6bf5be	Januari	januari	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.679677+00	2026-07-21 17:28:04.679677+00
c273ffb6-852c-48b4-bf04-f7647f0e7f53	Hakim	hakim	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.679677+00	2026-07-21 17:28:04.679677+00
ed47c261-812c-4897-8cc4-3b0bc5d73173	Profil Hendra Kurniawan	profil hendra kurniawan	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.6914+00	2026-07-21 17:28:04.6914+00
ffa4b2f0-fd80-4dd8-a29f-75b353874ebe	Brigadir	brigadir	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.6914+00	2026-07-21 17:28:04.6914+00
69aa26bc-efc4-4de1-b868-8b7d804b0b45	Nama Brigjen Pol Hendra Kurniawan	nama brigjen pol hendra kurniawan	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.6914+00	2026-07-21 17:28:04.6914+00
2347300e-a095-47c1-b255-c0cb02bc58f1	Kepala Biro Pengamanan Internal	kepala biro pengamanan internal	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.6914+00	2026-07-21 17:28:04.6914+00
6ec427f1-c58e-4b3c-ab89-55935f06f024	Karopaminal	karopaminal	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.6914+00	2026-07-21 17:28:04.6914+00
1638fd44-9a64-4855-a7ac-7a44d1414566	Agus Pramono	agus pramono	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.701706+00	2026-07-21 17:28:04.701706+00
4368d120-4a3b-47e0-b20a-fd1a720bcb9b	Sekda Ponorogo	sekda ponorogo	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.701706+00	2026-07-21 17:28:04.701706+00
f60f9e5b-3038-4883-94be-c3c3db07555a	Sekretaris Daerah	sekretaris daerah	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.701706+00	2026-07-21 17:28:04.701706+00
5db022e6-f8ae-4d7c-b516-3076bb828d6c	Sekda	sekda	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.701706+00	2026-07-21 17:28:04.701706+00
b85d8a6f-2007-4c85-b79d-a961dde645dd	Ponorogo Agus Pramono	ponorogo agus pramono	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.701706+00	2026-07-21 17:28:04.701706+00
686b274d-a82a-4641-ad84-05070497a7bc	Profil Dwiarso Budi Santiarto	profil dwiarso budi santiarto	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.711531+00	2026-07-21 17:28:04.711531+00
692a60b2-27c4-42c1-bbba-c28976d81398	Bidang Non	bidang non	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.711531+00	2026-07-21 17:28:04.711531+00
046003b6-ebf9-4367-8186-6647b0acab4c	Yudisial	yudisial	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.711531+00	2026-07-21 17:28:04.711531+00
c6583016-f180-4a76-ad76-8f51a69ea895	Dwiarso Budi Santiarto	dwiarso budi santiarto	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.711531+00	2026-07-21 17:28:04.711531+00
81565283-4364-449d-8cfb-ad89a1de7075	Wakil Ketua Mahkamah Agung	wakil ketua mahkamah agung	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.711531+00	2026-07-21 17:28:04.711531+00
56698776-5e42-4453-bed2-25b6b9a18616	Bidang	bidang	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.711531+00	2026-07-21 17:28:04.711531+00
14f9b266-e290-4506-938b-65aa008d0742	Profil Jimly Asshiddiqie	profil jimly asshiddiqie	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.722992+00	2026-07-21 17:28:04.722992+00
621a2538-4ed5-4b65-b9b1-b452aa933254	Ketua Komite Reformasi Polri	ketua komite reformasi polri	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.722992+00	2026-07-21 17:28:04.722992+00
ba913a5a-ec58-45f6-968c-3a863db7f524	Istana Merdeka	istana merdeka	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.722992+00	2026-07-21 17:28:04.722992+00
9642041b-d3dc-4025-8bfa-f057748b1809	Komisi Percepatan Reformasi Polri	komisi percepatan reformasi polri	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:04.722992+00	2026-07-21 17:28:04.732739+00
af4372c5-e410-4b1b-9dbe-84fe54ef5d42	Komisi Percepatan	komisi percepatan	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.732739+00	2026-07-21 17:28:04.732739+00
89f27e8a-d9d4-4a84-81a4-514b251031ff	Profil Sugiri Sancoko	profil sugiri sancoko	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.740947+00	2026-07-21 17:28:04.740947+00
35f1f9ea-c37a-46f5-8842-7c623be3405d	Bupati Ponorogo	bupati ponorogo	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:04.740947+00	2026-07-21 17:28:04.758026+00
b2ed22c3-b6d1-4f7e-81d1-fb145a3f41de	Asia	asia	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.023482+00	2026-07-21 17:28:05.023482+00
f6185fb2-8aca-4474-aef2-f9819cb3c669	Presiden Prabowo	presiden prabowo	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:04.653802+00	2026-07-21 17:28:05.236302+00
5cee2d9a-fa5c-4025-9653-4dc568c7bced	Direktur Utama	direktur utama	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:04.653802+00	2026-07-21 17:28:05.361919+00
650cf68d-daa8-4e75-ba6a-d3639418493b	Lhokseumawe	Lhokseumawe	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:00.964066+00	2026-07-22 09:57:00.964066+00
ce5d06c8-0c46-4abd-aec0-c3a8b1540736	Mengenang Junko Furuta	mengenang junko furuta	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.749276+00	2026-07-21 17:28:04.749276+00
b5b50fb3-e3ee-4d56-b734-0687ad587e53	Jepang	jepang	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.749276+00	2026-07-21 17:28:04.749276+00
1ab9a7e7-77f6-49e8-9958-b6366f4399de	Jadi	jadi	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.749276+00	2026-07-21 17:28:04.749276+00
71829724-e357-4aa9-ab1c-165c864b9cb8	Junko Furuta	junko furuta	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.749276+00	2026-07-21 17:28:04.749276+00
1f834b12-739f-4a83-b7f1-01c4d3aa2a3b	Sugiri Sancoko	sugiri sancoko	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.758026+00	2026-07-21 17:28:04.758026+00
06cc425f-a3e7-417e-9915-80d84d5026c8	Bupati Ponorogo Sugiri Sancoko	bupati ponorogo sugiri sancoko	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.758026+00	2026-07-21 17:28:04.758026+00
a424c6e7-1e90-4ec7-9abf-40f15a7c256e	Survei Ungkap Fakta Baru	survei ungkap fakta baru	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.769563+00	2026-07-21 17:28:04.769563+00
ebd3fbc2-0b9b-4e97-91b5-c52f0c9202d8	Perang Iran Jadi	perang iran jadi	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.769563+00	2026-07-21 17:28:04.769563+00
2975c933-e7b4-4381-abb8-9dc9bb2f84e5	Gerbang Kehancuran	gerbang kehancuran	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.769563+00	2026-07-21 17:28:04.769563+00
fb52b62a-98d0-455e-9910-375f91050e47	Trump	trump	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.769563+00	2026-07-21 17:28:04.769563+00
54c133dd-04f4-4c84-8d69-a6ea9ed9984b	Perang Iran	perang iran	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.769563+00	2026-07-21 17:28:04.769563+00
a271089e-4675-4fca-b0fb-7c0c672b41e7	Potret Chaos Demonstan Vs Polisi Gegara Warga Tewas	potret chaos demonstan vs polisi gegara warga tewas	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.785628+00	2026-07-21 17:28:04.785628+00
8c0ab509-3b8d-4b07-a059-800253cdf68f	Tahanan	tahanan	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.785628+00	2026-07-21 17:28:04.785628+00
ce3832ca-f22f-4fee-9908-fdd1249d4110	Bentrokan	bentrokan	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.785628+00	2026-07-21 17:28:04.785628+00
756892e9-56d8-4941-9d1b-3ac0428eaa6f	Abderrahim Fakir	abderrahim fakir	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.785628+00	2026-07-21 17:28:04.785628+00
7e5a02a6-d301-444a-b7cd-086eea5024ae	Babinsa	babinsa	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.794711+00	2026-07-21 17:28:04.794711+00
162e2383-d588-46b1-8613-4852b1a3a1bb	Bhabinkamtibmas Tarik Pajak	bhabinkamtibmas tarik pajak	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.794711+00	2026-07-21 17:28:04.794711+00
49ba124e-76bf-4c3f-a765-46fc361721e7	Ini Kata Dirjen Pajak	ini kata dirjen pajak	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.794711+00	2026-07-21 17:28:04.794711+00
b1e6f2d7-4fa1-46e2-a06b-ab5ee835e883	Kantor Imigrasi Kelas	Kantor Imigrasi Kelas	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:00.964066+00	2026-07-22 09:57:00.964066+00
07f1943d-d395-4f11-82c7-9589c386d7ec	Semester	semester	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.805342+00	2026-07-21 17:28:04.805342+00
fc292730-a010-4741-bda6-26ccda1279e6	Defisit Rp	defisit rp	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.805342+00	2026-07-21 17:28:04.805342+00
01c4797a-4661-41c6-addb-ac87015bd797	Banjir Bandang Hancurkan Satu Kota	banjir bandang hancurkan satu kota	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.814782+00	2026-07-21 17:28:04.814782+00
191d6d36-e64a-4022-ab7a-a503cd4b9757	Tewas	tewas	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.814782+00	2026-07-21 17:28:04.814782+00
ceb23bae-808e-401c-8969-d424e499a29c	Orang Hilang	orang hilang	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.814782+00	2026-07-21 17:28:04.814782+00
a5225649-c4c6-4070-aa90-e20e66f05822	Banjir	banjir	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.814782+00	2026-07-21 17:28:04.814782+00
2ecbbcc4-4226-4c2e-8ebd-7b8c72ad26d1	Nuristan	nuristan	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.814782+00	2026-07-21 17:28:04.814782+00
9cfce0e7-e9cb-41a7-b7b9-716a036b746f	Afghanistan	afghanistan	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.814782+00	2026-07-21 17:28:04.814782+00
2c06fcbc-94f8-4223-91bc-670315590542	Kerusakan	kerusakan	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.814782+00	2026-07-21 17:28:04.814782+00
7cad4fac-3b3e-498e-83c5-6c48e1f7b9ec	Dana Rehab	dana rehab	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.824501+00	2026-07-21 17:28:04.824501+00
48a178c1-40c5-4db4-abda-5d47a65e36bc	Rekon Didistribusikan	rekon didistribusikan	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.824501+00	2026-07-21 17:28:04.824501+00
ef0747d0-eacb-433d-b0d3-4ba754912027	Ketua Satgas	ketua satgas	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.824501+00	2026-07-21 17:28:04.824501+00
0a9ea47d-fac9-4906-83dd-82135c4d5729	Tekankan Hal Ini	tekankan hal ini	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.824501+00	2026-07-21 17:28:04.824501+00
4ff11f0b-a83f-4b65-b943-cf96ff75d096	Mendagri Tito Karnavian	mendagri tito karnavian	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.824501+00	2026-07-21 17:28:04.824501+00
971ac464-b8cb-4e6d-a1f7-6f8a4d193749	Rehab	rehab	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.824501+00	2026-07-21 17:28:04.824501+00
5d9e7e29-6432-4fd3-8378-05549c2832c5	Rekon	rekon	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.824501+00	2026-07-21 17:28:04.824501+00
7b3d08b2-c5e5-48a5-bc90-a8b3ca173831	Sumatra	sumatra	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.824501+00	2026-07-21 17:28:04.824501+00
2654ee3d-5fcb-4dcf-a9e2-fa3271dd9873	Total	total	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.824501+00	2026-07-21 17:28:04.824501+00
211ff62e-e449-4ccd-a168-edf6deecd4f4	Video	video	PERSON	{}	\N	\N	7	0	0	2026-07-21 17:28:04.794711+00	2026-07-21 17:28:04.911477+00
be4b817d-48d6-4297-85da-828768b1ca60	Penerimaan Negara	penerimaan negara	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.836084+00	2026-07-21 17:28:04.836084+00
b49c0fc3-efaa-416e-bfa6-98170e6f2f4e	Batu Bara Melambat	batu bara melambat	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.836084+00	2026-07-21 17:28:04.836084+00
adbf29a5-3e86-4fb6-8974-1dbc780ca429	Triliun	triliun	PERSON	{}	\N	\N	3	0	0	2026-07-21 17:28:04.805342+00	2026-07-21 17:28:04.942801+00
3994b92c-9bdd-44c8-b4f9-ebbd40432805	Likuiditas Perbankan Jadi Sorotan	likuiditas perbankan jadi sorotan	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.84487+00	2026-07-21 17:28:04.84487+00
d58ec7e4-290a-441c-9f35-7c1ae7a1314b	Pemerintah Siapkan Strategi	pemerintah siapkan strategi	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.84487+00	2026-07-21 17:28:04.84487+00
f7ea7782-2908-4a16-b41d-a4000c65b580	Pemerintah Siapkan Strategi Baru	pemerintah siapkan strategi baru	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.84487+00	2026-07-21 17:28:04.84487+00
27d4628c-41bb-4470-b044-19ff549df4a1	Rezim Kian Otoriter	rezim kian otoriter	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.854545+00	2026-07-21 17:28:04.854545+00
c47e2762-a6b9-4e22-b4fd-46649e169e41	Hapuskan Pemilu Demi Cegah Oposisi Berkuasa	hapuskan pemilu demi cegah oposisi berkuasa	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.854545+00	2026-07-21 17:28:04.854545+00
d70cfec5-ad74-4b86-96b0-6ebba9fcec45	Presiden Nikaragua	presiden nikaragua	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.854545+00	2026-07-21 17:28:04.854545+00
8dfd7c9f-7fe3-4c2b-8d49-790a1daf856b	Daniel Ortega	daniel ortega	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.854545+00	2026-07-21 17:28:04.854545+00
5f362003-4402-4bb8-bccc-d7983dd1209c	Purbaya Umumkan Panda Bond Pertama	purbaya umumkan panda bond pertama	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.864732+00	2026-07-21 17:28:04.864732+00
0d4930b5-873b-4290-8360-2b818b6e573c	Terbit	terbit	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.864732+00	2026-07-21 17:28:04.864732+00
f8f1c1c2-4830-419e-a708-6f095c5f0f40	Juli	juli	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.864732+00	2026-07-21 17:28:04.864732+00
51233ed9-2fa7-4156-86fe-5292cf88fb7b	Zulhas Ungkap Program Besar Tidak Kalah	zulhas ungkap program besar tidak kalah	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.874889+00	2026-07-21 17:28:04.874889+00
ef14bb2c-3724-4101-bdf5-1b7d7c20178b	Kopdes Merah Putih	kopdes merah putih	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.874889+00	2026-07-21 17:28:04.874889+00
937af1ec-0e65-4864-859f-bb0a06e03c44	Capaian	Capaian	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:00.964066+00	2026-07-22 09:57:00.964066+00
b07e5f48-d428-475b-bfdb-cebacd046b7b	Aceh	Aceh	PERSON	{}	\N	\N	4	0	0	2026-07-22 09:57:00.964066+00	2026-07-22 10:19:05.201938+00
9d464a5c-9048-451f-82f5-f887c047766c	Kampung Budi Daya Tematik	kampung budi daya tematik	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.874889+00	2026-07-21 17:28:04.874889+00
335573d6-edf4-4874-8606-c8b67afdd1b0	Ancaman Karhutla Meningkat	ancaman karhutla meningkat	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.88854+00	2026-07-21 17:28:04.88854+00
c7682a94-42e3-4673-8076-cd87dc37c050	Perketat Pengawasan Gambut	perketat pengawasan gambut	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.88854+00	2026-07-21 17:28:04.88854+00
7887ff9b-3458-411e-bed2-50669c74ba95	Terowongan	terowongan	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.897693+00	2026-07-21 17:28:04.897693+00
60123098-7124-40cf-98b9-e4460af9c490	Meledak	meledak	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.897693+00	2026-07-21 17:28:04.897693+00
02ffac65-1dbf-4c14-a663-250a8cb01cde	Pekerja Tewas	pekerja tewas	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.897693+00	2026-07-21 17:28:04.897693+00
66995514-f6c9-40aa-8308-b88fb633b696	Belum Ditemukan	belum ditemukan	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.897693+00	2026-07-21 17:28:04.897693+00
17735cdb-b5b7-4f16-bc80-88b472371c7e	Ledakan	ledakan	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.897693+00	2026-07-21 17:28:04.897693+00
13f690a6-f962-4c1b-a43a-8a8934da7ece	Teesta Stage	teesta stage	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.897693+00	2026-07-21 17:28:04.897693+00
e0fbd542-e91b-4312-b3b0-fe07ddd991fb	Sikkim	sikkim	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.897693+00	2026-07-21 17:28:04.897693+00
f4bfbbd3-2227-421b-9242-4d172dd52cd9	India	india	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.897693+00	2026-07-21 17:28:04.897693+00
c5b43ab1-1346-4104-b315-af05cd4078cd	Perkuat	perkuat	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.911477+00	2026-07-21 17:28:04.911477+00
151f06ea-e053-49f2-aba2-554b41c693f5	Maritim	maritim	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.911477+00	2026-07-21 17:28:04.911477+00
f6f8b4d6-fab1-4448-b406-246dd18f100f	Resmikan Ocean Institute	resmikan ocean institute	ORG	{}	\N	\N	1	0	0	2026-07-21 17:28:04.911477+00	2026-07-21 17:28:04.911477+00
ccee56c2-0f6c-45e8-9ae1-ec027921fcdd	Anggaran	anggaran	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.922203+00	2026-07-21 17:28:04.922203+00
3afcb5fb-4e79-4772-b3c1-b4dce32e9f66	Dipangkas Jadi Rp	dipangkas jadi rp	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.922203+00	2026-07-21 17:28:04.922203+00
502ec378-b92f-403d-9d4e-f93697a84bb0	Ungkap Alasannya	ungkap alasannya	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.922203+00	2026-07-21 17:28:04.922203+00
dd45542f-0449-4517-a65d-71505d44ec91	Program	program	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.922203+00	2026-07-21 17:28:04.922203+00
2c587863-2d9c-42fa-988a-0a05e515b24c	Purbaya Soal Efisiensi Anggaran	purbaya soal efisiensi anggaran	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.932232+00	2026-07-21 17:28:04.932232+00
304ddfd3-e99a-443d-92ea-67c723654ee3	Tunggu Pertemuan	tunggu pertemuan	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.932232+00	2026-07-21 17:28:04.932232+00
5b0b515a-7ce8-4cfd-9aef-40fa335352eb	Begini Nasib Proyek Motor Listrik Mangkrak	begini nasib proyek motor listrik mangkrak	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.942801+00	2026-07-21 17:28:04.942801+00
de06259d-ffac-4205-804e-705fd464182b	Senilai Rp	senilai rp	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.942801+00	2026-07-21 17:28:04.942801+00
fd3e4b4d-3273-4db1-98aa-87dee648864a	Perang	perang	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.951844+00	2026-07-21 17:28:04.951844+00
c9b01714-32b8-42b8-87d8-850eff1c7dcf	Iran Makan Korban Lagi	iran makan korban lagi	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.951844+00	2026-07-21 17:28:04.951844+00
124a65d9-565b-4f38-9c6d-80022e2a9a55	Meledak Rp	meledak rp	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.951844+00	2026-07-21 17:28:04.951844+00
b6e42723-39e8-46b6-a27b-627add792dc3	Jawa	jawa	LOCATION	{}	\N	\N	1	0	0	2026-07-21 17:28:04.961828+00	2026-07-21 17:28:04.961828+00
2b7f9e2d-6cfb-4bcd-93fe-4d0bd0715dc7	Uji Coba Tabung	uji coba tabung	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.961828+00	2026-07-21 17:28:04.961828+00
b81b98e1-d820-4f1a-963e-de0dd2c58329	Jawa Barat Mulai Agustus	jawa barat mulai agustus	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.961828+00	2026-07-21 17:28:04.961828+00
e36c67ae-7870-4e7b-be62-b6e72c308bc2	Seperti	seperti	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.972437+00	2026-07-21 17:28:04.972437+00
7d96ee5e-0600-4adb-85b3-bc0f5e589f95	Negeri Arab Ini Juga Lagi Garap Proyek Gas Raksasa	negeri arab ini juga lagi garap proyek gas raksasa	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.972437+00	2026-07-21 17:28:04.972437+00
557916fa-de3c-478a-a11b-5c8b5868f531	Ladang Gas Umm Shaif	ladang gas umm shaif	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.972437+00	2026-07-21 17:28:04.972437+00
3869a277-36be-4396-b16f-4bf988145d9b	Punya	punya	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.982478+00	2026-07-21 17:28:04.982478+00
92b1503f-6e5f-45cb-9e59-70e0ab6cdf0d	Pejabat Baru	pejabat baru	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.982478+00	2026-07-21 17:28:04.982478+00
f37eb0b6-2953-405d-b52a-9a146e592cd4	Latar Belakang Dokter Sampai Jaksa	latar belakang dokter sampai jaksa	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.982478+00	2026-07-21 17:28:04.982478+00
6fd8b36a-27dc-4831-8881-a635196c1c20	Badan Gizi Nasional	badan gizi nasional	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:04.942801+00	2026-07-21 17:28:04.982478+00
d76257e1-3080-4e7d-bf5e-0de27ea4c167	Program Makan Bergizi Gratis	program makan bergizi gratis	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.982478+00	2026-07-21 17:28:04.982478+00
649162ae-678c-4f0b-8613-1a55f89fb8cc	Titah Prabowo	titah prabowo	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.993731+00	2026-07-21 17:28:04.993731+00
81bffd53-267d-4eb6-8cb9-a7292edc8ad3	Istana Pastikan Motor Listrik Nasional Segera Meluncur	istana pastikan motor listrik nasional segera meluncur	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:04.993731+00	2026-07-21 17:28:04.993731+00
b9061945-9f04-4754-87a7-2648c843dfea	Peran Pertamina Dukung Pembangunan Ekosistem	peran pertamina dukung pembangunan ekosistem	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.005098+00	2026-07-21 17:28:05.005098+00
12415c9c-a12d-484e-84e2-5fbbed97a88e	Baru Hidrogen	baru hidrogen	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.005098+00	2026-07-21 17:28:05.005098+00
96c4b9c7-fe43-4920-87fb-820a3f285cdd	Ternyata Produksi Ratusan Ton Pengganti Bensin	ternyata produksi ratusan ton pengganti bensin	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.014315+00	2026-07-21 17:28:05.014315+00
8540710c-8154-4e03-8b57-b5314a0dfc5d	Kerajaan	kerajaan	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.023482+00	2026-07-21 17:28:05.023482+00
eaa16a7c-5b9d-4c29-a557-0f9d54858bbf	Penipuan Online Gasak Duit Rp	penipuan online gasak duit rp	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.023482+00	2026-07-21 17:28:05.023482+00
c19e1875-a55d-445e-b16d-e2bf7a0176c5	Tersebar	tersebar	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.023482+00	2026-07-21 17:28:05.023482+00
694eaf33-d749-4fab-912b-4246c3705c93	Dekat	dekat	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.023482+00	2026-07-21 17:28:05.023482+00
e6152071-c21a-474f-9e91-3e49bd799bd2	Sindikat	sindikat	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.023482+00	2026-07-21 17:28:05.023482+00
1e9020f3-f32a-4b13-9b78-3c40913221d9	Harga	harga	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:04.951844+00	2026-07-21 17:28:05.049506+00
cb4cc129-d550-4650-bf6e-a26fbbc0d449	PLN	pln	ORG	{}	\N	\N	3	0	0	2026-07-21 17:28:05.014315+00	2026-07-21 17:28:05.361919+00
e3d60e42-3e37-4921-9e46-b390f2990864	Makan Bergizi Gratis	makan bergizi gratis	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:04.932232+00	2026-07-21 17:28:05.157287+00
71f798d9-e294-451a-a460-a37ace41767b	Begini	begini	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:04.942801+00	2026-07-21 17:28:05.3709+00
b9842aa9-e08c-4075-8422-bb1e99b5f479	Pertamina	pertamina	ORG	{}	\N	\N	2	0	0	2026-07-21 17:28:05.005098+00	2026-07-21 17:28:05.279918+00
da19d063-a17e-49a3-a2a8-ee181dfb4e0a	Pemerintah Indonesia	pemerintah indonesia	PERSON	{}	\N	\N	3	0	0	2026-07-21 17:28:04.993731+00	2026-07-21 17:28:05.310117+00
97426c6d-e544-4690-be0b-ac84ead24ce3	Menkeu Purbaya Yudhi Sadewa	menkeu purbaya yudhi sadewa	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:04.932232+00	2026-07-21 17:28:05.405043+00
74eb4832-98d6-4887-8fd5-6bfdb62a7000	Memperluas	Memperluas	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:00.995365+00	2026-07-22 09:57:00.995365+00
eb3ee4cc-284c-42e4-8c26-7f3d20fa2f3b	Pasifik	Pasifik	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:00.995365+00	2026-07-22 09:57:00.995365+00
ce25e25e-e5dd-403e-a2a8-4e3df56ef2df	Pasifik	pasifik	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.023482+00	2026-07-21 17:28:05.023482+00
929dd79d-667d-4811-b2e6-4ba157878d7f	Mereka	mereka	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.023482+00	2026-07-21 17:28:05.023482+00
a1372d4e-060b-48d2-89b7-205ff483b0bd	Penjualan Rumah Subsidi Turun	penjualan rumah subsidi turun	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.037576+00	2026-07-21 17:28:05.037576+00
43c54a33-463f-4a70-a603-cab3863d9705	Penyebabnya Banyak	penyebabnya banyak	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.037576+00	2026-07-21 17:28:05.037576+00
dd343fa6-a32c-4910-9491-add50bacc1a2	Termasuk	termasuk	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.037576+00	2026-07-21 17:28:05.037576+00
4ce50209-c994-422a-962e-cb99eb7f876c	Penurunan	penurunan	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.037576+00	2026-07-21 17:28:05.037576+00
575324ed-cda0-44bd-8052-c91e0abd491e	Sejumlah	sejumlah	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.037576+00	2026-07-21 17:28:05.037576+00
89143f7b-a653-4037-b092-e79b9285445b	Pertamax Cs Turun Bulan Depan	pertamax cs turun bulan depan	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.049506+00	2026-07-21 17:28:05.049506+00
e73c5e89-0d20-4790-81ec-cf04af7fdad2	Ini Kata	ini kata	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.049506+00	2026-07-21 17:28:05.049506+00
421c1246-73e7-4448-8f34-4e0f2302fe37	Pertamax	pertamax	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.049506+00	2026-07-21 17:28:05.049506+00
9aea0df9-211c-45fc-9883-27e5ace714eb	Ada Temuan Gas Jumbo	ada temuan gas jumbo	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.060559+00	2026-07-21 17:28:05.060559+00
ef19be3e-5020-43c2-a08a-cb96b5f794c1	Pemerintah Prioritaskan Manfaat	pemerintah prioritaskan manfaat	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.060559+00	2026-07-21 17:28:05.060559+00
6d61d768-ac0b-4f40-add0-8174852fde2a	Warga Aceh	warga aceh	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.060559+00	2026-07-21 17:28:05.060559+00
2d8b8d62-a92a-4fac-897c-ea6967d63376	China	china	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:05.110874+00	2026-07-21 17:28:05.405043+00
7e9b732d-14dc-41d3-b85f-b60a2517b3b4	South Andaman	south andaman	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.060559+00	2026-07-21 17:28:05.060559+00
6f0cdd1f-e366-4948-8895-f5dcefc6a0e5	Aceh	aceh	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.060559+00	2026-07-21 17:28:05.060559+00
9793bbf6-ef27-457c-bb37-49871cacad2c	Antara	antara	ORG	{}	\N	\N	1	0	0	2026-07-21 17:28:05.073019+00	2026-07-21 17:28:05.073019+00
541ea02b-bb01-4a6c-9f0a-3dcbd560e810	Mendag Bilang Harga Telur	mendag bilang harga telur	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.073019+00	2026-07-21 17:28:05.073019+00
b430b298-6dfd-4e34-b47d-f9e2f7e6468d	Daging Ayam Kondisi Ideal	daging ayam kondisi ideal	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.073019+00	2026-07-21 17:28:05.073019+00
3dc9332e-368a-4d4a-a073-55e4d00388b5	Ini Alasannya	ini alasannya	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.073019+00	2026-07-21 17:28:05.073019+00
90d6e70a-7c1a-413a-aa8a-3422ee74a4d8	Menteri Perdagangan Budi Santoso	menteri perdagangan budi santoso	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.073019+00	2026-07-21 17:28:05.073019+00
1e6ff109-3742-41af-83eb-69f8bb542274	Pintu Devisa Baru	pintu devisa baru	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.087699+00	2026-07-21 17:28:05.087699+00
fb44bfd5-18ff-4d8c-95f3-a4cdd183020f	Produk	produk	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.087699+00	2026-07-21 17:28:05.087699+00
6d55b3bd-48c1-4023-a77d-cf90e0ee310f	Masuk Lokasi Ini Kena Diskon Tarif	masuk lokasi ini kena diskon tarif	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.087699+00	2026-07-21 17:28:05.087699+00
9840d841-e2d7-4cd7-ae19-f9c9640304b1	Perjanjian Perdagangan Bebas	perjanjian perdagangan bebas	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.087699+00	2026-07-21 17:28:05.087699+00
c2fb79d6-3502-4a25-90e3-2024db384b78	Setoran Bea Cukai Tak Capai Target	setoran bea cukai tak capai target	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.10112+00	2026-07-21 17:28:05.10112+00
7789266f-b912-4bbf-a5c7-7bc99ccdea9b	Purbaya Ungkap Alasannya	purbaya ungkap alasannya	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.10112+00	2026-07-21 17:28:05.10112+00
db71d78e-5d37-4465-a7b0-5d3ec5072ae0	Tabung	tabung	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.110874+00	2026-07-21 17:28:05.110874+00
1413903d-ffb7-4bb3-b161-2054a613633c	Kg Lagi Uji Coba	kg lagi uji coba	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.110874+00	2026-07-21 17:28:05.110874+00
67126f4f-8d2e-4c09-adba-87f6a1b71645	Selanjutnya Diproduksi Pindad	selanjutnya diproduksi pindad	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.110874+00	2026-07-21 17:28:05.110874+00
d5d1c80c-73cd-4cfa-a055-303cd7666ecf	Kementerian	kementerian	PERSON	{}	\N	\N	4	0	0	2026-07-21 17:28:04.961828+00	2026-07-21 17:28:05.110874+00
492fb0f9-82ff-4792-b239-99868c66d7de	Bangkit Kencang	bangkit kencang	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.122386+00	2026-07-21 17:28:05.122386+00
e2b89007-77f9-46f4-8981-8819daa680b2	Asing Tinggalkan Korea Cs Borong Saham	asing tinggalkan korea cs borong saham	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.122386+00	2026-07-21 17:28:05.122386+00
37be1245-4b0c-4ad7-a129-4fe157b8f714	Mendadak Rilis Travel Warning Baru	mendadak rilis travel warning baru	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.132225+00	2026-07-21 17:28:05.132225+00
02721f19-7cba-4c43-b95f-e576243f453b	Ada Apa	ada apa	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.132225+00	2026-07-21 17:28:05.132225+00
800fc0b1-bcd7-44bc-813d-770ca206b76b	Timur Tengah	timur tengah	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.132225+00	2026-07-21 17:28:05.132225+00
2dd25d43-7bb2-4db6-920e-a3bd60b7f0f7	Bulog Mau Jual	bulog mau jual	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.142674+00	2026-07-21 17:28:05.142674+00
8f503379-4d07-4291-8f18-7008e1d27259	Juta Ton Beras	juta ton beras	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.142674+00	2026-07-21 17:28:05.142674+00
6460621b-9e42-45fa-96c4-c51c5a70f230	Premium	premium	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.142674+00	2026-07-21 17:28:05.142674+00
a61b4e4b-d7e4-46f9-a1af-cabe56fba56c	Akan Terjadi	akan terjadi	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.142674+00	2026-07-21 17:28:05.142674+00
68d71197-7154-474b-99c8-10e41545ca39	Perum Bulog	perum bulog	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.142674+00	2026-07-21 17:28:05.142674+00
70be2b0a-791b-4150-ba1c-4bfba7757901	Beras Kita	beras kita	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.142674+00	2026-07-21 17:28:05.142674+00
21116ee4-66fe-4cb7-8427-382380615a75	Mensesneg Benarkan Kemungkinan Anggaran	mensesneg benarkan kemungkinan anggaran	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.157287+00	2026-07-21 17:28:05.157287+00
67f27376-4bf0-4589-af3e-642d987da3a7	Diturunkan	diturunkan	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.157287+00	2026-07-21 17:28:05.157287+00
c04638ba-a8ed-4a90-b3f8-0ecabced258b	Menhub Beri Kabar Terbaru Soal	menhub beri kabar terbaru soal	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.168545+00	2026-07-21 17:28:05.168545+00
a9ea4bde-a7bc-4873-a7f8-e4d134fc4786	Green Line	green line	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.168545+00	2026-07-21 17:28:05.168545+00
e80178c7-1c38-464b-a07e-dc61c0d23af3	Menteri Perhubungan Dudy Purwagandhi	menteri perhubungan dudy purwagandhi	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.168545+00	2026-07-21 17:28:05.168545+00
23bdf964-a398-4e9b-a882-753c0624175b	Green Line Tanah Abang	green line tanah abang	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.168545+00	2026-07-21 17:28:05.168545+00
7bc197df-0146-4fe1-b686-079d514b7e4e	Rangkasbitung	rangkasbitung	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.168545+00	2026-07-21 17:28:05.168545+00
61e89692-6cec-49d6-91b6-a6de14efb923	Kapan	kapan	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.168545+00	2026-07-21 17:28:05.168545+00
bfb295c6-0d11-4aae-b3a1-446b44af7bdb	Mensesneg Jawab Rumor Prabowo Reshuffle Kabinet	mensesneg jawab rumor prabowo reshuffle kabinet	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.186352+00	2026-07-21 17:28:05.186352+00
9b63d400-f547-439e-9af2-a44c240f17e7	Belum	belum	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.186352+00	2026-07-21 17:28:05.186352+00
26f3a582-3094-4e50-b79a-3f67111e2264	Siapkan Kontrak Jangka Panjang	siapkan kontrak jangka panjang	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.198185+00	2026-07-21 17:28:05.198185+00
99e57cac-2f47-4468-968e-4d0a06fc9fbb	Chile	Chile	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:00.995365+00	2026-07-22 09:57:00.995365+00
707d6420-2b71-4056-a8d9-846a81148fe7	Studi	Studi	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.016204+00	2026-07-22 09:57:01.016204+00
05b94c81-73ce-4e4f-9339-33adf87f986b	Akselerasi Proyek	akselerasi proyek	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.198185+00	2026-07-21 17:28:05.198185+00
3a76270a-7a2b-4c3e-accc-5e740d38d5b2	Proyek Pengolahan Sampah	proyek pengolahan sampah	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.198185+00	2026-07-21 17:28:05.198185+00
eb66f3f9-ef5b-407a-a151-7eb6e8e9bd80	Energi Listrik	energi listrik	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.198185+00	2026-07-21 17:28:05.198185+00
e06e6751-3fec-471c-a630-9d848316adb6	Harga Daging Sapi Adem Ayem	harga daging sapi adem ayem	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.210691+00	2026-07-21 17:28:05.210691+00
c5f22990-acad-428a-9721-765c9eda5230	Mendag Tak Perlu Tambah Kuota Impor	mendag tak perlu tambah kuota impor	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.210691+00	2026-07-21 17:28:05.210691+00
60a1c7a3-8b1a-4e2a-8bcb-c16a4d2619bf	Mendag Budi Santoso	mendag budi santoso	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.210691+00	2026-07-21 17:28:05.210691+00
47582a4f-5784-4d23-9538-ed10d7d91248	Kuota	kuota	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.210691+00	2026-07-21 17:28:05.210691+00
318e21b5-3e59-403f-b1b0-3b215e38d7d7	Ibu Kota Argentina Rusuh	ibu kota argentina rusuh	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.220085+00	2026-07-21 17:28:05.220085+00
210f8426-e1e5-4d4e-9575-93c220f142eb	Ekspor Satu Pintu	ekspor satu pintu	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.220085+00	2026-07-21 17:28:05.220085+00
52759019-2c35-46c5-b484-06d679ac0294	Mulai	mulai	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.220085+00	2026-07-21 17:28:05.220085+00
5cd71f90-a210-4ee0-948b-f08bcb3a8be6	Mensesneg Ungkap Prabowo Segera Teken Keppres Jampidus Kejagung	mensesneg ungkap prabowo segera teken keppres jampidus kejagung	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.236302+00	2026-07-21 17:28:05.236302+00
0f0386c2-3211-4c43-858c-9c438dd721ce	Jaksa Agung Muda Pidana Khusus	jaksa agung muda pidana khusus	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.236302+00	2026-07-21 17:28:05.236302+00
275ceb75-28fa-41e1-97a8-872d66b5496f	UMKM	umkm	ORG	{}	\N	\N	1	0	0	2026-07-21 17:28:05.246177+00	2026-07-21 17:28:05.246177+00
551f3cd5-9ee2-4060-bd9d-a987cd16e5ec	Dari Jalan Berlumpur	dari jalan berlumpur	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.246177+00	2026-07-21 17:28:05.246177+00
06aa9a3a-2ac2-4cf1-8ea3-36a16541280a	Pelosok	pelosok	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.246177+00	2026-07-21 17:28:05.246177+00
edeeddc3-794a-4953-8277-103c0497bfe3	Mantri	mantri	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.246177+00	2026-07-21 17:28:05.246177+00
9302cae4-cd98-4e18-957b-520b6bd48499	Dorong Ekonomi Rakyat	dorong ekonomi rakyat	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.246177+00	2026-07-21 17:28:05.246177+00
288c2f64-86fd-43a5-a2ec-bc50b267b000	Rani	rani	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.246177+00	2026-07-21 17:28:05.246177+00
49d28f18-25bc-443d-963c-cc1df9932c37	Bandung	bandung	LOCATION	{}	\N	\N	1	0	0	2026-07-21 17:28:05.256301+00	2026-07-21 17:28:05.256301+00
ae5a966c-3664-4d11-bd18-be2b397e4b2f	Menhub	menhub	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.256301+00	2026-07-21 17:28:05.256301+00
48f2e038-3c5e-428d-b235-f3300906ab3a	Bandara Husein	bandara husein	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.256301+00	2026-07-21 17:28:05.256301+00
7ee275a7-9e46-48b7-88d0-ad3238725250	Rute Domestik	rute domestik	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.256301+00	2026-07-21 17:28:05.256301+00
0e7ebb43-330d-4484-80aa-198b5ba10444	Internasional	internasional	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.256301+00	2026-07-21 17:28:05.256301+00
ccf0166c-a036-4a77-aaac-46766005c5db	Kertajati	kertajati	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.256301+00	2026-07-21 17:28:05.256301+00
c1e6a8cf-be73-4c3c-8529-7f698f191863	Menhub Dudy Purwagandhi	menhub dudy purwagandhi	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.256301+00	2026-07-21 17:28:05.256301+00
fe1493e3-c873-422a-b6f6-00cf217cdff2	Bandara Husein Sastranegara	bandara husein sastranegara	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.256301+00	2026-07-21 17:28:05.256301+00
8fab309f-959e-488f-804e-57835454c4c3	September	september	PERSON	{}	\N	\N	2	0	0	2026-07-21 17:28:05.220085+00	2026-07-21 17:28:05.256301+00
3494fff4-72db-4062-84c5-d630429a6044	Putuskan	putuskan	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.267867+00	2026-07-21 17:28:05.267867+00
8c78574e-075f-43e5-8f86-005d3347285a	Ormas Tak Bisa Tunjuk Langsung	ormas tak bisa tunjuk langsung	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.267867+00	2026-07-21 17:28:05.267867+00
3d02c628-90b3-434d-96f8-9b1980ff2e41	Bahlil Siapkan Ini	bahlil siapkan ini	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.267867+00	2026-07-21 17:28:05.267867+00
0744ad33-1caa-4bee-938a-2a2bb91d9228	Ormas	ormas	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.267867+00	2026-07-21 17:28:05.267867+00
290a49f2-e64b-408c-83f5-de14f21c7009	Pertamina Optimalkan Potensi	pertamina optimalkan potensi	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.279918+00	2026-07-21 17:28:05.279918+00
756ccd5f-37b1-4b25-88e9-92b9429ff49d	Limbah Sawit	limbah sawit	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.279918+00	2026-07-21 17:28:05.279918+00
ec53c620-eb43-4436-8978-560d139ff8c1	Substitusi Impor	substitusi impor	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.279918+00	2026-07-21 17:28:05.279918+00
7b853fe8-38f5-46b0-a355-a70205a53c6a	Fokus	fokus	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.279918+00	2026-07-21 17:28:05.279918+00
05b607fb-3c0b-4069-b275-f8d5c721cd15	Pakai Jurus Ini	pakai jurus ini	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.290665+00	2026-07-21 17:28:05.290665+00
93655a60-0328-4710-be6c-c687a8d32e44	Zulhas Targetkan Nelayan	zulhas targetkan nelayan	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.290665+00	2026-07-21 17:28:05.290665+00
9f4edcf4-1aa7-47d0-9f2c-a5445e2b576f	Sejahtera	sejahtera	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.290665+00	2026-07-21 17:28:05.290665+00
086255b7-588b-4434-bc06-fb76d6657a8e	Tahun Lagi	tahun lagi	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.290665+00	2026-07-21 17:28:05.290665+00
b9d5dcef-79b1-469a-a9b4-564b858e2fe4	Menkop Pangan Zulkifli Hasan	menkop pangan zulkifli hasan	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.290665+00	2026-07-21 17:28:05.290665+00
bcf140e0-bda5-431d-9fea-0bfdec55bb5b	Warga	warga	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.299918+00	2026-07-21 17:28:05.299918+00
9b4ac1cc-dc5c-42a1-8c04-cb0bc15e5348	Kabur	kabur	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.299918+00	2026-07-21 17:28:05.299918+00
4fd210a0-d18a-4246-b546-465394364ddf	Luar Negeri	luar negeri	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.299918+00	2026-07-21 17:28:05.299918+00
2fee5703-e89b-4199-a13a-98107e4d13ed	Setahun Terakhir	setahun terakhir	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.299918+00	2026-07-21 17:28:05.299918+00
5e355b28-a637-4688-ae34-f8b8cab4a964	Lebih	lebih	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.299918+00	2026-07-21 17:28:05.299918+00
2285b2c5-6375-4d1d-a801-fae79a853592	Bakal Kembangkan	bakal kembangkan	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.310117+00	2026-07-21 17:28:05.310117+00
b894f997-b817-49bc-9204-b76ca0a1bce8	Baru Lebih Bersih	baru lebih bersih	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.310117+00	2026-07-21 17:28:05.310117+00
b050a028-d193-4dae-98d2-dcaca77d996a	Asalnya Bisa	asalnya bisa	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.310117+00	2026-07-21 17:28:05.310117+00
f5d3f065-f179-49a3-af36-9223e28f6954	Geger Pria Gondol	geger pria gondol	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.320321+00	2026-07-21 17:28:05.320321+00
682d2164-68d3-4835-af1e-5ce24412ed65	Batang Emas Senilai Rp	batang emas senilai rp	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.320321+00	2026-07-21 17:28:05.320321+00
57077d77-d720-4643-9770-b724b86e2c9e	Miliar	miliar	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.320321+00	2026-07-21 17:28:05.320321+00
0bc22469-f985-41aa-a041-5fd410b2a21e	Seorang	seorang	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.320321+00	2026-07-21 17:28:05.320321+00
8272c3fb-06e6-4bba-9e39-d0fc4ffff734	Emas	emas	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.320321+00	2026-07-21 17:28:05.320321+00
268aeecd-b49b-48fb-8b09-834d3d6f1d80	Nyamuk Bikin Pening Satu Negara	nyamuk bikin pening satu negara	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.329335+00	2026-07-21 17:28:05.329335+00
a96a5112-f93c-4110-ba6b-08acb22a160a	Pemerintah Terjunkan Militer	pemerintah terjunkan militer	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.329335+00	2026-07-21 17:28:05.329335+00
bf98cf21-b52b-42f3-835c-1aebb1feb1c9	Karawang	Karawang	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.010732+00	2026-07-22 09:57:01.010732+00
4834af7e-3c9d-48f3-83c6-5d397704eb6d	Sri Lanka	sri lanka	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.329335+00	2026-07-21 17:28:05.329335+00
c9263d71-165a-4b33-8130-0a2868ef71df	Militer	militer	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.329335+00	2026-07-21 17:28:05.329335+00
296d8e9c-35ac-4ec1-b9a8-a06f617ed8b0	Bea Cukai Tak Jadi Dibubarkan Prabowo	bea cukai tak jadi dibubarkan prabowo	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.33812+00	2026-07-21 17:28:05.33812+00
c5589a5c-1403-4a82-98b9-49c3ea27e680	Sinergi Lintas Sektor Bangun Ekosistem Material Maju Indonesia	sinergi lintas sektor bangun ekosistem material maju indonesia	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.345862+00	2026-07-21 17:28:05.345862+00
1d32f0f0-215b-4ee6-9b13-2cba2554ef55	Beri Sinyal Keras	beri sinyal keras	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.352994+00	2026-07-21 17:28:05.352994+00
d2aabb81-9a29-4881-a6ab-9c58964ad0a5	Laut China Selatan	laut china selatan	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.352994+00	2026-07-21 17:28:05.352994+00
dd11fa9e-2afc-4a2f-9ab4-ac51df1c9d65	Sugiono Ungkap Hal Ini	sugiono ungkap hal ini	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.352994+00	2026-07-21 17:28:05.352994+00
9dc35227-d546-4c8d-ad21-733dc118a260	Code	code	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.352994+00	2026-07-21 17:28:05.352994+00
6a83ad69-4156-44ba-a12b-1ec57395beaa	Conduct Laut China Selatan	conduct laut china selatan	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.352994+00	2026-07-21 17:28:05.352994+00
a13feae4-3a6b-4070-b1c7-bd34f8412cc4	Ungkap Pasokan Batu Bara	ungkap pasokan batu bara	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.361919+00	2026-07-21 17:28:05.361919+00
2e7b0db6-3d04-4c1f-aed6-3b7d01e85f1e	Pembangkit Listrik Sudah Aman	pembangkit listrik sudah aman	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.361919+00	2026-07-21 17:28:05.361919+00
dff1257a-6709-4cde-80a3-89135f1adc37	Darmawan Prasodjo	darmawan prasodjo	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.361919+00	2026-07-21 17:28:05.361919+00
e11496cc-93dc-4ff1-989b-e6dace45d00e	Ramai	ramai	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.3709+00	2026-07-21 17:28:05.3709+00
cebc0823-fe33-4d99-b2f8-08b6f921e1e0	Ramai Nikah	ramai nikah	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.3709+00	2026-07-21 17:28:05.3709+00
95dd0e51-fb81-4c91-a3ab-4017b54a24d6	Efeknya Terasa Sampai	efeknya terasa sampai	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.3709+00	2026-07-21 17:28:05.3709+00
6e32652a-0270-4b87-87ed-23e80df2ba5c	Pengusaha	pengusaha	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.3709+00	2026-07-21 17:28:05.3709+00
cf0849e0-ad40-4185-889d-e2100d5b6f44	Tren Gen	tren gen	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.3709+00	2026-07-21 17:28:05.3709+00
115bb101-58a4-465b-ac22-86d5debd8f51	Mau Rilis	mau rilis	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.384278+00	2026-07-21 17:28:05.384278+00
db1cce18-b8fa-4663-9529-b0289d0a7b57	Pengusaha Penasaran Bentuk	pengusaha penasaran bentuk	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.384278+00	2026-07-21 17:28:05.384278+00
5bf3e49f-c35c-489e-b662-091bc01fe3f8	Produsen Motor Listrik Nasional	produsen motor listrik nasional	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.384278+00	2026-07-21 17:28:05.384278+00
66bf545d-3ec3-49b0-87fc-ed622e66f078	Asosiasi	asosiasi	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.384278+00	2026-07-21 17:28:05.384278+00
2f5fbc61-6c61-4f3b-bad9-d82c03188ade	Impor Minyak	impor minyak	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.393795+00	2026-07-21 17:28:05.393795+00
2663fe32-3c17-4469-b89e-748a026ed478	Rusia Tahap	rusia tahap	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.393795+00	2026-07-21 17:28:05.393795+00
50343521-dda5-470b-b6b2-f7f1f159e61b	Sudah Dieksekusi Via Lemigas	sudah dieksekusi via lemigas	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.393795+00	2026-07-21 17:28:05.393795+00
ef20d7bf-0a7f-4710-ad71-d79a50973882	Lemigas	lemigas	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.393795+00	2026-07-21 17:28:05.393795+00
e7eb9a18-b095-41f1-ae21-5a15e1019e4f	Purbaya Gerebek Perusahaan China	purbaya gerebek perusahaan china	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.405043+00	2026-07-21 17:28:05.405043+00
16f67b92-17ab-4a2c-a8d5-535b02214fcc	Potensi Pajak Terutang Bisa	potensi pajak terutang bisa	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.405043+00	2026-07-21 17:28:05.405043+00
7e6a5b6d-6e70-481b-ac22-dbd041ffa818	Investigasi	investigasi	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.405043+00	2026-07-21 17:28:05.405043+00
45d9a5e3-08c1-4091-94d6-d5c666f172e7	Bahlil Mulai Uji Coba Kendaraan	bahlil mulai uji coba kendaraan	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.414144+00	2026-07-21 17:28:05.414144+00
545faefb-367c-4233-a99a-c4ecfca58ec4	Ganda	ganda	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.414144+00	2026-07-21 17:28:05.414144+00
e537b761-db40-4085-965f-626ce20e638f	Solar	solar	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.414144+00	2026-07-21 17:28:05.414144+00
e1e42a62-9fbe-44f5-bd5b-05afab366d40	Hidrogen	hidrogen	PERSON	{}	\N	\N	1	0	0	2026-07-21 17:28:05.414144+00	2026-07-21 17:28:05.414144+00
412162b0-7aee-4cf3-a2d2-f5ae1c7298bd	September	September	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:00.696642+00	2026-07-22 09:57:00.696642+00
66223c0e-2bd3-4339-860c-f58e1ee4abfa	Ilustrasi	Ilustrasi	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:00.696642+00	2026-07-22 09:57:00.696642+00
883a3469-89b5-49b5-9e57-151146ea1642	Waskita	Waskita	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:00.840877+00	2026-07-22 09:57:00.840877+00
6c37a009-4ce9-48be-9bfb-689d596c110b	Jasa Marga	Jasa Marga	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:00.840877+00	2026-07-22 09:57:00.840877+00
2a1ff458-08e0-4de9-b00f-99f9da01b2ba	Waskita Karya	Waskita Karya	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:00.840877+00	2026-07-22 09:57:00.840877+00
17106bb2-1386-4036-89a7-e953d2b1236e	Jasa	Jasa	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:00.840877+00	2026-07-22 09:57:00.840877+00
88deb78e-2d25-49c6-aa7f-33b1d954f19e	Palestina	Palestina	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:00.696642+00	2026-07-22 09:57:01.102381+00
15e72c66-7b27-4562-a3df-69ca249113e7	Nadeo Argawinata	Nadeo Argawinata	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:00.84153+00	2026-07-22 09:57:00.84153+00
375cefe4-cf7d-469c-8e10-c4efd32e247e	Persija	Persija	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:00.84153+00	2026-07-22 09:57:00.84153+00
3159848b-19c3-4377-b5c7-acd9f5dfd226	Distribusi	Distribusi	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:00.88155+00	2026-07-22 09:57:00.88155+00
a2b42e67-8031-42fe-9dbc-49796d4780f7	Kiper	Kiper	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:00.84153+00	2026-07-22 09:57:00.84153+00
9e49e62f-db11-495e-aad5-e4c1405fd021	Relawan	Relawan	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:00.88155+00	2026-07-22 09:57:00.88155+00
f9f8ef4d-b08d-4176-88bd-fba9ccfd59bf	Madrasah Ibtidaiyah	Madrasah Ibtidaiyah	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:00.88155+00	2026-07-22 09:57:00.88155+00
7ef45d19-b6a2-4d64-8d85-b764f9b94b19	Indonesia Nadeo Argawinata	Indonesia Nadeo Argawinata	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:00.84153+00	2026-07-22 09:57:00.84153+00
c937c71e-5834-4014-8329-3313e0b4629a	Darul	Darul	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:00.88155+00	2026-07-22 09:57:00.88155+00
7851798b-14e4-4268-8ff4-553d20255e26	Persija Jakarta	Persija Jakarta	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:00.84153+00	2026-07-22 09:57:00.84153+00
a150ebd0-73fc-47dc-9377-3a140f1669df	Belanda	Belanda	PERSON	{}	\N	\N	3	0	0	2026-07-22 09:57:00.696642+00	2026-07-22 10:19:04.940223+00
e7bbabee-c80e-4d34-bd44-343bf907da8a	Jakarta	Jakarta	LOCATION	{}	\N	\N	34	0	0	2026-07-22 09:57:00.84153+00	2026-07-22 10:19:05.223568+00
1c40deea-fc7c-4b91-921d-f6d1f55e5be4	Israel	Israel	PERSON	{}	\N	\N	3	0	0	2026-07-22 09:57:00.696642+00	2026-07-22 10:19:04.38498+00
e31306d0-6ff7-42a4-8a7c-c214588940a4	Rabu	Rabu	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:00.84153+00	2026-07-22 09:57:02.342667+00
0903dbdc-ca32-4e15-ad2a-4506094b52b0	Perusahaan	Perusahaan	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.010732+00	2026-07-22 09:57:01.010732+00
f862abba-0a01-4768-803a-142b5cf1f015	Tiongkok	Tiongkok	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.010732+00	2026-07-22 09:57:01.010732+00
4c637cf0-5634-42b5-972e-09a94d312f80	Pemerintah Jepang	Pemerintah Jepang	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.038779+00	2026-07-22 09:57:01.038779+00
e8d85b08-708e-484c-b367-8a63f5642e59	Selasa	Selasa	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.038779+00	2026-07-22 09:57:01.038779+00
5a369aea-dd51-4a0e-a779-5fd60dfc1f5b	Bank Pembangunan	Bank Pembangunan	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.038779+00	2026-07-22 09:57:01.038779+00
75156203-afee-48c3-bc4d-4015d114659a	Glenmore	Glenmore	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.064393+00	2026-07-22 09:57:01.064393+00
907dbc5f-4397-4b61-a3d5-f34cb2199f14	Image	Image	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:00.986213+00	2026-07-22 09:57:01.064393+00
2116a1d3-3b6f-4388-b1ca-836f25ec8250	Wakil Direktur Utama	Wakil Direktur Utama	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.064393+00	2026-07-22 09:57:01.064393+00
84e641ec-6d03-4614-8b2e-ab6e68488d7f	Persero	Persero	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.064393+00	2026-07-22 09:57:01.064393+00
841f0b47-5497-42bb-afe0-480eb97431db	Oki Muraza	Oki Muraza	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.064393+00	2026-07-22 09:57:01.064393+00
cdcded4d-023b-46e8-8057-fa3514fcaf61	Satgas	Satgas	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.127348+00	2026-07-22 09:57:01.127348+00
df01860a-00eb-474e-a4dc-10f0dd4d892a	Menteri Dalam Negeri	Menteri Dalam Negeri	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.127348+00	2026-07-22 09:57:01.127348+00
d6a93522-fe1a-45e4-86b0-6099158e6975	Mendagri	Mendagri	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.127348+00	2026-07-22 09:57:01.127348+00
9e376d7d-e1a8-49bf-979a-999a43f084cc	Muhammad Tito Karnavian	Muhammad Tito Karnavian	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.127348+00	2026-07-22 09:57:01.127348+00
bc5a293b-cc32-45a0-913d-2f70c1e3c792	Ketua Satuan Tugas	Ketua Satuan Tugas	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.127348+00	2026-07-22 09:57:01.127348+00
bedb3200-0183-47a5-a69e-f86f765a86f1	Kasatgas	Kasatgas	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.127348+00	2026-07-22 09:57:01.127348+00
e83fa0af-6f5f-44ae-8435-349826f751a3	Percepatan Rehabilitasi	Percepatan Rehabilitasi	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.127348+00	2026-07-22 09:57:01.127348+00
54c2032d-36a4-4994-9756-9dd4e0133131	Pemprov	Pemprov	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.16703+00	2026-07-22 09:57:01.16703+00
445afc3d-2f8e-4ac5-b8af-ff017c9d49f2	Jakarta Pramono Anung Wibowo	Jakarta Pramono Anung Wibowo	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.16703+00	2026-07-22 09:57:01.16703+00
4c9eaef5-00b1-4c88-a9c4-77953f6a47fd	Pemerintah Provinsi	Pemerintah Provinsi	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.16703+00	2026-07-22 09:57:01.16703+00
a2486d9d-b843-4cf8-8ab2-e555e9a4e076	Danantara	Danantara	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:00.911975+00	2026-07-22 09:57:01.197196+00
e5998d6e-33c0-4b1f-af70-99c63c32240f	Komisi	Komisi	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.197196+00	2026-07-22 09:57:01.197196+00
62651660-d0f4-4108-a7f9-40f06e65b296	Detik	Detik	ORG	{}	\N	\N	119	0	0	2026-07-22 09:57:01.216417+00	2026-07-22 10:19:05.360947+00
725b8ee6-bdee-4269-b102-ed12468cf95c	Gubernur	Gubernur	PERSON	{}	\N	\N	4	0	0	2026-07-22 09:57:01.16703+00	2026-07-22 10:19:05.223568+00
2b0857d5-158c-454e-9841-3c7df4307f16	Menteri Dody Temukan Praktik Surat Cuti Bodong	Menteri Dody Temukan Praktik Surat Cuti Bodong	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.216417+00	2026-07-22 10:19:04.440066+00
16c76495-17e4-4b85-bdb7-d08553e852d0	Jalur Maut Terus Makan Korban	Jalur Maut Terus Makan Korban	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.427286+00	2026-07-22 10:19:04.313119+00
8cc569c1-2df8-40c7-bdff-ea3670f69223	Proses	Proses	PERSON	{}	\N	\N	4	0	0	2026-07-22 09:57:01.354435+00	2026-07-22 10:19:05.264287+00
29dd46f6-cc71-4025-a300-08029f9ded19	Video	Video	PERSON	{}	\N	\N	4	0	0	2026-07-22 09:57:01.393625+00	2026-07-22 10:19:05.179652+00
ed1a4829-c020-4d6d-8eb1-357054d8577c	Pertamina	Pertamina	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.064393+00	2026-07-22 10:19:04.227881+00
fd4424f0-43d3-44ad-86c5-cb59b6d4070c	Prabowo Lantik Gubernur	Prabowo Lantik Gubernur	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.393625+00	2026-07-22 10:19:04.688661+00
f0539735-737e-4d8e-a067-55311daa3085	Penumpang Kapal Tewas	Penumpang Kapal Tewas	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.427286+00	2026-07-22 10:19:04.313119+00
e0a31fb0-ab08-4304-bef7-05ad77fc2c13	Hilang	Hilang	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.427286+00	2026-07-22 10:19:04.313119+00
e5ee28fd-8301-4002-a21f-0f4099c0968e	Jepang	Jepang	PERSON	{}	\N	\N	3	0	0	2026-07-22 09:57:01.038779+00	2026-07-22 10:19:04.360311+00
e74c4a46-50c7-4da9-b970-085ddb3a019b	Saya Zero Tolerance Korupsi	Saya Zero Tolerance Korupsi	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.263175+00	2026-07-22 10:19:04.482333+00
4e078f87-73f4-4ffb-a15e-a2196aecefb2	Hengki Pengki	Hengki Pengki	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.263175+00	2026-07-22 10:19:04.482333+00
9d408259-8eec-4a70-8155-f9465820be93	Makan Bergizi Gratis	Makan Bergizi Gratis	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.263175+00	2026-07-22 10:19:04.482333+00
48fe5cdb-e490-44ee-a325-36d8510bf12c	Delegasi Malaysia Sempat Datangi Kantor Amran	Delegasi Malaysia Sempat Datangi Kantor Amran	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.298628+00	2026-07-22 10:19:04.542027+00
e41e910e-5b30-41f7-be40-d0371faba07f	Mohon	Mohon	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.298628+00	2026-07-22 10:19:04.542027+00
aa1a757d-901e-4d9d-8a28-5ba91623f9de	Kementan	Kementan	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.298628+00	2026-07-22 10:19:04.542027+00
7a70c1d4-c540-418a-bc23-c7b33e16d136	Lengkap	Lengkap	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.327993+00	2026-07-22 10:19:04.607351+00
0bc899fb-1741-41b9-8577-83a526c7c603	Begini Isi Keputusan	Begini Isi Keputusan	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.327993+00	2026-07-22 10:19:04.607351+00
6cfcde60-749d-48db-bd42-77dd55198f97	Tahan Suku Bunga	Tahan Suku Bunga	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.327993+00	2026-07-22 10:19:04.607351+00
19e6dafa-ec9e-482a-8ac9-51babcbd8869	Dewan Gubernur	Dewan Gubernur	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.327993+00	2026-07-22 10:19:04.607351+00
2c1b7ee6-ac53-4e68-befe-2d1dbeabea3d	Kebijakan	Kebijakan	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.327993+00	2026-07-22 10:19:04.607351+00
f9378e6a-0742-4edc-8aed-91a9292ff949	Ribuan	Ribuan	PERSON	{}	\N	\N	3	0	0	2026-07-22 09:57:01.354435+00	2026-07-22 10:19:04.647989+00
5718cf71-90b2-41c2-9666-0c99b50ea028	Judol Ratusan Juta Rupiah	Judol Ratusan Juta Rupiah	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.354435+00	2026-07-22 10:19:04.647989+00
34c6d59e-05bc-4e7c-8bda-0e78d4753998	Ini Sanksi	Ini Sanksi	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.354435+00	2026-07-22 10:19:04.647989+00
23575fd2-3793-4fb1-a702-653e3843d9c0	Menteri Dody	Menteri Dody	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.354435+00	2026-07-22 10:19:04.647989+00
10b79b39-be77-4ebb-8e9c-84dbfcc9fb7f	Wakil Gubernur Universitas	Wakil Gubernur Universitas	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.393625+00	2026-07-22 10:19:04.688661+00
aa0a949c-ee36-4b9e-873f-320395d02e07	Wakil Gubernur Universitas Republik Indonesia	Wakil Gubernur Universitas Republik Indonesia	PERSON	{}	\N	\N	3	0	0	2026-07-22 09:57:01.393625+00	2026-07-22 10:19:04.816632+00
388420fa-1386-4bb5-bc7b-772178c2c3de	Likes	Likes	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.016204+00	2026-07-22 09:57:01.016204+00
ea63e606-6971-438c-8ea2-618cbc92e1ac	Medsos	Medsos	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.016204+00	2026-07-22 09:57:01.016204+00
d6281f37-ae17-4d1c-987b-81621f7acd5a	Bakom	Bakom	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.040013+00	2026-07-22 09:57:01.040013+00
4f1b85a6-1a81-4f0f-bf03-f65f7f233bfa	Pengunduran	Pengunduran	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.040013+00	2026-07-22 09:57:01.040013+00
04bc91f4-35fb-43eb-a483-bd1d8166ceae	Badan Komunikasi Pemerintah Republik Indonesia	Badan Komunikasi Pemerintah Republik Indonesia	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.040013+00	2026-07-22 09:57:01.040013+00
85abde95-a592-4d6c-b641-8345e5afab12	Nanik Sudaryati	Nanik Sudaryati	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.040013+00	2026-07-22 09:57:01.040013+00
3fbc43ba-395c-46e8-81c5-0aef37046905	Presiden Prabowo Subianto	Presiden Prabowo Subianto	PERSON	{}	\N	\N	13	0	0	2026-07-22 09:57:01.189613+00	2026-07-22 10:19:05.253536+00
5cb9e995-c077-4083-b10d-b0f6fe44f193	Yusril	Yusril	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.102381+00	2026-07-22 09:57:01.102381+00
ad99bc8f-053c-4861-b961-6201775e1c48	Deportasi Abdul Karim	Deportasi Abdul Karim	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.102381+00	2026-07-22 09:57:01.102381+00
cdfaaa11-b7c4-4e4e-8ac7-08478a9956d7	Menteri Koordinator Bidang Hukum	Menteri Koordinator Bidang Hukum	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.102381+00	2026-07-22 09:57:01.102381+00
f21c4511-9cc6-4ddc-aa40-ab0844b0697d	Imigrasi	Imigrasi	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.102381+00	2026-07-22 09:57:01.102381+00
9f7230bf-0323-492d-9804-ef7c6c432e27	Pemasyarakatan Yusril Ihza Mahendra	Pemasyarakatan Yusril Ihza Mahendra	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.102381+00	2026-07-22 09:57:01.102381+00
ce12275f-9628-4a5a-9c97-42fecbbe7283	Sahroni	Sahroni	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.153066+00	2026-07-22 09:57:01.153066+00
42c81d60-33e8-4828-a6b1-0166fb66395d	Kitabisa	Kitabisa	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.153066+00	2026-07-22 09:57:01.153066+00
9d018ba6-d688-4a96-bdfb-87c20ebb023c	Ahmad Sahroni	Ahmad Sahroni	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.153066+00	2026-07-22 09:57:01.153066+00
1fd863f0-a5b6-4624-b63c-ceb8fd28d26d	Tentara Nasional Indonesia	Tentara Nasional Indonesia	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.153066+00	2026-07-22 09:57:01.153066+00
24e0bc9c-0b9d-482f-bdaf-cdc8bb0ff133	Profil Sudaryono	Profil Sudaryono	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.189613+00	2026-07-22 09:57:01.189613+00
ff740c00-83a0-4652-8192-f92f94a7e726	Wamentan	Wamentan	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.189613+00	2026-07-22 09:57:01.189613+00
ab601888-f8fe-4864-ba50-2866f68e25a8	Sudaryono	Sudaryono	PERSON	{}	\N	\N	12	0	0	2026-07-22 09:57:01.189613+00	2026-07-22 10:19:05.318078+00
cff464fd-8a8d-414a-9455-e0091f6b8cb1	Mantan Wakil Menteri Pertanian	Mantan Wakil Menteri Pertanian	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.189613+00	2026-07-22 09:57:01.189613+00
aa11631b-18e9-4787-9c15-f13bd811638a	Purbaya	Purbaya	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.338732+00	2026-07-22 09:57:01.338732+00
e2f5bdb9-d35e-4757-bd8d-1dd8f2ccae8b	Herdman	Herdman	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.213409+00	2026-07-22 09:57:01.213409+00
a2b7a513-b563-4331-a4ed-59ca8c98286c	Pemusatan	Pemusatan	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.213409+00	2026-07-22 09:57:01.213409+00
ab9eae29-6069-4822-9bac-6c7f9c4df82f	Latihan	Latihan	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.213409+00	2026-07-22 09:57:01.213409+00
742d9815-07fe-44e6-929a-93a2fe4b570a	Timnas	Timnas	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.213409+00	2026-07-22 09:57:01.213409+00
682e50cf-8e34-402d-9e01-7c652acf4d63	Pelatih	Pelatih	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.213409+00	2026-07-22 09:57:01.213409+00
0ed5132c-fb9e-460a-a711-417c2f03fc20	Indonesia John Herdman	Indonesia John Herdman	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.213409+00	2026-07-22 09:57:01.213409+00
926d2460-1704-46b5-8444-3ce411c114df	Pulau Sabalana	Pulau Sabalana	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.242094+00	2026-07-22 09:57:01.242094+00
1f6ede49-5ca1-4456-a394-ca265722d397	Basarnas	Basarnas	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.242094+00	2026-07-22 09:57:01.242094+00
884a248f-e47d-494c-b064-ad9a89011541	Kecamatan Liukang Tangaya	Kecamatan Liukang Tangaya	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.242094+00	2026-07-22 09:57:01.242094+00
f8b56d29-5566-49c4-ad1d-29e8f3a831b5	Kabupaten Pangkajene	Kabupaten Pangkajene	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.242094+00	2026-07-22 09:57:01.242094+00
85482cb0-89f9-4300-a021-0c05710e66b7	Menteri Keuangan Purbaya Yudhi Sadewa	Menteri Keuangan Purbaya Yudhi Sadewa	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.338732+00	2026-07-22 09:57:01.338732+00
33cf6286-e0c6-490a-8d0c-08a5ca335a1a	Orang	Orang	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.016204+00	2026-07-22 09:57:02.309132+00
a3358fb9-2ba2-4918-84d9-2a67c2ae2f80	Gus Yahya	Gus Yahya	PERSON	{}	\N	\N	3	0	0	2026-07-22 09:57:01.338732+00	2026-07-22 10:19:04.96969+00
098c269a-b995-4075-b0be-30e901e40e30	Ketua Umum Pengurus Besar Nahdlatul Ulana	Ketua Umum Pengurus Besar Nahdlatul Ulana	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.338732+00	2026-07-22 09:57:01.338732+00
21e8e508-6c40-41e9-bb16-72cd6d908964	Kemkomdigi	Kemkomdigi	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.267424+00	2026-07-22 09:57:01.267424+00
db8f862a-59b5-4a2d-9115-703ae7c6e345	Kementerian Komunikasi	Kementerian Komunikasi	ORG	{}	\N	\N	1	0	0	2026-07-22 09:57:01.267424+00	2026-07-22 09:57:01.267424+00
5eb69b8d-d194-4bf9-85b2-7d3398595169	Digital	Digital	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.267424+00	2026-07-22 09:57:01.267424+00
104df0f6-2478-4314-a41a-16baf4e604da	Badan Pengelola	Badan Pengelola	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.267424+00	2026-07-22 09:57:01.267424+00
90d640e1-4a68-4ce0-89ab-64d378b82b28	Wapres	Wapres	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.312812+00	2026-07-22 09:57:01.312812+00
ddd11ce1-efa1-4e5d-814f-49151d65c6f6	Pelantikan Kepala	Pelantikan Kepala	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.312812+00	2026-07-22 09:57:01.312812+00
81205c86-1715-4e76-abf1-47188ca93284	Wakil Presiden	Wakil Presiden	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.312812+00	2026-07-22 09:57:01.312812+00
02cc9baf-2397-45e5-a77f-66874f10988e	Gibran Rakabuming	Gibran Rakabuming	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.312812+00	2026-07-22 09:57:01.312812+00
f9c95857-681a-45ff-b5a1-bc3ba93bf784	Pimpinan	Pimpinan	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.361728+00	2026-07-22 09:57:01.361728+00
2fbe3be9-17a3-468b-9438-a1128bff8054	Pembenahan	Pembenahan	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.361728+00	2026-07-22 09:57:01.361728+00
c73ba4a3-5173-4311-a2c2-f3a88fb69a56	Wakil Ketua	Wakil Ketua	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.361728+00	2026-07-22 09:57:01.361728+00
0025fa41-6fd1-4d03-9cab-4440bcda8ea5	Eddy Soeparno	Eddy Soeparno	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.361728+00	2026-07-22 09:57:01.361728+00
cbb315c1-0589-4751-99d0-fc0a6e6214fa	Nurul Salsa	Nurul Salsa	PERSON	{}	\N	\N	10	0	0	2026-07-22 09:57:01.242094+00	2026-07-22 10:19:05.297215+00
ae44b2ea-af35-4cfe-97b5-8f466b271136	Kepala	Kepala	PERSON	{}	\N	\N	10	0	0	2026-07-22 09:57:01.189613+00	2026-07-22 10:19:04.863718+00
7a8567b7-930f-4355-895a-0ae84950d713	Polri	Polri	PERSON	{}	\N	\N	5	0	0	2026-07-22 09:57:01.153066+00	2026-07-22 10:19:05.081347+00
190f78d9-8787-40fc-af6e-d59e2c17c0e3	Presiden	Presiden	PERSON	{}	\N	\N	3	0	0	2026-07-22 09:57:01.153066+00	2026-07-22 10:19:05.235245+00
867eac22-d474-4f7c-a0da-8cab6a63a0bb	Prabowo Subianto	Prabowo Subianto	PERSON	{}	\N	\N	30	0	0	2026-07-22 09:57:01.189613+00	2026-07-22 10:19:05.253536+00
5d704653-b2a5-4382-9c72-a2f2f134cc8d	Jaktim	Jaktim	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.405193+00	2026-07-22 09:57:01.405193+00
9173467e-5686-4a30-8f4e-d4a4c4751a49	Sudaryono Merapat	Sudaryono Merapat	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.770573+00	2026-07-22 10:19:04.797755+00
ba5c9307-1efc-45b9-bf09-ef1493ebe947	Geger	Geger	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.454907+00	2026-07-22 10:19:04.38498+00
6ff32e17-8434-4dd9-b654-dc57700c2e3d	Danantara Serahkan Proyek Olah Sampah Jadi Listrik Tahap	Danantara Serahkan Proyek Olah Sampah Jadi Listrik Tahap	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.526352+00	2026-07-22 10:19:04.501273+00
1b58fefc-6d4c-4f03-9beb-55894597831a	Tahun	Tahun	PERSON	{}	\N	\N	6	0	0	2026-07-22 09:57:01.730603+00	2026-07-22 10:19:05.223568+00
85e4ddfd-22f8-4bc0-80a0-4089f4dcd104	Saya	Saya	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.491968+00	2026-07-22 10:19:04.458303+00
910b12a5-e937-42d6-9743-1a718f5a70fc	Pemerintah Kebut Ambil Alih Bandara Kertajati	Pemerintah Kebut Ambil Alih Bandara Kertajati	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.621489+00	2026-07-22 10:19:04.675889+00
c4e70a47-638b-4817-8421-2bdccc4b6af4	Jepang Catat	Jepang Catat	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.42483+00	2026-07-22 10:19:04.360311+00
8e4675d3-e884-4698-82f0-fdc81bb091dd	Mitra	Mitra	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.526352+00	2026-07-22 10:19:04.501273+00
0c43dfd2-9423-4bf6-b182-8a859175ef03	Hari Sangat Kejam	Hari Sangat Kejam	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.42483+00	2026-07-22 10:19:04.360311+00
8f51bdb2-2b50-4880-bfd6-4e48c4e03e7d	Suhu Mendidih	Suhu Mendidih	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.42483+00	2026-07-22 10:19:04.360311+00
5a087ff1-8d0f-4437-8f45-79d7cc891514	Kampung Israel	Kampung Israel	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.454907+00	2026-07-22 10:19:04.38498+00
f9799082-4ea5-4053-b5b8-170c54be4d74	Prabowo Lantik Sudaryono Jadi Kepala	Prabowo Lantik Sudaryono Jadi Kepala	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.559479+00	2026-07-22 10:19:04.590336+00
b70133ea-24cd-4ee0-ad93-f2f9f1370616	Anwar Ibrahim Mulai Bertindak	Anwar Ibrahim Mulai Bertindak	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.454907+00	2026-07-22 10:19:04.38498+00
d3599537-fbf7-47bf-843e-7ae51f92cef7	Pemerintah Malaysia	Pemerintah Malaysia	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.454907+00	2026-07-22 10:19:04.38498+00
8258964a-9859-40ab-869d-33f58074da54	Johor	Johor	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.454907+00	2026-07-22 10:19:04.38498+00
e2bbee38-04b4-4799-80d0-93a91fde918c	Keluarga Tak Punya Dapur	Keluarga Tak Punya Dapur	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.491968+00	2026-07-22 10:19:04.458303+00
8a77f02b-973b-4508-852b-231162a47675	Donny Ermawan Dilantik Sebagai Rektor Universitas Republik Indonesia	Donny Ermawan Dilantik Sebagai Rektor Universitas Republik Indonesia	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.591138+00	2026-07-22 10:19:04.625466+00
62a851ed-0a46-40ba-a2d4-8dc51f578856	Danantara Invesment Management	Danantara Invesment Management	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.526352+00	2026-07-22 10:19:04.501273+00
52ffcd85-f0fc-4faf-9d75-33500e197518	Conditional Letter	Conditional Letter	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.526352+00	2026-07-22 10:19:04.501273+00
e9b6740a-01d5-4ad3-8d3b-71b821d15195	Award	Award	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.526352+00	2026-07-22 10:19:04.501273+00
37b9c94a-b7bf-434c-b6ab-1191ec159f4d	Gubernur Universitas Republik Indonesia	Gubernur Universitas Republik Indonesia	PERSON	{}	\N	\N	4	0	0	2026-07-22 09:57:01.591138+00	2026-07-22 10:19:05.235245+00
bb47ed54-fabb-4d3a-b19f-df2e6e9a5312	Istana Negara	Istana Negara	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.559479+00	2026-07-22 10:19:04.590336+00
60071fb4-fdad-4f62-8ee1-3496d989770d	Nanik Sudaryati Deyang	Nanik Sudaryati Deyang	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.559479+00	2026-07-22 10:19:04.590336+00
bab3104a-c86b-421e-bb8f-770b5abe89a2	Donny Taufanto	Donny Taufanto	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.591138+00	2026-07-22 10:19:04.625466+00
8a41a579-7585-4a53-b93d-ac2df0ba50ac	Kepala Badan Gizi Nasional	Kepala Badan Gizi Nasional	PERSON	{}	\N	\N	7	0	0	2026-07-22 09:57:01.312812+00	2026-07-22 10:19:05.318078+00
48fd1240-bfa1-4953-856d-117af9d71c9e	Pemprov Jabar	Pemprov Jabar	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.621489+00	2026-07-22 10:19:04.675889+00
1b073255-cf95-4b73-ac00-4bc52aa7fdbb	Pengembangan Bandara Kertajati	Pengembangan Bandara Kertajati	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.621489+00	2026-07-22 10:19:04.675889+00
9e6e8f72-1b95-465f-8ba6-ef9151eafaef	Pemerintah	Pemerintah	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.621489+00	2026-07-22 10:19:04.675889+00
a1413e59-f74a-47f4-b2f5-c4e29ecec716	Media Asing Sorot Nanik Mundur	Media Asing Sorot Nanik Mundur	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.65181+00	2026-07-22 10:19:04.708933+00
bc832cab-ecaa-4a77-9728-3f361902179e	Diganti Sudaryono	Diganti Sudaryono	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.65181+00	2026-07-22 10:19:04.708933+00
e8d3d263-1939-46bb-9348-287eb7aa1752	Sejumlah	Sejumlah	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.65181+00	2026-07-22 10:19:04.708933+00
299e5c27-2ae3-4dcd-a15d-2110173ed7e4	Nanik Deyang	Nanik Deyang	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.65181+00	2026-07-22 10:19:04.708933+00
ed898211-2a33-48c6-a740-dab9b29c57a0	Sudaryono Lepas Jabatan Wamentan	Sudaryono Lepas Jabatan Wamentan	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.691719+00	2026-07-22 10:19:04.729152+00
77218935-12d1-4616-8f41-0183c82448b5	Wakil Menteri Pertanian	Wakil Menteri Pertanian	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.691719+00	2026-07-22 10:19:04.729152+00
546528c4-11b8-48b6-8b63-089761fad912	Produksi Gas	Produksi Gas	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.730603+00	2026-07-22 10:19:04.758899+00
5f81e3e7-9038-47bf-b73e-5c972d787487	Bisa Melejit	Bisa Melejit	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.730603+00	2026-07-22 10:19:04.758899+00
f6268758-2926-4a48-bba3-ad7b877938a4	Dalam	Dalam	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.730603+00	2026-07-22 10:19:04.758899+00
6684a1ca-11c4-4331-8bc2-c17d4c968a25	Nanik	Nanik	PERSON	{}	\N	\N	5	0	0	2026-07-22 09:57:01.040013+00	2026-07-22 10:19:05.318078+00
e853cbb2-0551-43db-8968-d0aa15b01973	Ini Pendorongnya	Ini Pendorongnya	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.730603+00	2026-07-22 10:19:04.758899+00
e056b081-365d-428c-ba07-6d7c55f7eb4a	Produksi	Produksi	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.730603+00	2026-07-22 10:19:04.758899+00
c0f62d4d-9400-44ad-ac24-01674df0cb2b	Istana Kepresidenan	Istana Kepresidenan	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.770573+00	2026-07-22 10:19:04.797755+00
afb57e8b-05da-469a-a842-9b224b569dce	Segera Dilantik Jadi Bos	Segera Dilantik Jadi Bos	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.770573+00	2026-07-22 10:19:04.797755+00
2968944e-b667-4ab3-998d-9b33d4fde778	Wakil Menteri Pertanian Sudaryono	Wakil Menteri Pertanian Sudaryono	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.770573+00	2026-07-22 10:19:04.797755+00
64f8cb2a-0253-479b-8407-3943201f9031	Badan Gizi Nasional	Badan Gizi Nasional	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.770573+00	2026-07-22 10:19:04.797755+00
7be798fa-326b-49ed-92d8-02366ce86533	Polisi	Polisi	PERSON	{}	\N	\N	3	0	0	2026-07-22 09:57:01.405193+00	2026-07-22 10:19:05.123397+00
2896ce6e-7abe-4b06-8dd2-ca3751dab474	Malaysia	Malaysia	PERSON	{}	\N	\N	6	0	0	2026-07-22 09:57:01.298628+00	2026-07-22 10:19:05.123397+00
280d0c54-6bf5-4d25-9ce2-fd38b4df1c64	China Vs Jepang	China Vs Jepang	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.711511+00	2026-07-22 09:57:01.711511+00
665d484d-2251-4c34-acbc-cff1d4a1178b	Jadi Kepala	Jadi Kepala	PERSON	{}	\N	\N	4	0	0	2026-07-22 09:57:01.574513+00	2026-07-22 10:19:04.863718+00
0b27cc41-e7ff-401d-bd23-adcbc050ecb4	Ini Bocoran Pertemuan Purbaya	Ini Bocoran Pertemuan Purbaya	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.674492+00	2026-07-22 10:19:04.96969+00
e2c79c9b-2f39-4cb7-8589-1bad6f43dcc9	Mau Garap Hidrogen	Mau Garap Hidrogen	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.751999+00	2026-07-22 09:57:01.751999+00
9bb9ce47-fe92-46da-b4b3-6a93dbfadc07	Perlu Kajian Lebih Dalam	Perlu Kajian Lebih Dalam	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.751999+00	2026-07-22 09:57:01.751999+00
79da9afa-4196-496e-8293-dbaf22aa34eb	Bahlil Lahadalia	Bahlil Lahadalia	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.711511+00	2026-07-22 09:57:01.751999+00
0d1f56fc-6b7e-4df1-8350-dcb21ecc3efc	Ini Tantangan Berat Program Nyicil Rumah Sampai	Ini Tantangan Berat Program Nyicil Rumah Sampai	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.828159+00	2026-07-22 09:57:01.828159+00
d0605210-ddbb-4d8b-afe6-8aa761a2a3ad	Prabowo Lantik Sudaryono Sebagai Kepala	Prabowo Lantik Sudaryono Sebagai Kepala	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.469787+00	2026-07-22 10:19:04.342715+00
71c58a26-cad2-4f22-99ce-a4f44fe58395	Perang Dagang	Perang Dagang	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.785054+00	2026-07-22 09:57:01.785054+00
1a7a4beb-1ee8-4a21-975a-6155d7b7f9ed	Bak Singapura	Bak Singapura	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.499147+00	2026-07-22 10:19:04.365938+00
d416bf45-e3da-48ca-aa17-243ee1a5666b	Bangkit	Bangkit	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.785054+00	2026-07-22 09:57:01.785054+00
23631448-5561-42f8-b052-b950232f11a2	Kubur	Kubur	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.785054+00	2026-07-22 09:57:01.785054+00
672c3af2-8643-4b26-a837-c4695f9de301	Rencana	Rencana	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.828159+00	2026-07-22 09:57:01.828159+00
621b64f1-2630-453b-83e7-fb5c67225db7	Polisi Olah	Polisi Olah	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.887746+00	2026-07-22 10:19:04.927961+00
c319dc5e-9c54-472b-bbd5-d85255019520	Ketika Bahlil Sebut Persaingan China Vs Jepang	Ketika Bahlil Sebut Persaingan China Vs Jepang	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.711511+00	2026-07-22 09:57:01.711511+00
f235b626-bb4e-457f-8141-ea5de6fdbaa9	Hidrogen	Hidrogen	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.711511+00	2026-07-22 09:57:01.711511+00
2e477b3e-7c75-4838-a1e0-1a22682118e7	Trump Naikkan Tarif Ini	Trump Naikkan Tarif Ini	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.785054+00	2026-07-22 09:57:01.785054+00
301c9af2-0c9d-47d1-ad78-380b99eb2309	Perang	Perang	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.785054+00	2026-07-22 09:57:01.785054+00
a8dbe191-e1c2-4d4f-af61-f93611f1be8e	Trump	Trump	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.785054+00	2026-07-22 09:57:01.785054+00
bd91d521-fc77-4058-87ce-12160e202b99	Brasil	Brasil	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.785054+00	2026-07-22 09:57:01.785054+00
f294d8b8-5421-4f0d-b3f1-0d1b3c7d198f	Kanada	Kanada	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:01.785054+00	2026-07-22 09:57:01.785054+00
f1fc38d0-a58c-491a-965e-0e0412f37c78	Tokyo	Tokyo	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.499147+00	2026-07-22 10:19:04.365938+00
b3f23161-2af6-4f05-b44b-2910a20574e6	Proyek	Proyek	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.499147+00	2026-07-22 10:19:04.365938+00
b08eb5d2-7d0b-454a-8d87-c75553b72a96	Kepemilikan Asing	Kepemilikan Asing	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.543075+00	2026-07-22 10:19:04.411307+00
2799f052-8b02-4cd5-890d-409b081041a1	Ciut	Ciut	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.543075+00	2026-07-22 10:19:04.411307+00
63098359-1979-4e73-b820-1582f304e243	Ini Buktinya	Ini Buktinya	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.543075+00	2026-07-22 10:19:04.411307+00
bfc75f13-e3d0-4bdd-97fa-54b01910f214	Kepemilikan	Kepemilikan	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.543075+00	2026-07-22 10:19:04.411307+00
7b226b87-7ac3-4823-8a24-d8c0ef177745	Sekuritas Rupiah Bank Indonesia	Sekuritas Rupiah Bank Indonesia	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.543075+00	2026-07-22 10:19:04.411307+00
6d662f00-230e-4336-aa76-2c01abc87985	Alasan	Alasan	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.606769+00	2026-07-22 10:19:04.908772+00
cd8bc97a-6891-484c-96bc-49bdca608918	Baru	Baru	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.574513+00	2026-07-22 10:19:04.863718+00
023912a3-922a-471d-89fe-da7802cff5df	Sudaryono Minta Didoakan	Sudaryono Minta Didoakan	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.574513+00	2026-07-22 10:19:04.863718+00
0ba44d4d-24ae-45a3-84f9-ab430badd409	Janjikan Ini	Janjikan Ini	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.574513+00	2026-07-22 10:19:04.863718+00
48036ec4-cdda-406d-8ac8-b5f85a3c31d2	Wamentan Sudaryono	Wamentan Sudaryono	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.574513+00	2026-07-22 10:19:04.863718+00
850d1428-0b4b-472d-9c6e-602feead80cb	Rate Kini Ditahan	Rate Kini Ditahan	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.606769+00	2026-07-22 10:19:04.908772+00
610cee97-d0cb-401d-aaec-d4d746d62ec0	Level	Level	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.606769+00	2026-07-22 10:19:04.908772+00
58610788-8b1b-4f1b-a41f-15f03ae157b8	Jaga Rupiah	Jaga Rupiah	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.606769+00	2026-07-22 10:19:04.908772+00
b8e2524c-d0d3-4d77-b32b-29dc5c237206	Tekan Inflasi	Tekan Inflasi	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.606769+00	2026-07-22 10:19:04.908772+00
bc6c00dc-e0db-48ae-a519-84909a141b6f	Dewan Gubernur Bank Indonesia	Dewan Gubernur Bank Indonesia	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.606769+00	2026-07-22 10:19:04.908772+00
1f25f4f4-b421-426b-8cc1-4d388caea829	Rumah Grand Polonia Medan Usai Ledakan	Rumah Grand Polonia Medan Usai Ledakan	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.887746+00	2026-07-22 10:19:04.927961+00
6aa6bc4d-fce0-4de1-b9b4-89b5618fb35f	Polrestabes Medan	Polrestabes Medan	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.887746+00	2026-07-22 10:19:04.927961+00
6912169c-721e-409e-a6c1-e9925809fe46	Grand Polonia	Grand Polonia	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.887746+00	2026-07-22 10:19:04.927961+00
16000178-622b-4171-8e2b-238db051aa9b	Petaka Eropa  Menggila	Petaka Eropa  Menggila	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.640512+00	2026-07-22 10:19:04.940223+00
2ceb961d-7a71-40aa-836c-a59f919b4c98	Negeri	Negeri	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.640512+00	2026-07-22 10:19:04.940223+00
58657eef-9b57-466c-920f-bad2abe324c2	Bawah Laut	Bawah Laut	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.640512+00	2026-07-22 10:19:04.940223+00
0b6c896b-706a-4438-a679-d3bd1c5fd134	Terancam Krisis Air	Terancam Krisis Air	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.640512+00	2026-07-22 10:19:04.940223+00
1d8ab2e7-fa12-4551-9565-cafc98eed8b5	Eropa	Eropa	PERSON	{}	\N	\N	4	0	0	2026-07-22 09:57:01.427286+00	2026-07-22 10:19:04.940223+00
c86ead66-0c7d-4715-bbb7-e775bbe9d0b1	Kekeringan	Kekeringan	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.640512+00	2026-07-22 10:19:04.940223+00
dddb50af-4c70-442b-87c8-151eef2bdec2	Kantor	Kantor	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.674492+00	2026-07-22 10:19:04.96969+00
16132e77-6734-489e-ad06-71c927ec0b15	Menkeu Purbaya Yudhi Sadewa	Menkeu Purbaya Yudhi Sadewa	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.674492+00	2026-07-22 10:19:04.96969+00
8adae7ed-aa43-4eb8-84dc-712258a6d714	Upacara Prasetya Perwira	Upacara Prasetya Perwira	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.999798+00	2026-07-22 10:19:05.081347+00
26b76af1-4084-4f8a-97a7-afd0bf2688cb	Rate Diramal Bisa Sampai	Rate Diramal Bisa Sampai	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.807741+00	2026-07-22 10:19:04.835864+00
0904e9d8-6e66-4588-8ad7-88b54c55791a	Kebakaran	Kebakaran	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.93748+00	2026-07-22 10:19:05.015453+00
468ebe20-8534-44f3-a46f-b97e1e51bfb6	Siap	Siap	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.807741+00	2026-07-22 10:19:04.835864+00
4cf77fbd-d1c5-4133-b609-72e337fabd1c	Prabowo Lantik Donny Ermawan Gubernur Universitas Republik Indonesia	Prabowo Lantik Donny Ermawan Gubernur Universitas Republik Indonesia	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.143367+00	2026-07-22 10:19:05.235245+00
23f30504-1687-468f-b8b7-f31fbcd0cffb	Evakuasi Jenazah Korban	Evakuasi Jenazah Korban	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.174576+00	2026-07-22 10:19:05.282662+00
19b22424-17d4-4783-852a-789df0b72610	Bareskrim Tetapkan Ayah	Bareskrim Tetapkan Ayah	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.848791+00	2026-07-22 10:19:04.952556+00
0171e85a-89df-4278-b338-96d5d65a13c9	Anak Pemilik Pabrik Whip Pink Jadi Tersangka	Anak Pemilik Pabrik Whip Pink Jadi Tersangka	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.848791+00	2026-07-22 10:19:04.952556+00
e0ae689e-e280-4230-936d-fc45c9b3677c	Bareskrim Polri	Bareskrim Polri	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.848791+00	2026-07-22 10:19:04.952556+00
a15a1b10-b44e-4de3-8b99-8341c86e1ad3	Andi Hioe	Andi Hioe	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.848791+00	2026-07-22 10:19:04.952556+00
8d15897a-817e-4460-9a5e-3342102f3c55	Lantik	Lantik	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.885544+00	2026-07-22 10:19:04.984318+00
e50985f6-c556-40d0-b3d2-e3d8f0c4ff1b	Perwira Remaja	Perwira Remaja	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.885544+00	2026-07-22 10:19:04.984318+00
7f9ba4e3-9d39-4788-92f9-ebedf986d509	Prabowo Singgung Peran Vital	Prabowo Singgung Peran Vital	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.885544+00	2026-07-22 10:19:04.984318+00
6fd8d222-af62-4c5e-a34f-5afda9a734e2	Bangsa Indonesia	Bangsa Indonesia	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.885544+00	2026-07-22 10:19:04.984318+00
62653e1c-e434-43af-81b0-a6534d839e7b	Presiden Prabowo	Presiden Prabowo	PERSON	{}	\N	\N	4	0	0	2026-07-22 09:57:01.770573+00	2026-07-22 10:19:04.995403+00
129db3c7-3eed-4048-a3d9-3d39b2699d0c	Walhi Jatim	Walhi Jatim	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.93748+00	2026-07-22 10:19:05.015453+00
56e1ea27-3b58-4808-8449-a149d57d142e	Benowo Surabaya	Benowo Surabaya	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.93748+00	2026-07-22 10:19:05.015453+00
f8b57cb4-2852-4da3-82c7-dca0c5024152	Bukan Insiden Biasa	Bukan Insiden Biasa	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.93748+00	2026-07-22 10:19:05.015453+00
d19c7be2-551f-4e3f-92c6-8ffd79531814	Bobrok Kaderisasi	Bobrok Kaderisasi	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.966426+00	2026-07-22 10:19:05.051727+00
223a2182-e0b5-4309-8ec8-095ee96b6c7e	Buruk Integritas	Buruk Integritas	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.966426+00	2026-07-22 10:19:05.051727+00
1fde83e5-e683-4075-8afb-eb24b291d5fa	Balik	Balik	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.966426+00	2026-07-22 10:19:05.051727+00
edc9834e-34c9-42e1-9fcd-5813ead52a37	Kepala Daerah	Kepala Daerah	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.966426+00	2026-07-22 10:19:05.051727+00
5729abbf-e729-4408-82d3-673545d62dce	Terima Permintaan Maaf Hotman Paris	Terima Permintaan Maaf Hotman Paris	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.091138+00	2026-07-22 10:19:05.189632+00
7f8ee319-0d1e-4898-a8e8-3fd41b26d550	Perlu	Perlu	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.966426+00	2026-07-22 10:19:05.051727+00
3714c7a5-5cca-4e57-b45e-ead38706a344	Tak Ada	Tak Ada	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.024238+00	2026-07-22 10:19:05.123397+00
1393d363-a64b-4e8f-bd48-484eba5d165c	Rekam Penculikan Atlet Golf Jesslyn	Rekam Penculikan Atlet Golf Jesslyn	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.024238+00	2026-07-22 10:19:05.123397+00
440b76f5-535f-4a03-b5a4-56314307afe3	Jesslyn Wijaya Lay	Jesslyn Wijaya Lay	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.024238+00	2026-07-22 10:19:05.123397+00
0fa6e896-c104-4410-b61d-3dc52775ed7e	Tidak	Tidak	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.024238+00	2026-07-22 10:19:05.123397+00
ccf3deb2-0ed6-4dcc-b320-5589a48125ff	Istri	Istri	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.057521+00	2026-07-22 10:19:05.167745+00
d9ab42ee-29d9-4aeb-b85a-e275c3827d66	Bali Dipolisikan Suami Perkara Melahirkan	Bali Dipolisikan Suami Perkara Melahirkan	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.057521+00	2026-07-22 10:19:05.167745+00
0ababae6-3856-47e1-b224-050c3f8f5e03	Lain	Lain	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.057521+00	2026-07-22 10:19:05.167745+00
9f7521fe-4419-4b8c-94a2-807146248808	Polresta Denpasar	Polresta Denpasar	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.057521+00	2026-07-22 10:19:05.167745+00
9fd91e68-bad6-4dee-91b6-293b857b30be	Kasus	Kasus	PERSON	{}	\N	\N	4	0	0	2026-07-22 09:57:01.966426+00	2026-07-22 10:19:05.167745+00
34b45eef-1a6b-4592-8061-d61d5e97b2f3	Tapi Proses Hukum Tetap Jalan	Tapi Proses Hukum Tetap Jalan	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.091138+00	2026-07-22 10:19:05.189632+00
97ac6096-0033-4702-97ad-8878e9be3195	Hotman Paris	Hotman Paris	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.091138+00	2026-07-22 10:19:05.189632+00
0e0c4314-f1a1-42c9-a832-b662bd44a981	Petugas Perlintasan Diduga Tertidur	Petugas Perlintasan Diduga Tertidur	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.11423+00	2026-07-22 10:19:05.212147+00
eb78f88b-3947-44c0-86e9-0a36ea662747	Truk Nyaris Tertabrak	Truk Nyaris Tertabrak	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.11423+00	2026-07-22 10:19:05.212147+00
0fa156aa-8e53-419f-91ce-a84f81cb9d85	Brantas	Brantas	PERSON	{}	\N	\N	3	0	0	2026-07-22 09:57:02.11423+00	2026-07-22 10:19:05.212147+00
a9df0732-a3f6-43cb-b83d-e186549af202	Penjaga	Penjaga	PERSON	{}	\N	\N	3	0	0	2026-07-22 09:57:02.11423+00	2026-07-22 10:19:05.212147+00
b0042eed-35e4-45d5-ad5e-71f7b5e24cdc	Kediri	Kediri	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.11423+00	2026-07-22 10:19:05.212147+00
f9c7eb6a-8600-4a68-b5b6-4be3bb15754f	Sebuah	Sebuah	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.11423+00	2026-07-22 10:19:05.212147+00
7b6e12e3-ab17-4911-b4e6-6b0fa71b4216	Karam	Karam	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.174576+00	2026-07-22 10:19:05.282662+00
2a98acf7-ad54-4d2f-a3e8-a93499a9163f	Pelabuhan Soekarno	Pelabuhan Soekarno	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.174576+00	2026-07-22 10:19:05.282662+00
edea173e-9d70-4671-a9e9-2092aea8b92b	Hatta	Hatta	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.174576+00	2026-07-22 10:19:05.282662+00
a2de3068-2385-487b-a24b-ea958a847132	Makassar	Makassar	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.174576+00	2026-07-22 10:19:05.282662+00
a4327d21-f4f3-4173-9f3b-23020a68bb8f	Sudaryono Kepala	Sudaryono Kepala	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.213934+00	2026-07-22 10:19:05.318078+00
2be9a1ec-7b86-4107-8a75-b48b4b3e5ec4	Pengganti Nanik Berharta	Pengganti Nanik Berharta	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.213934+00	2026-07-22 10:19:05.318078+00
c63b4d0b-32bc-4b9a-a660-4c63c8a86825	Miliar	Miliar	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.213934+00	2026-07-22 10:19:05.318078+00
21410536-0622-4a05-9e8a-27af1c4f2585	Polda Sulsel Identifikasi	Polda Sulsel Identifikasi	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.916611+00	2026-07-22 10:19:05.264287+00
2a2f5eb1-da91-436b-b332-baa0ce286409	Nevi Rizal Pejabat Gayo Lues Minta Maaf	Nevi Rizal Pejabat Gayo Lues Minta Maaf	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.131672+00	2026-07-22 10:19:05.201938+00
04c781b5-677a-4fb1-87f8-92321fe198ec	Dekapan Suami	Dekapan Suami	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.074125+00	2026-07-22 10:19:05.140059+00
cf12b2c0-cf9c-46bf-988b-98e7124c621a	Dilanda Kekeringan	Dilanda Kekeringan	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.03787+00	2026-07-22 10:19:05.100348+00
fb94c632-c2d6-40c6-92bc-3d9fe7cbe242	Mukjizat Selembar Gabus	Mukjizat Selembar Gabus	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.074125+00	2026-07-22 10:19:05.140059+00
e2f450a1-0f4c-4a4d-8503-3688556f9180	Daftar Lengkap	Daftar Lengkap	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.1977+00	2026-07-22 10:19:05.253536+00
8d02aca6-d1b1-4cfd-87e9-2bf61cf108fd	Pejabat Baru Kejagung	Pejabat Baru Kejagung	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.1977+00	2026-07-22 10:19:05.253536+00
73564c5b-4731-4093-a534-9a56bc341f45	Warga Bangkalan Antre Bantuan Air	Warga Bangkalan Antre Bantuan Air	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.03787+00	2026-07-22 10:19:05.100348+00
5afde987-6f4d-47e6-a8b9-fe37cddfe5bb	Jasad Diduga Korban	Jasad Diduga Korban	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.916611+00	2026-07-22 10:19:05.264287+00
ed38036a-2862-49c9-8bed-24b892f347aa	Krisis	Krisis	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.03787+00	2026-07-22 10:19:05.100348+00
f9bd915a-dccb-4e7a-a4a8-3d509d3400b3	Laut Selayar	Laut Selayar	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.074125+00	2026-07-22 10:19:05.140059+00
338f185a-cd26-4e97-88f4-e1d155a013fc	Sitti Amang	Sitti Amang	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.074125+00	2026-07-22 10:19:05.140059+00
fe2bd2c1-63c9-4fa3-b188-ac98d4aba9bb	Empat	Empat	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.074125+00	2026-07-22 10:19:05.140059+00
b2180bd2-5437-45c5-b24a-85de9a4ae2c7	Cerita Paling Sedih	Cerita Paling Sedih	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.104092+00	2026-07-22 10:19:05.179652+00
a845f5e2-2ad1-41dd-a103-3601a28c4bec	Kakek Relakan Pelampung Demi Cucu	Kakek Relakan Pelampung Demi Cucu	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.104092+00	2026-07-22 10:19:05.179652+00
c72066a0-5d60-4f2f-9c4e-d56370b3e96a	Laut	Laut	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.951191+00	2026-07-22 10:19:05.297215+00
d1a55464-8dd6-4fa4-9a43-90e926f39d8b	Tegur Anaknya Rajin Flexing	Tegur Anaknya Rajin Flexing	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.131672+00	2026-07-22 10:19:05.201938+00
897b179c-e81b-4b43-ba74-66d0af296b5d	Anak	Anak	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.131672+00	2026-07-22 10:19:05.201938+00
f4baa5c0-bf0c-4469-813d-1c35f73b8e04	Kabupaten Gayo Lues	Kabupaten Gayo Lues	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.131672+00	2026-07-22 10:19:05.201938+00
8ce6af4d-b5af-44ac-9ff9-e345da0eb53b	Minta Maaf	Minta Maaf	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.160572+00	2026-07-22 10:19:05.223568+00
cdf31d08-f622-4a0f-b95b-a14f3e4650b6	Kebayoran Lama Roboh Terbengkalai	Kebayoran Lama Roboh Terbengkalai	PERSON	{}	\N	\N	3	0	0	2026-07-22 09:57:02.160572+00	2026-07-22 10:19:05.223568+00
b11656c3-58c1-4cd9-b6e2-22f57b555ee2	Jakarta Pramono Anung	Jakarta Pramono Anung	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.160572+00	2026-07-22 10:19:05.223568+00
0a52cd03-be05-42b7-b03e-6018f6dae36c	Kebayoran Lama Selatan	Kebayoran Lama Selatan	PERSON	{}	\N	\N	3	0	0	2026-07-22 09:57:02.160572+00	2026-07-22 10:19:05.223568+00
b742c4a9-2f48-4a91-b30e-99e6fcb47a1c	Pagi	Pagi	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.160572+00	2026-07-22 10:19:05.223568+00
5ce3ed49-985a-4185-8979-b5a1c3f58ffa	Ditunjuk Prabowo	Ditunjuk Prabowo	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.1977+00	2026-07-22 10:19:05.253536+00
45676087-445e-4f64-b94f-f8d7b7edbabf	Keppres	Keppres	PERSON	{}	\N	\N	4	0	0	2026-07-22 09:57:02.1977+00	2026-07-22 10:19:05.253536+00
e318db24-27e5-4adf-821a-650294f56164	Kejaksaan Agung	Kejaksaan Agung	PERSON	{}	\N	\N	4	0	0	2026-07-22 09:57:02.1977+00	2026-07-22 10:19:05.253536+00
79854dc0-c3a0-4d7e-93cc-459dae006ac5	Berikut	Berikut	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.1977+00	2026-07-22 10:19:05.253536+00
7d66fa30-168d-48e3-9556-53c873a2761b	Makassar Sulsel	Makassar Sulsel	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.916611+00	2026-07-22 10:19:05.264287+00
b4b8debe-62e5-40bd-9618-bc2f6927b7e0	Sulsel	Sulsel	PERSON	{}	\N	\N	4	0	0	2026-07-22 09:57:02.104092+00	2026-07-22 10:19:05.282662+00
567dfaf8-e0b5-4c2a-90d6-d97dfae61875	Basarnas Sisir Pulau Sabalana	Basarnas Sisir Pulau Sabalana	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.951191+00	2026-07-22 10:19:05.297215+00
e0547483-f2a9-4453-bef1-5f4a04c03c7c	Cari Korban	Cari Korban	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.951191+00	2026-07-22 10:19:05.297215+00
12260cd2-bc71-408f-a48d-c2cbf1581733	Salsa	Salsa	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.951191+00	2026-07-22 10:19:05.297215+00
91eb32dd-9a2f-43e5-8c7d-f8c3636b75fc	Selayar	Selayar	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.951191+00	2026-07-22 10:19:05.297215+00
2a305d53-b86e-4c7c-add8-471dfa19180e	Pencarian	Pencarian	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.951191+00	2026-07-22 10:19:05.297215+00
20094821-f621-4743-b5be-023d6d291af4	Cerita Warga Bandung Pesan	Cerita Warga Bandung Pesan	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.98499+00	2026-07-22 10:19:05.334339+00
ab4f7692-129f-43f6-a1e6-55f39a0d616c	Ojol Antar Pulang	Ojol Antar Pulang	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.98499+00	2026-07-22 10:19:05.334339+00
434b000b-63b3-481d-b647-a5c27cffc650	Takut Begal	Takut Begal	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.98499+00	2026-07-22 10:19:05.334339+00
212589b4-24b1-465f-8fd5-04a3f1ca40ed	Claudia	Claudia	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.98499+00	2026-07-22 10:19:05.334339+00
74860087-4ee5-4242-9422-38fbc332ea7a	Piala Dunia	Piala Dunia	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.98499+00	2026-07-22 10:19:05.334339+00
ba262c87-4d3e-48d5-accd-9d7c3e00fba8	Teknologi	Teknologi	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.255153+00	2026-07-22 10:19:05.348391+00
fc642e25-4ec2-4cc2-a8de-f6ee89dc167c	Banyak	Banyak	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.255153+00	2026-07-22 10:19:05.348391+00
921b229f-7ba5-4bda-b3a1-8250b4ec50cd	Cholil	Cholil	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.011285+00	2026-07-22 10:19:05.360947+00
3ea80315-8349-474a-8a5e-284523c5bfc9	Gabung Badan Pengawas	Gabung Badan Pengawas	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.011285+00	2026-07-22 10:19:05.360947+00
388c06a9-04ea-42f9-9c20-36a503de8af3	Eka The Brandals Pengurus	Eka The Brandals Pengurus	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.011285+00	2026-07-22 10:19:05.360947+00
73ee1078-7011-4ae7-8ad3-db2bd40056c1	SCIE	SCIE	PRODUCT	{}	\N	\N	2	0	0	2026-07-22 09:57:02.235252+00	2026-07-22 10:19:05.369985+00
059d634b-5681-4446-944d-cb7736304117	Cholil Mahmud	Cholil Mahmud	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.011285+00	2026-07-22 10:19:05.360947+00
490ef9e1-f0ee-4219-9082-cc0f6bcd13db	Sistem Social Intelligence Engine	Sistem Social Intelligence Engine	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.235252+00	2026-07-22 10:19:05.369985+00
b58c8929-76f6-4f45-afe1-e25dad365b52	Prabowo Teken Keppres	Prabowo Teken Keppres	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:02.250962+00	2026-07-22 09:57:02.250962+00
2b17e75f-f191-4665-893f-5e65e9566a2d	Wakil Jaksa Agung Asep Nana	Wakil Jaksa Agung Asep Nana	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:02.250962+00	2026-07-22 09:57:02.250962+00
85101e54-386c-4846-b647-3119cb93bf12	Jampidsus Kuntadi	Jampidsus Kuntadi	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:02.250962+00	2026-07-22 09:57:02.250962+00
5e263ec8-db8d-47d1-96bd-0af9f29fe01c	Wakil Jaksa Agung	Wakil Jaksa Agung	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:02.250962+00	2026-07-22 09:57:02.250962+00
942c5e43-4e85-42ca-9bdd-55d195d98af3	Tidak Ada Penugasan Baru Babinsa	Tidak Ada Penugasan Baru Babinsa	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:02.285151+00	2026-07-22 09:57:02.285151+00
b0cca660-2c34-4fc3-b451-240010d43d72	Bidang Perpajakan	Bidang Perpajakan	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:02.285151+00	2026-07-22 09:57:02.285151+00
a27af718-582e-43f3-8bd3-3a12110a73fa	Angkatan Darat	Angkatan Darat	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:02.285151+00	2026-07-22 09:57:02.285151+00
a5a57546-3e3b-45f7-8a14-b7e97b30cf6f	Bintara Pembina Desa	Bintara Pembina Desa	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:02.285151+00	2026-07-22 09:57:02.285151+00
88a44cf8-cd6e-4afa-b84b-d0e89bfc0c2e	Babinsa	Babinsa	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:02.285151+00	2026-07-22 09:57:02.285151+00
db75338f-3861-45a1-9beb-5a1c7e3870ca	Ratusan Siswa Ngungsi	Ratusan Siswa Ngungsi	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:02.309132+00	2026-07-22 09:57:02.309132+00
a164e2e6-b81f-448a-a3de-8af463284f75	Gempa Magnitudo	Gempa Magnitudo	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:02.342667+00	2026-07-22 09:57:02.342667+00
71763972-37c1-4595-bec1-f13da9e1ce6f	Gayo Lues Aceh	Gayo Lues Aceh	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:02.342667+00	2026-07-22 09:57:02.342667+00
38d05a2b-71f4-46a6-8cdb-9c9a7dfd2913	Getaran Sampai Medan	Getaran Sampai Medan	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:02.342667+00	2026-07-22 09:57:02.342667+00
9e781282-89d1-4235-96d4-42055f54aecf	Gempa	Gempa	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:02.342667+00	2026-07-22 09:57:02.342667+00
dd98341f-aa23-4876-8dae-0a6a24029aaa	Gayo Lues	Gayo Lues	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:02.342667+00	2026-07-22 09:57:02.342667+00
4e722203-25c1-403e-bc94-22768e41bb86	Getaran	Getaran	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:02.342667+00	2026-07-22 09:57:02.342667+00
b7d7e3e9-d07a-493d-a381-b2b0e8de8e39	Daftar Penerima Adhi Makayasa	Daftar Penerima Adhi Makayasa	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:02.376907+00	2026-07-22 09:57:02.376907+00
d81ee34c-ed02-4b36-adc8-e01c90665638	Sebanyak	Sebanyak	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:02.376907+00	2026-07-22 09:57:02.376907+00
be941c1f-3f1e-453a-bbdd-ab2733283d94	Adhi Makayasa	Adhi Makayasa	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:02.376907+00	2026-07-22 09:57:02.376907+00
11dd5033-0339-4152-96a6-e39f519b56ab	Akademi	Akademi	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:02.376907+00	2026-07-22 09:57:02.376907+00
11b2311b-3c84-4ed3-8e17-a584d6b995ee	Akademi Kepolisian	Akademi Kepolisian	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:02.376907+00	2026-07-22 09:57:02.376907+00
a5d4d446-1762-481d-8d51-14b68b9b9165	Densus	Densus	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:02.402126+00	2026-07-22 09:57:02.402126+00
7e62b2ba-1210-49f5-89e7-03c6a8d5f13b	Tangkap Penyebar Propaganda Teror	Tangkap Penyebar Propaganda Teror	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:02.402126+00	2026-07-22 09:57:02.402126+00
f91c334e-afdb-4c56-be16-d4f07e2279ec	Bandar Lampung	Bandar Lampung	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:02.402126+00	2026-07-22 09:57:02.402126+00
89e93046-0a31-40d8-9241-0fd94714cce6	Antiteror Polri	Antiteror Polri	PERSON	{}	\N	\N	1	0	0	2026-07-22 09:57:02.402126+00	2026-07-22 09:57:02.402126+00
103906ed-4bcc-41d8-9582-777a645f84fa	Deyang	Deyang	PERSON	{}	\N	\N	4	0	0	2026-07-22 09:57:01.491968+00	2026-07-22 10:19:05.318078+00
ceaa1b92-da31-481b-ae4c-2e69e36a0fe5	Pentingnya	Pentingnya	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.441699+00	2026-07-22 10:19:05.383658+00
8a0118d9-a104-48a1-ba81-0b7d9992bf4f	Layanan	Layanan	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.42493+00	2026-07-22 10:19:05.403918+00
f46799ee-ea2c-4cb3-af90-ff7943e70196	Terbaru	Terbaru	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.227881+00	2026-07-22 10:19:04.227881+00
d85c446b-2ace-4ced-86b5-eacdafb7a5c7	Berhasil Uji Produksi Minyak Sumur Akasia Maju	Berhasil Uji Produksi Minyak Sumur Akasia Maju	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.227881+00	2026-07-22 10:19:04.227881+00
e4a9b9a9-7d14-4542-b170-21afb7faff8d	Barel	Barel	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.227881+00	2026-07-22 10:19:04.227881+00
00e60d11-20eb-4096-9c1a-4b00194a1bea	Sumur	Sumur	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.227881+00	2026-07-22 10:19:04.227881+00
1c22db1c-9ea2-4c59-b69d-87d44d546e1d	Akasia Maju	Akasia Maju	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.227881+00	2026-07-22 10:19:04.227881+00
0d7ca94e-bcdf-4e98-8bb1-0c55722b7343	Terjadi	Terjadi	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.260641+00	2026-07-22 10:19:04.260641+00
70055218-5846-48a7-83aa-6888494ce56f	Harga Telur Naik Usai Libur Sekolah	Harga Telur Naik Usai Libur Sekolah	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.260641+00	2026-07-22 10:19:04.260641+00
f3d6216d-4f9e-4fa1-b453-bfbc7466637b	Kini	Kini	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.260641+00	2026-07-22 10:19:04.260641+00
e63534f0-6a83-4b74-bac1-85c7c6c26661	Harga	Harga	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.260641+00	2026-07-22 10:19:04.260641+00
ef9c3d63-38c6-4891-8b00-3a978582e6b4	Pasar Kebayoran Lama	Pasar Kebayoran Lama	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.260641+00	2026-07-22 10:19:04.260641+00
a0f5fc4a-b965-4966-bebd-857b8f641da4	Main Judol	Main Judol	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.293626+00	2026-07-22 10:19:04.293626+00
fc8a92dc-5255-4bfc-98f6-6df71a626fd2	Menteri Dody Lapor Bos	Menteri Dody Lapor Bos	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.293626+00	2026-07-22 10:19:04.293626+00
72be9579-c366-4b36-8513-6caf435e400b	Tragedi	Tragedi	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.427286+00	2026-07-22 10:19:04.313119+00
481537b3-d46f-4906-80a4-08b43b940987	Mauritania	Mauritania	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.427286+00	2026-07-22 10:19:04.313119+00
a41cf5b0-da68-4e02-a7ee-bebbb12cb811	Korupsi Proyek Desa Rp	Korupsi Proyek Desa Rp	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.330418+00	2026-07-22 10:19:04.330418+00
45269714-105f-4438-a97d-45404bf72ef1	Juta Terbongkar	Juta Terbongkar	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.330418+00	2026-07-22 10:19:04.330418+00
bb4c2570-ca6a-49cd-ac5f-a8064e199e5b	Orang Ditangkap	Orang Ditangkap	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.330418+00	2026-07-22 10:19:04.330418+00
d0b549ee-da4d-4501-b189-610568dc8f87	Enam	Enam	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.330418+00	2026-07-22 10:19:04.330418+00
383f8cf8-c974-4df5-8d61-a6f4b14f774c	Dugaan	Dugaan	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.330418+00	2026-07-22 10:19:04.330418+00
a85fbb27-a1ee-43ab-bc2a-9fe923ccf508	Tembus	Tembus	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.42483+00	2026-07-22 10:19:04.360311+00
0881f63e-5564-4687-a56e-7ad4e9b9d6ad	Derajat	Derajat	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.42483+00	2026-07-22 10:19:04.360311+00
356f94b0-330f-4973-ab06-0945000776b9	Utara Nyambung Selatan	Utara Nyambung Selatan	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.499147+00	2026-07-22 10:19:04.365938+00
31ef28a4-3b07-4831-867e-a3a19b99ae6a	Properti Apa Kabar	Properti Apa Kabar	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.499147+00	2026-07-22 10:19:04.365938+00
6c4b0b9e-1bb5-4420-bf96-6ca75d6f276c	Jakarta Fase	Jakarta Fase	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.499147+00	2026-07-22 10:19:04.365938+00
f30595dd-3b20-4b7d-abf5-21a65570c19a	Bundaran	Bundaran	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.499147+00	2026-07-22 10:19:04.365938+00
d141103e-6c5b-43ec-987d-de248fc3fc73	Anwar Ibrahim	Anwar Ibrahim	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.454907+00	2026-07-22 10:19:04.38498+00
789a1aa6-a8fc-4b3d-ae05-7fc1c1bfc8c2	Manipulasi Absen	Manipulasi Absen	PERSON	{}	\N	\N	3	0	0	2026-07-22 09:57:01.216417+00	2026-07-22 10:19:04.440066+00
1d692f93-c922-454b-9559-21e3bb5adabc	Menteri	Menteri	PERSON	{}	\N	\N	5	0	0	2026-07-22 09:57:01.216417+00	2026-07-22 10:19:04.440066+00
7562afc0-6734-4737-b3eb-7b3737eebff3	Dody Hanggodo	Dody Hanggodo	PERSON	{}	\N	\N	3	0	0	2026-07-22 09:57:01.216417+00	2026-07-22 10:19:04.440066+00
992420be-9953-4340-aca0-c89fe3864adc	Pasar Rakyat	Pasar Rakyat	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.741189+00	2026-07-22 10:19:04.741189+00
8e898767-d664-47f1-b818-62f2d7d02379	Budaya Jateng	Budaya Jateng	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.741189+00	2026-07-22 10:19:04.741189+00
62570dbc-56d8-4574-9f0c-59d613071d92	Dibuka	Dibuka	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.741189+00	2026-07-22 10:19:04.741189+00
7ab4f28f-df7c-42f2-af52-fa551b526336	Suguhkan Ratusan Karya Seni	Suguhkan Ratusan Karya Seni	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.741189+00	2026-07-22 10:19:04.741189+00
86d793a3-8ac0-43fa-9bb1-2905c6dc93ca	Pasar Raya Jawa Tengah	Pasar Raya Jawa Tengah	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.741189+00	2026-07-22 10:19:04.741189+00
58df0d5a-3257-4b33-aad9-7feec1a93ce7	Taman Budaya Surakarta	Taman Budaya Surakarta	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.741189+00	2026-07-22 10:19:04.741189+00
1b06af54-2b8f-4dde-82b5-6b30892306eb	Gubernur Jateng Dorong Tegal Business Forum Hasilkan Investasi Nyata	Gubernur Jateng Dorong Tegal Business Forum Hasilkan Investasi Nyata	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.77835+00	2026-07-22 10:19:04.77835+00
e4353741-60bf-46cd-9174-8a042e820512	Tegal Business Forum	Tegal Business Forum	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.77835+00	2026-07-22 10:19:04.77835+00
f70df1fb-81ca-4a91-8b67-6176c1c69860	Profil Donny Ermawan	Profil Donny Ermawan	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.816632+00	2026-07-22 10:19:04.816632+00
c899df7c-d925-4094-9bb0-5e5b64424d7e	Petinggi Universitas Republik Indonesia	Petinggi Universitas Republik Indonesia	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.816632+00	2026-07-22 10:19:04.816632+00
1e082fdd-1dbd-4fe0-b276-f9f7ed440688	Yos Sunitoyoso	Yos Sunitoyoso	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.816632+00	2026-07-22 10:19:04.816632+00
d87e055c-9175-45cf-bee8-06809b7b0e81	Siap Bunga	Siap Bunga	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.807741+00	2026-07-22 10:19:04.835864+00
50e07fd7-b3f6-455a-9817-3c6118113e90	Bakal Naik	Bakal Naik	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.807741+00	2026-07-22 10:19:04.835864+00
0a1862a0-f9c7-473b-8fa3-801b633a032b	Tantangan	Tantangan	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.807741+00	2026-07-22 10:19:04.835864+00
e98ae7fb-b23b-4118-8d9b-35efac7d16b2	Prabowo Teken Keppres Leonard Eben Ezer Jadi Jampidum	Prabowo Teken Keppres Leonard Eben Ezer Jadi Jampidum	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.853256+00	2026-07-22 10:19:04.853256+00
09eaa7cc-e9fc-47cd-b0d2-c5e8d46134a8	Jaksa Agung Muda Bidang Tindak Pidana Umum	Jaksa Agung Muda Bidang Tindak Pidana Umum	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.853256+00	2026-07-22 10:19:04.853256+00
b7c8106f-2fcb-467d-86a0-49b81e646cc7	Jampidum	Jampidum	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.853256+00	2026-07-22 10:19:04.853256+00
81af2f15-3ee0-4291-a815-06b627e91cac	Palang Perlintasan Tak Ditutup	Palang Perlintasan Tak Ditutup	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.883856+00	2026-07-22 10:19:04.883856+00
ed2f4014-1e90-4dce-929e-125541285ee2	Truk Nyaris Tabrak	Truk Nyaris Tabrak	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.883856+00	2026-07-22 10:19:04.883856+00
36879c49-5a64-477e-9a28-80b8c0533922	Simpang Mengkreng	Simpang Mengkreng	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.883856+00	2026-07-22 10:19:04.883856+00
194dde2b-fad1-403c-8717-1659f76ffc13	Rate	Rate	PERSON	{}	\N	\N	4	0	0	2026-07-22 09:57:01.606769+00	2026-07-22 10:19:04.908772+00
0ebe697e-217c-47c6-839e-ea315b9da885	Gelombang	Gelombang	PERSON	{}	\N	\N	4	0	0	2026-07-22 09:57:01.42483+00	2026-07-22 10:19:04.940223+00
13f0a554-3efc-45ba-bbdb-3c57691ecc9d	Terima Dubes Iran	Terima Dubes Iran	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.995403+00	2026-07-22 10:19:04.995403+00
84c0d10a-583c-4f0b-a529-1647db302640	Donny Ermawan Taufanto	Donny Ermawan Taufanto	PERSON	{}	\N	\N	3	0	0	2026-07-22 09:57:02.143367+00	2026-07-22 10:19:05.235245+00
e264ade9-b547-4ec9-9bdf-b86848dc7fa0	Knowledge Graph	Knowledge Graph	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.255153+00	2026-07-22 10:19:05.348391+00
3e4ae7e7-c01f-4700-bead-ada1392a1b08	Kecamatan Purwoasri	Kecamatan Purwoasri	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.883856+00	2026-07-22 10:19:04.883856+00
45b79c79-99c3-496a-b1b6-5865c8c6735d	Kabupaten Kediri	Kabupaten Kediri	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.883856+00	2026-07-22 10:19:04.883856+00
447df29e-fe58-4072-a90d-465d649d8e3a	Jasen Hioe	Jasen Hioe	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.848791+00	2026-07-22 10:19:04.952556+00
b137faf6-e343-4b44-9175-429e65a8deda	Kesehatan	Kesehatan	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.848791+00	2026-07-22 10:19:04.952556+00
ef27e9c4-5b85-478e-a632-f5f7d4ee4a51	Whip Pink	Whip Pink	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:01.848791+00	2026-07-22 10:19:04.952556+00
f18f7d6e-4746-417b-91ff-e4a1d35b66ec	Bangkalan	Bangkalan	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.03787+00	2026-07-22 10:19:05.100348+00
cd9a60a7-a432-4115-91a5-35b3ac778992	Jawa Timur	Jawa Timur	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.03787+00	2026-07-22 10:19:05.100348+00
cc8775c9-cc41-480d-bb67-2357d2c147de	Warga	Warga	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.03787+00	2026-07-22 10:19:05.100348+00
ef90622f-f647-4762-bc85-a2041ffe3be7	Luthfi Sampaikan Duka	Luthfi Sampaikan Duka	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.995403+00	2026-07-22 10:19:04.995403+00
548b7c60-6a65-4947-92db-03bbd76ec31e	Wafatnya Ali Khamenei	Wafatnya Ali Khamenei	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.995403+00	2026-07-22 10:19:04.995403+00
5eb3457c-cce2-48de-b4b0-cd46cc549b58	Gubernur Jateng Ahmad Luthfi	Gubernur Jateng Ahmad Luthfi	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.995403+00	2026-07-22 10:19:04.995403+00
31666dd9-4728-4786-8d30-c0519befbb67	Ali Khamenei	Ali Khamenei	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.995403+00	2026-07-22 10:19:04.995403+00
9def4989-2c88-45a7-80e9-49a371cf2359	Dubes Iran	Dubes Iran	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:04.995403+00	2026-07-22 10:19:04.995403+00
7d96df26-e516-4ae1-96bb-a6badbc9b33e	Saksi Diperiksa Dugaan Kelebihan Muatan	Saksi Diperiksa Dugaan Kelebihan Muatan	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:05.049823+00	2026-07-22 10:19:05.049823+00
d1ca7a07-91c2-4f48-beb2-50ddb88b9929	Pihak	Pihak	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:05.049823+00	2026-07-22 10:19:05.049823+00
0cf012e3-6ad8-4ee1-971d-e317243aa709	Perairan Kabupaten Kepulauan Selayar	Perairan Kabupaten Kepulauan Selayar	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:05.049823+00	2026-07-22 10:19:05.049823+00
635076c1-1781-42aa-8e9e-b1167ad3998d	Sulawesi Selatan	Sulawesi Selatan	PERSON	{}	\N	\N	1	0	0	2026-07-22 10:19:05.049823+00	2026-07-22 10:19:05.049823+00
3b4b3e92-1934-47b5-88ee-7bfa57971231	Indonesia	Indonesia	LOCATION	{}	\N	\N	133	0	0	2026-07-22 09:57:00.840877+00	2026-07-22 10:19:05.360947+00
a400eb28-4230-4166-ba06-3534faccd167	Eka Annash	Eka Annash	PERSON	{}	\N	\N	2	0	0	2026-07-22 09:57:02.011285+00	2026-07-22 10:19:05.360947+00
\.


--
-- Data for Name: entity_mentions_ts; Type: TABLE DATA; Schema: public; Owner: scie
--

COPY public.entity_mentions_ts ("time", entity_id, entity_name, platform, mention_count, sentiment_avg) FROM stdin;
\.


--
-- Data for Name: hashtags; Type: TABLE DATA; Schema: public; Owner: scie
--

COPY public.hashtags (id, text, platform, post_count, trend_score, first_seen) FROM stdin;
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: scie
--

COPY public.organizations (id, name, slug, plan, created_at, updated_at) FROM stdin;
00000000-0000-0000-0000-000000000001	SCIE Admin	scie-admin	enterprise	2026-07-21 17:23:12.561616+00	2026-07-21 17:23:12.561616+00
\.


--
-- Data for Name: platform_metrics; Type: TABLE DATA; Schema: public; Owner: scie
--

COPY public.platform_metrics ("time", platform, posts_count, unique_users, avg_engagement) FROM stdin;
\.


--
-- Data for Name: post_entities; Type: TABLE DATA; Schema: public; Owner: scie
--

COPY public.post_entities (post_id, entity_id, confidence) FROM stdin;
\.


--
-- Data for Name: posts; Type: TABLE DATA; Schema: public; Owner: scie
--

COPY public.posts (id, platform, platform_id, type, text, text_cleaned, language, url, author_id, parent_post_id, original_post_id, "timestamp", likes, comments, shares, views, bookmarks, sentiment_label, sentiment_score, emotions, topics, keywords, summary, virality_score, is_original, is_deleted, collected_at, processed_at) FROM stdin;
92c86bb3-e8ca-4874-ae68-7969a4119aac	news	c84d5f304876735c12e1feb9	article	Kemkomdigi resmikan Deklarasi Sekolah Cakap Digital dukung PP Tunas. Kementerian Komunikasi dan Digital (Kemkomdigi) bersama para tenaga pendidik dan perwakilan siswa dari delapan sekolah ...	Kemkomdigi resmikan Deklarasi Sekolah Cakap Digital dukung PP Tunas. Kementerian Komunikasi dan Digital (Kemkomdigi) bersama para tenaga pendidik dan perwakilan siswa dari delapan sekolah ...	id	https://www.antaranews.com/berita/5659627/kemkomdigi-resmikan-deklarasi-sekolah-cakap-digital-dukung-pp-tunas	6e9c0ef4-3ed9-4abf-817b-fdebb740ee27	\N	\N	2026-07-21 15:53:40+00	0	0	0	0	0	neutral	0	\N	{teknologi}	{kemkomdigi,sekolah,digital,resmikan,deklarasi}	\N	0	t	f	2026-07-21 17:28:03.566978+00	2026-07-21 17:28:03.566978+00
5789a80d-ef5f-4fe1-a3b0-1c80427c0d57	news	cb999f5bdd17f23a7e24d29b	article	Purbaya menilai DJP intip rekening wajib pajak praktik biasa. Menteri Keuangan (Menkeu) Purbaya Yudhi Sadewa menilai, kewenangan Direktorat Jenderal Pajak (DJP) untuk mengawasi ...	Purbaya menilai DJP intip rekening wajib pajak praktik biasa. Menteri Keuangan (Menkeu) Purbaya Yudhi Sadewa menilai, kewenangan Direktorat Jenderal Pajak (DJP) untuk mengawasi ...	id	https://www.antaranews.com/berita/5659609/purbaya-menilai-djp-intip-rekening-wajib-pajak-praktik-biasa	6e9c0ef4-3ed9-4abf-817b-fdebb740ee27	\N	\N	2026-07-21 15:46:12+00	0	0	0	0	0	neutral	0	\N	{politik}	{purbaya,menilai,pajak,intip,rekening}	\N	0	t	f	2026-07-21 17:28:03.600834+00	2026-07-21 17:28:03.600834+00
995e25dd-5c99-47b0-8175-514bfef72ac4	news	577b9e13495f1d3d5e90ad11	article	Menkes: Rokok elektrik sama bahayanya dengan rokok konvensional. Menteri Kesehatan (Menkes) Budi Gunadi Sadikin menegaskan rokok elektrik bukanlah alternatif yang lebih aman ...	Menkes: Rokok elektrik sama bahayanya dengan rokok konvensional. Menteri Kesehatan (Menkes) Budi Gunadi Sadikin menegaskan rokok elektrik bukanlah alternatif yang lebih aman ...	id	https://www.antaranews.com/berita/5659544/menkes-rokok-elektrik-sama-bahayanya-dengan-rokok-konvensional	6e9c0ef4-3ed9-4abf-817b-fdebb740ee27	\N	\N	2026-07-21 15:01:08+00	0	0	0	0	0	positive	1	\N	{politik}	{rokok,menkes,elektrik,sama,bahayanya}	\N	0	t	f	2026-07-21 17:28:03.613319+00	2026-07-21 17:28:03.613319+00
879ed81e-650c-474e-b9ad-8d3e276d201b	news	bd20707f809f18c60f4dfda2	article	Dua belas kursi MotoGP 2027 terisi setelah Quartararo gabung ke Honda. Sebanyak 12 dari 22 kursi pembalap MotoGP 2027 telah terisi setelah Fabio Quartararo dipastikan meninggalkan Yamaha ...	Dua belas kursi MotoGP 2027 terisi setelah Quartararo gabung ke Honda. Sebanyak 12 dari 22 kursi pembalap MotoGP 2027 telah terisi setelah Fabio Quartararo dipastikan meninggalkan Yamaha ...	id	https://www.antaranews.com/berita/5659423/dua-belas-kursi-motogp-2027-terisi-setelah-quartararo-gabung-ke-honda	6e9c0ef4-3ed9-4abf-817b-fdebb740ee27	\N	\N	2026-07-21 13:50:17+00	0	0	0	0	0	neutral	0	\N	{umum}	{kursi,motogp,terisi,setelah,quartararo}	\N	0	t	f	2026-07-21 17:28:03.623215+00	2026-07-21 17:28:03.623215+00
bf05a2dd-b53f-4aab-b9b6-0d1b845ea38f	news	3364194a0a73efaf20f9fe21	article	Purbaya sebut Bea Cukai batal dibubarkan setelah kinerjanya membaik. Menteri Keuangan (Menkeu) Purbaya Yudhi Sadewa menilai kinerja Direktorat Jenderal Bea dan Cukai (DJBC) telah ...	Purbaya sebut Bea Cukai batal dibubarkan setelah kinerjanya membaik. Menteri Keuangan (Menkeu) Purbaya Yudhi Sadewa menilai kinerja Direktorat Jenderal Bea dan Cukai (DJBC) telah ...	id	https://www.antaranews.com/berita/5659416/purbaya-sebut-bea-cukai-batal-dibubarkan-setelah-kinerjanya-membaik	6e9c0ef4-3ed9-4abf-817b-fdebb740ee27	\N	\N	2026-07-21 13:45:49+00	0	0	0	0	0	neutral	0	\N	{politik}	{purbaya,cukai,sebut,batal,dibubarkan}	\N	0	t	f	2026-07-21 17:28:03.634097+00	2026-07-21 17:28:03.634097+00
62936751-99cb-4028-8002-1f1563347e4c	news	cff7da672fcd51f9f91fa6db	article	Iran serang pusat data Amazon di Bahrain sebagai balasan kepada AS. Korps Garda Revolusi Islam Iran (IRGC) mengumumkan pihaknya telah menyerang pusat data milik raksasa perdagangan AS, ...	Iran serang pusat data Amazon di Bahrain sebagai balasan kepada AS. Korps Garda Revolusi Islam Iran (IRGC) mengumumkan pihaknya telah menyerang pusat data milik raksasa perdagangan AS, ...	id	https://www.antaranews.com/berita/5659403/iran-serang-pusat-data-amazon-di-bahrain-sebagai-balasan-kepada-as	6e9c0ef4-3ed9-4abf-817b-fdebb740ee27	\N	\N	2026-07-21 13:34:02+00	0	0	0	0	0	neutral	0	\N	{teknologi}	{iran,pusat,data,serang,amazon}	\N	0	t	f	2026-07-21 17:28:03.647233+00	2026-07-21 17:28:03.647233+00
c806061e-8d2d-4bbf-b793-db60adc8c3a2	news	725ff8480bcda284c5204e99	article	IDAI ingatkan orang tua jalin komunikasi dan cermati perilaku anak. Anggota Unit Kerja Koordinasi (UKK) Tumbuh Kembang dan Pediatri Sosial Ikatan Dokter Anak Indonesia Dr. Angga ...	IDAI ingatkan orang tua jalin komunikasi dan cermati perilaku anak. Anggota Unit Kerja Koordinasi (UKK) Tumbuh Kembang dan Pediatri Sosial Ikatan Dokter Anak Indonesia Dr. Angga ...	id	https://www.antaranews.com/berita/5659400/idai-ingatkan-orang-tua-jalin-komunikasi-dan-cermati-perilaku-anak	6e9c0ef4-3ed9-4abf-817b-fdebb740ee27	\N	\N	2026-07-21 13:33:13+00	0	0	0	0	0	positive	1	\N	{sosial}	{anak,idai,ingatkan,orang,jalin}	\N	0	t	f	2026-07-21 17:28:03.658754+00	2026-07-21 17:28:03.658754+00
a588f78a-383e-470a-909b-5e80275f6bec	news	090d4d17dbd5e230e8854f1a	article	Indonesia minta ASEAN tingkatkan kesiapsiagaan hadapi krisis global. Menteri Luar Negeri Indonesia Sugiono mendorong ASEAN untuk memperkuat ketahanan dan kesiapsiagaan bersama dalam ...	Indonesia minta ASEAN tingkatkan kesiapsiagaan hadapi krisis global. Menteri Luar Negeri Indonesia Sugiono mendorong ASEAN untuk memperkuat ketahanan dan kesiapsiagaan bersama dalam ...	id	https://www.antaranews.com/berita/5659379/indonesia-minta-asean-tingkatkan-kesiapsiagaan-hadapi-krisis-global	6e9c0ef4-3ed9-4abf-817b-fdebb740ee27	\N	\N	2026-07-21 13:17:29+00	0	0	0	0	0	negative	-1	\N	{politik}	{indonesia,asean,kesiapsiagaan,minta,tingkatkan}	\N	0	t	f	2026-07-21 17:28:03.671285+00	2026-07-21 17:28:03.671285+00
2657d9d9-1bb5-4175-acf7-2f78b3874005	news	eda64d85abf5df3030fb84a8	article	Mendikdasmen siapkan rekrutmen guru PNS Sekolah Nasional Terintegrasi. Kementerian Pendidikan Dasar dan Menengah (Kemendikdasmen) tengah menyiapkan rekrutmen guru dengan status Pegawai ...	Mendikdasmen siapkan rekrutmen guru PNS Sekolah Nasional Terintegrasi. Kementerian Pendidikan Dasar dan Menengah (Kemendikdasmen) tengah menyiapkan rekrutmen guru dengan status Pegawai ...	id	https://www.antaranews.com/berita/5659095/mendikdasmen-siapkan-rekrutmen-guru-pns-sekolah-nasional-terintegrasi	6e9c0ef4-3ed9-4abf-817b-fdebb740ee27	\N	\N	2026-07-21 11:25:43+00	0	0	0	0	0	neutral	0	\N	{sosial}	{rekrutmen,guru,mendikdasmen,siapkan,sekolah}	\N	0	t	f	2026-07-21 17:28:03.68165+00	2026-07-21 17:28:03.68165+00
44e4f6c2-6dcc-4b68-8388-69615ac0fc60	news	715dff87ca549e42b65fa49b	article	Menteri Bahlil: Impor minyak Rusia tahap pertama sudah dilakukan. Menteri Energi dan Sumber Daya Mineral (ESDM) Bahlil Lahadalia menyampaikan pemerintah sudah melakukan impor minyak ...	Menteri Bahlil: Impor minyak Rusia tahap pertama sudah dilakukan. Menteri Energi dan Sumber Daya Mineral (ESDM) Bahlil Lahadalia menyampaikan pemerintah sudah melakukan impor minyak ...	id	https://www.antaranews.com/berita/5658989/menteri-bahlil-impor-minyak-rusia-tahap-pertama-sudah-dilakukan	6e9c0ef4-3ed9-4abf-817b-fdebb740ee27	\N	\N	2026-07-21 10:41:03+00	0	0	0	0	0	neutral	0	\N	{politik,ekonomi}	{menteri,bahlil,impor,minyak,sudah}	\N	0	t	f	2026-07-21 17:28:03.694152+00	2026-07-21 17:28:03.694152+00
88dfeb20-d0fe-4417-93f5-f83779b33a3a	news	955debeb93a685f0fa2de44c	article	Pemerintah tegaskan komitmen wujudkan ekosistem kendaraan listrik. Menteri Sekretaris Negara Prasetyo Hadi menegaskan Pemerintah berkomitmen untuk terus mendorong transformasi ekosistem ...	Pemerintah tegaskan komitmen wujudkan ekosistem kendaraan listrik. Menteri Sekretaris Negara Prasetyo Hadi menegaskan Pemerintah berkomitmen untuk terus mendorong transformasi ekosistem ...	id	https://www.antaranews.com/berita/5658977/pemerintah-tegaskan-komitmen-wujudkan-ekosistem-kendaraan-listrik	6e9c0ef4-3ed9-4abf-817b-fdebb740ee27	\N	\N	2026-07-21 10:37:37+00	0	0	0	0	0	neutral	0	\N	{politik}	{pemerintah,ekosistem,tegaskan,komitmen,wujudkan}	\N	0	t	f	2026-07-21 17:28:03.708219+00	2026-07-21 17:28:03.708219+00
ede7c5d3-1446-422f-b2af-47fe5837af20	news	1312cae4c9675aec8590048d	article	Pelabuhan Benoa Denpasar dikembangkan menjadi Bali Maritime Tourism Hub. Petugas berjalan di Zona Marina kawasan Bali Maritime Tourism Hub (BMTH) Pelabuhan Benoa, Denpasar, Bali, Selasa ...	Pelabuhan Benoa Denpasar dikembangkan menjadi Bali Maritime Tourism Hub. Petugas berjalan di Zona Marina kawasan Bali Maritime Tourism Hub (BMTH) Pelabuhan Benoa, Denpasar, Bali, Selasa ...	id	https://www.antaranews.com/foto/5658955/pelabuhan-benoa-denpasar-dikembangkan-menjadi-bali-maritime-tourism-hub	6e9c0ef4-3ed9-4abf-817b-fdebb740ee27	\N	\N	2026-07-21 10:32:04+00	0	0	0	0	0	neutral	0	\N	{umum}	{bali,pelabuhan,benoa,denpasar,maritime}	\N	0	t	f	2026-07-21 17:28:03.719566+00	2026-07-21 17:28:03.719566+00
f4909d7d-8c59-48bd-b5d8-c2e299efcfd2	news	ace5142ffcdc056a09cf6913	article	Purbaya lapor APBN cetak defisit Rp196,5 triliun per Juni 2026. Menteri Keuangan Purbaya Yudhi Sadewa melaporkan Anggaran Pendapatan dan Belanja Negara (APBN) mencatat defisit sebesar ...	Purbaya lapor APBN cetak defisit Rp196,5 triliun per Juni 2026. Menteri Keuangan Purbaya Yudhi Sadewa melaporkan Anggaran Pendapatan dan Belanja Negara (APBN) mencatat defisit sebesar ...	id	https://www.antaranews.com/berita/5658855/purbaya-lapor-apbn-cetak-defisit-rp1965-triliun-per-juni-2026	6e9c0ef4-3ed9-4abf-817b-fdebb740ee27	\N	\N	2026-07-21 09:56:30+00	0	0	0	0	0	neutral	0	\N	{politik}	{purbaya,apbn,defisit,lapor,cetak}	\N	0	t	f	2026-07-21 17:28:03.733618+00	2026-07-21 17:28:03.733618+00
4dec0989-2c0f-4041-99b6-8ef75cbd6769	news	b7b502261a070ea1d1b8d081	article	Prabowo segera teken Keppres pengangkatan Jampidsus. Menteri Sekretaris Negara Prasetyo Hadi mengatakan Presiden Prabowo Subianto akan segera menandatangani Keputusan ...	Prabowo segera teken Keppres pengangkatan Jampidsus. Menteri Sekretaris Negara Prasetyo Hadi mengatakan Presiden Prabowo Subianto akan segera menandatangani Keputusan ...	id	https://www.antaranews.com/berita/5658833/prabowo-segera-teken-keppres-pengangkatan-jampidsus	6e9c0ef4-3ed9-4abf-817b-fdebb740ee27	\N	\N	2026-07-21 09:47:06+00	0	0	0	0	0	neutral	0	\N	{politik}	{prabowo,segera,teken,keppres,pengangkatan}	\N	0	t	f	2026-07-21 17:28:03.745068+00	2026-07-21 17:28:03.745068+00
376dc406-f4dc-4f7c-9b1b-4a669f1f1d88	news	a02ead163205cfb870182b00	article	Rupiah menguat seiring meredanya kekhawatiran investor pada fiskal RI. Nilai tukar (kurs) rupiah pada penutupan perdagangan Rabu sore menguat 60 poin atau 0,33 persen menjadi Rp17.888 per ...	Rupiah menguat seiring meredanya kekhawatiran investor pada fiskal RI. Nilai tukar (kurs) rupiah pada penutupan perdagangan Rabu sore menguat 60 poin atau 0,33 persen menjadi Rp17.888 per ...	id	https://www.antaranews.com/berita/5658816/rupiah-menguat-seiring-meredanya-kekhawatiran-investor-pada-fiskal-ri	6e9c0ef4-3ed9-4abf-817b-fdebb740ee27	\N	\N	2026-07-21 09:39:53+00	0	0	0	0	0	neutral	0	\N	{umum}	{rupiah,menguat,seiring,meredanya,kekhawatiran}	\N	0	t	f	2026-07-21 17:28:03.758296+00	2026-07-21 17:28:03.758296+00
85c0e249-f76f-4db5-b843-173b98f321ce	news	c491aaa25851ded523c94329	article	Korban tewas gempa Venezuela tembus 5.278 orang, 23.500 mengungsi. Jumlah korban tewas akibat dua gempa bumi yang mengguncang Venezuela pada 24 Juni bertambah menjadi 5.278 orang, ...	Korban tewas gempa Venezuela tembus 5.278 orang, 23.500 mengungsi. Jumlah korban tewas akibat dua gempa bumi yang mengguncang Venezuela pada 24 Juni bertambah menjadi 5.278 orang, ...	id	https://www.antaranews.com/berita/5658753/korban-tewas-gempa-venezuela-tembus-5278-orang-23500-mengungsi	6e9c0ef4-3ed9-4abf-817b-fdebb740ee27	\N	\N	2026-07-21 09:15:26+00	0	0	0	0	0	neutral	0	\N	{lingkungan}	{korban,tewas,gempa,venezuela,orang}	\N	0	t	f	2026-07-21 17:28:03.770875+00	2026-07-21 17:28:03.770875+00
18372536-17b6-4866-86fe-28227e4c565c	news	d81c6e987fe015f26ff8aef5	article	ASEAN desak AS dan Iran untuk tahan eskalasi konflik. Perhimpunan Bangsa-Bangsa Asia Tenggara (ASEAN) mendesak Amerika Serikat dan Iran untuk mengendalikan diri, karena ...	ASEAN desak AS dan Iran untuk tahan eskalasi konflik. Perhimpunan Bangsa-Bangsa Asia Tenggara (ASEAN) mendesak Amerika Serikat dan Iran untuk mengendalikan diri, karena ...	id	https://www.antaranews.com/berita/5658751/asean-desak-as-dan-iran-untuk-tahan-eskalasi-konflik	6e9c0ef4-3ed9-4abf-817b-fdebb740ee27	\N	\N	2026-07-21 09:13:42+00	0	0	0	0	0	negative	-1	\N	{umum}	{asean,iran,bangsa,desak,tahan}	\N	0	t	f	2026-07-21 17:28:03.783429+00	2026-07-21 17:28:03.783429+00
6d3efd7d-dee8-4c7e-b3dc-dea44e8b8607	news	4fbca3feb0d723990da5ab1e	article	Macet parah di Cakung-Cilincing akibat aktivitas bongkar muat di depo. Satuan Lalu Lintas (Satlantas) Polres Metro Jakarta Timur mengungkapkan kemacetan parah yang terjadi di ruas Jalan Raya ...	Macet parah di Cakung-Cilincing akibat aktivitas bongkar muat di depo. Satuan Lalu Lintas (Satlantas) Polres Metro Jakarta Timur mengungkapkan kemacetan parah yang terjadi di ruas Jalan Raya ...	id	https://www.antaranews.com/berita/5658749/macet-parah-di-cakung-cilincing-akibat-aktivitas-bongkar-muat-di-depo	6e9c0ef4-3ed9-4abf-817b-fdebb740ee27	\N	\N	2026-07-21 09:11:11+00	0	0	0	0	0	negative	-1	\N	{umum}	{parah,macet,cakung,cilincing,akibat}	\N	0	t	f	2026-07-21 17:28:03.796102+00	2026-07-21 17:28:03.796102+00
740d91e6-fb0d-4e91-9e89-d75442d095cd	news	164bd9fccf93d34082e0e485	article	ASEAN tetapkan Jerman, Qatar jadi mitra dialog sektoral. Menteri luar negeri ASEAN menyetujui pemberian status Mitra Dialog Sektoral kepada Jerman dan Qatar, serta menerima ...	ASEAN tetapkan Jerman, Qatar jadi mitra dialog sektoral. Menteri luar negeri ASEAN menyetujui pemberian status Mitra Dialog Sektoral kepada Jerman dan Qatar, serta menerima ...	id	https://www.antaranews.com/berita/5658716/asean-tetapkan-jerman-qatar-jadi-mitra-dialog-sektoral	6e9c0ef4-3ed9-4abf-817b-fdebb740ee27	\N	\N	2026-07-21 09:04:03+00	0	0	0	0	0	neutral	0	\N	{politik}	{asean,jerman,qatar,mitra,dialog}	\N	0	t	f	2026-07-21 17:28:03.812185+00	2026-07-21 17:28:03.812185+00
8b74a6ae-f389-4b31-90f9-dacfccc76981	news	86d80502f695dc20449670f5	article	Waka MPR: Program Kompor Listrik Bergulir 2027 untuk kurangi subsidi. Wakil Ketua MPR RI Eddy Soeparno mengatakan bahwa pada 2027 pemerintah melakukan transisi dari kompor gas menjadi ...	Waka MPR: Program Kompor Listrik Bergulir 2027 untuk kurangi subsidi. Wakil Ketua MPR RI Eddy Soeparno mengatakan bahwa pada 2027 pemerintah melakukan transisi dari kompor gas menjadi ...	id	https://www.antaranews.com/berita/5658660/waka-mpr-program-kompor-listrik-bergulir-2027-untuk-kurangi-subsidi	6e9c0ef4-3ed9-4abf-817b-fdebb740ee27	\N	\N	2026-07-21 08:27:12+00	0	0	0	0	0	neutral	0	\N	{politik}	{kompor,waka,program,listrik,bergulir}	\N	0	t	f	2026-07-21 17:28:03.82217+00	2026-07-21 17:28:03.82217+00
ef533fc2-c981-4d03-bdf9-ecf7cf4fb6e2	news	28d4492d7c5fe1d46c942143	article	Bahlil akan bahas TransJakarta berbasis hidrogen dengan Gubernur DKI. Menteri Energi dan Sumber Daya Mineral (ESDM) Bahlil Lahadalia menyampaikan akan membahas penggunaan bus TransJakarta ...	Bahlil akan bahas TransJakarta berbasis hidrogen dengan Gubernur DKI. Menteri Energi dan Sumber Daya Mineral (ESDM) Bahlil Lahadalia menyampaikan akan membahas penggunaan bus TransJakarta ...	id	https://www.antaranews.com/berita/5658657/bahlil-akan-bahas-transjakarta-berbasis-hidrogen-dengan-gubernur-dki	6e9c0ef4-3ed9-4abf-817b-fdebb740ee27	\N	\N	2026-07-21 08:22:03+00	0	0	0	0	0	neutral	0	\N	{politik}	{bahlil,transjakarta,bahas,berbasis,hidrogen}	\N	0	t	f	2026-07-21 17:28:03.835245+00	2026-07-21 17:28:03.835245+00
a3b2a13d-9e86-4807-9551-eafe45b8b8a5	news	c2b9a2cd7310e0e9dce36c27	article	Kemendikdasmen: Pengumuman seleksi SPMB Sekolah Terintegrasi 3 Agustus. Kementerian Pendidikan Dasar dan Menengah (Kemendikdasmen) membuka Sistem Penerimaan Murid Baru (SPMB) untuk Sekolah ...	Kemendikdasmen: Pengumuman seleksi SPMB Sekolah Terintegrasi 3 Agustus. Kementerian Pendidikan Dasar dan Menengah (Kemendikdasmen) membuka Sistem Penerimaan Murid Baru (SPMB) untuk Sekolah ...	id	https://www.antaranews.com/berita/5658605/kemendikdasmen-pengumuman-seleksi-spmb-sekolah-terintegrasi-3-agustus	6e9c0ef4-3ed9-4abf-817b-fdebb740ee27	\N	\N	2026-07-21 08:01:23+00	0	0	0	0	0	neutral	0	\N	{sosial}	{kemendikdasmen,spmb,sekolah,pengumuman,seleksi}	\N	0	t	f	2026-07-21 17:28:03.848893+00	2026-07-21 17:28:03.848893+00
c985321b-eb32-4ce8-bd12-0f3477786586	news	fe5e5072ca6fc30e262d6b4a	article	KPK periksa mantan Presdir PPT ET Tokyo Mochamad Harun sebagai saksi. Komisi Pemberantasan Korupsi (KPK) memeriksa mantan Presiden Direktur PPT Energy Trading (PPT ET) Tokyo Mochamad Harun ...	KPK periksa mantan Presdir PPT ET Tokyo Mochamad Harun sebagai saksi. Komisi Pemberantasan Korupsi (KPK) memeriksa mantan Presiden Direktur PPT Energy Trading (PPT ET) Tokyo Mochamad Harun ...	id	https://www.antaranews.com/berita/5658587/kpk-periksa-mantan-presdir-ppt-et-tokyo-mochamad-harun-sebagai-saksi	6e9c0ef4-3ed9-4abf-817b-fdebb740ee27	\N	\N	2026-07-21 07:51:14+00	0	0	0	0	0	negative	-1	\N	{hukum,politik}	{mantan,tokyo,mochamad,harun,periksa}	\N	0	t	f	2026-07-21 17:28:03.86399+00	2026-07-21 17:28:03.86399+00
a0411ec8-7401-4c42-afbf-11546ee719b6	news	15fd8f4567de643eeccdaca6	article	Menkum: Tak perlu resah soal tarif naturalisasi dan lepas status WNI. Menteri Hukum Supratman Andi Agtas mengimbau masyarakat untuk tidak khawatir dengan naiknya tarif untuk melepaskan ...	Menkum: Tak perlu resah soal tarif naturalisasi dan lepas status WNI. Menteri Hukum Supratman Andi Agtas mengimbau masyarakat untuk tidak khawatir dengan naiknya tarif untuk melepaskan ...	id	https://www.antaranews.com/berita/5658577/menkum-tak-perlu-resah-soal-tarif-naturalisasi-dan-lepas-status-wni	6e9c0ef4-3ed9-4abf-817b-fdebb740ee27	\N	\N	2026-07-21 07:46:06+00	0	0	0	0	0	neutral	0	\N	{politik,ekonomi}	{tarif,menkum,perlu,resah,soal}	\N	0	t	f	2026-07-21 17:28:03.878239+00	2026-07-21 17:28:03.878239+00
5bf8e20a-0fe9-4f05-b661-77b415f1a086	news	3b744bf35863b5685babd3b4	article	Menko AHY membahas relokasi kapal ikan Pelabuhan Benoa jadi marina. Menteri Koordinator (Menko) Bidang Infrastruktur dan Pembangunan Kewilayahan Agus Harimurti Yudhoyono (AHY) membahas ...	Menko AHY membahas relokasi kapal ikan Pelabuhan Benoa jadi marina. Menteri Koordinator (Menko) Bidang Infrastruktur dan Pembangunan Kewilayahan Agus Harimurti Yudhoyono (AHY) membahas ...	id	https://www.antaranews.com/berita/5658556/menko-ahy-membahas-relokasi-kapal-ikan-pelabuhan-benoa-jadi-marina	6e9c0ef4-3ed9-4abf-817b-fdebb740ee27	\N	\N	2026-07-21 07:39:21+00	0	0	0	0	0	neutral	0	\N	{politik}	{menko,membahas,relokasi,kapal,ikan}	\N	0	t	f	2026-07-21 17:28:03.88671+00	2026-07-21 17:28:03.88671+00
419f6e65-82ec-4549-b64b-2cec2384a0b6	news	adc075b02b8f215c3883b869	article	KPK periksa Kepala BPK Perwakilan Sumsel Rio Tirta sebagai saksi. Komisi Pemberantasan Korupsi (KPK) memeriksa Kepala Badan Pemeriksa Keuangan (BPK) Perwakilan Provinsi Sumatera Selatan ...	KPK periksa Kepala BPK Perwakilan Sumsel Rio Tirta sebagai saksi. Komisi Pemberantasan Korupsi (KPK) memeriksa Kepala Badan Pemeriksa Keuangan (BPK) Perwakilan Provinsi Sumatera Selatan ...	id	https://www.antaranews.com/berita/5658537/kpk-periksa-kepala-bpk-perwakilan-sumsel-rio-tirta-sebagai-saksi	6e9c0ef4-3ed9-4abf-817b-fdebb740ee27	\N	\N	2026-07-21 07:28:31+00	0	0	0	0	0	negative	-1	\N	{hukum}	{kepala,perwakilan,periksa,sumsel,tirta}	\N	0	t	f	2026-07-21 17:28:03.898215+00	2026-07-21 17:28:03.898215+00
980d427e-c97e-4573-9204-cc2ae9279f0b	news	316e1f5f9f4c590eabbc771c	article	WHO: RI berhasil perluas cakupan imunisasi anak dan tutup kesenjangan. Organisasi Kesehatan Dunia (WHO) menyatakan Indonesia berhasil memperluas cakupan imunisasi anak dan menutup ...	WHO: RI berhasil perluas cakupan imunisasi anak dan tutup kesenjangan. Organisasi Kesehatan Dunia (WHO) menyatakan Indonesia berhasil memperluas cakupan imunisasi anak dan menutup ...	id	https://www.antaranews.com/berita/5658521/who-ri-berhasil-perluas-cakupan-imunisasi-anak-dan-tutup-kesenjangan	6e9c0ef4-3ed9-4abf-817b-fdebb740ee27	\N	\N	2026-07-21 07:16:45+00	0	0	0	0	0	positive	1	\N	{umum}	{berhasil,cakupan,imunisasi,anak,perluas}	\N	0	t	f	2026-07-21 17:28:03.913704+00	2026-07-21 17:28:03.913704+00
49038911-482a-44ba-a993-4078d85a0b42	news	02150f76aafc67eefa1c120c	article	Mirae sebut peluang pasar saham RI ditopang valuasi dan status MSCI. PT Mirae Asset Sekuritas Indonesia (MASI) menyebutkan arah pergerakan pasar saham Indonesia, ditentukan oleh kondisi ...	Mirae sebut peluang pasar saham RI ditopang valuasi dan status MSCI. PT Mirae Asset Sekuritas Indonesia (MASI) menyebutkan arah pergerakan pasar saham Indonesia, ditentukan oleh kondisi ...	id	https://www.antaranews.com/berita/5658515/mirae-sebut-peluang-pasar-saham-ri-ditopang-valuasi-dan-status-msci	6e9c0ef4-3ed9-4abf-817b-fdebb740ee27	\N	\N	2026-07-21 07:14:59+00	0	0	0	0	0	neutral	0	\N	{ekonomi}	{mirae,pasar,saham,indonesia,sebut}	\N	0	t	f	2026-07-21 17:28:03.925575+00	2026-07-21 17:28:03.925575+00
747539d6-2cbd-450f-b1e3-9c7a0b13d747	news	21e20cc01c9b24b0cadfd960	article	KPK mulai panggil saksi kasus Bupati Langkat nonaktif Syah Afandin. Komisi Pemberantasan Korupsi (KPK) mulai memanggil saksi dalam penyidikan kasus dugaan suap yang menjerat Bupati ...	KPK mulai panggil saksi kasus Bupati Langkat nonaktif Syah Afandin. Komisi Pemberantasan Korupsi (KPK) mulai memanggil saksi dalam penyidikan kasus dugaan suap yang menjerat Bupati ...	id	https://www.antaranews.com/berita/5658484/kpk-mulai-panggil-saksi-kasus-bupati-langkat-nonaktif-syah-afandin	6e9c0ef4-3ed9-4abf-817b-fdebb740ee27	\N	\N	2026-07-21 07:02:30+00	0	0	0	0	0	negative	-1	\N	{hukum}	{mulai,saksi,kasus,bupati,panggil}	\N	0	t	f	2026-07-21 17:28:03.939673+00	2026-07-21 17:28:03.939673+00
fcbcb00e-c732-4af1-adf6-1f496fb6b0a7	news	478bb546a9c9f89b681b7fd5	article	Kemenkes pacu penelusuran kasus di daerah, percepat eliminasi TBC. Wakil Menteri Kesehatan (Wamenkes) Benjamin Paulus Octavianus mengatakan penelusuran (tracing) kasus tuberkulosis (TBC) ...	Kemenkes pacu penelusuran kasus di daerah, percepat eliminasi TBC. Wakil Menteri Kesehatan (Wamenkes) Benjamin Paulus Octavianus mengatakan penelusuran (tracing) kasus tuberkulosis (TBC) ...	id	https://www.antaranews.com/berita/5658380/kemenkes-pacu-penelusuran-kasus-di-daerah-percepat-eliminasi-tbc	6e9c0ef4-3ed9-4abf-817b-fdebb740ee27	\N	\N	2026-07-21 05:55:16+00	0	0	0	0	0	neutral	0	\N	{politik,hukum}	{penelusuran,kasus,kemenkes,pacu,daerah}	\N	0	t	f	2026-07-21 17:28:03.955856+00	2026-07-21 17:28:03.955856+00
03f9a117-f0f9-4984-b195-abc3fd7deed1	news	598670e98db7e322e8eb5e38	article	Berikut rangkuman lawatan Ratu Máxima di Indonesia. Ratu Máxima baru saja merampungkan rangkaian kunjungan kerjanya ke Indonesia yang berlangsung sejak Senin hingga ...	Berikut rangkuman lawatan Ratu Máxima di Indonesia. Ratu Máxima baru saja merampungkan rangkaian kunjungan kerjanya ke Indonesia yang berlangsung sejak Senin hingga ...	id	https://www.antaranews.com/berita/5270237/berikut-rangkuman-lawatan-ratu-mxima-di-indonesia	c29b0cad-cf1e-40be-b1d2-9d0f986841dc	\N	\N	2025-11-27 06:58:38+00	0	0	0	0	0	neutral	0	\N	{umum}	{ratu,indonesia,berikut,rangkuman,lawatan}	\N	0	t	f	2026-07-21 17:28:03.972589+00	2026-07-21 17:28:03.972589+00
dd540c8f-995b-4c83-8818-8d3ba9d42462	news	85d70307f0a3638840b9e974	article	Profil istri Wiranto, Rugaiya Usman. Keluarga besar Jenderal (Purn) TNI Wiranto tengah berduka atas wafatnya sang istri, Rugaiya Usman, yang meninggal dunia ...	Profil istri Wiranto, Rugaiya Usman. Keluarga besar Jenderal (Purn) TNI Wiranto tengah berduka atas wafatnya sang istri, Rugaiya Usman, yang meninggal dunia ...	id	https://www.antaranews.com/berita/5247525/profil-istri-wiranto-rugaiya-usman	c29b0cad-cf1e-40be-b1d2-9d0f986841dc	\N	\N	2025-11-17 11:33:12+00	0	0	0	0	0	neutral	0	\N	{umum}	{istri,wiranto,rugaiya,usman,profil}	\N	0	t	f	2026-07-21 17:28:03.989084+00	2026-07-21 17:28:03.989084+00
e20e6cd2-b0f3-475e-b3e1-02d54b0e679e	news	9e4639e7cb605e027b164188	article	Raja Yordania Abdullah II sambangi Indonesia, berikut profilnya. Raja Yordania Abdullah Bin Al-Hussein (Abdullah II) dijadwalkan melakukan kunjungan kenegaraan ke Indonesia pada Jumat ...	Raja Yordania Abdullah II sambangi Indonesia, berikut profilnya. Raja Yordania Abdullah Bin Al-Hussein (Abdullah II) dijadwalkan melakukan kunjungan kenegaraan ke Indonesia pada Jumat ...	id	https://www.antaranews.com/berita/5243173/raja-yordania-abdullah-ii-sambangi-indonesia-berikut-profilnya	c29b0cad-cf1e-40be-b1d2-9d0f986841dc	\N	\N	2025-11-14 14:44:23+00	0	0	0	0	0	neutral	0	\N	{umum}	{abdullah,raja,yordania,indonesia,sambangi}	\N	0	t	f	2026-07-21 17:28:04.010067+00	2026-07-21 17:28:04.010067+00
037d54a6-8595-45d4-a5c5-cb4933f28fe3	news	e9ce26bef6e5b9979613d403	article	Kilas balik hubungan bersejarah Prabowo dan Raja Yordania. Raja Yordania Abdullah Bin Al-Hussein (Abdullah II) dijadwalkan melakukan kunjungan kenegaraan ke Indonesia pada Jumat ...	Kilas balik hubungan bersejarah Prabowo dan Raja Yordania. Raja Yordania Abdullah Bin Al-Hussein (Abdullah II) dijadwalkan melakukan kunjungan kenegaraan ke Indonesia pada Jumat ...	id	https://www.antaranews.com/berita/5243169/kilas-balik-hubungan-bersejarah-prabowo-dan-raja-yordania	c29b0cad-cf1e-40be-b1d2-9d0f986841dc	\N	\N	2025-11-14 14:43:31+00	0	0	0	0	0	neutral	0	\N	{umum}	{raja,yordania,abdullah,kilas,balik}	\N	0	t	f	2026-07-21 17:28:04.030904+00	2026-07-21 17:28:04.030904+00
fedbe997-a429-47ae-9dc6-fa3723b98f3a	news	d9d3326c888ab64cfb389813	article	Profil Sari Yuliati pengganti Mukhtarudin sebagai sekretaris F-Golkar di DPR. Nama Sari Yuliati tengah menjadi sorotan publik karena dirinya kini ditetapkan sebagai Sekretaris Fraksi Partai Golkar ...	Profil Sari Yuliati pengganti Mukhtarudin sebagai sekretaris F-Golkar di DPR. Nama Sari Yuliati tengah menjadi sorotan publik karena dirinya kini ditetapkan sebagai Sekretaris Fraksi Partai Golkar ...	id	https://www.antaranews.com/berita/5240457/profil-sari-yuliati-pengganti-mukhtarudin-sebagai-sekretaris-f-golkar-di-dpr	c29b0cad-cf1e-40be-b1d2-9d0f986841dc	\N	\N	2025-11-13 13:05:26+00	0	0	0	0	0	neutral	0	\N	{politik}	{sari,yuliati,sekretaris,golkar,profil}	\N	0	t	f	2026-07-21 17:28:04.05164+00	2026-07-21 17:28:04.05164+00
2e05be56-3574-4a77-b5fb-f81ab18cc68a	news	ba949f4c119ee6e68c785701	article	Sosok Marsinah, buruh tangguh yang ditetapkan sebagai pahlawan. Presiden Prabowo Subianto pada peringatan Hari Pahlawan, Senin (10/11), di Istana Negara Jakarta, resmi menganugerahkan ...	Sosok Marsinah, buruh tangguh yang ditetapkan sebagai pahlawan. Presiden Prabowo Subianto pada peringatan Hari Pahlawan, Senin (10/11), di Istana Negara Jakarta, resmi menganugerahkan ...	id	https://www.antaranews.com/berita/5234417/sosok-marsinah-buruh-tangguh-yang-ditetapkan-sebagai-pahlawan	c29b0cad-cf1e-40be-b1d2-9d0f986841dc	\N	\N	2025-11-11 07:44:54+00	0	0	0	0	0	neutral	0	\N	{politik}	{pahlawan,sosok,marsinah,buruh,tangguh}	\N	0	t	f	2026-07-21 17:28:04.068771+00	2026-07-21 17:28:04.068771+00
322dcac9-f076-42a2-9d25-0093d5d650ab	news	f168536356116d151df1d6a1	article	Riwayat Mochtar Kusumaatmadja yang dianugerahi Pahlawan Nasional. Presiden RI Prabowo Subianto baru saja menganugerahi gelar Pahlawan Nasional kepada sepuluh tokoh pada peringatan Hari ...	Riwayat Mochtar Kusumaatmadja yang dianugerahi Pahlawan Nasional. Presiden RI Prabowo Subianto baru saja menganugerahi gelar Pahlawan Nasional kepada sepuluh tokoh pada peringatan Hari ...	id	https://www.antaranews.com/berita/5233365/riwayat-mochtar-kusumaatmadja-yang-dianugerahi-pahlawan-nasional	c29b0cad-cf1e-40be-b1d2-9d0f986841dc	\N	\N	2025-11-10 16:59:59+00	0	0	0	0	0	neutral	0	\N	{politik}	{pahlawan,nasional,riwayat,mochtar,kusumaatmadja}	\N	0	t	f	2026-07-21 17:28:04.093672+00	2026-07-21 17:28:04.093672+00
f2804d58-03a0-4a18-989e-9d3454914d1d	news	c5fee2fc6a7dea2bea21d318	article	Profil 10 pahlawan nasional baru yang ditetapkan Prabowo tahun 2025. Setiap tanggal 10 November, bangsa Indonesia memperingati Hari Pahlawan sebagai bentuk penghormatan atas perjuangan ...	Profil 10 pahlawan nasional baru yang ditetapkan Prabowo tahun 2025. Setiap tanggal 10 November, bangsa Indonesia memperingati Hari Pahlawan sebagai bentuk penghormatan atas perjuangan ...	id	https://www.antaranews.com/berita/5233357/profil-10-pahlawan-nasional-baru-yang-ditetapkan-prabowo-tahun-2025	c29b0cad-cf1e-40be-b1d2-9d0f986841dc	\N	\N	2025-11-10 16:58:09+00	0	0	0	0	0	neutral	0	\N	{umum}	{pahlawan,profil,nasional,baru,ditetapkan}	\N	0	t	f	2026-07-21 17:28:04.116443+00	2026-07-21 17:28:04.116443+00
1d56bfac-68af-46c1-9ab3-d01d1411c37f	news	e86b698813da31056727c455	article	Sosok Zainal Abidin Syah yang perjuangkan Irian Barat bagian NKRI. Presiden RI Prabowo Subianto baru saja menganugerahi gelar Pahlawan Nasional kepada sepuluh tokoh pada peringatan Hari ...	Sosok Zainal Abidin Syah yang perjuangkan Irian Barat bagian NKRI. Presiden RI Prabowo Subianto baru saja menganugerahi gelar Pahlawan Nasional kepada sepuluh tokoh pada peringatan Hari ...	id	https://www.antaranews.com/berita/5233321/sosok-zainal-abidin-syah-yang-perjuangkan-irian-barat-bagian-nkri	c29b0cad-cf1e-40be-b1d2-9d0f986841dc	\N	\N	2025-11-10 16:51:16+00	0	0	0	0	0	neutral	0	\N	{politik}	{sosok,zainal,abidin,syah,perjuangkan}	\N	0	t	f	2026-07-21 17:28:04.137821+00	2026-07-21 17:28:04.137821+00
2793824e-744e-4a46-ad44-47347297e3db	news	d371843b855a9141d6e34227	article	Tuan Rondahaim Saragih, Napoleon dari Batak yang dapat gelar pahlawan. Presiden RI Prabowo Subianto baru saja menganugerahi gelar Pahlawan Nasional kepada sepuluh tokoh pada peringatan Hari ...	Tuan Rondahaim Saragih, Napoleon dari Batak yang dapat gelar pahlawan. Presiden RI Prabowo Subianto baru saja menganugerahi gelar Pahlawan Nasional kepada sepuluh tokoh pada peringatan Hari ...	id	https://www.antaranews.com/berita/5233285/tuan-rondahaim-saragih-napoleon-dari-batak-yang-dapat-gelar-pahlawan	c29b0cad-cf1e-40be-b1d2-9d0f986841dc	\N	\N	2025-11-10 16:41:37+00	0	0	0	0	0	neutral	0	\N	{politik}	{gelar,pahlawan,tuan,rondahaim,saragih}	\N	0	t	f	2026-07-21 17:28:04.154095+00	2026-07-21 17:28:04.154095+00
3f8cee32-5987-4edb-ad95-0ea0c7cb189c	news	cc264800b4df94b759e4fc71	article	Mengenal lembaga MKD DPR RI beserta tugas dan wewenangnya. Dalam sistem parlemen Indonesia, terdapat lembaga internal yang berperan menjaga kehormatan dan pengawas etika para ...	Mengenal lembaga MKD DPR RI beserta tugas dan wewenangnya. Dalam sistem parlemen Indonesia, terdapat lembaga internal yang berperan menjaga kehormatan dan pengawas etika para ...	id	https://www.antaranews.com/berita/5224313/mengenal-lembaga-mkd-dpr-ri-beserta-tugas-dan-wewenangnya	c29b0cad-cf1e-40be-b1d2-9d0f986841dc	\N	\N	2025-11-06 10:03:15+00	0	0	0	0	0	neutral	0	\N	{politik}	{lembaga,mengenal,beserta,tugas,wewenangnya}	\N	0	t	f	2026-07-21 17:28:04.16872+00	2026-07-21 17:28:04.16872+00
a101b281-93af-4cf6-8ddb-a9849e80005c	news	198876779f1c397faab16e52	article	Segini harta kekayaan Wakil Gubernur Riau S. F. Hariyanto. Nama Wakil Gubernur Riau Sofyan Franyata (S. F.) Hariyanto mencuat setelah Gubernur Riau Abdul Wahid terjaring operasi ...	Segini harta kekayaan Wakil Gubernur Riau S. F. Hariyanto. Nama Wakil Gubernur Riau Sofyan Franyata (S. F.) Hariyanto mencuat setelah Gubernur Riau Abdul Wahid terjaring operasi ...	id	https://www.antaranews.com/berita/5222369/segini-harta-kekayaan-wakil-gubernur-riau-s-f-hariyanto	c29b0cad-cf1e-40be-b1d2-9d0f986841dc	\N	\N	2025-11-05 12:35:38+00	0	0	0	0	0	neutral	0	\N	{umum}	{gubernur,riau,wakil,hariyanto,segini}	\N	0	t	f	2026-07-21 17:28:04.182669+00	2026-07-21 17:28:04.182669+00
db98aafc-591b-460e-b4ac-be83da476514	news	8c061c71165bc785a22503b3	article	Profil Dini Yuliani, sosok pendamping setia Bupati Purwakarta Om Zein. Dini Yuliani, istri Bupati Purwakarta Saepul Bahri atau yang akrab disapa Om Zein, dikabarkan wafat pada Selasa (28/10) ...	Profil Dini Yuliani, sosok pendamping setia Bupati Purwakarta Om Zein. Dini Yuliani, istri Bupati Purwakarta Saepul Bahri atau yang akrab disapa Om Zein, dikabarkan wafat pada Selasa (28/10) ...	id	https://www.antaranews.com/berita/5207901/profil-dini-yuliani-sosok-pendamping-setia-bupati-purwakarta-om-zein	c29b0cad-cf1e-40be-b1d2-9d0f986841dc	\N	\N	2025-10-29 16:02:41+00	0	0	0	0	0	neutral	0	\N	{umum}	{dini,yuliani,bupati,purwakarta,zein}	\N	0	t	f	2026-07-21 17:28:04.196624+00	2026-07-21 17:28:04.196624+00
abced90c-9f73-4331-b6b2-07fea1fee96e	news	2509144ae757be79391ad9ab	article	Donald Trump sebut Prabowo "sosok luar biasa" di KTT Perdamaian Gaza. Presiden Amerika Serikat Donald Trump menyampaikan pujian kepada Presiden Prabowo Subianto atas peran dan ...	Donald Trump sebut Prabowo "sosok luar biasa" di KTT Perdamaian Gaza. Presiden Amerika Serikat Donald Trump menyampaikan pujian kepada Presiden Prabowo Subianto atas peran dan ...	id	https://www.antaranews.com/berita/5174817/donald-trump-sebut-prabowo-sosok-luar-biasa-di-ktt-perdamaian-gaza	c29b0cad-cf1e-40be-b1d2-9d0f986841dc	\N	\N	2025-10-15 01:54:04+00	0	0	0	0	0	neutral	0	\N	{politik}	{donald,trump,prabowo,presiden,sebut}	\N	0	t	f	2026-07-21 17:28:04.209056+00	2026-07-21 17:28:04.209056+00
3a98374e-dea5-4131-b899-95202555ee91	news	3744a635b3a1725104f8ca56	article	Ketahui daftar gaji, tunjangan, dan masa kerja PPPK Paruh Waktu 2025. Tak hanya menjadi Pegawai Negeri Sipil (PNS), banyak masyarakat yang turut mengincar posisi sebagai pegawai pemerintah ...	Ketahui daftar gaji, tunjangan, dan masa kerja PPPK Paruh Waktu 2025. Tak hanya menjadi Pegawai Negeri Sipil (PNS), banyak masyarakat yang turut mengincar posisi sebagai pegawai pemerintah ...	id	https://www.antaranews.com/berita/5174793/ketahui-daftar-gaji-tunjangan-dan-masa-kerja-pppk-paruh-waktu-2025	c29b0cad-cf1e-40be-b1d2-9d0f986841dc	\N	\N	2025-10-15 01:47:59+00	0	0	0	0	0	neutral	0	\N	{politik,sosial}	{pegawai,ketahui,daftar,gaji,tunjangan}	\N	0	t	f	2026-07-21 17:28:04.219463+00	2026-07-21 17:28:04.219463+00
9e2ccf3a-aeb9-4c24-b9dd-8c78c461de33	news	6a021a7a8abd9db9d85021aa	article	Ini Profil Astrid Widayani, Wakil Wali Kota Solo-Ketua DPD PSI Solo. Sosok Wakil Wali Kota Solo Astrid Widayani tengah menjadi sorotan publik lantaran posisi baru yang diembannya sebagai ...	Ini Profil Astrid Widayani, Wakil Wali Kota Solo-Ketua DPD PSI Solo. Sosok Wakil Wali Kota Solo Astrid Widayani tengah menjadi sorotan publik lantaran posisi baru yang diembannya sebagai ...	id	https://www.antaranews.com/berita/5174689/ini-profil-astrid-widayani-wakil-wali-kota-solo-ketua-dpd-psi-solo	c29b0cad-cf1e-40be-b1d2-9d0f986841dc	\N	\N	2025-10-15 01:07:48+00	0	0	0	0	0	neutral	0	\N	{sosial}	{solo,astrid,widayani,wakil,wali}	\N	0	t	f	2026-07-21 17:28:04.23138+00	2026-07-21 17:28:04.23138+00
87aacead-d2b5-4994-983e-ab6d4f9126d5	news	e272bf5397897717eeb1cf17	article	Profil Dirgayuza, Asisten presiden bidang Komunikasi Analis Kebijakan. Untuk memperkuat struktur komunikasi strategis di lingkungan Istana Kepresidenan, Presiden Prabowo Subianto secara ...	Profil Dirgayuza, Asisten presiden bidang Komunikasi Analis Kebijakan. Untuk memperkuat struktur komunikasi strategis di lingkungan Istana Kepresidenan, Presiden Prabowo Subianto secara ...	id	https://www.antaranews.com/berita/5163441/profil-dirgayuzaasisten-presiden-bidang-komunikasi-analis-kebijakan	c29b0cad-cf1e-40be-b1d2-9d0f986841dc	\N	\N	2025-10-09 06:44:41+00	0	0	0	0	0	neutral	0	\N	{politik}	{presiden,komunikasi,profil,dirgayuza,asisten}	\N	0	t	f	2026-07-21 17:28:04.247516+00	2026-07-21 17:28:04.247516+00
23fce69b-d841-409b-a314-73d7d51ffbcb	news	1f006ccc41d2b14896c1c2af	article	Profil Agung Gumilar, Asisten presiden bidang Analis Data Strategis. Agung Gumilar Saputra resmi dilantik sebagai Asisten Khusus Presiden Bidang Analisis Data Strategis pada Rabu (8/10) di ...	Profil Agung Gumilar, Asisten presiden bidang Analis Data Strategis. Agung Gumilar Saputra resmi dilantik sebagai Asisten Khusus Presiden Bidang Analisis Data Strategis pada Rabu (8/10) di ...	id	https://www.antaranews.com/berita/5163421/profil-agung-gumilar-asisten-presiden-bidang-analis-data-strategis	c29b0cad-cf1e-40be-b1d2-9d0f986841dc	\N	\N	2025-10-09 06:41:54+00	0	0	0	0	0	neutral	0	\N	{politik,teknologi}	{agung,gumilar,asisten,presiden,bidang}	\N	0	t	f	2026-07-21 17:28:04.259317+00	2026-07-21 17:28:04.259317+00
558d771a-8688-407b-84ce-d0f05fc9f079	news	e50025596f2895f4b2d6efc6	article	Daftar 25 pejabat & 10 Dubes yang dilantik Prabowo pada Oktober 2025. Presiden Prabowo Subianto resmi melantik 25 pejabat negara dan 10 Duta Besar (Dubes) Luar Biasa dan Berkuasa Penuh ...	Daftar 25 pejabat & 10 Dubes yang dilantik Prabowo pada Oktober 2025. Presiden Prabowo Subianto resmi melantik 25 pejabat negara dan 10 Duta Besar (Dubes) Luar Biasa dan Berkuasa Penuh ...	id	https://www.antaranews.com/berita/5162865/daftar-25-pejabat-10-dubes-yang-dilantik-prabowo-pada-oktober-2025	c29b0cad-cf1e-40be-b1d2-9d0f986841dc	\N	\N	2025-10-09 00:28:06+00	0	0	0	0	0	neutral	0	\N	{politik}	{pejabat,dubes,prabowo,daftar,dilantik}	\N	0	t	f	2026-07-21 17:28:04.271814+00	2026-07-21 17:28:04.271814+00
bcde9e35-d52d-4084-b0cf-937a4cc7806d	news	f78dfa0f0e16e6d6d78e2134	article	Profil Akhmad Wiyagus: Dari perwira tinggi Polri ke Wamendagri. Komjen Polisi (Purn) Akhmad Wiyagus resmi dilantik sebagai Wakil Menteri Dalam Negeri (Wamendagri) dalam Kabinet Merah ...	Profil Akhmad Wiyagus: Dari perwira tinggi Polri ke Wamendagri. Komjen Polisi (Purn) Akhmad Wiyagus resmi dilantik sebagai Wakil Menteri Dalam Negeri (Wamendagri) dalam Kabinet Merah ...	id	https://www.antaranews.com/berita/5162857/profil-akhmad-wiyagus-dari-perwira-tinggi-polri-ke-wamendagri	c29b0cad-cf1e-40be-b1d2-9d0f986841dc	\N	\N	2025-10-09 00:18:10+00	0	0	0	0	0	neutral	0	\N	{politik,hukum}	{akhmad,wiyagus,wamendagri,dalam,profil}	\N	0	t	f	2026-07-21 17:28:04.292945+00	2026-07-21 17:28:04.292945+00
c5825c73-d2bd-419f-86d5-b7ab4b868f49	news	27a2efee25fcbde41159513c	article	Apakah bensin dicampur minyak kayu putih bisa lebih irit?. Klaim bahwa mencampurkan minyak kayu putih ke dalam bensin dapat membuat konsumsi bahan bakar lebih irit ramai ...	Apakah bensin dicampur minyak kayu putih bisa lebih irit?. Klaim bahwa mencampurkan minyak kayu putih ke dalam bensin dapat membuat konsumsi bahan bakar lebih irit ramai ...	id	https://otomotif.antaranews.com/berita/5653273/apakah-bensin-dicampur-minyak-kayu-putih-bisa-lebih-irit	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-17 01:05:17+00	0	0	0	0	0	neutral	0	\N	{umum}	{bensin,minyak,kayu,putih,irit}	\N	0	t	f	2026-07-21 17:28:04.309718+00	2026-07-21 17:28:04.309718+00
8e3dd634-3c48-4bbb-85aa-2e42909fbafb	news	c92ab6b607a11064221b8828	article	Mata uang Iran melemah, apa bedanya rial dan toman?. Mata uang Iran belakangan menjadi sorotan dunia seiring memanasnya tensi geopolitik dan kebijakan ekonomi global. ...	Mata uang Iran melemah, apa bedanya rial dan toman?. Mata uang Iran belakangan menjadi sorotan dunia seiring memanasnya tensi geopolitik dan kebijakan ekonomi global. ...	id	https://www.antaranews.com/berita/5352089/mata-uang-iran-melemah-apa-bedanya-rial-dan-toman	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-01-14 11:23:19+00	0	0	0	0	0	neutral	0	\N	{ekonomi,politik}	{mata,uang,iran,melemah,bedanya}	\N	0	t	f	2026-07-21 17:28:04.322986+00	2026-07-21 17:28:04.322986+00
150f5beb-6052-427e-a0c7-2bf89d1ec213	news	855a131b56a6ff45e1736559	article	Jenis perak yang bisa dijadikan aset investasi. Selain emas, perak juga merupakan jenis logam berharga lainnya yang memiliki nilai strategis sebagai instrumen ...	Jenis perak yang bisa dijadikan aset investasi. Selain emas, perak juga merupakan jenis logam berharga lainnya yang memiliki nilai strategis sebagai instrumen ...	id	https://www.antaranews.com/berita/5328430/jenis-perak-yang-bisa-dijadikan-aset-investasi	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2025-12-31 08:53:57+00	0	0	0	0	0	neutral	0	\N	{ekonomi}	{jenis,perak,dijadikan,aset,investasi}	\N	0	t	f	2026-07-21 17:28:04.33153+00	2026-07-21 17:28:04.33153+00
9a608d36-c046-4bd1-878e-c015429ed5ce	news	00369e7286b2ed9fe219d940	article	Ketahui keuntungan dan kekurangan berinvestasi perak. Investasi perak kini mulai dilirik sebagai alternatif aset karena harga yang jauh lebih terjangkau dibandingkan emas. ...	Ketahui keuntungan dan kekurangan berinvestasi perak. Investasi perak kini mulai dilirik sebagai alternatif aset karena harga yang jauh lebih terjangkau dibandingkan emas. ...	id	https://www.antaranews.com/berita/5327344/ketahui-keuntungan-dan-kekurangan-berinvestasi-perak	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2025-12-30 12:43:43+00	0	0	0	0	0	neutral	0	\N	{ekonomi}	{perak,ketahui,keuntungan,kekurangan,berinvestasi}	\N	0	t	f	2026-07-21 17:28:04.34407+00	2026-07-21 17:28:04.34407+00
501d27b1-ad87-4ea4-9029-83e201b9d46b	news	45f659a718e943f1d69359a0	article	Ingin coba investasi perak? Simak tips dan caranya untuk pemula. Selama ini, emas dikenal sebagai primadona investasi logam mulia. Namun, saat ini perak juga bisa menjadi alternatif ...	Ingin coba investasi perak? Simak tips dan caranya untuk pemula. Selama ini, emas dikenal sebagai primadona investasi logam mulia. Namun, saat ini perak juga bisa menjadi alternatif ...	id	https://www.antaranews.com/berita/5326660/ingin-coba-investasi-perak-simak-tips-dan-caranya-untuk-pemula	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2025-12-30 04:04:20+00	0	0	0	0	0	neutral	0	\N	{ekonomi}	{investasi,perak,ingin,coba,simak}	\N	0	t	f	2026-07-21 17:28:04.356743+00	2026-07-21 17:28:04.356743+00
fcf88e2a-ffc6-4d35-9ab8-f2bada216f12	news	9ba4276753752bf1b0c00495	article	Sosok Brigitte Bardot: Aktris legenda asal Prancis & aktivis hak hewan. Aktris legendaris Prancis, Brigitte Bardot, dikabarkan meninggal dunia pada usia 91 tahun pada Minggu (28/12). Dalam ...	Sosok Brigitte Bardot: Aktris legenda asal Prancis & aktivis hak hewan. Aktris legendaris Prancis, Brigitte Bardot, dikabarkan meninggal dunia pada usia 91 tahun pada Minggu (28/12). Dalam ...	id	https://www.antaranews.com/berita/5325640/sosok-brigitte-bardot-aktris-legenda-asal-prancis-aktivis-hak-hewan	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2025-12-29 09:51:10+00	0	0	0	0	0	neutral	0	\N	{umum}	{brigitte,bardot,aktris,prancis,sosok}	\N	0	t	f	2026-07-21 17:28:04.369788+00	2026-07-21 17:28:04.369788+00
0397c1ee-4e1c-4d45-9c52-b01e7a9b1ef4	news	e6b712a6c504fc42be645a1e	article	Sering terjadi, hindari 10 kesalahan dalam mengatur keuangan di akhir tahun. Menjelang berakhirnya tahun 2025, tidak sedikit orang mulai melakukan evaluasi keuangan sekaligus merencanakan langkah ...	Sering terjadi, hindari 10 kesalahan dalam mengatur keuangan di akhir tahun. Menjelang berakhirnya tahun 2025, tidak sedikit orang mulai melakukan evaluasi keuangan sekaligus merencanakan langkah ...	id	https://www.antaranews.com/berita/5323399/sering-terjadi-hindari-10-kesalahan-dalam-mengatur-keuangan-di-akhir-tahun	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2025-12-27 02:24:10+00	0	0	0	0	0	neutral	0	\N	{umum}	{keuangan,tahun,sering,terjadi,hindari}	\N	0	t	f	2026-07-21 17:28:04.386833+00	2026-07-21 17:28:04.386833+00
d70292e3-7209-4ef9-95e8-d8b5c8a4566b	news	f6b9644783ae6ee7bdf194ad	article	Cara menyusun target keuangan 2026 agar lebih terarah & berkelanjutan. Menjelang datangnya Tahun Baru 2026, tidak sedikit orang mulai melakukan refleksi sekaligus menyusun rencana keuangan ...	Cara menyusun target keuangan 2026 agar lebih terarah & berkelanjutan. Menjelang datangnya Tahun Baru 2026, tidak sedikit orang mulai melakukan refleksi sekaligus menyusun rencana keuangan ...	id	https://www.antaranews.com/berita/5323396/cara-menyusun-target-keuangan-2026-agar-lebih-terarah-berkelanjutan	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2025-12-27 02:22:08+00	0	0	0	0	0	neutral	0	\N	{umum}	{menyusun,keuangan,cara,target,agar}	\N	0	t	f	2026-07-21 17:28:04.398461+00	2026-07-21 17:28:04.398461+00
7dd449fb-80d2-41c6-b4c7-396284bcab0d	news	9ff12417115c699caaa34e50	article	Investasi emas atau perak, mana yang aman untuk jangka panjang?. Belakangan, linimasa media sosial mulai dibanjiri narasi bahwa perak adalah “harta karun tersembunyi” yang ...	Investasi emas atau perak, mana yang aman untuk jangka panjang?. Belakangan, linimasa media sosial mulai dibanjiri narasi bahwa perak adalah “harta karun tersembunyi” yang ...	id	https://www.antaranews.com/berita/5320981/investasi-emas-atau-perak-mana-yang-aman-untuk-jangka-panjang	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2025-12-24 12:14:55+00	0	0	0	0	0	positive	1	\N	{ekonomi,sosial}	{perak,investasi,emas,atau,mana}	\N	0	t	f	2026-07-21 17:28:04.410149+00	2026-07-21 17:28:04.410149+00
b7d19678-2254-490b-8476-db5a552142e3	news	911d27050f1c3410c2d08b83	article	Bolehkah menolak pembayaran uang tunai? Ini aturan hukum dan sanksinya. Kebijakan pembayaran non-tunai atau QRIS di salah satu gerai roti ternama memicu polemik di media sosial setelah ...	Bolehkah menolak pembayaran uang tunai? Ini aturan hukum dan sanksinya. Kebijakan pembayaran non-tunai atau QRIS di salah satu gerai roti ternama memicu polemik di media sosial setelah ...	id	https://www.antaranews.com/berita/5319970/bolehkah-menolak-pembayaran-uang-tunai-ini-aturan-hukum-dan-sanksinya	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2025-12-24 01:46:39+00	0	0	0	0	0	negative	-1	\N	{politik,ekonomi}	{pembayaran,tunai,bolehkah,menolak,uang}	\N	0	t	f	2026-07-21 17:28:04.420752+00	2026-07-21 17:28:04.420752+00
5147db0b-8a6c-444f-87d6-d01cff58f5d1	news	4be2775707e0b0318c4ee71f	article	Mengenal Bank Syariah Nasional (BSN). PT Bank Syariah Nasional (BSN) baru beroperasi secara efektif pada Senin (22/12) setelah berpisah dari PT Bank Tabungan ...	Mengenal Bank Syariah Nasional (BSN). PT Bank Syariah Nasional (BSN) baru beroperasi secara efektif pada Senin (22/12) setelah berpisah dari PT Bank Tabungan ...	id	https://www.antaranews.com/berita/5319484/mengenal-bank-syariah-nasional-bsn	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2025-12-23 13:34:16+00	0	0	0	0	0	neutral	0	\N	{ekonomi}	{bank,syariah,nasional,mengenal,baru}	\N	0	t	f	2026-07-21 17:28:04.430068+00	2026-07-21 17:28:04.430068+00
7c3dabc3-24c3-4b2f-884f-7883ed802db4	news	998f8b5acf2d47c1d19b8e4c	article	Apa itu Bank Syariah? Pahami pengertian, jenis, & contoh produknya. Bagi banyak umat Muslim, mengelola keuangan bukan hanya mengutamakan nilai dan keuntungan, tetapi juga tentang ...	Apa itu Bank Syariah? Pahami pengertian, jenis, & contoh produknya. Bagi banyak umat Muslim, mengelola keuangan bukan hanya mengutamakan nilai dan keuntungan, tetapi juga tentang ...	id	https://www.antaranews.com/berita/5319466/apa-itu-bank-syariah-pahami-pengertian-jenis-contoh-produknya	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2025-12-23 13:28:55+00	0	0	0	0	0	neutral	0	\N	{ekonomi}	{bank,syariah,pahami,pengertian,jenis}	\N	0	t	f	2026-07-21 17:28:04.441672+00	2026-07-21 17:28:04.441672+00
17b38aef-9afd-49cd-b255-0b6c828034c8	news	1e1f155c71532170891aaccb	article	Susunan direksi & komisaris BRI terbaru hasil RUPSLB 17 Desember 2025. PT Bank Rakyat Indonesia (Persero) Tbk atau BRI kembali melakukan penataan jajaran manajemen melalui Rapat Umum ...	Susunan direksi & komisaris BRI terbaru hasil RUPSLB 17 Desember 2025. PT Bank Rakyat Indonesia (Persero) Tbk atau BRI kembali melakukan penataan jajaran manajemen melalui Rapat Umum ...	id	https://www.antaranews.com/berita/5314405/susunan-direksi-komisaris-bri-terbaru-hasil-rupslb-17-desember-2025	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2025-12-20 02:12:10+00	0	0	0	0	0	neutral	0	\N	{ekonomi}	{susunan,direksi,komisaris,terbaru,hasil}	\N	0	t	f	2026-07-21 17:28:04.454033+00	2026-07-21 17:28:04.454033+00
5077a9c8-db00-43aa-87a8-f7d78c00042e	news	83979e61d4660a680340ed4f	article	Daftar harga diskon 20% tarif tol trans Sumatra Nataru 2025/2026. Menyambut libur Natal 2025 dan Tahun Baru 2026 (Nataru 2025/2026), PT Jasa Marga (Persero) Tbk memberikan stimulus ...	Daftar harga diskon 20% tarif tol trans Sumatra Nataru 2025/2026. Menyambut libur Natal 2025 dan Tahun Baru 2026 (Nataru 2025/2026), PT Jasa Marga (Persero) Tbk memberikan stimulus ...	id	https://www.antaranews.com/berita/5307253/daftar-harga-diskon-20-tarif-tol-trans-sumatra-nataru-2025-2026	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2025-12-16 07:39:02+00	0	0	0	0	0	neutral	0	\N	{ekonomi}	{nataru,daftar,harga,diskon,tarif}	\N	0	t	f	2026-07-21 17:28:04.467029+00	2026-07-21 17:28:04.467029+00
38c07b95-1b82-4991-ab1a-74e48e916a50	news	9e062420bdb3a3dd55c51052	article	Sejarah BRI dalam peringatan HUT ke-130 dan tema yang diusung di 2025. Setiap tanggal 16 Desember, PT Bank Rakyat Indonesia (Persero) Tbk atau BRI memperingati hari lahirnya sebagai salah ...	Sejarah BRI dalam peringatan HUT ke-130 dan tema yang diusung di 2025. Setiap tanggal 16 Desember, PT Bank Rakyat Indonesia (Persero) Tbk atau BRI memperingati hari lahirnya sebagai salah ...	id	https://www.antaranews.com/berita/5307247/sejarah-bri-dalam-peringatan-hut-ke-130-dan-tema-yang-diusung-di-2025	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2025-12-16 07:37:07+00	0	0	0	0	0	neutral	0	\N	{ekonomi}	{sejarah,dalam,peringatan,tema,diusung}	\N	0	t	f	2026-07-21 17:28:04.484968+00	2026-07-21 17:28:04.484968+00
d02173f0-43b6-4113-9eb3-170d5ac40327	news	d6e8a79adf7b533a2a3c183b	article	Spesifikasi dan harga Honda All New Vario 125 terbaru 2025. Honda All New Vario 125 kembali menjadi sorotan setelah resmi diperkenalkan sebagai generasi terbaru dalam jajaran ...	Spesifikasi dan harga Honda All New Vario 125 terbaru 2025. Honda All New Vario 125 kembali menjadi sorotan setelah resmi diperkenalkan sebagai generasi terbaru dalam jajaran ...	id	https://otomotif.antaranews.com/berita/5284265/spesifikasi-dan-harga-honda-all-new-vario-125-terbaru-2025	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2025-12-03 06:50:07+00	0	0	0	0	0	neutral	0	\N	{umum}	{honda,vario,terbaru,spesifikasi,harga}	\N	0	t	f	2026-07-21 17:28:04.498764+00	2026-07-21 17:28:04.498764+00
a2c80369-40e7-4e0f-be6f-f79125e737a7	news	b09101f42c9f44d85f5da343	article	Shell Super atau V-Power? Ini perbedaan dan keunggulannya. Memilih jenis bahan bakar yang tepat menjadi salah satu kunci menjaga performa kendaraan tetap prima. Di jaringan SPBU ...	Shell Super atau V-Power? Ini perbedaan dan keunggulannya. Memilih jenis bahan bakar yang tepat menjadi salah satu kunci menjaga performa kendaraan tetap prima. Di jaringan SPBU ...	id	https://otomotif.antaranews.com/berita/5280125/shell-super-atau-v-power-ini-perbedaan-dan-keunggulannya	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2025-12-01 12:28:53+00	0	0	0	0	0	positive	1	\N	{umum}	{shell,super,atau,power,perbedaan}	\N	0	t	f	2026-07-21 17:28:04.512422+00	2026-07-21 17:28:04.512422+00
2fb2bb93-016f-4efd-a3ce-5b60d5978e86	news	39edb8c7d04ad688377d2821	article	Panduan lengkap memilih BBM Shell di tengah penyesuaian harga terbaru. Mengenali berbagai jenis bahan bakar yang ditawarkan Shell Indonesia menjadi penting bagi para pemilik kendaraan, ...	Panduan lengkap memilih BBM Shell di tengah penyesuaian harga terbaru. Mengenali berbagai jenis bahan bakar yang ditawarkan Shell Indonesia menjadi penting bagi para pemilik kendaraan, ...	id	https://otomotif.antaranews.com/berita/5280073/panduan-lengkap-memilih-bbm-shell-di-tengah-penyesuaian-harga-terbaru	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2025-12-01 12:18:41+00	0	0	0	0	0	neutral	0	\N	{umum}	{shell,panduan,lengkap,memilih,tengah}	\N	0	t	f	2026-07-21 17:28:04.523673+00	2026-07-21 17:28:04.523673+00
b68e3175-a897-4952-a9ca-db29b1e25006	news	0f41cfad10e9c3a2c52fc50c	article	Sejarah sarang burung walet sebagai komoditas unggulan Indonesia. Sarang burung walet telah lama dikenal sebagai salah satu komoditas unggulan dan bernilai tinggi di ...	Sejarah sarang burung walet sebagai komoditas unggulan Indonesia. Sarang burung walet telah lama dikenal sebagai salah satu komoditas unggulan dan bernilai tinggi di ...	id	https://www.antaranews.com/berita/5241161/sejarah-sarang-burung-walet-sebagai-komoditas-unggulan-indonesia	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2025-11-14 00:44:45+00	0	0	0	0	0	neutral	0	\N	{umum}	{sarang,burung,walet,komoditas,unggulan}	\N	0	t	f	2026-07-21 17:28:04.537814+00	2026-07-21 17:28:04.537814+00
dcd0122e-b74b-40c4-b6c8-daf6d9ca632d	news	c1a30adc81754a6764f9f045	article	Mengenal Bobibos, bahan bakar dari jerami inovasi anak bangsa. Indonesia kembali menunjukkan kemampuan inovatifnya di bidang energi terbarukan melalui terobosan baru bernama Bobibos, ...	Mengenal Bobibos, bahan bakar dari jerami inovasi anak bangsa. Indonesia kembali menunjukkan kemampuan inovatifnya di bidang energi terbarukan melalui terobosan baru bernama Bobibos, ...	id	https://otomotif.antaranews.com/berita/5238361/mengenal-bobibos-bahan-bakar-dari-jerami-inovasi-anak-bangsa	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2025-11-12 14:58:17+00	0	0	0	0	0	neutral	0	\N	{umum}	{bobibos,mengenal,bahan,bakar,jerami}	\N	0	t	f	2026-07-21 17:28:04.549666+00	2026-07-21 17:28:04.549666+00
7f596e3b-1cf4-4b24-b880-3cb967cf0674	news	ef9e1343919a72128db26959	article	Cara membuat SIM digital resmi dengan mudah dan cepat. Pengendara kini dapat memanfaatkan SIM Digital sebagai dokumen pendamping SIM fisik melalui aplikasi resmi Digital ...	Cara membuat SIM digital resmi dengan mudah dan cepat. Pengendara kini dapat memanfaatkan SIM Digital sebagai dokumen pendamping SIM fisik melalui aplikasi resmi Digital ...	id	https://www.antaranews.com/berita/5657467/cara-membuat-sim-digital-resmi-dengan-mudah-dan-cepat	4119984d-09e2-4d96-9c57-672c243b2d01	\N	\N	2026-07-20 11:27:53+00	0	0	0	0	0	neutral	0	\N	{teknologi}	{digital,resmi,cara,membuat,mudah}	\N	0	t	f	2026-07-21 17:28:04.560193+00	2026-07-21 17:28:04.560193+00
45c4e543-d8dd-435e-a9a5-0609598e5863	news	5567fcfda52c85d68751d633	article	Cara dan biaya balik nama sertifikat tanah orang tua ke anak. Proses balik nama sertipikat tanah dari orang tua kepada anak kerap menjadi pertanyaan masyarakat, terutama terkait ...	Cara dan biaya balik nama sertifikat tanah orang tua ke anak. Proses balik nama sertipikat tanah dari orang tua kepada anak kerap menjadi pertanyaan masyarakat, terutama terkait ...	id	https://www.antaranews.com/berita/5653296/cara-dan-biaya-balik-nama-sertifikat-tanah-orang-tua-ke-anak	4119984d-09e2-4d96-9c57-672c243b2d01	\N	\N	2026-07-17 01:56:17+00	0	0	0	0	0	neutral	0	\N	{sosial}	{balik,nama,tanah,orang,anak}	\N	0	t	f	2026-07-21 17:28:04.568205+00	2026-07-21 17:28:04.568205+00
b7b1def7-3465-41a8-921f-14319ddc4df4	news	5343182ef7128512a3e9139e	article	Profil Laras Faizati. Majelis Hakim Pengadilan Negeri Jakarta Selatan, pada Kamis (15/1), menjatuhkan vonis pidana pengawasan kepada Laras ...	Profil Laras Faizati. Majelis Hakim Pengadilan Negeri Jakarta Selatan, pada Kamis (15/1), menjatuhkan vonis pidana pengawasan kepada Laras ...	id	https://www.antaranews.com/berita/5357446/profil-laras-faizati	4119984d-09e2-4d96-9c57-672c243b2d01	\N	\N	2026-01-17 10:59:37+00	0	0	0	0	0	neutral	0	\N	{hukum}	{laras,profil,faizati,majelis,hakim}	\N	0	t	f	2026-07-21 17:28:04.576767+00	2026-07-21 17:28:04.576767+00
354ab4cf-8ff2-439c-860d-876d4649d02b	news	ed58e9771fbb941505280492	article	Profil Yaqut Cholil Qoumas, eks Menag yang terjerat korupsi kouta haji. Komisi Pemberantasan Korupsi (KPK) telah menetapkan mantan Menteri Agama (Menag) Yaqut Cholil Qoumas, dan staf ...	Profil Yaqut Cholil Qoumas, eks Menag yang terjerat korupsi kouta haji. Komisi Pemberantasan Korupsi (KPK) telah menetapkan mantan Menteri Agama (Menag) Yaqut Cholil Qoumas, dan staf ...	id	https://www.antaranews.com/berita/5344189/profil-yaqut-cholil-qoumas-eks-menag-yang-terjerat-korupsi-kouta-haji	4119984d-09e2-4d96-9c57-672c243b2d01	\N	\N	2026-01-10 12:34:46+00	0	0	0	0	0	negative	-1	\N	{hukum,politik}	{yaqut,cholil,qoumas,menag,korupsi}	\N	0	t	f	2026-07-21 17:28:04.587166+00	2026-07-21 17:28:04.587166+00
bb1533fa-141f-4911-a660-78ae71c072cd	news	dd60388407b82cd7837e43f3	article	Simak rekrutmen PPPK Kemenham 2026: Syarat dan jadwal pelaksanaan. Kementerian Hak Asasi Manusia (KemenHAM) tengah membuka kesempatan bagi talenta terbaik bangsa untuk bergabung sebagai ...	Simak rekrutmen PPPK Kemenham 2026: Syarat dan jadwal pelaksanaan. Kementerian Hak Asasi Manusia (KemenHAM) tengah membuka kesempatan bagi talenta terbaik bangsa untuk bergabung sebagai ...	id	https://www.antaranews.com/berita/5332888/simak-rekrutmen-pppk-kemenham-2026-syarat-dan-jadwal-pelaksanaan	4119984d-09e2-4d96-9c57-672c243b2d01	\N	\N	2026-01-04 11:56:49+00	0	0	0	0	0	positive	1	\N	{umum}	{kemenham,simak,rekrutmen,pppk,syarat}	\N	0	t	f	2026-07-21 17:28:04.599484+00	2026-07-21 17:28:04.599484+00
3651606f-ab15-437e-a65f-6ecdf00e9cae	news	28e4187e00c26da64a36670c	article	Rincian LHKPN Bupati Bekasi Ade Kuswara Kunang capai Rp79 miliar. Bupati Bekasi Ade Kuswara Kunang ditangkap Komisi Pemberantasan Korupsi (KPK) dalam operasi tangkap tangan (OTT) yang ...	Rincian LHKPN Bupati Bekasi Ade Kuswara Kunang capai Rp79 miliar. Bupati Bekasi Ade Kuswara Kunang ditangkap Komisi Pemberantasan Korupsi (KPK) dalam operasi tangkap tangan (OTT) yang ...	id	https://www.antaranews.com/berita/5312848/rincian-lhkpn-bupati-bekasi-ade-kuswara-kunang-capai-rp79-miliar	4119984d-09e2-4d96-9c57-672c243b2d01	\N	\N	2025-12-19 06:29:24+00	0	0	0	0	0	negative	-1	\N	{hukum}	{bupati,bekasi,kuswara,kunang,rincian}	\N	0	t	f	2026-07-21 17:28:04.609908+00	2026-07-21 17:28:04.609908+00
2f919a57-128a-4659-a9d8-039219f82e0b	news	2319d4ea5e87a45ca5ab5590	article	Profil Ade Kuswara Kunang, Bupati Bekasi yang ditangkap KPK. Bupati Bekasi, Ade Kuswara Kunang yang kurang lebih 10 bulan menjabat, telah terjaring dalam operasi tangkap tangan ...	Profil Ade Kuswara Kunang, Bupati Bekasi yang ditangkap KPK. Bupati Bekasi, Ade Kuswara Kunang yang kurang lebih 10 bulan menjabat, telah terjaring dalam operasi tangkap tangan ...	id	https://www.antaranews.com/berita/5312827/profil-ade-kuswara-kunang-bupati-bekasi-yang-ditangkap-kpk	4119984d-09e2-4d96-9c57-672c243b2d01	\N	\N	2025-12-19 06:19:58+00	0	0	0	0	0	neutral	0	\N	{hukum}	{kuswara,kunang,bupati,bekasi,profil}	\N	0	t	f	2026-07-21 17:28:04.621512+00	2026-07-21 17:28:04.621512+00
f7b32377-470b-47b2-aa42-5820a3ccdf5c	news	32cacd6264a3c13950194dc7	article	Profil Komjen Suyudi Ario Seto, Kepala BNN penangkap buronan Interpol. Komjen Pol Suyudi Ario Seto, Kepala Badan Narkotika Nasional (BNN) RI, belakangan menjadi perhatian publik setelah ...	Profil Komjen Suyudi Ario Seto, Kepala BNN penangkap buronan Interpol. Komjen Pol Suyudi Ario Seto, Kepala Badan Narkotika Nasional (BNN) RI, belakangan menjadi perhatian publik setelah ...	id	https://www.antaranews.com/berita/5309269/profil-komjen-suyudi-ario-seto-kepala-bnn-penangkap-buronan-interpol	4119984d-09e2-4d96-9c57-672c243b2d01	\N	\N	2025-12-17 08:11:31+00	0	0	0	0	0	neutral	0	\N	{umum}	{komjen,suyudi,ario,seto,kepala}	\N	0	t	f	2026-07-21 17:28:04.631754+00	2026-07-21 17:28:04.631754+00
05da4e9d-0bb8-41e2-812c-351c08c09f3b	news	4cbcb58251e08538019e7af3	article	Daftar negara Eropa yang bisa dikunjungi WNI tanpa visa. Mengunjungi negara-negara di kawasan Eropa kerap menjadi impian banyak pelancong. Namun, proses pengajuan visa Schengen ...	Daftar negara Eropa yang bisa dikunjungi WNI tanpa visa. Mengunjungi negara-negara di kawasan Eropa kerap menjadi impian banyak pelancong. Namun, proses pengajuan visa Schengen ...	id	https://www.antaranews.com/berita/5307133/daftar-negara-eropa-yang-bisa-dikunjungi-wni-tanpa-visa	4119984d-09e2-4d96-9c57-672c243b2d01	\N	\N	2025-12-16 06:55:37+00	0	0	0	0	0	neutral	0	\N	{umum}	{negara,eropa,visa,daftar,dikunjungi}	\N	0	t	f	2026-07-21 17:28:04.643147+00	2026-07-21 17:28:04.643147+00
1ea5535c-02b1-41a1-8a06-c6caa3da8b38	news	1df0361055cb3bd389e8a27e	article	Sosok Ira Puspadewi, eks dirut ASDP yang terima rehabilitasi presiden. Presiden Prabowo secara resmi memberikan hak rehabilitasi hukum kepada Ira Puspadewi, eks Direktur Utama PT Angkutan ...	Sosok Ira Puspadewi, eks dirut ASDP yang terima rehabilitasi presiden. Presiden Prabowo secara resmi memberikan hak rehabilitasi hukum kepada Ira Puspadewi, eks Direktur Utama PT Angkutan ...	id	https://www.antaranews.com/berita/5267953/sosok-ira-puspadewi-eks-dirut-asdp-yang-terima-rehabilitasi-presiden	4119984d-09e2-4d96-9c57-672c243b2d01	\N	\N	2025-11-26 08:58:59+00	0	0	0	0	0	neutral	0	\N	{politik,hukum}	{puspadewi,rehabilitasi,presiden,sosok,dirut}	\N	0	t	f	2026-07-21 17:28:04.653802+00	2026-07-21 17:28:04.653802+00
51f7a55c-331d-46e6-a341-966831fc2dff	news	75dbc863edb4ede5bcb6cee9	article	Apa Itu KUHAP? memahami regulasi baru setelah disahkan DPR. Dewan Perwakilan Rakyat Republik Indonesia (DPR RI) resmi mengesahkan Rancangan Kitab Undang-Undang Hukum Acara Pidana ...	Apa Itu KUHAP? memahami regulasi baru setelah disahkan DPR. Dewan Perwakilan Rakyat Republik Indonesia (DPR RI) resmi mengesahkan Rancangan Kitab Undang-Undang Hukum Acara Pidana ...	id	https://www.antaranews.com/berita/5252153/apa-itu-kuhap-memahami-regulasi-baru-setelah-disahkan-dpr	4119984d-09e2-4d96-9c57-672c243b2d01	\N	\N	2025-11-19 08:42:13+00	0	0	0	0	0	neutral	0	\N	{hukum,politik}	{undang,kuhap,memahami,regulasi,baru}	\N	0	t	f	2026-07-21 17:28:04.664644+00	2026-07-21 17:28:04.664644+00
7b62f823-a2fc-4212-bdde-df2331b023c1	news	88182c69f1d865e5f350bab5	article	Profil Arsul Sani, Hakim Konstitusi yang datang dari politisi. Arsul Sani yang merupakan politikus dilantik sebagai Hakim Konstitusi pada 18 Januari 2024. Ia diajukan sebagai Hakim ...	Profil Arsul Sani, Hakim Konstitusi yang datang dari politisi. Arsul Sani yang merupakan politikus dilantik sebagai Hakim Konstitusi pada 18 Januari 2024. Ia diajukan sebagai Hakim ...	id	https://www.antaranews.com/berita/5247593/profil-arsul-sani-hakim-konstitusi-yang-datang-dari-politisi	4119984d-09e2-4d96-9c57-672c243b2d01	\N	\N	2025-11-17 11:46:47+00	0	0	0	0	0	neutral	0	\N	{umum}	{hakim,arsul,sani,konstitusi,profil}	\N	0	t	f	2026-07-21 17:28:04.679677+00	2026-07-21 17:28:04.679677+00
901e803a-c0ba-4c41-b336-1e8e2a0c8c51	news	d65ee9bf5b2762290da69129	article	Profil Hendra Kurniawan yang batal dijatuhi PTDH dari kasus Brigadir J. Nama Brigjen Pol Hendra Kurniawan, yang sebelumnya menjabat sebagai Kepala Biro Pengamanan Internal (Karopaminal) ...	Profil Hendra Kurniawan yang batal dijatuhi PTDH dari kasus Brigadir J. Nama Brigjen Pol Hendra Kurniawan, yang sebelumnya menjabat sebagai Kepala Biro Pengamanan Internal (Karopaminal) ...	id	https://www.antaranews.com/berita/5243549/profil-hendra-kurniawan-yang-batal-dijatuhi-ptdh-dari-kasus-brigadir-j	4119984d-09e2-4d96-9c57-672c243b2d01	\N	\N	2025-11-15 00:17:09+00	0	0	0	0	0	neutral	0	\N	{hukum}	{hendra,kurniawan,profil,batal,dijatuhi}	\N	0	t	f	2026-07-21 17:28:04.6914+00	2026-07-21 17:28:04.6914+00
16b09942-8057-4340-9b8b-5c4d69a3fa40	news	96bf0fffceb926921330d9ce	article	LHKPN Agus Pramono, Sekda Ponorogo selama 13 tahun. Komisi Pemberantasan Korupsi (KPK) menetapkan Sekretaris Daerah (Sekda) Ponorogo Agus Pramono sebagai salah satu dari ...	LHKPN Agus Pramono, Sekda Ponorogo selama 13 tahun. Komisi Pemberantasan Korupsi (KPK) menetapkan Sekretaris Daerah (Sekda) Ponorogo Agus Pramono sebagai salah satu dari ...	id	https://www.antaranews.com/berita/5234961/lhkpn-agus-pramono-sekda-ponorogo-selama-13-tahun	4119984d-09e2-4d96-9c57-672c243b2d01	\N	\N	2025-11-11 10:29:46+00	0	0	0	0	0	negative	-1	\N	{hukum}	{agus,pramono,sekda,ponorogo,lhkpn}	\N	0	t	f	2026-07-21 17:28:04.701706+00	2026-07-21 17:28:04.701706+00
5aaa8198-138e-4f65-be08-b0f30a949413	news	334a9a8101d3c6c7c34a71a1	article	Profil Dwiarso Budi Santiarto, Wakil Ketua MA Bidang Non-Yudisial baru. Presiden RI Prabowo Subianto melantik Dwiarso Budi Santiarto sebagai Wakil Ketua Mahkamah Agung (MA) Bidang ...	Profil Dwiarso Budi Santiarto, Wakil Ketua MA Bidang Non-Yudisial baru. Presiden RI Prabowo Subianto melantik Dwiarso Budi Santiarto sebagai Wakil Ketua Mahkamah Agung (MA) Bidang ...	id	https://www.antaranews.com/berita/5234421/profil-dwiarso-budi-santiarto-wakil-ketua-ma-bidang-non-yudisial-baru	4119984d-09e2-4d96-9c57-672c243b2d01	\N	\N	2025-11-11 07:45:17+00	0	0	0	0	0	neutral	0	\N	{politik}	{dwiarso,budi,santiarto,wakil,ketua}	\N	0	t	f	2026-07-21 17:28:04.711531+00	2026-07-21 17:28:04.711531+00
ce1c439e-c151-413e-a9f3-af6dab1192fb	news	c8cf616166b1cbfe845194c1	article	Profil Jimly Asshiddiqie, sosok Ketua Komite Reformasi Polri. Presiden RI Prabowo Subianto resmi melantik sepuluh anggota Komisi Percepatan Reformasi Polri di Istana Merdeka, ...	Profil Jimly Asshiddiqie, sosok Ketua Komite Reformasi Polri. Presiden RI Prabowo Subianto resmi melantik sepuluh anggota Komisi Percepatan Reformasi Polri di Istana Merdeka, ...	id	https://www.antaranews.com/berita/5230469/profil-jimly-asshiddiqie-sosok-ketua-komite-reformasi-polri	4119984d-09e2-4d96-9c57-672c243b2d01	\N	\N	2025-11-09 12:14:55+00	0	0	0	0	0	neutral	0	\N	{politik}	{reformasi,polri,profil,jimly,asshiddiqie}	\N	0	t	f	2026-07-21 17:28:04.722992+00	2026-07-21 17:28:04.722992+00
da09c2d1-a2ae-46de-b61d-6a084980516f	news	3b9fa406b692c33567c38ec8	article	Daftar 10 anggota Komisi Percepatan Reformasi Polri. Presiden Prabowo Subianto beberapa hari lalu secara resmi melantik sepuluh tokoh sebagai anggota Komisi Percepatan ...	Daftar 10 anggota Komisi Percepatan Reformasi Polri. Presiden Prabowo Subianto beberapa hari lalu secara resmi melantik sepuluh tokoh sebagai anggota Komisi Percepatan ...	id	https://www.antaranews.com/berita/5230465/daftar-10-anggota-komisi-percepatan-reformasi-polri	4119984d-09e2-4d96-9c57-672c243b2d01	\N	\N	2025-11-09 12:13:42+00	0	0	0	0	0	neutral	0	\N	{politik}	{anggota,komisi,percepatan,daftar,reformasi}	\N	0	t	f	2026-07-21 17:28:04.732739+00	2026-07-21 17:28:04.732739+00
4eb5411d-0a0a-419e-83c1-1a7514cc081d	news	eaa122f5565bcac8d4720fa0	article	Profil Sugiri Sancoko, Bupati Ponorogo yang terjaring OTT KPK. Komisi Pemberantasan Korupsi (KPK) kembali melakukan operasi tangkap tangan (OTT) yang kali ini menyasar lingkungan ...	Profil Sugiri Sancoko, Bupati Ponorogo yang terjaring OTT KPK. Komisi Pemberantasan Korupsi (KPK) kembali melakukan operasi tangkap tangan (OTT) yang kali ini menyasar lingkungan ...	id	https://www.antaranews.com/berita/5230461/profil-sugiri-sancoko-bupati-ponorogo-yang-terjaring-ott-kpk	4119984d-09e2-4d96-9c57-672c243b2d01	\N	\N	2025-11-09 12:12:16+00	0	0	0	0	0	negative	-1	\N	{hukum}	{profil,sugiri,sancoko,bupati,ponorogo}	\N	0	t	f	2026-07-21 17:28:04.740947+00	2026-07-21 17:28:04.740947+00
2fbf551a-b841-49c4-8b23-feec7370692c	news	a09494106b2aa3c75a547c66	article	Mengenang Junko Furuta, gadis Jepang yang Jadi korban kekerasan brutal. Belakangan ini, media sosial diramaikan kembali oleh pembahasan kasus Junko Furuta, seorang gadis Jepang yang menjadi ...	Mengenang Junko Furuta, gadis Jepang yang Jadi korban kekerasan brutal. Belakangan ini, media sosial diramaikan kembali oleh pembahasan kasus Junko Furuta, seorang gadis Jepang yang menjadi ...	id	https://www.antaranews.com/berita/5228165/mengenang-junko-furuta-gadis-jepang-yang-jadi-korban-kekerasan-brutal	4119984d-09e2-4d96-9c57-672c243b2d01	\N	\N	2025-11-07 18:04:44+00	0	0	0	0	0	neutral	0	\N	{hukum,sosial}	{junko,furuta,gadis,jepang,mengenang}	\N	0	t	f	2026-07-21 17:28:04.749276+00	2026-07-21 17:28:04.749276+00
d4c92be0-e3b6-4b37-b442-da470f36b37a	news	357eebe7f29d16e0dbb5af7b	article	Segini harta kekayaan Sugiri Sancoko, Bupati Ponorogo yang kena OTT. Komisi Pemberantasan Korupsi (KPK) menangkap Bupati Ponorogo Sugiri Sancoko dalam operasi tangkap tangan (OTT) pada ...	Segini harta kekayaan Sugiri Sancoko, Bupati Ponorogo yang kena OTT. Komisi Pemberantasan Korupsi (KPK) menangkap Bupati Ponorogo Sugiri Sancoko dalam operasi tangkap tangan (OTT) pada ...	id	https://www.antaranews.com/berita/5228149/segini-harta-kekayaan-sugiri-sancoko-bupati-ponorogo-yang-kena-ott	4119984d-09e2-4d96-9c57-672c243b2d01	\N	\N	2025-11-07 17:58:16+00	0	0	0	0	0	negative	-1	\N	{hukum}	{sugiri,sancoko,bupati,ponorogo,segini}	\N	0	t	f	2026-07-21 17:28:04.758026+00	2026-07-21 17:28:04.758026+00
98ad72c7-fb55-40a7-bd6f-3a4193e22e6f	news	6d50a7d4afacfb61ed1cbc0f	article	Survei Ungkap Fakta Baru, Perang Iran Jadi "Gerbang Kehancuran" Trump. Perang Iran yang diluncurkan Trump menjadi salah satu yang paling tidak populer dalam sejarah AS, dengan 68% warga menilai perang ini tidak layak diperjuangkan.	Survei Ungkap Fakta Baru, Perang Iran Jadi "Gerbang Kehancuran" Trump. Perang Iran yang diluncurkan Trump menjadi salah satu yang paling tidak populer dalam sejarah AS, dengan 68% warga menilai perang ini tidak layak diperjuangkan.	id	https://www.cnbcindonesia.com/news/20260721175316-4-752695/survei-ungkap-fakta-baru-perang-iran-jadi-gerbang-kehancuran-trump	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 15:00:00+00	0	0	0	0	0	neutral	0	\N	{sosial}	{perang,iran,trump,survei,ungkap}	\N	0	t	f	2026-07-21 17:28:04.769563+00	2026-07-21 17:28:04.769563+00
b673e01a-f9df-4d9d-90d8-212cc1d3f0e7	news	f30eca6c7bf84e91564ce907	article	Potret Chaos Demonstan Vs Polisi Gegara Warga Tewas di Tahanan. Bentrokan dengan polisi anti huru hara menyusul kematian Abderrahim Fakir setelah ia ditahan oleh polisi selama upaya penangkapan.	Potret Chaos Demonstan Vs Polisi Gegara Warga Tewas di Tahanan. Bentrokan dengan polisi anti huru hara menyusul kematian Abderrahim Fakir setelah ia ditahan oleh polisi selama upaya penangkapan.	id	https://www.cnbcindonesia.com/news/20260721155800-7-752631/potret-chaos-demonstan-vs-polisi-gegara-warga-tewas-di-tahanan	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 14:50:00+00	0	0	0	0	0	neutral	0	\N	{hukum,sosial}	{polisi,potret,chaos,demonstan,gegara}	\N	0	t	f	2026-07-21 17:28:04.785628+00	2026-07-21 17:28:04.785628+00
e3a1d0e2-27f2-417e-9131-0417d7fb61ce	news	5549dda2ecf4ce963aaaf91e	article	Video: Babinsa dan Bhabinkamtibmas Tarik Pajak, Ini Kata Dirjen Pajak. Babinsa dan Bhabinkamtibmas Tarik Pajak, Ini Kata Dirjen Pajak	Video: Babinsa dan Bhabinkamtibmas Tarik Pajak, Ini Kata Dirjen Pajak. Babinsa dan Bhabinkamtibmas Tarik Pajak, Ini Kata Dirjen Pajak	id	https://www.cnbcindonesia.com/news/20260721203452-8-752732/video-babinsa-dan-bhabinkamtibmas-tarik-pajak-ini-kata-dirjen-pajak	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 14:40:44+00	0	0	0	0	0	neutral	0	\N	{umum}	{pajak,babinsa,bhabinkamtibmas,tarik,kata}	\N	0	t	f	2026-07-21 17:28:04.794711+00	2026-07-21 17:28:04.794711+00
f569ebf5-45af-4858-aaa2-c225d965d1a8	news	f38b24f496ee8fefb4a0b2fd	article	Video: Semester 1 APBN Defisit Rp 196.5 Triliun. Semester 1 APBN Defisit Rp 196.5 Triliun	Video: Semester 1 APBN Defisit Rp 196.5 Triliun. Semester 1 APBN Defisit Rp 196.5 Triliun	id	https://www.cnbcindonesia.com/news/20260721203417-8-752731/video-semester-1-apbn-defisit-rp-1965-triliun	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 14:30:33+00	0	0	0	0	0	neutral	0	\N	{umum}	{semester,apbn,defisit,triliun,video}	\N	0	t	f	2026-07-21 17:28:04.805342+00	2026-07-21 17:28:04.805342+00
16566585-ca14-4297-b415-ff4a9bfa8b8e	news	bbb4e72faa6ca3ac27a4163c	article	Banjir Bandang Hancurkan Satu Kota, 20 Tewas-105 Orang Hilang. Banjir bandang di Nuristan, Afghanistan, menewaskan 20 orang dan 105 lainnya hilang, termasuk wali kota. Kerusakan parah melanda permukiman dan ekonomi lokal.	Banjir Bandang Hancurkan Satu Kota, 20 Tewas-105 Orang Hilang. Banjir bandang di Nuristan, Afghanistan, menewaskan 20 orang dan 105 lainnya hilang, termasuk wali kota. Kerusakan parah melanda permukiman dan ekonomi lokal.	id	https://www.cnbcindonesia.com/news/20260721200939-4-752724/banjir-bandang-hancurkan-satu-kota-20-tewas-105-orang-hilang	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 14:30:00+00	0	0	0	0	0	negative	-1	\N	{ekonomi,sosial}	{banjir,bandang,kota,orang,hilang}	\N	0	t	f	2026-07-21 17:28:04.814782+00	2026-07-21 17:28:04.814782+00
b5c42df3-cde3-4482-ab0b-8605d6abea8d	news	7cedb6645fc676704405a3ce	article	Dana Rehab-Rekon Didistribusikan, Ketua Satgas PRR Tekankan Hal Ini. Mendagri Tito Karnavian minta kementerian/lembaga transparan soal anggaran Rehab-Rekon pascabencana Sumatra 2026-2028. Total anggaran Rp100,1 triliun.	Dana Rehab-Rekon Didistribusikan, Ketua Satgas PRR Tekankan Hal Ini. Mendagri Tito Karnavian minta kementerian/lembaga transparan soal anggaran Rehab-Rekon pascabencana Sumatra 2026-2028. Total anggaran Rp100,1 triliun.	id	https://www.cnbcindonesia.com/news/20260721211647-4-752733/dana-rehab-rekon-didistribusikan-ketua-satgas-prr-tekankan-hal-ini	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 14:23:46+00	0	0	0	0	0	neutral	0	\N	{umum}	{rehab,rekon,anggaran,dana,didistribusikan}	\N	0	t	f	2026-07-21 17:28:04.824501+00	2026-07-21 17:28:04.824501+00
e6500770-a610-4662-b033-56e61d809a7f	news	8b1d33d9091297729edf2eb4	article	Video: Penerimaan Negara dari Batu Bara Melambat. Penerimaan Negara dari Batu Bara Melambat	Video: Penerimaan Negara dari Batu Bara Melambat. Penerimaan Negara dari Batu Bara Melambat	id	https://www.cnbcindonesia.com/news/20260721203417-8-752730/video-penerimaan-negara-dari-batu-bara-melambat	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 14:20:53+00	0	0	0	0	0	neutral	0	\N	{umum}	{penerimaan,negara,batu,bara,melambat}	\N	0	t	f	2026-07-21 17:28:04.836084+00	2026-07-21 17:28:04.836084+00
9ab5051a-acf1-4ab4-84d5-4f56f1aec8bf	news	86cd1cab09a387ae93397949	article	Video: Likuiditas Perbankan Jadi Sorotan, Pemerintah Siapkan Strategi. Likuiditas Perbankan Jadi Sorotan, Pemerintah Siapkan Strategi Baru	Video: Likuiditas Perbankan Jadi Sorotan, Pemerintah Siapkan Strategi. Likuiditas Perbankan Jadi Sorotan, Pemerintah Siapkan Strategi Baru	id	https://www.cnbcindonesia.com/news/20260721203416-8-752729/video-likuiditas-perbankan-jadi-sorotan-pemerintah-siapkan-strategi	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 14:10:51+00	0	0	0	0	0	neutral	0	\N	{politik}	{likuiditas,perbankan,jadi,sorotan,pemerintah}	\N	0	t	f	2026-07-21 17:28:04.84487+00	2026-07-21 17:28:04.84487+00
6e7f6169-54fa-491c-a25f-632f1ca930b0	news	98e586997b18d1501544043b	article	Rezim Kian Otoriter, Hapuskan Pemilu Demi Cegah Oposisi Berkuasa. Presiden Nikaragua, Daniel Ortega, mengumumkan penghentian pemilihan umum untuk mencegah oposisi berkuasa.	Rezim Kian Otoriter, Hapuskan Pemilu Demi Cegah Oposisi Berkuasa. Presiden Nikaragua, Daniel Ortega, mengumumkan penghentian pemilihan umum untuk mencegah oposisi berkuasa.	id	https://www.cnbcindonesia.com/news/20260721200251-4-752722/rezim-kian-otoriter-hapuskan-pemilu-demi-cegah-oposisi-berkuasa	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 14:10:00+00	0	0	0	0	0	neutral	0	\N	{politik}	{oposisi,berkuasa,rezim,kian,otoriter}	\N	0	t	f	2026-07-21 17:28:04.854545+00	2026-07-21 17:28:04.854545+00
fc70f3d4-d331-4c48-ba1a-de8cd06cb9f2	news	2816e92fab7c3fcba8c9b582	article	Video: Purbaya Umumkan Panda Bond Pertama RI Terbit 23 Juli 2026. Purbaya Umumkan Panda Bond Pertama RI Terbit 23 Juli 2026	Video: Purbaya Umumkan Panda Bond Pertama RI Terbit 23 Juli 2026. Purbaya Umumkan Panda Bond Pertama RI Terbit 23 Juli 2026	id	https://www.cnbcindonesia.com/news/20260721203415-8-752728/video-purbaya-umumkan-panda-bond-pertama-ri-terbit-23-juli-2026	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 14:00:15+00	0	0	0	0	0	neutral	0	\N	{umum}	{purbaya,umumkan,panda,bond,pertama}	\N	0	t	f	2026-07-21 17:28:04.864732+00	2026-07-21 17:28:04.864732+00
eae40705-0927-40bc-ab68-a61cacf77154	news	ffca6bdc2f5ed4f09b886d3b	article	Zulhas Ungkap Program Besar Tidak Kalah dari Kopdes Merah Putih. Pemerintah luncurkan program Kampung Budi Daya Tematik untuk 40 ribu desa hingga 2029, fokus pada kemandirian pangan dan peningkatan ekspor perikanan.	Zulhas Ungkap Program Besar Tidak Kalah dari Kopdes Merah Putih. Pemerintah luncurkan program Kampung Budi Daya Tematik untuk 40 ribu desa hingga 2029, fokus pada kemandirian pangan dan peningkatan ekspor perikanan.	id	https://www.cnbcindonesia.com/news/20260721201406-4-752725/zulhas-ungkap-program-besar-tidak-kalah-dari-kopdes-merah-putih	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 13:55:00+00	0	0	0	0	0	neutral	0	\N	{politik}	{program,zulhas,ungkap,besar,kalah}	\N	0	t	f	2026-07-21 17:28:04.874889+00	2026-07-21 17:28:04.874889+00
b90668f9-fc99-45cf-ac43-5332c2bf7805	news	0dc86aaf3320a3251028f9e0	article	Video: Ancaman Karhutla Meningkat, KLH Perketat Pengawasan Gambut. Ancaman Karhutla Meningkat, KLH Perketat Pengawasan Gambut	Video: Ancaman Karhutla Meningkat, KLH Perketat Pengawasan Gambut. Ancaman Karhutla Meningkat, KLH Perketat Pengawasan Gambut	id	https://www.cnbcindonesia.com/news/20260721203414-8-752727/video-ancaman-karhutla-meningkat-klh-perketat-pengawasan-gambut	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 13:50:35+00	0	0	0	0	0	negative	-1	\N	{umum}	{ancaman,karhutla,meningkat,perketat,pengawasan}	\N	0	t	f	2026-07-21 17:28:04.88854+00	2026-07-21 17:28:04.88854+00
d6525b4b-1a2d-4cfa-84fc-073aad1939e4	news	6c49eefba005a8be6555f3e3	article	Terowongan PLTA Meledak, 10 Pekerja Tewas-15 Belum Ditemukan. Ledakan di terowongan PLTA Teesta Stage VI, Sikkim, India, menewaskan 10 pekerja. 15 lainnya terjebak, peluang selamat semakin kecil akibat gas beracun.	Terowongan PLTA Meledak, 10 Pekerja Tewas-15 Belum Ditemukan. Ledakan di terowongan PLTA Teesta Stage VI, Sikkim, India, menewaskan 10 pekerja. 15 lainnya terjebak, peluang selamat semakin kecil akibat gas beracun.	id	https://www.cnbcindonesia.com/news/20260721195115-4-752720/terowongan-plta-meledak-10-pekerja-tewas-15-belum-ditemukan	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 13:50:00+00	0	0	0	0	0	neutral	0	\N	{umum}	{terowongan,plta,pekerja,meledak,tewas}	\N	0	t	f	2026-07-21 17:28:04.897693+00	2026-07-21 17:28:04.897693+00
bd5fea3d-2d7a-4111-808d-af110354fa54	news	dea32ea1502c947e6bef7364	article	Video: Perkuat SDM Maritim, KKP Resmikan Ocean Institute of Indonesia. Perkuat SDM Maritim, KKP Resmikan Ocean Institute of Indonesia	Video: Perkuat SDM Maritim, KKP Resmikan Ocean Institute of Indonesia. Perkuat SDM Maritim, KKP Resmikan Ocean Institute of Indonesia	id	https://www.cnbcindonesia.com/news/20260721203419-8-752726/video-perkuat-sdm-maritim-kkp-resmikan-ocean-institute-of-indonesia	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 13:44:02+00	0	0	0	0	0	neutral	0	\N	{umum}	{perkuat,maritim,resmikan,ocean,institute}	\N	0	t	f	2026-07-21 17:28:04.911477+00	2026-07-21 17:28:04.911477+00
ef3951ec-a973-49d5-a8ec-697438a372e9	news	34019f23465afc1ad8670b01	article	Anggaran MBG Dipangkas Jadi Rp 229 Triliun, BGN Ungkap Alasannya. BGN mengumumkan penurunan pagu anggaran Program MBG 2026 menjadi Rp 229 triliun, fokus pada perbaikan tata kelola dan efisiensi.	Anggaran MBG Dipangkas Jadi Rp 229 Triliun, BGN Ungkap Alasannya. BGN mengumumkan penurunan pagu anggaran Program MBG 2026 menjadi Rp 229 triliun, fokus pada perbaikan tata kelola dan efisiensi.	id	https://www.cnbcindonesia.com/news/20260721195334-4-752721/anggaran-mbg-dipangkas-jadi-rp-229-triliun-bgn-ungkap-alasannya	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 13:35:00+00	0	0	0	0	0	neutral	0	\N	{umum}	{anggaran,triliun,dipangkas,jadi,ungkap}	\N	0	t	f	2026-07-21 17:28:04.922203+00	2026-07-21 17:28:04.922203+00
3a4d03f3-9315-4605-926e-290f7cc61ad1	news	9c27c4d050de386140cea4b6	article	Purbaya Soal Efisiensi Anggaran MBG: Tunggu Pertemuan dengan Bos BGN. Menkeu Purbaya Yudhi Sadewa akan bertemu Kepala BGN untuk membahas efisiensi anggaran Makan Bergizi Gratis, yang dipastikan tidak lagi Rp268 triliun.	Purbaya Soal Efisiensi Anggaran MBG: Tunggu Pertemuan dengan Bos BGN. Menkeu Purbaya Yudhi Sadewa akan bertemu Kepala BGN untuk membahas efisiensi anggaran Makan Bergizi Gratis, yang dipastikan tidak lagi Rp268 triliun.	id	https://www.cnbcindonesia.com/news/20260721170907-4-752684/purbaya-soal-efisiensi-anggaran-mbg-tunggu-pertemuan-dengan-bos-bgn	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 13:20:20+00	0	0	0	0	0	neutral	0	\N	{umum}	{purbaya,efisiensi,anggaran,soal,tunggu}	\N	0	t	f	2026-07-21 17:28:04.932232+00	2026-07-21 17:28:04.932232+00
8d7507a0-2d57-44e8-87da-86dd844ccc55	news	820d349d1ac1297f20bc06a6	article	Begini Nasib Proyek Motor Listrik Mangkrak BGN Senilai Rp 1 Triliun. Badan Gizi Nasional memastikan 21.801 motor listrik senilai Rp1 triliun tidak menganggur. Begini nasibnya.	Begini Nasib Proyek Motor Listrik Mangkrak BGN Senilai Rp 1 Triliun. Badan Gizi Nasional memastikan 21.801 motor listrik senilai Rp1 triliun tidak menganggur. Begini nasibnya.	id	https://www.cnbcindonesia.com/news/20260721193641-4-752718/begini-nasib-proyek-motor-listrik-mangkrak-bgn-senilai-rp-1-triliun	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 13:15:00+00	0	0	0	0	0	neutral	0	\N	{umum}	{begini,motor,listrik,senilai,triliun}	\N	0	t	f	2026-07-21 17:28:04.942801+00	2026-07-21 17:28:04.942801+00
eacbfe32-827d-451a-aa83-ff2f42b89b22	news	5b41c22d610bcbfe95b01b9d	article	Perang AS-Iran Makan Korban Lagi, Harga BBM Meledak Rp 72.000. Harga bensin melonjak ke US$4,00 (Rp 72.000) per galon akibat konflik AS-Iran.	Perang AS-Iran Makan Korban Lagi, Harga BBM Meledak Rp 72.000. Harga bensin melonjak ke US$4,00 (Rp 72.000) per galon akibat konflik AS-Iran.	id	https://www.cnbcindonesia.com/news/20260721152401-4-752615/perang-as-iran-makan-korban-lagi-harga-bbm-meledak-rp-72000	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 13:10:00+00	0	0	0	0	0	negative	-1	\N	{umum}	{iran,harga,perang,makan,korban}	\N	0	t	f	2026-07-21 17:28:04.951844+00	2026-07-21 17:28:04.951844+00
ad50ac6d-228d-4cdd-913c-5d5238039402	news	3e43a107a3e9b6241db549ca	article	ESDM Uji Coba Tabung CNG 3 Kg di Jawa Barat Mulai Agustus 2026. Kementerian ESDM menjadwalkan uji coba tabung CNG 3 kg pengganti LPG 3 kg bersubsidi dilakukan mulai Agustus 2026	ESDM Uji Coba Tabung CNG 3 Kg di Jawa Barat Mulai Agustus 2026. Kementerian ESDM menjadwalkan uji coba tabung CNG 3 kg pengganti LPG 3 kg bersubsidi dilakukan mulai Agustus 2026	id	https://www.cnbcindonesia.com/news/20260721173811-4-752692/esdm-uji-coba-tabung-cng-3-kg-di-jawa-barat-mulai-agustus-2026	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 12:50:05+00	0	0	0	0	0	neutral	0	\N	{umum}	{esdm,coba,tabung,mulai,agustus}	\N	0	t	f	2026-07-21 17:28:04.961828+00	2026-07-21 17:28:04.961828+00
3c0971ce-009a-4a27-9d46-c7fc195a5d2c	news	2c4dfb5303f845080942350a	article	Seperti RI, Negeri Arab Ini Juga Lagi Garap Proyek Gas Raksasa!. ADNOC UEA investasi US$ 6,2 miliar untuk pengembangan Ladang Gas Umm Shaif.	Seperti RI, Negeri Arab Ini Juga Lagi Garap Proyek Gas Raksasa!. ADNOC UEA investasi US$ 6,2 miliar untuk pengembangan Ladang Gas Umm Shaif.	id	https://www.cnbcindonesia.com/news/20260721165823-4-752670/seperti-ri-negeri-arab-ini-juga-lagi-garap-proyek-gas-raksasa	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 12:45:05+00	0	0	0	0	0	neutral	0	\N	{ekonomi}	{seperti,negeri,arab,lagi,garap}	\N	0	t	f	2026-07-21 17:28:04.972437+00	2026-07-21 17:28:04.972437+00
aef18074-8159-429b-b02e-9c02ec57db1e	news	de066b4d1e16f4deb563ffe3	article	BGN Punya 5 Pejabat Baru, Latar Belakang Dokter Sampai Jaksa. Badan Gizi Nasional (BGN) melantik lima pejabat tinggi madya baru untuk memperkuat organisasi dan optimalkan Program Makan Bergizi Gratis.	BGN Punya 5 Pejabat Baru, Latar Belakang Dokter Sampai Jaksa. Badan Gizi Nasional (BGN) melantik lima pejabat tinggi madya baru untuk memperkuat organisasi dan optimalkan Program Makan Bergizi Gratis.	id	https://www.cnbcindonesia.com/news/20260721182147-4-752700/bgn-punya-5-pejabat-baru-latar-belakang-dokter-sampai-jaksa	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 12:35:00+00	0	0	0	0	0	neutral	0	\N	{hukum}	{pejabat,baru,punya,latar,belakang}	\N	0	t	f	2026-07-21 17:28:04.982478+00	2026-07-21 17:28:04.982478+00
640e4e65-ecdd-40a1-95ab-9d3986461c1b	news	2eadfcdb658d3156f066eb15	article	Titah Prabowo, Istana Pastikan Motor Listrik Nasional Segera Meluncur. Pemerintah Indonesia akan segera meluncurkan motor listrik nasional karya anak bangsa.	Titah Prabowo, Istana Pastikan Motor Listrik Nasional Segera Meluncur. Pemerintah Indonesia akan segera meluncurkan motor listrik nasional karya anak bangsa.	id	https://www.cnbcindonesia.com/news/20260721161223-4-752645/titah-prabowo-istana-pastikan-motor-listrik-nasional-segera-meluncur	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 12:30:14+00	0	0	0	0	0	neutral	0	\N	{politik}	{motor,listrik,nasional,segera,titah}	\N	0	t	f	2026-07-21 17:28:04.993731+00	2026-07-21 17:28:04.993731+00
30c4a87d-d769-4079-9330-a82190dcffdf	news	bf375483c899139ba864c9b6	article	Peran Pertamina Dukung Pembangunan Ekosistem 'BBM' Baru Hidrogen. PT Pertamina (Persero) tengah mempercepat pembangunan ekosistem hidrogen sebagai alternatif bahan bakar dalam negeri.	Peran Pertamina Dukung Pembangunan Ekosistem 'BBM' Baru Hidrogen. PT Pertamina (Persero) tengah mempercepat pembangunan ekosistem hidrogen sebagai alternatif bahan bakar dalam negeri.	id	https://www.cnbcindonesia.com/news/20260721182602-4-752701/peran-pertamina-dukung-pembangunan-ekosistem-bbm-baru-hidrogen	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 12:25:05+00	0	0	0	0	0	neutral	0	\N	{umum}	{pertamina,pembangunan,ekosistem,hidrogen,peran}	\N	0	t	f	2026-07-21 17:28:05.005098+00	2026-07-21 17:28:05.005098+00
5fca7a14-6121-4abe-a592-5fd80ae92a0c	news	6529141047ebfd4224a1cf94	article	PLN Ternyata Produksi Ratusan Ton Pengganti Bensin. PT PLN mendukung pengembangan ekosistem hidrogen di Indonesia, memanfaatkan surplus produksi hidrogen untuk transportasi dan dedieselisasi.	PLN Ternyata Produksi Ratusan Ton Pengganti Bensin. PT PLN mendukung pengembangan ekosistem hidrogen di Indonesia, memanfaatkan surplus produksi hidrogen untuk transportasi dan dedieselisasi.	id	https://www.cnbcindonesia.com/news/20260721181610-4-752699/pln-ternyata-produksi-ratusan-ton-pengganti-bensin	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 12:15:00+00	0	0	0	0	0	positive	1	\N	{sosial}	{produksi,hidrogen,ternyata,ratusan,pengganti}	\N	0	t	f	2026-07-21 17:28:05.014315+00	2026-07-21 17:28:05.014315+00
1d98f4a6-6129-4005-b6f4-cc60f6a47e74	news	ad6be8fbd3af562937cb8865	article	'Kerajaan' Penipuan Online Gasak Duit Rp 2.053 T, Tersebar di Dekat RI. Sindikat kejahatan siber di Asia-Pasifik diperkirakan merugikan hingga US$ 114,1 miliar pada 2025. Mereka memanfaatkan AI	'Kerajaan' Penipuan Online Gasak Duit Rp 2.053 T, Tersebar di Dekat RI. Sindikat kejahatan siber di Asia-Pasifik diperkirakan merugikan hingga US$ 114,1 miliar pada 2025. Mereka memanfaatkan AI	id	https://www.cnbcindonesia.com/news/20260721152853-4-752617/kerajaan-penipuan-online-gasak-duit-rp-2053-t-tersebar-di-dekat-ri	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 12:00:00+00	0	0	0	0	0	neutral	0	\N	{teknologi}	{kerajaan,penipuan,online,gasak,duit}	\N	0	t	f	2026-07-21 17:28:05.023482+00	2026-07-21 17:28:05.023482+00
2e65f32b-938b-4fb3-a16a-1dfe57992748	news	e113f323d5de154a8bf36e8c	article	Penjualan Rumah Subsidi Turun 24%, Penyebabnya Banyak-Termasuk SLIK. Penurunan tersebut tidak dipicu oleh satu faktor saja. Sejumlah tantangan muncul secara bersamaan.	Penjualan Rumah Subsidi Turun 24%, Penyebabnya Banyak-Termasuk SLIK. Penurunan tersebut tidak dipicu oleh satu faktor saja. Sejumlah tantangan muncul secara bersamaan.	id	https://www.cnbcindonesia.com/news/20260721175414-4-752696/penjualan-rumah-subsidi-turun-24-penyebabnya-banyak-termasuk-slik	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 11:55:00+00	0	0	0	0	0	negative	-1	\N	{umum}	{penjualan,rumah,subsidi,turun,penyebabnya}	\N	0	t	f	2026-07-21 17:28:05.037576+00	2026-07-21 17:28:05.037576+00
7c4af06c-8cdb-42ce-8ebe-90ddc3f50d4e	news	ab5f4c86f17e9e7beca229ad	article	Harga BBM Pertamax Cs Turun Bulan Depan? Ini Kata ESDM. Kementerian ESDM belum membahas penurunan harga BBM non subsidi, termasuk Pertamax.	Harga BBM Pertamax Cs Turun Bulan Depan? Ini Kata ESDM. Kementerian ESDM belum membahas penurunan harga BBM non subsidi, termasuk Pertamax.	id	https://www.cnbcindonesia.com/news/20260721162510-4-752649/harga-bbm-pertamax-cs-turun-bulan-depan-ini-kata-esdm	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 11:45:05+00	0	0	0	0	0	negative	-1	\N	{umum}	{harga,pertamax,esdm,turun,bulan}	\N	0	t	f	2026-07-21 17:28:05.049506+00	2026-07-21 17:28:05.049506+00
6c02a235-b81d-4a2d-9609-019aaeded01c	news	9e25484f3dd0f4bea564892f	article	Ada Temuan Gas Jumbo, Pemerintah Prioritaskan Manfaat untuk Warga Aceh. Kementerian ESDM sosialisasikan rencana pengelolaan WK South Andaman kepada masyarakat Aceh. ESDM:	Ada Temuan Gas Jumbo, Pemerintah Prioritaskan Manfaat untuk Warga Aceh. Kementerian ESDM sosialisasikan rencana pengelolaan WK South Andaman kepada masyarakat Aceh. ESDM:	id	https://www.cnbcindonesia.com/news/20260721154120-4-752621/ada-temuan-gas-jumbo-pemerintah-prioritaskan-manfaat-untuk-warga-aceh	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 11:40:05+00	0	0	0	0	0	neutral	0	\N	{sosial,politik}	{aceh,esdm,temuan,jumbo,pemerintah}	\N	0	t	f	2026-07-21 17:28:05.060559+00	2026-07-21 17:28:05.060559+00
508735b0-9ef0-4cc1-ac8e-cf70a4be8eab	news	bd5153ffc59d966b456d7e80	article	Mendag Bilang Harga Telur dan Daging Ayam Kondisi Ideal, Ini Alasannya. Menteri Perdagangan Budi Santoso menyatakan harga telur dan daging ayam mendekati HET, menjaga keseimbangan antara peternak dan konsumen.	Mendag Bilang Harga Telur dan Daging Ayam Kondisi Ideal, Ini Alasannya. Menteri Perdagangan Budi Santoso menyatakan harga telur dan daging ayam mendekati HET, menjaga keseimbangan antara peternak dan konsumen.	id	https://www.cnbcindonesia.com/news/20260721172508-4-752690/mendag-bilang-harga-telur-daging-ayam-kondisi-ideal-ini-alasannya	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 11:35:00+00	0	0	0	0	0	neutral	0	\N	{politik}	{harga,telur,daging,ayam,mendag}	\N	0	t	f	2026-07-21 17:28:05.073019+00	2026-07-21 17:28:05.073019+00
97ef040c-9410-47ad-b224-c6d73178c99b	news	29f9b873d2087cc1939fac5d	article	Pintu Devisa Baru, 11.882 Produk RI Masuk Lokasi Ini Kena Diskon Tarif. Pemerintah Indonesia melanjutkan Perjanjian Perdagangan Bebas dengan EAEU, membuka akses pasar baru dan meningkatkan daya saing produk nasional di pasar global.	Pintu Devisa Baru, 11.882 Produk RI Masuk Lokasi Ini Kena Diskon Tarif. Pemerintah Indonesia melanjutkan Perjanjian Perdagangan Bebas dengan EAEU, membuka akses pasar baru dan meningkatkan daya saing produk nasional di pasar global.	id	https://www.cnbcindonesia.com/news/20260721160825-4-752641/pintu-devisa-baru-11882-produk-ri-masuk-lokasi-ini-kena-diskon-tarif	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 11:30:00+00	0	0	0	0	0	neutral	0	\N	{politik,ekonomi}	{baru,produk,pasar,pintu,devisa}	\N	0	t	f	2026-07-21 17:28:05.087699+00	2026-07-21 17:28:05.087699+00
37091511-e4a3-4dd9-b063-1dc7963fee79	news	89e3e0c32aad9849a8f96074	article	Setoran Bea Cukai Tak Capai Target 2026, Purbaya Ungkap Alasannya. Pemerintah memproyeksikan realisasi penerimaan bea dan cukai hingga akhir tahun 2026 akan di bawah target atau terjadi shortfall.	Setoran Bea Cukai Tak Capai Target 2026, Purbaya Ungkap Alasannya. Pemerintah memproyeksikan realisasi penerimaan bea dan cukai hingga akhir tahun 2026 akan di bawah target atau terjadi shortfall.	id	https://www.cnbcindonesia.com/news/20260721171926-4-752687/setoran-bea-cukai-tak-capai-target-2026-purbaya-ungkap-alasannya	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 11:15:26+00	0	0	0	0	0	neutral	0	\N	{politik}	{cukai,target,setoran,capai,purbaya}	\N	0	t	f	2026-07-21 17:28:05.10112+00	2026-07-21 17:28:05.10112+00
99fcdb34-2e08-4385-9e9a-d834084a28b6	news	32557a21306554e212fab7f9	article	Tabung CNG 3 Kg Lagi Uji Coba di China, Selanjutnya Diproduksi Pindad. Kementerian ESDM tengah melakukan uji coba penggunaan tabung CNG 3 kg di China sebagai pengganti LPG 3 kg bersubsidi.	Tabung CNG 3 Kg Lagi Uji Coba di China, Selanjutnya Diproduksi Pindad. Kementerian ESDM tengah melakukan uji coba penggunaan tabung CNG 3 kg di China sebagai pengganti LPG 3 kg bersubsidi.	id	https://www.cnbcindonesia.com/news/20260721154046-4-752620/tabung-cng-3-kg-lagi-uji-coba-di-china-selanjutnya-diproduksi-pindad	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 10:50:05+00	0	0	0	0	0	neutral	0	\N	{umum}	{tabung,coba,china,lagi,selanjutnya}	\N	0	t	f	2026-07-21 17:28:05.110874+00	2026-07-21 17:28:05.110874+00
c1790d6f-088f-4e68-9939-8a01f3f7fd3e	news	1004e48b3e73270c2d4fbbc0	article	IHSG Bangkit Kencang! Asing Tinggalkan Korea Cs Borong Saham RI?. IHSG Bangkit Kencang! Asing Tinggalkan Korea Cs Borong Saham RI?	IHSG Bangkit Kencang! Asing Tinggalkan Korea Cs Borong Saham RI?. IHSG Bangkit Kencang! Asing Tinggalkan Korea Cs Borong Saham RI?	id	https://www.cnbcindonesia.com/news/20260721155159-8-752629/ihsg-bangkit-kencang-asing-tinggalkan-korea-cs-borong-saham-ri	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 10:45:40+00	0	0	0	0	0	neutral	0	\N	{ekonomi}	{ihsg,bangkit,kencang,asing,tinggalkan}	\N	0	t	f	2026-07-21 17:28:05.122386+00	2026-07-21 17:28:05.122386+00
53fa0599-c24b-484d-af82-d750be37d9d6	news	357dd20fd075bd2a09b278dd	article	Pemerintah AS Mendadak Rilis Travel Warning Baru, Ada Apa?. Pemerintah AS mengeluarkan peringatan keamanan global bagi warganya terkait ketegangan di Timur Tengah.	Pemerintah AS Mendadak Rilis Travel Warning Baru, Ada Apa?. Pemerintah AS mengeluarkan peringatan keamanan global bagi warganya terkait ketegangan di Timur Tengah.	id	https://www.cnbcindonesia.com/news/20260721173301-4-752691/pemerintah-as-mendadak-rilis-travel-warning-baru-ada-apa	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 10:45:00+00	0	0	0	0	0	neutral	0	\N	{politik}	{pemerintah,mendadak,rilis,travel,warning}	\N	0	t	f	2026-07-21 17:28:05.132225+00	2026-07-21 17:28:05.132225+00
3a16f095-898c-4b32-85b1-1154270c584c	news	1b667afb15480fecf20feed7	article	Bulog Mau Jual 2 Juta Ton Beras SPHP Premium, Ini yang Akan Terjadi. Perum Bulog rencanakan jual Beras Kita premium dan medium, namun kritik muncul.	Bulog Mau Jual 2 Juta Ton Beras SPHP Premium, Ini yang Akan Terjadi. Perum Bulog rencanakan jual Beras Kita premium dan medium, namun kritik muncul.	id	https://www.cnbcindonesia.com/news/20260721151438-4-752612/bulog-mau-jual-2-juta-ton-beras-sphp-premium-ini-yang-akan-terjadi	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 10:40:00+00	0	0	0	0	0	negative	-1	\N	{umum}	{bulog,jual,beras,premium,juta}	\N	0	t	f	2026-07-21 17:28:05.142674+00	2026-07-21 17:28:05.142674+00
f57cf00e-38e3-4297-b016-e896379fd1dd	news	03d5e1c80d16f52865762e38	article	Mensesneg Benarkan Kemungkinan Anggaran MBG Diturunkan. Menteri Sekretaris Negara Prasetyo Hadi mengonfirmasi kemungkinan penurunan anggaran program Makan Bergizi Gratis (MBG) untuk efisiensi tata kelola pemerintah.	Mensesneg Benarkan Kemungkinan Anggaran MBG Diturunkan. Menteri Sekretaris Negara Prasetyo Hadi mengonfirmasi kemungkinan penurunan anggaran program Makan Bergizi Gratis (MBG) untuk efisiensi tata kelola pemerintah.	id	https://www.cnbcindonesia.com/news/20260721172618-4-752688/mensesneg-benarkan-kemungkinan-anggaran-mbg-diturunkan	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 10:38:14+00	0	0	0	0	0	neutral	0	\N	{politik}	{kemungkinan,anggaran,mensesneg,benarkan,diturunkan}	\N	0	t	f	2026-07-21 17:28:05.157287+00	2026-07-21 17:28:05.157287+00
0c552edd-664a-41ca-a7a2-d54c230290ec	news	4cf33d6686bedebd8674ef57	article	Menhub Beri Kabar Terbaru Soal KRL Green Line, Simak!. Menteri Perhubungan Dudy Purwagandhi mengumumkan pembenahan KRL Green Line Tanah Abang-Rangkasbitung. Kapan?	Menhub Beri Kabar Terbaru Soal KRL Green Line, Simak!. Menteri Perhubungan Dudy Purwagandhi mengumumkan pembenahan KRL Green Line Tanah Abang-Rangkasbitung. Kapan?	id	https://www.cnbcindonesia.com/news/20260721172511-4-752689/menhub-beri-kabar-terbaru-soal-krl-green-line-simak	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 10:27:04+00	0	0	0	0	0	neutral	0	\N	{politik}	{green,line,menhub,beri,kabar}	\N	0	t	f	2026-07-21 17:28:05.168545+00	2026-07-21 17:28:05.168545+00
843fb310-c7c1-45fa-8096-9ebc941516c0	news	5c105ac96a48b72cf51263c4	article	Mensesneg Jawab Rumor Prabowo Reshuffle Kabinet: Belum, Belum, Belum. Menteri Sekretaris Negara Prasetyo Hadi menegaskan tidak ada rencana reshuffle kabinet dalam waktu dekat, meski evaluasi kinerja terus dilakukan.	Mensesneg Jawab Rumor Prabowo Reshuffle Kabinet: Belum, Belum, Belum. Menteri Sekretaris Negara Prasetyo Hadi menegaskan tidak ada rencana reshuffle kabinet dalam waktu dekat, meski evaluasi kinerja terus dilakukan.	id	https://www.cnbcindonesia.com/news/20260721171509-4-752685/mensesneg-jawab-rumor-prabowo-reshuffle-kabinet-belum-belum-belum	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 10:23:09+00	0	0	0	0	0	neutral	0	\N	{politik}	{belum,reshuffle,kabinet,mensesneg,jawab}	\N	0	t	f	2026-07-21 17:28:05.186352+00	2026-07-21 17:28:05.186352+00
d92214cc-7d9d-4953-b446-3b4063d57cf5	news	9507440994f53346a48f76c6	article	PLN Siapkan Kontrak Jangka Panjang untuk Akselerasi Proyek PSEL. Proyek Pengolahan Sampah menjadi Energi Listrik (PSEL) menarik minat investor global. Pemerintah percepat regulasi untuk solusi sampah dan transisi energi.	PLN Siapkan Kontrak Jangka Panjang untuk Akselerasi Proyek PSEL. Proyek Pengolahan Sampah menjadi Energi Listrik (PSEL) menarik minat investor global. Pemerintah percepat regulasi untuk solusi sampah dan transisi energi.	id	https://www.cnbcindonesia.com/news/20260721171538-4-752686/pln-siapkan-kontrak-jangka-panjang-untuk-akselerasi-proyek-psel	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 10:20:47+00	0	0	0	0	0	neutral	0	\N	{politik,lingkungan}	{proyek,psel,sampah,energi,siapkan}	\N	0	t	f	2026-07-21 17:28:05.198185+00	2026-07-21 17:28:05.198185+00
2e040c3b-f7a3-4d9c-acaf-bae405482b5c	news	b8530551ee50de97390ec0a4	article	Harga Daging Sapi Adem Ayem, Mendag Tak Perlu Tambah Kuota Impor. Mendag Budi Santoso memastikan pasokan daging sapi aman meski ada beberapa yang naik. Kuota impor tak ditambah.	Harga Daging Sapi Adem Ayem, Mendag Tak Perlu Tambah Kuota Impor. Mendag Budi Santoso memastikan pasokan daging sapi aman meski ada beberapa yang naik. Kuota impor tak ditambah.	id	https://www.cnbcindonesia.com/news/20260721145005-4-752604/harga-daging-sapi-adem-ayem-mendag-tak-perlu-tambah-kuota-impor	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 10:20:25+00	0	0	0	0	0	positive	1	\N	{ekonomi}	{daging,sapi,mendag,kuota,impor}	\N	0	t	f	2026-07-21 17:28:05.210691+00	2026-07-21 17:28:05.210691+00
b456a76c-f6b5-496e-a3e0-45affc323578	news	8fdec2d1d5c516cddc179231	article	Ibu Kota Argentina Rusuh - Ekspor Satu Pintu DSI Mulai 1 September. Ibu Kota Argentina Rusuh - Ekspor Satu Pintu DSI Mulai 1 September	Ibu Kota Argentina Rusuh - Ekspor Satu Pintu DSI Mulai 1 September. Ibu Kota Argentina Rusuh - Ekspor Satu Pintu DSI Mulai 1 September	id	https://www.cnbcindonesia.com/news/20260721142541-8-752591/ibu-kota-argentina-rusuh--ekspor-satu-pintu-dsi-mulai-1-september	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 10:20:13+00	0	0	0	0	0	neutral	0	\N	{sosial}	{kota,argentina,rusuh,ekspor,satu}	\N	0	t	f	2026-07-21 17:28:05.220085+00	2026-07-21 17:28:05.220085+00
20a253ad-2473-4c2c-83b8-3af9c0765033	news	42dedff946195666ced526bf	article	Mensesneg Ungkap Prabowo Segera Teken Keppres Jampidus Kejagung. Menteri Sekretaris Negara Prasetyo Hadi mengungkapkan bahwa Presiden Prabowo akan segera memutuskan pengganti Jaksa Agung Muda Pidana Khusus.	Mensesneg Ungkap Prabowo Segera Teken Keppres Jampidus Kejagung. Menteri Sekretaris Negara Prasetyo Hadi mengungkapkan bahwa Presiden Prabowo akan segera memutuskan pengganti Jaksa Agung Muda Pidana Khusus.	id	https://www.cnbcindonesia.com/news/20260721171246-4-752683/mensesneg-ungkap-prabowo-segera-teken-keppres-jampidus-kejagung	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 10:18:46+00	0	0	0	0	0	neutral	0	\N	{politik,hukum}	{prabowo,segera,mensesneg,ungkap,teken}	\N	0	t	f	2026-07-21 17:28:05.236302+00	2026-07-21 17:28:05.236302+00
bbdf2f13-e83b-4c25-af6b-4c73d8df8f87	news	4f83b01c8c2e0a529c16802d	article	Dari Jalan Berlumpur hingga Pelosok, Mantri BRI Dorong Ekonomi Rakyat. BRI berkomitmen mendorong ekonomi kerakyatan melalui Mantri BRI yang mendampingi UMKM. Rani, salah satu Mantri, berbagi pengalaman dan dampak positifnya.	Dari Jalan Berlumpur hingga Pelosok, Mantri BRI Dorong Ekonomi Rakyat. BRI berkomitmen mendorong ekonomi kerakyatan melalui Mantri BRI yang mendampingi UMKM. Rani, salah satu Mantri, berbagi pengalaman dan dampak positifnya.	id	https://www.cnbcindonesia.com/news/20260721171010-4-752673/dari-jalan-berlumpur-hingga-pelosok-mantri-bri-dorong-ekonomi-rakyat	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 10:14:00+00	0	0	0	0	0	neutral	0	\N	{ekonomi}	{mantri,ekonomi,jalan,berlumpur,hingga}	\N	0	t	f	2026-07-21 17:28:05.246177+00	2026-07-21 17:28:05.246177+00
a826326f-5d48-4a1f-a9fe-e94676e973ca	news	e142624b50069f14d5b48c3b	article	Menhub: Bandara Husein untuk Rute Domestik, Internasional di Kertajati. Menhub Dudy Purwagandhi mengumumkan Bandara Husein Sastranegara di Bandung akan kembali beroperasi untuk penerbangan domestik pada September 2026.	Menhub: Bandara Husein untuk Rute Domestik, Internasional di Kertajati. Menhub Dudy Purwagandhi mengumumkan Bandara Husein Sastranegara di Bandung akan kembali beroperasi untuk penerbangan domestik pada September 2026.	id	https://www.cnbcindonesia.com/news/20260721171000-4-752672/menhub-bandara-husein-untuk-rute-domestik-internasional-di-kertajati	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 10:12:50+00	0	0	0	0	0	neutral	0	\N	{umum}	{menhub,bandara,husein,domestik,rute}	\N	0	t	f	2026-07-21 17:28:05.256301+00	2026-07-21 17:28:05.256301+00
d8c85c88-7d76-46e2-b810-4eb0a6fc4606	news	b259ae5e63eb5aebaf55f21c	article	MK Putuskan IUP ke Ormas Tak Bisa Tunjuk Langsung, Bahlil Siapkan Ini. Menteri ESDM Bahlil akan terbitkan aturan baru usai putusan MK tentang pemberian IUP ke Ormas tak bisa melalui penunjukan langsung.	MK Putuskan IUP ke Ormas Tak Bisa Tunjuk Langsung, Bahlil Siapkan Ini. Menteri ESDM Bahlil akan terbitkan aturan baru usai putusan MK tentang pemberian IUP ke Ormas tak bisa melalui penunjukan langsung.	id	https://www.cnbcindonesia.com/news/20260721141719-4-752588/mk-putuskan-iup-ke-ormas-tak-bisa-tunjuk-langsung-bahlil-siapkan-ini	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 10:10:05+00	0	0	0	0	0	neutral	0	\N	{politik,hukum}	{ormas,langsung,bahlil,putuskan,tunjuk}	\N	0	t	f	2026-07-21 17:28:05.267867+00	2026-07-21 17:28:05.267867+00
d7061fa6-1342-4b10-9944-ee43985bf711	news	2ec1e2903e8bb47cf52bcd05	article	Pertamina Optimalkan Potensi dan Limbah Sawit untuk Substitusi Impor BBM. PT Pertamina berkomitmen mendukung ketahanan energi nasional dengan bioenergi berbasis kelapa sawit. Fokus pada pengurangan impor BBM dan pengembangan bioetanol	Pertamina Optimalkan Potensi dan Limbah Sawit untuk Substitusi Impor BBM. PT Pertamina berkomitmen mendukung ketahanan energi nasional dengan bioenergi berbasis kelapa sawit. Fokus pada pengurangan impor BBM dan pengembangan bioetanol	id	https://www.cnbcindonesia.com/news/20260721163704-4-752663/pertamina-optimalkan-potensi-limbah-sawit-untuk-substitusi-impor-bbm	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 09:57:11+00	0	0	0	0	0	positive	1	\N	{ekonomi}	{pertamina,sawit,impor,optimalkan,potensi}	\N	0	t	f	2026-07-21 17:28:05.279918+00	2026-07-21 17:28:05.279918+00
85c386dd-8925-4b9d-8c0b-ab6f5a52e101	news	6cee4841547329d24a357969	article	Pakai Jurus Ini, Zulhas Targetkan Nelayan RI Sejahtera 2 Tahun Lagi. Menkop Pangan Zulkifli Hasan targetkan nilai tukar nelayan mencapai 120 dalam dua tahun. Ini dia resepnya.	Pakai Jurus Ini, Zulhas Targetkan Nelayan RI Sejahtera 2 Tahun Lagi. Menkop Pangan Zulkifli Hasan targetkan nilai tukar nelayan mencapai 120 dalam dua tahun. Ini dia resepnya.	id	https://www.cnbcindonesia.com/news/20260721164731-4-752659/pakai-jurus-ini-zulhas-targetkan-nelayan-ri-sejahtera-2-tahun-lagi	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 09:52:07+00	0	0	0	0	0	neutral	0	\N	{umum}	{targetkan,nelayan,tahun,pakai,jurus}	\N	0	t	f	2026-07-21 17:28:05.290665+00	2026-07-21 17:28:05.290665+00
265e1766-c762-4852-8cec-b5be8947656a	news	213d1aeb285cf24916fa1455	article	288.000 Warga 'Kabur' ke Luar Negeri dalam Setahun Terakhir. Lebih dari 288.000 warga Jerman pindah ke luar negeri dalam setahun, didorong oleh prospek pendapatan lebih tinggi dan kualitas hidup yang lebih baik.	288.000 Warga 'Kabur' ke Luar Negeri dalam Setahun Terakhir. Lebih dari 288.000 warga Jerman pindah ke luar negeri dalam setahun, didorong oleh prospek pendapatan lebih tinggi dan kualitas hidup yang lebih baik.	id	https://www.cnbcindonesia.com/news/20260721155008-4-752627/288000-warga-kabur-ke-luar-negeri-dalam-setahun-terakhir	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 09:50:00+00	0	0	0	0	0	positive	1	\N	{sosial}	{warga,luar,negeri,dalam,setahun}	\N	0	t	f	2026-07-21 17:28:05.299918+00	2026-07-21 17:28:05.299918+00
5d2633c5-469d-422d-84f7-baf4485932ca	news	bd1c602ea26950f1175ffb11	article	RI Bakal Kembangkan 'BBM' Baru Lebih Bersih, Asalnya Bisa dari PLTS. Pemerintah Indonesia mengembangkan ekosistem hidrogen dari energi terbarukan.	RI Bakal Kembangkan 'BBM' Baru Lebih Bersih, Asalnya Bisa dari PLTS. Pemerintah Indonesia mengembangkan ekosistem hidrogen dari energi terbarukan.	id	https://www.cnbcindonesia.com/news/20260721135831-4-752581/ri-bakal-kembangkan-bbm-baru-lebih-bersih-asalnya-bisa-dari-plts	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 09:45:05+00	0	0	0	0	0	neutral	0	\N	{politik}	{bakal,kembangkan,baru,bersih,asalnya}	\N	0	t	f	2026-07-21 17:28:05.310117+00	2026-07-21 17:28:05.310117+00
26829f9e-005d-48d8-8fb2-13d5585560e4	news	c3d79b2192efc86cc3d50d0b	article	Geger Pria Gondol 1.600 Batang Emas Senilai Rp 5,7 Miliar. Seorang pria divonis penjara karena terlibat penipuan emas senilai Rp 5,72 miliar. Emas belum ditemukan.	Geger Pria Gondol 1.600 Batang Emas Senilai Rp 5,7 Miliar. Seorang pria divonis penjara karena terlibat penipuan emas senilai Rp 5,72 miliar. Emas belum ditemukan.	id	https://www.cnbcindonesia.com/news/20260721161249-4-752643/geger-pria-gondol-1600-batang-emas-senilai-rp-57-miliar	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 09:40:00+00	0	0	0	0	0	neutral	0	\N	{umum}	{emas,pria,senilai,miliar,geger}	\N	0	t	f	2026-07-21 17:28:05.320321+00	2026-07-21 17:28:05.320321+00
bb1763b7-b78f-4070-9333-92a1b8451b92	news	f6a2cabf8d643747e2a8ea63	article	Nyamuk Bikin Pening Satu Negara, Pemerintah Terjunkan Militer. Sri Lanka menghadapi wabah demam berdarah terburuk dalam hampir satu dekade. Militer dikerahkan untuk membantu menekan penyebaran penyakit ini.	Nyamuk Bikin Pening Satu Negara, Pemerintah Terjunkan Militer. Sri Lanka menghadapi wabah demam berdarah terburuk dalam hampir satu dekade. Militer dikerahkan untuk membantu menekan penyebaran penyakit ini.	id	https://www.cnbcindonesia.com/news/20260721144547-4-752600/nyamuk-bikin-pening-satu-negara-pemerintah-terjunkan-militer	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 09:35:00+00	0	0	0	0	0	neutral	0	\N	{politik}	{satu,militer,nyamuk,bikin,pening}	\N	0	t	f	2026-07-21 17:28:05.329335+00	2026-07-21 17:28:05.329335+00
edea6133-6a24-4117-925a-34e1748aa2bf	news	539e8b96f9c941012c68a0cd	article	Bea Cukai Tak Jadi Dibubarkan Prabowo. Presiden Prabowo Subianto telah puas terhadap perkembangan perbaikan di Direktorat Jenderal Bea dan Cukai (DJBC).	Bea Cukai Tak Jadi Dibubarkan Prabowo. Presiden Prabowo Subianto telah puas terhadap perkembangan perbaikan di Direktorat Jenderal Bea dan Cukai (DJBC).	id	https://www.cnbcindonesia.com/news/20260721162423-4-752648/bea-cukai-tak-jadi-dibubarkan-prabowo	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 09:32:42+00	0	0	0	0	0	positive	1	\N	{politik}	{cukai,prabowo,jadi,dibubarkan,presiden}	\N	0	t	f	2026-07-21 17:28:05.33812+00	2026-07-21 17:28:05.33812+00
02d6dd80-c7bc-40de-ac72-cd7004a1f2c5	news	9d91aa8188868b2d97ad3f4c	article	Sinergi Lintas Sektor Bangun Ekosistem Material Maju Indonesia. Sinergi Lintas Sektor Bangun Ekosistem Material Maju Indonesia	Sinergi Lintas Sektor Bangun Ekosistem Material Maju Indonesia. Sinergi Lintas Sektor Bangun Ekosistem Material Maju Indonesia	id	https://www.cnbcindonesia.com/news/20260721160414-8-752639/sinergi-lintas-sektor-bangun-ekosistem-material-maju-indonesia	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 09:30:15+00	0	0	0	0	0	positive	1	\N	{umum}	{sinergi,lintas,sektor,bangun,ekosistem}	\N	0	t	f	2026-07-21 17:28:05.345862+00	2026-07-21 17:28:05.345862+00
37ad20e3-29e2-457e-98e5-273246db9f6c	news	5d58d7ff055c3b3cf7f67b0b	article	RI Beri Sinyal Keras soal Laut China Selatan, Sugiono Ungkap Hal Ini. Indonesia menegaskan komitmennya untuk menyelesaikan Code of Conduct Laut China Selatan sebelum akhir tahun.	RI Beri Sinyal Keras soal Laut China Selatan, Sugiono Ungkap Hal Ini. Indonesia menegaskan komitmennya untuk menyelesaikan Code of Conduct Laut China Selatan sebelum akhir tahun.	id	https://www.cnbcindonesia.com/news/20260721160156-4-752630/ri-beri-sinyal-keras-soal-laut-china-selatan-sugiono-ungkap-hal-ini	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 09:10:00+00	0	0	0	0	0	neutral	0	\N	{umum}	{laut,china,selatan,beri,sinyal}	\N	0	t	f	2026-07-21 17:28:05.352994+00	2026-07-21 17:28:05.352994+00
3546848c-452d-463a-bf22-c27ea23d78cf	news	0a75ac88d7f0e311ddcb6be1	article	Bos PLN Ungkap Pasokan Batu Bara untuk Pembangkit Listrik Sudah Aman. Direktur Utama PLN Darmawan Prasodjo memastikan ketersediaan batu bara untuk pembangkit listrik sudah tercukupi.	Bos PLN Ungkap Pasokan Batu Bara untuk Pembangkit Listrik Sudah Aman. Direktur Utama PLN Darmawan Prasodjo memastikan ketersediaan batu bara untuk pembangkit listrik sudah tercukupi.	id	https://www.cnbcindonesia.com/news/20260721154406-4-752623/bos-pln-ungkap-pasokan-batu-bara-untuk-pembangkit-listrik-sudah-aman	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 09:02:39+00	0	0	0	0	0	positive	1	\N	{umum}	{batu,bara,pembangkit,listrik,sudah}	\N	0	t	f	2026-07-21 17:28:05.361919+00	2026-07-21 17:28:05.361919+00
8bc23ef6-bcbc-40fe-a89c-6035df388f8d	news	9a8644e1e7da250bde4a2ea5	article	Gen Z Ramai-Ramai Nikah di KUA, Efeknya Terasa Sampai ke Pengusaha WO. Tren Gen Z memilih menikah di KUA dan berdampak pada pengusaha wedding. Begini dampaknya.	Gen Z Ramai-Ramai Nikah di KUA, Efeknya Terasa Sampai ke Pengusaha WO. Tren Gen Z memilih menikah di KUA dan berdampak pada pengusaha wedding. Begini dampaknya.	id	https://www.cnbcindonesia.com/news/20260721122639-4-752545/gen-z-ramai-ramai-nikah-di-kua-efeknya-terasa-sampai-ke-pengusaha-wo	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 09:00:00+00	0	0	0	0	0	neutral	0	\N	{umum}	{ramai,pengusaha,nikah,efeknya,terasa}	\N	0	t	f	2026-07-21 17:28:05.3709+00	2026-07-21 17:28:05.3709+00
78e2d50f-2290-43ad-a0af-4a887b882949	news	5112563387d337b92bf303f7	article	Mau Rilis, Pengusaha Penasaran Bentuk-Produsen Motor Listrik Nasional. Asosiasi industri menunggu keputusan pemerintah terkait merek dan kolaborasi dengan produsen yang ada.	Mau Rilis, Pengusaha Penasaran Bentuk-Produsen Motor Listrik Nasional. Asosiasi industri menunggu keputusan pemerintah terkait merek dan kolaborasi dengan produsen yang ada.	id	https://www.cnbcindonesia.com/news/20260721125914-4-752555/mau-rilis-pengusaha-penasaran-bentuk-produsen-motor-listrik-nasional	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 08:55:00+00	0	0	0	0	0	neutral	0	\N	{politik}	{produsen,rilis,pengusaha,penasaran,bentuk}	\N	0	t	f	2026-07-21 17:28:05.384278+00	2026-07-21 17:28:05.384278+00
060ff62c-a200-4e56-aebf-257903343cb6	news	10da649ee1ddc1881c06d8ef	article	Bahlil: Impor Minyak dari Rusia Tahap I Sudah Dieksekusi Via Lemigas. Menteri ESDM Bahlil mengumumkan bahwa impor minyak mentah dari Rusia tahap pertama telah dieksekusi melalui Lemigas	Bahlil: Impor Minyak dari Rusia Tahap I Sudah Dieksekusi Via Lemigas. Menteri ESDM Bahlil mengumumkan bahwa impor minyak mentah dari Rusia tahap pertama telah dieksekusi melalui Lemigas	id	https://www.cnbcindonesia.com/news/20260721151526-4-752611/bahlil-impor-minyak-dari-rusia-tahap-i-sudah-dieksekusi-via-lemigas	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 08:52:05+00	0	0	0	0	0	neutral	0	\N	{politik,ekonomi}	{bahlil,impor,minyak,rusia,tahap}	\N	0	t	f	2026-07-21 17:28:05.393795+00	2026-07-21 17:28:05.393795+00
34810765-c817-4ad0-9f02-bd71cb27dd0c	news	b475b11c0a666e5d40303bd3	article	Purbaya Gerebek Perusahaan China, Potensi Pajak Terutang Bisa Rp500 M. Menkeu Purbaya Yudhi Sadewa blusukan ke perusahaan China terkait pelanggaran pajak. Investigasi menunjukkan potensi pajak terutang hingga Rp 500 miliar.	Purbaya Gerebek Perusahaan China, Potensi Pajak Terutang Bisa Rp500 M. Menkeu Purbaya Yudhi Sadewa blusukan ke perusahaan China terkait pelanggaran pajak. Investigasi menunjukkan potensi pajak terutang hingga Rp 500 miliar.	id	https://www.cnbcindonesia.com/news/20260721153332-4-752618/purbaya-gerebek-perusahaan-china-potensi-pajak-terutang-bisa-rp500-m	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 08:43:33+00	0	0	0	0	0	neutral	0	\N	{umum}	{pajak,purbaya,perusahaan,china,potensi}	\N	0	t	f	2026-07-21 17:28:05.405043+00	2026-07-21 17:28:05.405043+00
5720976b-e6ee-4f6f-a7c8-d05ae5a3fc80	news	b46c13a6fa01ac37bb170716	article	Bahlil Mulai Uji Coba Kendaraan dengan BBM Ganda: Solar dan Hidrogen. Menteri ESDM Bahlil Lahadalia mendorong penggunaan energi ganda melalui kombinasi BBM Solar dan hidrogen di sektor transportasi.	Bahlil Mulai Uji Coba Kendaraan dengan BBM Ganda: Solar dan Hidrogen. Menteri ESDM Bahlil Lahadalia mendorong penggunaan energi ganda melalui kombinasi BBM Solar dan hidrogen di sektor transportasi.	id	https://www.cnbcindonesia.com/news/20260721151730-4-752613/bahlil-mulai-uji-coba-kendaraan-dengan-bbm-ganda-solar-hidrogen	ec636367-716f-47e0-8cc7-242409a1bc03	\N	\N	2026-07-21 08:33:33+00	0	0	0	0	0	neutral	0	\N	{politik,sosial}	{bahlil,ganda,solar,hidrogen,mulai}	\N	0	t	f	2026-07-21 17:28:05.414144+00	2026-07-21 17:28:05.414144+00
bbffc0e8-9ab1-4df4-a089-a12afdccce92	rss	https://www.antaranews.com/berita/5660717/belanda-larang-impor-dari-permukiman-ilegal-israel-mulai-september	article	Belanda larang impor dari permukiman ilegal Israel mulai September\n\n<img align="left" border="0" src="https://cdn.antaranews.com/cache/800x533/2026/07/22/Ilustrasi-Belanda-bendera.jpg" />Belanda akan mulai memberlakukan larangan impor dari permukiman ilegal Israel di wilayah Palestina yang diduduki mulai ...	Belanda larang impor dari permukiman ilegal Israel mulai September <img align="left" border="0" src=" />Belanda akan mulai memberlakukan larangan impor dari permukiman ilegal Israel di wilayah Palestina yang diduduki mulai ...	\N	https://www.antaranews.com/berita/5660717/belanda-larang-impor-dari-permukiman-ilegal-israel-mulai-september	40001e07-40c6-44ab-aa57-90b1d7e3bba1	\N	\N	2026-07-22 09:57:00.696642+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI"}	{mulai,belanda,impor,permukiman,ilegal}	\N	0	t	f	2026-07-22 09:57:00.696642+00	2026-07-22 09:57:00.696642+00
1ad97967-cdd7-46ad-9878-f97d1f1e83cc	rss	https://www.antaranews.com/berita/5660712/pengamat-nilai-pembagian-tugas-waskita-jasa-marga-harus-jelas	article	Pengamat nilai pembagian tugas Waskita-Jasa Marga harus jelas\n\n<img align="left" border="0" src="https://cdn.antaranews.com/cache/800x533/2024/10/05/etintas.jpg" />Pengamat BUMN sekaligus Direktur NEXT Indonesia Center Herry Gunawan menilai pembagian tugas Waskita Karya dan Jasa ...	Pengamat nilai pembagian tugas Waskita-Jasa Marga harus jelas <img align="left" border="0" src=" />Pengamat BUMN sekaligus Direktur NEXT Indonesia Center Herry Gunawan menilai pembagian tugas Waskita Karya dan Jasa ...	\N	https://www.antaranews.com/berita/5660712/pengamat-nilai-pembagian-tugas-waskita-jasa-marga-harus-jelas	40001e07-40c6-44ab-aa57-90b1d7e3bba1	\N	\N	2026-07-22 09:57:00.840877+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI"}	{pengamat,pembagian,tugas,waskita,jasa}	\N	0	t	f	2026-07-22 09:57:00.840877+00	2026-07-22 09:57:00.840877+00
1bbe27e4-d06d-48bd-bdde-eeafadd5abd6	rss	https://www.antaranews.com/berita/5660692/nadeo-argawinata-resmi-gabung-persija	article	Nadeo Argawinata resmi gabung Persija\n\n<img align="left" border="0" src="https://cdn.antaranews.com/cache/800x533/2026/07/22/IMG_7325.jpg" />Kiper tim nasional Indonesia Nadeo Argawinata resmi bergabung dengan Persija Jakarta, Rabu, dengan ikatan kontrak ...	Nadeo Argawinata resmi gabung Persija <img align="left" border="0" src=" />Kiper tim nasional Indonesia Nadeo Argawinata resmi bergabung dengan Persija Jakarta, Rabu, dengan ikatan kontrak ...	\N	https://www.antaranews.com/berita/5660692/nadeo-argawinata-resmi-gabung-persija	40001e07-40c6-44ab-aa57-90b1d7e3bba1	\N	\N	2026-07-22 09:57:00.84153+00	0	0	0	0	0	neutral	0	\N	{Umum}	{nadeo,argawinata,resmi,persija,gabung}	\N	0	t	f	2026-07-22 09:57:00.84153+00	2026-07-22 09:57:00.84153+00
6bf6c300-8e20-4ee1-b345-90f22afbf843	rss	https://www.antaranews.com/foto/5660708/distribusi-mbg-ke-sekolah-tepi-garis-batas-negara	article	Distribusi MBG ke sekolah tepi garis batas negara\n\n<img align="left" border="0" src="https://cdn.antaranews.com/cache/800x533/2026/07/22/Distribusi-MBG-di-tepi-garis-batas-negara-220726-MRH-3.jpg" />Relawan mengendarai sepeda motor saat mengirim paket makan bergizi gratis (MBG) ke Madrasah Ibtidaiyah (MI) Darul ...	Distribusi MBG ke sekolah tepi garis batas negara <img align="left" border="0" src=" />Relawan mengendarai sepeda motor saat mengirim paket makan bergizi gratis (MBG) ke Madrasah Ibtidaiyah (MI) Darul ...	\N	https://www.antaranews.com/foto/5660708/distribusi-mbg-ke-sekolah-tepi-garis-batas-negara	40001e07-40c6-44ab-aa57-90b1d7e3bba1	\N	\N	2026-07-22 09:57:00.88155+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI"}	{mbg,distribusi,sekolah,tepi,garis}	\N	0	t	f	2026-07-22 09:57:00.88155+00	2026-07-22 09:57:00.88155+00
36331b5e-5e34-4692-be20-ba5c40dd2df4	rss	https://www.antaranews.com/berita/5660707/dpr-minta-aturan-nikotin-tetap-jaga-sektor-tembakau-nasional	article	DPR minta aturan nikotin tetap jaga sektor tembakau nasional\n\n<img align="left" border="0" src="https://cdn.antaranews.com/cache/800x533/2025/02/24/tembakau-1.jpg" />Wakil Ketua Komisi IV DPR Panggah Susanto&nbsp;meminta kepada pemerintah agar&nbsp;kebijakan rancangan ketentuan kadar ...	DPR minta aturan nikotin tetap jaga sektor tembakau nasional <img align="left" border="0" src=" />Wakil Ketua Komisi IV DPR Panggah Susanto&nbsp;meminta kepada pemerintah agar&nbsp;kebijakan rancangan ketentuan kadar ...	\N	https://www.antaranews.com/berita/5660707/dpr-minta-aturan-nikotin-tetap-jaga-sektor-tembakau-nasional	40001e07-40c6-44ab-aa57-90b1d7e3bba1	\N	\N	2026-07-22 09:57:00.90827+00	0	0	0	0	0	neutral	0	\N	{"Ekonomi & Bisnis","Politik & Pemerintahan"}	{dpr,nbsp,minta,aturan,nikotin}	\N	0	t	f	2026-07-22 09:57:00.90827+00	2026-07-22 09:57:00.90827+00
93577dee-1a3f-4a06-836f-d8bdbf07f020	rss	https://www.antaranews.com/berita/5660689/next-indonesia-center-danantara-bisa-manfaatkan-talent-pool-bumn	article	NEXT Indonesia Center: Danantara bisa manfaatkan 'talent pool' BUMN\n\n<img align="left" border="0" src="https://cdn.antaranews.com/cache/800x533/2026/07/09/kerja-sama-investasi-danantara-acwa-power-2569889.jpg" />Pengamat BUMN sekaligus Direktur NEXT Indonesia Center Herry Gunawan mengatakan Danantara bisa memanfaatkan program ...	NEXT Indonesia Center: Danantara bisa manfaatkan 'talent pool' BUMN <img align="left" border="0" src=" />Pengamat BUMN sekaligus Direktur NEXT Indonesia Center Herry Gunawan mengatakan Danantara bisa memanfaatkan program ...	\N	https://www.antaranews.com/berita/5660689/next-indonesia-center-danantara-bisa-manfaatkan-talent-pool-bumn	40001e07-40c6-44ab-aa57-90b1d7e3bba1	\N	\N	2026-07-22 09:57:00.911975+00	0	0	0	0	0	neutral	0	\N	{Umum}	{next,indonesia,center,danantara,bumn}	\N	0	t	f	2026-07-22 09:57:00.911975+00	2026-07-22 09:57:00.911975+00
b2e16bbc-4603-4133-bff9-cd8736ec51cc	rss	https://www.antaranews.com/berita/5660705/indonesia-pastikan-wakil-di-sejumlah-nomor-enc-2026-jelang-pelatnas	article	Indonesia pastikan wakil di sejumlah nomor ENC 2026 jelang pelatnas\n\n<img align="left" border="0" src="https://cdn.antaranews.com/cache/800x533/2025/10/15/tempImageDk5DE1.jpg" />Tim nasional esports Indonesia telah memastikan wakil pada sejumlah nomor pertandingan untuk Esports Nations Cup (ENC) ...	Indonesia pastikan wakil di sejumlah nomor ENC 2026 jelang pelatnas <img align="left" border="0" src=" />Tim nasional esports Indonesia telah memastikan wakil pada sejumlah nomor pertandingan untuk Esports Nations Cup (ENC) ...	\N	https://www.antaranews.com/berita/5660705/indonesia-pastikan-wakil-di-sejumlah-nomor-enc-2026-jelang-pelatnas	40001e07-40c6-44ab-aa57-90b1d7e3bba1	\N	\N	2026-07-22 09:57:00.935564+00	0	0	0	0	0	neutral	0	\N	{Umum}	{indonesia,wakil,sejumlah,nomor,enc}	\N	0	t	f	2026-07-22 09:57:00.935564+00	2026-07-22 09:57:00.935564+00
aba4a756-415f-4b9a-98cc-4cb864591220	rss	https://www.antaranews.com/berita/5660685/iran-klaim-serang-pangkalan-militer-as-di-yordania-bahrain	article	Iran klaim serang pangkalan militer AS di Yordania, Bahrain\n\n<img align="left" border="0" src="https://cdn.antaranews.com/cache/800x533/2026/07/22/IRGC-IRNA.jpg" />Pasukan Iran menyerang posisi AS di pangkalan militer yang berlokasi di Yordania dan Bahrain, menurut militer Iran pada ...	Iran klaim serang pangkalan militer AS di Yordania, Bahrain <img align="left" border="0" src=" />Pasukan Iran menyerang posisi AS di pangkalan militer yang berlokasi di Yordania dan Bahrain, menurut militer Iran pada ...	\N	https://www.antaranews.com/berita/5660685/iran-klaim-serang-pangkalan-militer-as-di-yordania-bahrain	40001e07-40c6-44ab-aa57-90b1d7e3bba1	\N	\N	2026-07-22 09:57:00.958355+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI"}	{iran,militer,pangkalan,yordania,bahrain}	\N	0	t	f	2026-07-22 09:57:00.958355+00	2026-07-22 09:57:00.958355+00
6e9ec9f1-bd99-499a-959d-195936a03ee7	rss	https://www.antaranews.com/berita/5660684/kementerian-esdm-bidik-potensi-sumber-hidrogen-alami-di-sulawesi	article	Kementerian ESDM bidik potensi sumber hidrogen alami di Sulawesi\n\n<img align="left" border="0" src="https://cdn.antaranews.com/cache/800x533/2026/07/22/WhatsApp-Image-2026-07-22-at-15.13.26_edit_15111310082069_1.jpg" />Kementerian Energi dan Sumber Daya Mineral (ESDM) membidik lokasi potensi sumber hidrogen yang terbentuk secara alami ...	Kementerian ESDM bidik potensi sumber hidrogen alami di Sulawesi <img align="left" border="0" src=" />Kementerian Energi dan Sumber Daya Mineral (ESDM) membidik lokasi potensi sumber hidrogen yang terbentuk secara alami ...	\N	https://www.antaranews.com/berita/5660684/kementerian-esdm-bidik-potensi-sumber-hidrogen-alami-di-sulawesi	40001e07-40c6-44ab-aa57-90b1d7e3bba1	\N	\N	2026-07-22 09:57:00.986213+00	0	0	0	0	0	neutral	0	\N	{Umum}	{sumber,kementerian,esdm,potensi,hidrogen}	\N	0	t	f	2026-07-22 09:57:00.986213+00	2026-07-22 09:57:00.986213+00
e6f0d325-445a-4215-99c0-df387a787d02	rss	https://www.antaranews.com/berita/5660676/liugong-memulai-pembangunan-green-smart-industrial-park-di-karawang	article	LiuGong memulai pembangunan Green Smart Industrial Park di Karawang\n\n<img align="left" border="0" src="https://cdn.antaranews.com/cache/800x533/2026/07/22/IMG-20260722-WA0034.jpg" />Perusahaan manufaktur alat berat multinasional asal Tiongkok, LiuGong, resmi memulai pembangunan kawasan industri alat ...	LiuGong memulai pembangunan Green Smart Industrial Park di Karawang <img align="left" border="0" src=" />Perusahaan manufaktur alat berat multinasional asal Tiongkok, LiuGong, resmi memulai pembangunan kawasan industri alat ...	\N	https://www.antaranews.com/berita/5660676/liugong-memulai-pembangunan-green-smart-industrial-park-di-karawang	40001e07-40c6-44ab-aa57-90b1d7e3bba1	\N	\N	2026-07-22 09:57:01.010732+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI"}	{liugong,memulai,pembangunan,alat,green}	\N	0	t	f	2026-07-22 09:57:01.010732+00	2026-07-22 09:57:01.010732+00
cfe3f64f-b6ae-4e57-9bcb-e8a22e6608d8	rss	https://www.antaranews.com/berita/5660672/jepang-salurkan-rp179-miliar-ke-dana-air-bersih-adb	article	Jepang salurkan Rp179 miliar ke dana air bersih ADB\n\n<img align="left" border="0" src="https://cdn.antaranews.com/cache/800x533/2026/04/11/adb.jpg" />Pemerintah Jepang, Selasa (21/7), mengatakan akan menyumbang 10 juta dolar AS (Rp179 miliar) ke dana Bank Pembangunan ...	Jepang salurkan Rp179 miliar ke dana air bersih ADB <img align="left" border="0" src=" />Pemerintah Jepang, Selasa (21/7), mengatakan akan menyumbang 10 juta dolar AS (Rp179 miliar) ke dana Bank Pembangunan ...	\N	https://www.antaranews.com/berita/5660672/jepang-salurkan-rp179-miliar-ke-dana-air-bersih-adb	40001e07-40c6-44ab-aa57-90b1d7e3bba1	\N	\N	2026-07-22 09:57:01.038779+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI","Politik & Pemerintahan"}	{jepang,miliar,dana,salurkan,air}	\N	0	t	f	2026-07-22 09:57:01.038779+00	2026-07-22 09:57:01.038779+00
b0e54c2a-d146-429a-8afd-be1455880c28	rss	https://www.antaranews.com/berita/5660668/pertamina-bangun-fasilitas-pengembangan-bioetanol-di-glenmore	article	Pertamina bangun fasilitas pengembangan bioetanol di Glenmore\n\n<img align="left" border="0" src="https://cdn.antaranews.com/cache/800x533/2026/07/22/WhatsApp-Image-2026-07-21-at-21.57.23.jpeg" />Wakil Direktur Utama PT Pertamina (Persero) Oki Muraza mengungkapkan bahwa saat ini Pertamina sedang membangun ...	Pertamina bangun fasilitas pengembangan bioetanol di Glenmore <img align="left" border="0" src=" />Wakil Direktur Utama PT Pertamina (Persero) Oki Muraza mengungkapkan bahwa saat ini Pertamina sedang membangun ...	\N	https://www.antaranews.com/berita/5660668/pertamina-bangun-fasilitas-pengembangan-bioetanol-di-glenmore	40001e07-40c6-44ab-aa57-90b1d7e3bba1	\N	\N	2026-07-22 09:57:01.064393+00	0	0	0	0	0	neutral	0	\N	{Umum}	{pertamina,bangun,fasilitas,pengembangan,bioetanol}	\N	0	t	f	2026-07-22 09:57:01.064393+00	2026-07-22 09:57:01.064393+00
ab343d90-2348-4a9d-9605-0110b6c6072a	rss	https://www.antaranews.com/berita/5660664/satgas-prr-minta-k-l-informasikan-program-kepada-kepala-daerah	article	Satgas PRR minta K/L informasikan program kepada kepala daerah\n\n<img align="left" border="0" src="https://cdn.antaranews.com/cache/800x533/2026/07/08/1000555909.jpg" />Menteri Dalam Negeri (Mendagri) Muhammad Tito Karnavian selaku Ketua Satuan Tugas (Kasatgas) Percepatan Rehabilitasi ...	Satgas PRR minta K/L informasikan program kepada kepala daerah <img align="left" border="0" src=" />Menteri Dalam Negeri (Mendagri) Muhammad Tito Karnavian selaku Ketua Satuan Tugas (Kasatgas) Percepatan Rehabilitasi ...	\N	https://www.antaranews.com/berita/5660664/satgas-prr-minta-k-l-informasikan-program-kepada-kepala-daerah	40001e07-40c6-44ab-aa57-90b1d7e3bba1	\N	\N	2026-07-22 09:57:01.127348+00	0	0	0	0	0	neutral	0	\N	{Umum}	{satgas,prr,minta,informasikan,program}	\N	0	t	f	2026-07-22 09:57:01.127348+00	2026-07-22 09:57:01.127348+00
68e4b2cf-2e67-4a60-b5a1-ce8f0dbe656a	rss	https://www.antaranews.com/berita/5660660/ini-alasan-pemprov-dki-pilih-tenor-tujuh-tahun-untuk-obligasi-daerah	article	Ini alasan Pemprov DKI pilih tenor tujuh tahun untuk obligasi daerah\n\n<img align="left" border="0" src="https://cdn.antaranews.com/cache/800x533/2026/07/22/IMG_5200.jpeg" />Gubernur DKI Jakarta Pramono Anung Wibowo menjelaskan Pemerintah Provinsi (Pemprov) DKI Jakarta memiliki alasan ...	Ini alasan Pemprov DKI pilih tenor tujuh tahun untuk obligasi daerah <img align="left" border="0" src=" />Gubernur DKI Jakarta Pramono Anung Wibowo menjelaskan Pemerintah Provinsi (Pemprov) DKI Jakarta memiliki alasan ...	\N	https://www.antaranews.com/berita/5660660/ini-alasan-pemprov-dki-pilih-tenor-tujuh-tahun-untuk-obligasi-daerah	40001e07-40c6-44ab-aa57-90b1d7e3bba1	\N	\N	2026-07-22 09:57:01.16703+00	0	0	0	0	0	neutral	0	\N	{"Politik & Pemerintahan"}	{dki,alasan,pemprov,jakarta,pilih}	\N	0	t	f	2026-07-22 09:57:01.16703+00	2026-07-22 09:57:01.16703+00
3b8c9618-c04e-474b-af05-95d0725ef76c	rss	https://www.antaranews.com/video/5660661/permohonan-paspor-di-lhokseumawe-dorong-pnbp-capai-rp102-miliar	article	Permohonan paspor di Lhokseumawe dorong PNBP capai Rp10,2 miliar\n\n<img align="left" border="0" src="https://cdn.antaranews.com/cache/800x533/2026/07/PERMOHONAN-PASPOR-DI-LHOKSEUMAWE-DORONG-PNBP-CAPAI-RP10-2-MILIAR.jpg" />ANTARA - Kantor Imigrasi Kelas II TPI Lhokseumawe, Aceh, menerbitkan 12.390 paspor sepanjang semester I 2026. Capaian ...	Permohonan paspor di Lhokseumawe dorong PNBP capai Rp10,2 miliar <img align="left" border="0" src=" />ANTARA - Kantor Imigrasi Kelas II TPI Lhokseumawe, Aceh, menerbitkan 12.390 paspor sepanjang semester I 2026. Capaian ...	\N	https://www.antaranews.com/video/5660661/permohonan-paspor-di-lhokseumawe-dorong-pnbp-capai-rp102-miliar	40001e07-40c6-44ab-aa57-90b1d7e3bba1	\N	\N	2026-07-22 09:57:00.964066+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI"}	{paspor,lhokseumawe,permohonan,dorong,pnbp}	\N	0	t	f	2026-07-22 09:57:00.964066+00	2026-07-22 09:57:00.964066+00
ce5be0ac-0303-442c-83f7-2540169ba362	rss	https://www.antaranews.com/berita/5660704/memperluas-jejak-dagang-indonesia-di-pasifik-melalui-chile	article	Memperluas jejak dagang Indonesia di Pasifik melalui Chile\n\n<img align="left" border="0" src="https://cdn.antaranews.com/cache/800x533/2026/07/20/imgdownloader-2d9f11fa.jpeg" />Indonesia terus memperluas jangkauan perdagangan ke kawasan Pasifik, salah satunya dengan memberi perhatian pada Chile, ...	Memperluas jejak dagang Indonesia di Pasifik melalui Chile <img align="left" border="0" src=" />Indonesia terus memperluas jangkauan perdagangan ke kawasan Pasifik, salah satunya dengan memberi perhatian pada Chile, ...	\N	https://www.antaranews.com/berita/5660704/memperluas-jejak-dagang-indonesia-di-pasifik-melalui-chile	40001e07-40c6-44ab-aa57-90b1d7e3bba1	\N	\N	2026-07-22 09:57:00.995365+00	0	0	0	0	0	neutral	0	\N	{Umum}	{memperluas,indonesia,pasifik,chile,jejak}	\N	0	t	f	2026-07-22 09:57:00.995365+00	2026-07-22 09:57:00.995365+00
a55d1909-b3e0-4be7-8198-2034791366e8	rss	https://www.antaranews.com/berita/5660700/studi-menunjukkan-likes-lebih-berpengaruh-pada-orang-dengan-depresi	article	Studi menunjukkan "Likes" lebih berpengaruh pada orang dengan depresi\n\n<img align="left" border="0" src="https://cdn.antaranews.com/cache/800x533/2025/08/29/Medsos.jpg" />Orang-orang dengan depresi menunjukkan kecenderungan yang lebih besar untuk mendapatkan penguatan dari ...	Studi menunjukkan "Likes" lebih berpengaruh pada orang dengan depresi <img align="left" border="0" src=" />Orang-orang dengan depresi menunjukkan kecenderungan yang lebih besar untuk mendapatkan penguatan dari ...	\N	https://www.antaranews.com/berita/5660700/studi-menunjukkan-likes-lebih-berpengaruh-pada-orang-dengan-depresi	40001e07-40c6-44ab-aa57-90b1d7e3bba1	\N	\N	2026-07-22 09:57:01.016204+00	0	0	0	0	0	neutral	0	\N	{Umum}	{orang,menunjukkan,depresi,studi,likes}	\N	0	t	f	2026-07-22 09:57:01.016204+00	2026-07-22 09:57:01.016204+00
5e344514-2c15-4513-9f8f-a0bb14ae3765	rss	https://www.antaranews.com/video/5660600/bakom-ri-pengunduran-diri-nanik-tak-hambat-perbaikan-tata-kelola-mbg	article	Bakom RI: Pengunduran diri Nanik tak hambat perbaikan tata kelola MBG\n\n<img align="left" border="0" src="https://cdn.antaranews.com/cache/800x533/2026/07/AYM_BAKOM-RI-PENGUNDURAN-DIRI-NANIK-TAK-HAMBAT_1.jpg" />ANTARA - Badan Komunikasi Pemerintah Republik Indonesia (Bakom&nbsp;RI) menghormati pengunduran diri Nanik Sudaryati ...	Bakom RI: Pengunduran diri Nanik tak hambat perbaikan tata kelola MBG <img align="left" border="0" src=" />ANTARA - Badan Komunikasi Pemerintah Republik Indonesia (Bakom&nbsp;RI) menghormati pengunduran diri Nanik Sudaryati ...	\N	https://www.antaranews.com/video/5660600/bakom-ri-pengunduran-diri-nanik-tak-hambat-perbaikan-tata-kelola-mbg	40001e07-40c6-44ab-aa57-90b1d7e3bba1	\N	\N	2026-07-22 09:57:01.040013+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI","Politik & Pemerintahan","Sosial & Budaya"}	{bakom,pengunduran,diri,nanik,tak}	\N	0	t	f	2026-07-22 09:57:01.040013+00	2026-07-22 09:57:01.040013+00
da50879b-9dc4-4b42-bc5a-d93c539b783a	rss	https://www.antaranews.com/berita/5660699/yusril-deportasi-abdul-karim-tak-terkait-dengan-sikap-ri-ke-palestina	article	Yusril: Deportasi Abdul Karim tak terkait dengan sikap RI ke Palestina\n\n<img align="left" border="0" src="https://cdn.antaranews.com/cache/800x533/2026/07/22/1000447915.jpg" />Menteri Koordinator Bidang Hukum, HAM, Imigrasi, dan Pemasyarakatan Yusril Ihza Mahendra menyebut deportasi warga ...	Yusril: Deportasi Abdul Karim tak terkait dengan sikap RI ke Palestina <img align="left" border="0" src=" />Menteri Koordinator Bidang Hukum, HAM, Imigrasi, dan Pemasyarakatan Yusril Ihza Mahendra menyebut deportasi warga ...	\N	https://www.antaranews.com/berita/5660699/yusril-deportasi-abdul-karim-tak-terkait-dengan-sikap-ri-ke-palestina	40001e07-40c6-44ab-aa57-90b1d7e3bba1	\N	\N	2026-07-22 09:57:01.102381+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI","Hukum & Keamanan","Sosial & Budaya"}	{yusril,deportasi,abdul,karim,tak}	\N	0	t	f	2026-07-22 09:57:01.102381+00	2026-07-22 09:57:01.102381+00
d3fd6984-13eb-4b2b-89db-bc824e1de666	rss	https://www.antaranews.com/berita/5660696/sahroni-tni-dan-polri-harus-loyal-hanya-kepada-presiden	article	Sahroni: TNI dan Polri harus loyal hanya kepada Presiden\n\n<img align="left" border="0" src="https://cdn.antaranews.com/cache/800x533/2026/03/10/Sahroni-Kitabisa.jpeg" />Wakil Ketua Komisi III DPR RI Ahmad Sahroni mengingatkan bahwa institusi Tentara Nasional Indonesia (TNI) dan ...	Sahroni: TNI dan Polri harus loyal hanya kepada Presiden <img align="left" border="0" src=" />Wakil Ketua Komisi III DPR RI Ahmad Sahroni mengingatkan bahwa institusi Tentara Nasional Indonesia (TNI) dan ...	\N	https://www.antaranews.com/berita/5660696/sahroni-tni-dan-polri-harus-loyal-hanya-kepada-presiden	40001e07-40c6-44ab-aa57-90b1d7e3bba1	\N	\N	2026-07-22 09:57:01.153066+00	0	0	0	0	0	neutral	0	\N	{"Politik & Pemerintahan"}	{sahroni,tni,polri,harus,loyal}	\N	0	t	f	2026-07-22 09:57:01.153066+00	2026-07-22 09:57:01.153066+00
3c4ce43a-794f-413c-8c3f-246429109f84	rss	https://www.antaranews.com/berita/5660655/profil-sudaryono-dari-wamentan-jadi-kepala-bgn	article	Profil Sudaryono, dari Wamentan jadi Kepala BGN\n\n<img align="left" border="0" src="https://cdn.antaranews.com/cache/800x533/2026/07/22/IMG_4701.jpeg" />Presiden Prabowo Subianto baru saja melantik Mantan Wakil Menteri Pertanian (Wamentan),&nbsp;Sudaryono menjadi Kepala ...	Profil Sudaryono, dari Wamentan jadi Kepala BGN <img align="left" border="0" src=" />Presiden Prabowo Subianto baru saja melantik Mantan Wakil Menteri Pertanian (Wamentan),&nbsp;Sudaryono menjadi Kepala ...	\N	https://www.antaranews.com/berita/5660655/profil-sudaryono-dari-wamentan-jadi-kepala-bgn	40001e07-40c6-44ab-aa57-90b1d7e3bba1	\N	\N	2026-07-22 09:57:01.189613+00	0	0	0	0	0	neutral	0	\N	{"Politik & Pemerintahan"}	{sudaryono,wamentan,kepala,profil,jadi}	\N	0	t	f	2026-07-22 09:57:01.189613+00	2026-07-22 09:57:01.189613+00
bcffd0e0-38f9-4542-a977-118b564a8177	rss	https://www.antaranews.com/berita/5660656/dpr-nilai-transformasi-bumn-di-bawah-danantara-tunjukan-hasil-positif	article	DPR nilai transformasi BUMN di bawah Danantara tunjukan hasil positif\n\n<img align="left" border="0" src="https://cdn.antaranews.com/cache/800x533/2026/07/22/IMG_0606.jpeg" />Komisi XI DPR RI menilai transformasi BUMN sektor jasa keuangan yang dijalankan Danantara menunjukkan hasil yang ...	DPR nilai transformasi BUMN di bawah Danantara tunjukan hasil positif <img align="left" border="0" src=" />Komisi XI DPR RI menilai transformasi BUMN sektor jasa keuangan yang dijalankan Danantara menunjukkan hasil yang ...	\N	https://www.antaranews.com/berita/5660656/dpr-nilai-transformasi-bumn-di-bawah-danantara-tunjukan-hasil-positif	40001e07-40c6-44ab-aa57-90b1d7e3bba1	\N	\N	2026-07-22 09:57:01.197196+00	0	0	0	0	0	positive	1	\N	{"Teknologi & AI","Ekonomi & Bisnis","Politik & Pemerintahan"}	{dpr,transformasi,bumn,danantara,hasil}	\N	0	t	f	2026-07-22 09:57:01.197196+00	2026-07-22 09:57:01.197196+00
56e7cad0-c834-4690-82e1-7e9ea1f4f923	rss	https://www.cnbcindonesia.com/news/20260722161352-4-752979/sudaryono-saya-zero-tolerance-korupsi-hengki-pengki-di-mbg	article	Sudaryono:  Saya Zero Tolerance Korupsi dan 'Hengki Pengki' di MBG\n\n<img src="https://akcdn.detik.net.id/visual/2026/07/22/wakil-menteri-pertanian-wamentan-sudaryono-saat-tiba-di-istana-merdeka-jakarta-rabu-2272026-1784705977454_169.jpeg?w=1200&amp;q=90" /> Kepala BGN Sudaryono berkomitmen menutup potensi korupsi dalam program Makan Bergizi Gratis.	Sudaryono: Saya Zero Tolerance Korupsi dan 'Hengki Pengki' di MBG <img src=" /> Kepala BGN Sudaryono berkomitmen menutup potensi korupsi dalam program Makan Bergizi Gratis.	\N	https://www.cnbcindonesia.com/news/20260722161352-4-752979/sudaryono-saya-zero-tolerance-korupsi-hengki-pengki-di-mbg	aafb1e20-0136-41ff-8a49-5c469a422682	\N	\N	2026-07-22 09:57:01.263175+00	0	0	0	0	0	negative	-1	\N	{"Hukum & Keamanan"}	{sudaryono,korupsi,saya,zero,tolerance}	\N	0	t	f	2026-07-22 09:57:01.263175+00	2026-07-22 10:19:04.482333+00
3d6691f9-0f19-4595-a385-9be709a144f7	rss	https://www.cnbcindonesia.com/news/20260722152918-4-752946/delegasi-malaysia-sempat-datangi-kantor-amran-mohon-mohon-ini-ke-ri	article	Delegasi Malaysia Sempat Datangi Kantor Amran, Mohon-mohon Ini ke RI\n\n<img src="https://akcdn.detik.net.id/visual/2023/01/05/bendera-malaysia-di-perdana-putra-kompleks-kantor-perdana-menteri-di-putrajaya_169.jpeg?w=1200&amp;q=90" /> Kementan ungkap delegasi Malaysia sempat datangi mereka. Mohon-mohon ini ke RI.	Delegasi Malaysia Sempat Datangi Kantor Amran, Mohon-mohon Ini ke RI <img src=" /> Kementan ungkap delegasi Malaysia sempat datangi mereka. Mohon-mohon ini ke RI.	\N	https://www.cnbcindonesia.com/news/20260722152918-4-752946/delegasi-malaysia-sempat-datangi-kantor-amran-mohon-mohon-ini-ke-ri	aafb1e20-0136-41ff-8a49-5c469a422682	\N	\N	2026-07-22 09:57:01.298628+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI"}	{mohon,delegasi,malaysia,sempat,datangi}	\N	0	t	f	2026-07-22 09:57:01.298628+00	2026-07-22 10:19:04.542027+00
826122af-bd25-4651-86cd-6324de2d7693	rss	https://www.cnbcindonesia.com/news/20260722161158-4-752978/lengkap-begini-isi-keputusan-bi-tahan-suku-bunga-575	article	Lengkap! Begini Isi Keputusan BI Tahan Suku Bunga 5,75%\n\n<img src="https://akcdn.detik.net.id/visual/2018/03/27/bc331953-cd88-4102-990c-27a283556a27_169.jpeg?w=1200&amp;q=90" /> Dewan Gubernur BI menahan suku bunga acuannya di 5,75% untuk stabilitas nilai tukar rupiah. Kebijakan insentif diperluas untuk menarik investasi asing.	Lengkap! Begini Isi Keputusan BI Tahan Suku Bunga 5,75% <img src=" /> Dewan Gubernur BI menahan suku bunga acuannya di 5,75% untuk stabilitas nilai tukar rupiah. Kebijakan insentif diperluas untuk menarik investasi asing.	\N	https://www.cnbcindonesia.com/news/20260722161158-4-752978/lengkap-begini-isi-keputusan-bi-tahan-suku-bunga-575	aafb1e20-0136-41ff-8a49-5c469a422682	\N	\N	2026-07-22 09:57:01.327993+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI","Ekonomi & Bisnis","Politik & Pemerintahan"}	{suku,bunga,lengkap,begini,isi}	\N	0	t	f	2026-07-22 09:57:01.327993+00	2026-07-22 10:19:04.607351+00
27a47187-244d-48b4-9ec4-50268f90ceb4	rss	https://www.cnbcindonesia.com/news/20260722161006-4-752975/ribuan-asn-pu-judol-ratusan-juta-rupiah-ini-sanksi-dari-menteri-dody	article	Ribuan ASN PU Judol Ratusan Juta Rupiah, Ini Sanksi dari Menteri Dody\n\n<img src="https://akcdn.detik.net.id/visual/2026/07/22/menteri-pekerjaan-umum-pu-dody-hanggodo-saat-ditemui-di-kantor-kementerian-pekerjaan-umum-jakarta-rabu-2272026-1784705530566_169.jpeg?w=1200&amp;q=90" /> Proses pemeriksaan internal sedang dilakukan untuk menelusuri aliran dana dan transaksi mencurigakan.	Ribuan ASN PU Judol Ratusan Juta Rupiah, Ini Sanksi dari Menteri Dody <img src=" /> Proses pemeriksaan internal sedang dilakukan untuk menelusuri aliran dana dan transaksi mencurigakan.	\N	https://www.cnbcindonesia.com/news/20260722161006-4-752975/ribuan-asn-pu-judol-ratusan-juta-rupiah-ini-sanksi-dari-menteri-dody	aafb1e20-0136-41ff-8a49-5c469a422682	\N	\N	2026-07-22 09:57:01.354435+00	0	0	0	0	0	neutral	0	\N	{"Ekonomi & Bisnis"}	{ribuan,asn,judol,ratusan,juta}	\N	0	t	f	2026-07-22 09:57:01.354435+00	2026-07-22 10:19:04.647989+00
48bfeb12-8f88-443d-8941-1f466348e3d3	rss	https://www.cnbcindonesia.com/news/20260722101648-8-752817/video-prabowo-lantik-gubernur-wakil-gubernur-universitas-ri	article	Video: Prabowo Lantik Gubernur dan Wakil Gubernur Universitas RI\n\n<img src="https://akcdn.detik.net.id/visual/2026/07/22/prabowo-lantik-gubernur-wakil-gubernur-universitas-republik-indonesia-1784711491798_169.png?w=1200&amp;q=90" /> Prabowo Lantik Gubernur dan Wakil Gubernur Universitas Republik Indonesia	Video: Prabowo Lantik Gubernur dan Wakil Gubernur Universitas RI <img src=" /> Prabowo Lantik Gubernur dan Wakil Gubernur Universitas Republik Indonesia	\N	https://www.cnbcindonesia.com/news/20260722101648-8-752817/video-prabowo-lantik-gubernur-wakil-gubernur-universitas-ri	aafb1e20-0136-41ff-8a49-5c469a422682	\N	\N	2026-07-22 09:57:01.393625+00	0	0	0	0	0	neutral	0	\N	{"Sosial & Budaya"}	{gubernur,prabowo,lantik,wakil,universitas}	\N	0	t	f	2026-07-22 09:57:01.393625+00	2026-07-22 10:19:04.688661+00
42b8fbe5-0654-4b8d-851f-42732faee32c	rss	https://www.antaranews.com/berita/5660652/herdman-sebut-timnas-indonesia-mulai-tunjukkan-identitas-taktik	article	Herdman sebut timnas Indonesia mulai tunjukkan identitas taktik\n\n<img align="left" border="0" src="https://cdn.antaranews.com/cache/800x533/2026/07/10/Pemusatan-Latihan-Timnas-100726-fik-7A.jpg" />Pelatih timnas Indonesia John Herdman mengungkapkan bahwa timnya mulai menunjukkan identitas taktik yang jelas dan ...	Herdman sebut timnas Indonesia mulai tunjukkan identitas taktik <img align="left" border="0" src=" />Pelatih timnas Indonesia John Herdman mengungkapkan bahwa timnya mulai menunjukkan identitas taktik yang jelas dan ...	\N	https://www.antaranews.com/berita/5660652/herdman-sebut-timnas-indonesia-mulai-tunjukkan-identitas-taktik	40001e07-40c6-44ab-aa57-90b1d7e3bba1	\N	\N	2026-07-22 09:57:01.213409+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI"}	{herdman,timnas,indonesia,mulai,identitas}	\N	0	t	f	2026-07-22 09:57:01.213409+00	2026-07-22 09:57:01.213409+00
782bae03-2b93-47b9-9e7d-94ea47b6d818	rss	https://www.antaranews.com/berita/5660651/sar-gabungan-sisir-pulau-sabalana-cari-16-korban-km-nurul-salsa	article	SAR gabungan sisir Pulau Sabalana cari 16 korban KM Nurul Salsa\n\n<img align="left" border="0" src="https://cdn.antaranews.com/cache/800x533/2026/07/22/dokumentasi-Basarnas-1.jpg" />Tim SAR gabungan menyisir&nbsp;perairan Pulau Sabalana,&nbsp;Kecamatan Liukang Tangaya, Kabupaten Pangkajene dan ...	SAR gabungan sisir Pulau Sabalana cari 16 korban KM Nurul Salsa <img align="left" border="0" src=" />Tim SAR gabungan menyisir&nbsp;perairan Pulau Sabalana,&nbsp;Kecamatan Liukang Tangaya, Kabupaten Pangkajene dan ...	\N	https://www.antaranews.com/berita/5660651/sar-gabungan-sisir-pulau-sabalana-cari-16-korban-km-nurul-salsa	40001e07-40c6-44ab-aa57-90b1d7e3bba1	\N	\N	2026-07-22 09:57:01.242094+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI"}	{sar,gabungan,pulau,sabalana,nbsp}	\N	0	t	f	2026-07-22 09:57:01.242094+00	2026-07-22 09:57:01.242094+00
0091e1d8-7d0b-480b-815b-c5c7ce752543	rss	https://www.antaranews.com/berita/5660648/kemkomdigi-dan-bp-bumn-siapkan-jalur-karier-bagi-talenta-ai-indonesia	article	Kemkomdigi dan BP BUMN siapkan jalur karier bagi talenta AI Indonesia\n\n<img align="left" border="0" src="https://cdn.antaranews.com/cache/800x533/2026/07/22/1000138383.jpg" />Kementerian Komunikasi dan Digital (Kemkomdigi) bersama Badan Pengelola BUMN (BP BUMN) menyiapkan jalur karier bagi ...	Kemkomdigi dan BP BUMN siapkan jalur karier bagi talenta AI Indonesia <img align="left" border="0" src=" />Kementerian Komunikasi dan Digital (Kemkomdigi) bersama Badan Pengelola BUMN (BP BUMN) menyiapkan jalur karier bagi ...	\N	https://www.antaranews.com/berita/5660648/kemkomdigi-dan-bp-bumn-siapkan-jalur-karier-bagi-talenta-ai-indonesia	40001e07-40c6-44ab-aa57-90b1d7e3bba1	\N	\N	2026-07-22 09:57:01.267424+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI"}	{bumn,kemkomdigi,jalur,karier,bagi}	\N	0	t	f	2026-07-22 09:57:01.267424+00	2026-07-22 09:57:01.267424+00
3b310cc4-2c1c-4efa-9080-79c64e4a4a61	rss	https://www.antaranews.com/berita/5660645/wapres-pelantikan-kepala-bgn-dukung-tata-kelola-mbg-lebih-baik	article	Wapres: Pelantikan Kepala BGN dukung tata kelola MBG lebih baik\n\n<img align="left" border="0" src="https://cdn.antaranews.com/cache/800x533/2026/07/18/4d1b40e9-6259-45f6-a226-627a85714ad0.jpeg" />Wakil Presiden (Wapres) Gibran Rakabuming mengatakan pelantikan Sudaryono sebagai Kepala Badan Gizi Nasional (BGN) akan ...	Wapres: Pelantikan Kepala BGN dukung tata kelola MBG lebih baik <img align="left" border="0" src=" />Wakil Presiden (Wapres) Gibran Rakabuming mengatakan pelantikan Sudaryono sebagai Kepala Badan Gizi Nasional (BGN) akan ...	\N	https://www.antaranews.com/berita/5660645/wapres-pelantikan-kepala-bgn-dukung-tata-kelola-mbg-lebih-baik	40001e07-40c6-44ab-aa57-90b1d7e3bba1	\N	\N	2026-07-22 09:57:01.312812+00	0	0	0	0	0	positive	1	\N	{"Teknologi & AI","Politik & Pemerintahan"}	{wapres,pelantikan,kepala,bgn,dukung}	\N	0	t	f	2026-07-22 09:57:01.312812+00	2026-07-22 09:57:01.312812+00
a9084da2-29d7-4b28-a215-8ab7d4b48573	rss	https://www.antaranews.com/video/5660624/purbaya-temui-gus-yahya-bahas-peluang-kerja-sama-dengan-pbnu	article	Purbaya temui Gus Yahya, bahas peluang kerja sama dengan PBNU\n\n<img align="left" border="0" src="https://cdn.antaranews.com/cache/800x533/2026/07/AYM_PURBAYA-TEMUI-GUS-YAHYA-BAHAS-PELUANG.jpg" />ANTARA - Menteri Keuangan Purbaya Yudhi Sadewa melakukan pertemuan dengan Ketua Umum Pengurus Besar Nahdlatul Ulana ...	Purbaya temui Gus Yahya, bahas peluang kerja sama dengan PBNU <img align="left" border="0" src=" />ANTARA - Menteri Keuangan Purbaya Yudhi Sadewa melakukan pertemuan dengan Ketua Umum Pengurus Besar Nahdlatul Ulana ...	\N	https://www.antaranews.com/video/5660624/purbaya-temui-gus-yahya-bahas-peluang-kerja-sama-dengan-pbnu	40001e07-40c6-44ab-aa57-90b1d7e3bba1	\N	\N	2026-07-22 09:57:01.338732+00	0	0	0	0	0	neutral	0	\N	{"Ekonomi & Bisnis"}	{purbaya,temui,gus,yahya,bahas}	\N	0	t	f	2026-07-22 09:57:01.338732+00	2026-07-22 09:57:01.338732+00
c3d2525f-3147-4e9d-9aa4-250c1f1f9e77	rss	https://www.antaranews.com/berita/5660644/pimpinan-mpr-pembenahan-subsidi-dan-transisi-energi-harus-beriringan	article	Pimpinan MPR: Pembenahan subsidi dan transisi energi harus beriringan\n\n<img align="left" border="0" src="https://cdn.antaranews.com/cache/800x533/2026/07/21/IMG_20260721_214255.jpg" />Wakil Ketua MPR RI Eddy Soeparno menegaskan bahwa reformasi subsidi energi dan transisi energi merupakan dua hal ...	Pimpinan MPR: Pembenahan subsidi dan transisi energi harus beriringan <img align="left" border="0" src=" />Wakil Ketua MPR RI Eddy Soeparno menegaskan bahwa reformasi subsidi energi dan transisi energi merupakan dua hal ...	\N	https://www.antaranews.com/berita/5660644/pimpinan-mpr-pembenahan-subsidi-dan-transisi-energi-harus-beriringan	40001e07-40c6-44ab-aa57-90b1d7e3bba1	\N	\N	2026-07-22 09:57:01.361728+00	0	0	0	0	0	neutral	0	\N	{Umum}	{energi,mpr,subsidi,transisi,pimpinan}	\N	0	t	f	2026-07-22 09:57:01.361728+00	2026-07-22 09:57:01.361728+00
77a293f4-1cb2-44ce-830c-88f51585a748	rss	https://www.antaranews.com/berita/5660640/polisi-selidiki-komplotan-maling-gasak-empat-motor-di-indekos-jaktim	article	Polisi selidiki komplotan maling gasak empat motor di indekos Jaktim\n\n<img align="left" border="0" src="https://cdn.antaranews.com/cache/800x533/2025/03/11/IMG_20250311_221046.jpg" />Polisi menyelidiki komplotan pencuri sepeda motor yang diduga menggasak empat unit motor sekaligus di sebuah indekos di ...	Polisi selidiki komplotan maling gasak empat motor di indekos Jaktim <img align="left" border="0" src=" />Polisi menyelidiki komplotan pencuri sepeda motor yang diduga menggasak empat unit motor sekaligus di sebuah indekos di ...	\N	https://www.antaranews.com/berita/5660640/polisi-selidiki-komplotan-maling-gasak-empat-motor-di-indekos-jaktim	40001e07-40c6-44ab-aa57-90b1d7e3bba1	\N	\N	2026-07-22 09:57:01.405193+00	0	0	0	0	0	neutral	0	\N	{"Hukum & Keamanan"}	{motor,polisi,komplotan,empat,indekos}	\N	0	t	f	2026-07-22 09:57:01.405193+00	2026-07-22 09:57:01.405193+00
e0078b4d-1f4d-48d0-ab12-ce643aaad8ab	rss	https://www.cnbcindonesia.com/news/20260722140716-4-752922/geger-kampung-israel-di-malaysia-anwar-ibrahim-mulai-bertindak	article	Geger 'Kampung Israel' di Malaysia, Anwar Ibrahim Mulai Bertindak\n\n<img src="https://akcdn.detik.net.id/visual/2025/02/11/malaysia-turkey-7_169.jpeg?w=1200&amp;q=90" /> Pemerintah Malaysia menyelidiki keberadaan "kampung Israel" di Johor. PM Anwar Ibrahim menegaskan tidak mengakui Israel dan siap deportasi warga Israel.	Geger 'Kampung Israel' di Malaysia, Anwar Ibrahim Mulai Bertindak <img src=" /> Pemerintah Malaysia menyelidiki keberadaan "kampung Israel" di Johor. PM Anwar Ibrahim menegaskan tidak mengakui Israel dan siap deportasi warga Israel.	\N	https://www.cnbcindonesia.com/news/20260722140716-4-752922/geger-kampung-israel-di-malaysia-anwar-ibrahim-mulai-bertindak	aafb1e20-0136-41ff-8a49-5c469a422682	\N	\N	2026-07-22 09:57:01.454907+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI","Politik & Pemerintahan"}	{israel,kampung,malaysia,anwar,ibrahim}	\N	0	t	f	2026-07-22 09:57:01.454907+00	2026-07-22 10:19:04.38498+00
2716fcbc-a647-48d3-8c40-c40784bdbc86	rss	https://www.cnbcindonesia.com/news/20260722154031-4-752952/kepala-bgn-sudaryono-saya-dan-keluarga-tak-punya-dapur-mbg	article	Kepala BGN Sudaryono: Saya dan Keluarga Tak Punya Dapur MBG\n\n<img src="https://akcdn.detik.net.id/visual/2026/07/22/kepala-badan-gizi-nasional-sudaryono-menyampaikan-kepada-media-usai-dilantik-presiden-prabowo-subianto-di-istana-merdeka-jakar-1784708999297_169.png?w=1200&amp;q=90" /> Sudaryono dilantik sebagai Kepala Badan Gizi Nasional, menggantikan Nanik S Deyang. Fokusnya adalah pemenuhan gizi untuk anak, ibu hamil, dan lansia.	Kepala BGN Sudaryono: Saya dan Keluarga Tak Punya Dapur MBG <img src=" /> Sudaryono dilantik sebagai Kepala Badan Gizi Nasional, menggantikan Nanik S Deyang. Fokusnya adalah pemenuhan gizi untuk anak, ibu hamil, dan lansia.	\N	https://www.cnbcindonesia.com/news/20260722154031-4-752952/kepala-bgn-sudaryono-saya-dan-keluarga-tak-punya-dapur-mbg	aafb1e20-0136-41ff-8a49-5c469a422682	\N	\N	2026-07-22 09:57:01.491968+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI"}	{kepala,sudaryono,gizi,bgn,saya}	\N	0	t	f	2026-07-22 09:57:01.491968+00	2026-07-22 10:19:04.458303+00
51cd4c06-b0b9-4a5c-9e8e-8d14935a9c42	rss	https://www.cnbcindonesia.com/news/20260722153748-4-752951/danantara-serahkan-proyek-olah-sampah-jadi-listrik-tahap-2-ke-8-mitra	article	Danantara Serahkan Proyek Olah Sampah Jadi Listrik Tahap-2 ke 8 Mitra\n\n<img src="https://akcdn.detik.net.id/visual/2026/07/21/danantara-indonesia-resmi-menyerahkan-conditional-letter-of-award-cloa-kepada-mitra-terpilih-proyek-psel-kabupaten-bekasi-mena-1784607673508_169.jpeg?w=1200&amp;q=90" /> Danantara Invesment Management (DIM) serahkan Conditional Letter of Award (CLoA) kepada delapan mitra terpilih	Danantara Serahkan Proyek Olah Sampah Jadi Listrik Tahap-2 ke 8 Mitra <img src=" /> Danantara Invesment Management (DIM) serahkan Conditional Letter of Award (CLoA) kepada delapan mitra terpilih	\N	https://www.cnbcindonesia.com/news/20260722153748-4-752951/danantara-serahkan-proyek-olah-sampah-jadi-listrik-tahap-2-ke-8-mitra	aafb1e20-0136-41ff-8a49-5c469a422682	\N	\N	2026-07-22 09:57:01.526352+00	0	0	0	0	0	neutral	0	\N	{Umum}	{danantara,serahkan,mitra,proyek,olah}	\N	0	t	f	2026-07-22 09:57:01.526352+00	2026-07-22 10:19:04.501273+00
4637c4d1-91a1-4b95-a5ce-55732fc1088b	rss	https://www.cnbcindonesia.com/news/20260722152758-4-752947/sah-prabowo-lantik-sudaryono-jadi-kepala-bgn	article	Sah! Prabowo Lantik Sudaryono Jadi Kepala BGN\n\n<img src="https://akcdn.detik.net.id/visual/2026/07/22/sudaryono-saat-dilantik-sebagai-kepala-badan-gizi-nasional-bgn-oleh-presiden-prabowo-subianto-di-istana-merdeka-jakarta-rabu-2-1784708436062_169.png?w=1200&amp;q=90" /> Presiden Prabowo Subianto melantik Dr. Sudaryono sebagai Kepala Badan Gizi Nasional di Istana Negara. Sudaryono menggantikan Nanik Sudaryati Deyang.	Sah! Prabowo Lantik Sudaryono Jadi Kepala BGN <img src=" /> Presiden Prabowo Subianto melantik Dr. Sudaryono sebagai Kepala Badan Gizi Nasional di Istana Negara. Sudaryono menggantikan Nanik Sudaryati Deyang.	\N	https://www.cnbcindonesia.com/news/20260722152758-4-752947/sah-prabowo-lantik-sudaryono-jadi-kepala-bgn	aafb1e20-0136-41ff-8a49-5c469a422682	\N	\N	2026-07-22 09:57:01.559479+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI","Politik & Pemerintahan"}	{sudaryono,prabowo,kepala,sah,lantik}	\N	0	t	f	2026-07-22 09:57:01.559479+00	2026-07-22 10:19:04.590336+00
059edc48-5d20-401a-9f7f-3a6bfb26d970	rss	https://www.cnbcindonesia.com/news/20260722151931-4-752943/donny-ermawan-dilantik-sebagai-rektor-universitas-republik-indonesia	article	Donny Ermawan Dilantik Sebagai Rektor Universitas Republik Indonesia\n\n<img src="https://akcdn.detik.net.id/visual/2026/07/22/donny-ermawan-taufanto-saat-dilantik-sebagai-gubernur-universitas-republik-indonesia-oleh-presiden-prabowo-subianto-di-istana--1784708663227_169.png?w=1200&amp;q=90" /> Presiden Prabowo Subianto melantik Donny Taufanto sebagai Gubernur Universitas Republik Indonesia.	Donny Ermawan Dilantik Sebagai Rektor Universitas Republik Indonesia <img src=" /> Presiden Prabowo Subianto melantik Donny Taufanto sebagai Gubernur Universitas Republik Indonesia.	\N	https://www.cnbcindonesia.com/news/20260722151931-4-752943/donny-ermawan-dilantik-sebagai-rektor-universitas-republik-indonesia	aafb1e20-0136-41ff-8a49-5c469a422682	\N	\N	2026-07-22 09:57:01.591138+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI","Politik & Pemerintahan","Sosial & Budaya"}	{donny,universitas,republik,indonesia,ermawan}	\N	0	t	f	2026-07-22 09:57:01.591138+00	2026-07-22 10:19:04.625466+00
e7668a86-149b-452c-82b1-a3849d7c610d	rss	https://www.cnbcindonesia.com/news/20260722135802-4-752915/pemerintah-kebut-ambil-alih-bandara-kertajati-dari-pemprov-jabar	article	Pemerintah Kebut Ambil Alih Bandara Kertajati dari Pemprov Jabar\n\n<img src="https://akcdn.detik.net.id/visual/2023/07/11/kertajati-international-airport-dok-bijbcoid-1_169.jpeg?w=1200&amp;q=90" /> Pengembangan Bandara Kertajati sebagai pusat MRO dan embarkasi haji terus berlanjut. Pemerintah akan ambil alih kelola dari Pemprov Jabar.	Pemerintah Kebut Ambil Alih Bandara Kertajati dari Pemprov Jabar <img src=" /> Pengembangan Bandara Kertajati sebagai pusat MRO dan embarkasi haji terus berlanjut. Pemerintah akan ambil alih kelola dari Pemprov Jabar.	\N	https://www.cnbcindonesia.com/news/20260722135802-4-752915/pemerintah-kebut-ambil-alih-bandara-kertajati-dari-pemprov-jabar	aafb1e20-0136-41ff-8a49-5c469a422682	\N	\N	2026-07-22 09:57:01.621489+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI","Politik & Pemerintahan"}	{pemerintah,ambil,alih,bandara,kertajati}	\N	0	t	f	2026-07-22 09:57:01.621489+00	2026-07-22 10:19:04.675889+00
7b72771d-b599-4322-adc5-c15be96e5ee1	rss	https://www.cnbcindonesia.com/news/20260722101646-8-752816/video-prabowo-lantik-sudaryono-sebagai-kepala-bgn	article	video: Prabowo Lantik Sudaryono Sebagai Kepala BGN\n\n<img src="https://akcdn.detik.net.id/visual/2026/07/22/presiden-prabowo-subianto-pada-rabu-22-juli-2026-resmi-melantik-sudaryono-sebagai-kepala-badan-gizi-nasional-bgn-selain-itu-do-1784710947815_169.png?w=1200&amp;q=90" /> Prabowo Lantik Sudaryono Sebagai Kepala BGN	video: Prabowo Lantik Sudaryono Sebagai Kepala BGN <img src=" /> Prabowo Lantik Sudaryono Sebagai Kepala BGN	\N	https://www.cnbcindonesia.com/news/20260722101646-8-752816/video-prabowo-lantik-sudaryono-sebagai-kepala-bgn	aafb1e20-0136-41ff-8a49-5c469a422682	\N	\N	2026-07-22 09:57:01.469787+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI"}	{prabowo,lantik,sudaryono,kepala,bgn}	\N	0	t	f	2026-07-22 09:57:01.469787+00	2026-07-22 10:19:04.342715+00
2aa9a534-3f7b-490a-ade3-811420c9df62	rss	https://www.cnbcindonesia.com/news/20260722151332-4-752941/dki-bak-singapura-tokyo-utara-nyambung-selatan-properti-apa-kabar	article	DKI Bak Singapura-Tokyo: Utara Nyambung Selatan, Properti Apa Kabar?\n\n<img src="https://akcdn.detik.net.id/visual/2026/07/22/head-of-research-consulting-cbre-indonesia-anton-sitorus-dalam-media-briefing-cbre-indonesia-rabu-2272026-1784707981991_169.jpeg?w=1200&amp;q=90" /> Proyek MRT Jakarta Fase 2A dari Bundaran HI ke Jakarta Kota diprediksi akan meningkatkan mobilitas dan nilai properti di sekitarnya, mirip dengan tren global.	DKI Bak Singapura-Tokyo: Utara Nyambung Selatan, Properti Apa Kabar? <img src=" /> Proyek MRT Jakarta Fase 2A dari Bundaran HI ke Jakarta Kota diprediksi akan meningkatkan mobilitas dan nilai properti di sekitarnya, mirip dengan tren global.	\N	https://www.cnbcindonesia.com/news/20260722151332-4-752941/dki-bak-singapura-tokyo-utara-nyambung-selatan-properti-apa-kabar	aafb1e20-0136-41ff-8a49-5c469a422682	\N	\N	2026-07-22 09:57:01.499147+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI"}	{properti,jakarta,dki,bak,singapura}	\N	0	t	f	2026-07-22 09:57:01.499147+00	2026-07-22 10:19:04.365938+00
140b9c13-cba3-4bb3-a5b5-a256198b29e8	rss	https://www.cnbcindonesia.com/news/20260722154945-4-752960/kepemilikan-asing-di-srbi-ciut-ini-buktinya	article	Kepemilikan Asing di SRBI Ciut, Ini Buktinya\n\n<img src="https://akcdn.detik.net.id/visual/2026/07/07/gubernur-bank-indonesia-perry-warjiyo-saat-mengikuti-rapat-kerja-dengan-banggar-dpr-ri-di-komplek-parlemen-jakarta-selasa-7720-1783409739321_169.png?w=1200&amp;q=90" /> Kepemilikan nonresiden di Sekuritas Rupiah Bank Indonesia meningkat menjadi Rp288,65 triliun. BI menaikkan suku bunga untuk stabilitas nilai tukar rupiah.	Kepemilikan Asing di SRBI Ciut, Ini Buktinya <img src=" /> Kepemilikan nonresiden di Sekuritas Rupiah Bank Indonesia meningkat menjadi Rp288,65 triliun. BI menaikkan suku bunga untuk stabilitas nilai tukar rupiah.	\N	https://www.cnbcindonesia.com/news/20260722154945-4-752960/kepemilikan-asing-di-srbi-ciut-ini-buktinya	aafb1e20-0136-41ff-8a49-5c469a422682	\N	\N	2026-07-22 09:57:01.543075+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI","Ekonomi & Bisnis"}	{kepemilikan,rupiah,asing,srbi,ciut}	\N	0	t	f	2026-07-22 09:57:01.543075+00	2026-07-22 10:19:04.411307+00
872fc4ef-218a-4b65-915b-b2a1b435b1ea	rss	https://www.cnbcindonesia.com/news/20260722143012-4-752930/jadi-kepala-bgn-baru-sudaryono-minta-didoakan-dan-janjikan-ini	article	Jadi Kepala BGN Baru, Sudaryono Minta Didoakan dan Janjikan Ini\n\n<img src="https://akcdn.detik.net.id/visual/2026/07/22/wakil-menteri-pertanian-wamentan-sudaryono-saat-ditemui-di-kantor-kementan-jakarta-rabu-2272026-cnbc-indonesiamartyasari-rizky-1784702110831_169.jpeg?w=1200&amp;q=90" /> Wamentan Sudaryono ditunjuk sebagai Kepala BGN oleh Presiden Prabowo. Dia minta didoakan dan janjikan ini.	Jadi Kepala BGN Baru, Sudaryono Minta Didoakan dan Janjikan Ini <img src=" /> Wamentan Sudaryono ditunjuk sebagai Kepala BGN oleh Presiden Prabowo. Dia minta didoakan dan janjikan ini.	\N	https://www.cnbcindonesia.com/news/20260722143012-4-752930/jadi-kepala-bgn-baru-sudaryono-minta-didoakan-dan-janjikan-ini	aafb1e20-0136-41ff-8a49-5c469a422682	\N	\N	2026-07-22 09:57:01.574513+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI","Politik & Pemerintahan"}	{kepala,bgn,sudaryono,minta,didoakan}	\N	0	t	f	2026-07-22 09:57:01.574513+00	2026-07-22 10:19:04.863718+00
165063a4-d547-4a48-a40d-4dc7e770ff68	rss	https://www.cnbcindonesia.com/news/20260722133655-4-752906/alasan-bi-rate-kini-ditahan-di-level-575-jaga-rupiah-tekan-inflasi	article	Alasan BI Rate Kini Ditahan di Level 5,75%: Jaga Rupiah-Tekan Inflasi\n\n<img src="https://akcdn.detik.net.id/visual/2026/04/07/gubernur-bank-indonesia-perry-warjiyo-saat-tiba-di-istana-negara-jakarta-selasa-742026-1775547443127_169.jpeg?w=1200&amp;q=90" /> Dewan Gubernur Bank Indonesia (BI) memutuskan untuk mempertahankan BI Rate	Alasan BI Rate Kini Ditahan di Level 5,75%: Jaga Rupiah-Tekan Inflasi <img src=" /> Dewan Gubernur Bank Indonesia (BI) memutuskan untuk mempertahankan BI Rate	\N	https://www.cnbcindonesia.com/news/20260722133655-4-752906/alasan-bi-rate-kini-ditahan-di-level-575-jaga-rupiah-tekan-inflasi	aafb1e20-0136-41ff-8a49-5c469a422682	\N	\N	2026-07-22 09:57:01.606769+00	0	0	0	0	0	neutral	0	\N	{"Ekonomi & Bisnis"}	{rate,alasan,kini,ditahan,level}	\N	0	t	f	2026-07-22 09:57:01.606769+00	2026-07-22 10:19:04.908772+00
8e6d3607-9a9b-42ca-9c1c-8889585bab0c	rss	https://www.cnbcindonesia.com/news/20260722125736-4-752891/petaka-eropa-menggila-negeri-di-bawah-laut-terancam-krisis-air	article	Petaka Eropa  Menggila, "Negeri di Bawah Laut" Terancam Krisis Air\n\n<img src="https://akcdn.detik.net.id/visual/2026/07/22/sebuah-pemandangan-dari-drone-menunjukkan-rumah-rumah-perahu-di-sungai-het-meertje-karena-permukaan-sungai-lebih-rendah-dari-y-1784699830512_169.jpeg?w=1200&amp;q=90" /> Gelombang panas di Eropa memicu krisis air, termasuk di Belanda. Kekeringan mengancam pasokan air dan meningkatkan risiko intrusi air laut.	Petaka Eropa Menggila, "Negeri di Bawah Laut" Terancam Krisis Air <img src=" /> Gelombang panas di Eropa memicu krisis air, termasuk di Belanda. Kekeringan mengancam pasokan air dan meningkatkan risiko intrusi air laut.	\N	https://www.cnbcindonesia.com/news/20260722125736-4-752891/petaka-eropa-menggila-negeri-di-bawah-laut-terancam-krisis-air	aafb1e20-0136-41ff-8a49-5c469a422682	\N	\N	2026-07-22 09:57:01.640512+00	0	0	0	0	0	negative	-1	\N	{"Teknologi & AI"}	{air,eropa,laut,krisis,petaka}	\N	0	t	f	2026-07-22 09:57:01.640512+00	2026-07-22 10:19:04.940223+00
5fe09f3c-60ee-44ab-bca0-9c1e2abcfbbd	rss	https://www.cnbcindonesia.com/news/20260722140529-4-752920/produksi-gas-ri-bisa-melejit-150-dalam-5-tahun-ini-pendorongnya	article	Produksi Gas RI Bisa Melejit 150% Dalam 5 Tahun, Ini Pendorongnya\n\n<img src="https://akcdn.detik.net.id/visual/2026/06/11/pt-saka-energi-indonesia-perusahaan-hulu-migas-bagian-dari-subholding-gas-pertamina-mendapatkan-persetujuan-pengembangan-lapan-1781150129002_169.jpeg?w=1200&amp;q=90" /> Produksi gas di Indonesia diramal bisa meningkat hingga 150%	Produksi Gas RI Bisa Melejit 150% Dalam 5 Tahun, Ini Pendorongnya <img src=" /> Produksi gas di Indonesia diramal bisa meningkat hingga 150%	\N	https://www.cnbcindonesia.com/news/20260722140529-4-752920/produksi-gas-ri-bisa-melejit-150-dalam-5-tahun-ini-pendorongnya	aafb1e20-0136-41ff-8a49-5c469a422682	\N	\N	2026-07-22 09:57:01.730603+00	0	0	0	0	0	neutral	0	\N	{Umum}	{produksi,gas,melejit,dalam,tahun}	\N	0	t	f	2026-07-22 09:57:01.730603+00	2026-07-22 10:19:04.758899+00
236ca27e-df27-4f6f-a8df-ec8ee13f19be	rss	https://www.cnbcindonesia.com/news/20260722143503-4-752932/sudaryono-merapat-ke-istana-kepresidenan-segera-dilantik-jadi-bos-bgn	article	Sudaryono Merapat ke Istana Kepresidenan, Segera Dilantik Jadi Bos BGN\n\n<img src="https://akcdn.detik.net.id/visual/2026/07/22/wakil-menteri-pertanian-wamentan-sudaryono-saat-tiba-di-istana-merdeka-jakarta-rabu-2272026-1784705977383_169.jpeg?w=1200&amp;q=90" /> Wakil Menteri Pertanian Sudaryono dilantik sebagai kepala Badan Gizi Nasional oleh Presiden Prabowo, menggantikan Nanik Sudaryati Deyang yang mengundurkan diri.	Sudaryono Merapat ke Istana Kepresidenan, Segera Dilantik Jadi Bos BGN <img src=" /> Wakil Menteri Pertanian Sudaryono dilantik sebagai kepala Badan Gizi Nasional oleh Presiden Prabowo, menggantikan Nanik Sudaryati Deyang yang mengundurkan diri.	\N	https://www.cnbcindonesia.com/news/20260722143503-4-752932/sudaryono-merapat-ke-istana-kepresidenan-segera-dilantik-jadi-bos-bgn	aafb1e20-0136-41ff-8a49-5c469a422682	\N	\N	2026-07-22 09:57:01.770573+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI","Politik & Pemerintahan"}	{sudaryono,dilantik,merapat,istana,kepresidenan}	\N	0	t	f	2026-07-22 09:57:01.770573+00	2026-07-22 10:19:04.797755+00
1e6562b8-a0b5-4c13-88de-1a4f80fd0561	rss	https://www.cnbcindonesia.com/news/20260722133800-4-752909/bi-rate-diramal-bisa-sampai-675-siap-siap-bunga-kpr-bakal-naik	article	BI Rate Diramal Bisa Sampai 6,75%, Siap-Siap Bunga KPR Bakal Naik\n\n<img src="https://akcdn.detik.net.id/visual/2026/07/22/konferensi-pers-smf-rabu-2272026-cnbc-indonesiaferry-sandi-1784697672865_169.jpeg?w=1200&amp;q=90" /> PT SMF proyeksikan BI Rate bisa mencapai 6,75% akhir tahun, berdampak pada biaya KPR. Tantangan bagi industri perumahan, namun adaptasi kunci keberlanjutan.	BI Rate Diramal Bisa Sampai 6,75%, Siap-Siap Bunga KPR Bakal Naik <img src=" /> PT SMF proyeksikan BI Rate bisa mencapai 6,75% akhir tahun, berdampak pada biaya KPR. Tantangan bagi industri perumahan, namun adaptasi kunci keberlanjutan.	\N	https://www.cnbcindonesia.com/news/20260722133800-4-752909/bi-rate-diramal-bisa-sampai-675-siap-siap-bunga-kpr-bakal-naik	aafb1e20-0136-41ff-8a49-5c469a422682	\N	\N	2026-07-22 09:57:01.807741+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI"}	{rate,siap,kpr,diramal,sampai}	\N	0	t	f	2026-07-22 09:57:01.807741+00	2026-07-22 10:19:04.835864+00
e477dcab-63bd-40f8-8bbe-3e3a35481fd6	rss	https://www.cnnindonesia.com/nasional/20260722160320-12-1383688/bareskrim-tetapkan-ayah-anak-pemilik-pabrik-whip-pink-jadi-tersangka	article	Bareskrim Tetapkan Ayah-Anak Pemilik Pabrik Whip Pink Jadi Tersangka\n\n<img src="https://akcdn.detik.net.id/visual/2026/04/15/bareskrim-bongkar-pabrik-whip-pink-ilegal-di-jakarta-1776241691987_169.jpeg?w=360&amp;q=90" /> Bareskrim Polri menetapkan Andi Hioe dan Jasen Hioe sebagai tersangka pelanggaran UU Kesehatan terkait produksi gas N2O merek Whip Pink.	Bareskrim Tetapkan Ayah-Anak Pemilik Pabrik Whip Pink Jadi Tersangka <img src=" /> Bareskrim Polri menetapkan Andi Hioe dan Jasen Hioe sebagai tersangka pelanggaran UU Kesehatan terkait produksi gas N2O merek Whip Pink.	\N	https://www.cnnindonesia.com/nasional/20260722160320-12-1383688/bareskrim-tetapkan-ayah-anak-pemilik-pabrik-whip-pink-jadi-tersangka	c8537df0-902d-45bd-8db9-5729e6869541	\N	\N	2026-07-22 09:57:01.848791+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI","Sosial & Budaya"}	{bareskrim,whip,pink,tersangka,hioe}	\N	0	t	f	2026-07-22 09:57:01.848791+00	2026-07-22 10:19:04.952556+00
c226bc05-ec94-46cf-b9a1-3d30daebd5b6	rss	https://www.cnnindonesia.com/nasional/20260722150532-20-1383671/lantik-1177-perwira-remaja-prabowo-singgung-peran-vital-tni-polri	article	Lantik 1.177 Perwira Remaja, Prabowo Singgung Peran Vital TNI-Polri\n\n<img src="https://akcdn.detik.net.id/visual/2026/07/22/upacara-prasetya-perwira-tni-polri-1784701860984_169.jpeg?w=360&amp;q=90" /> Presiden Prabowo Subianto menyinggung peran vital institusi TNI-Polri untuk menjaga persatuan dan kesatuan Bangsa Indonesia.	Lantik 1.177 Perwira Remaja, Prabowo Singgung Peran Vital TNI-Polri <img src=" /> Presiden Prabowo Subianto menyinggung peran vital institusi TNI-Polri untuk menjaga persatuan dan kesatuan Bangsa Indonesia.	\N	https://www.cnnindonesia.com/nasional/20260722150532-20-1383671/lantik-1177-perwira-remaja-prabowo-singgung-peran-vital-tni-polri	c8537df0-902d-45bd-8db9-5729e6869541	\N	\N	2026-07-22 09:57:01.885544+00	0	0	0	0	0	neutral	0	\N	{"Politik & Pemerintahan"}	{prabowo,peran,vital,tni,polri}	\N	0	t	f	2026-07-22 09:57:01.885544+00	2026-07-22 10:19:04.984318+00
1f1a6ac1-15ed-47bf-8030-6f20a3a704a4	rss	https://www.cnbcindonesia.com/news/20260722125404-4-752889/ketika-bahlil-sebut-persaingan-china-vs-jepang-di-ev-hidrogen	article	Ketika Bahlil Sebut Persaingan China Vs Jepang di EV dan Hidrogen\n\n<img src="https://akcdn.detik.net.id/visual/2026/07/21/peresmian-uji-coba-bus-hidrogen-dalam-acara-global-hydrogen-ecosystem-summit-ghes-2026-di-jcc-jakarta-selasa-2172026-1784617640744_169.jpeg?w=1200&amp;q=90" /> Menteri ESDM Bahlil Lahadalia sebut persaingan China Vs Jepang bukan cuma EV melainkan hidrogen	Ketika Bahlil Sebut Persaingan China Vs Jepang di EV dan Hidrogen <img src=" /> Menteri ESDM Bahlil Lahadalia sebut persaingan China Vs Jepang bukan cuma EV melainkan hidrogen	\N	https://www.cnbcindonesia.com/news/20260722125404-4-752889/ketika-bahlil-sebut-persaingan-china-vs-jepang-di-ev-hidrogen	aafb1e20-0136-41ff-8a49-5c469a422682	\N	\N	2026-07-22 09:57:01.711511+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI"}	{bahlil,sebut,persaingan,china,jepang}	\N	0	t	f	2026-07-22 09:57:01.711511+00	2026-07-22 09:57:01.711511+00
4cd00a3b-9a99-469d-81a2-fffbfb6bef94	rss	https://www.cnbcindonesia.com/news/20260722124141-4-752883/ri-mau-garap-hidrogen-ini-4-isu-yang-perlu-kajian-lebih-dalam	article	RI Mau Garap Hidrogen, Ini 4 Isu yang Perlu Kajian Lebih Dalam\n\n<img src="https://akcdn.detik.net.id/visual/2024/09/04/pembangkit-listrik-tenaga-panas-bumi-pltp-kamojang-berhasil-memproduksi-hidrogen-hijau-green-hydrogen-berbasis-panas-bumi-gree-6_169.jpeg?w=1200&amp;q=90" /> Menteri ESDM Bahlil Lahadalia mendorong pengembangan ekosistem hidrogen	RI Mau Garap Hidrogen, Ini 4 Isu yang Perlu Kajian Lebih Dalam <img src=" /> Menteri ESDM Bahlil Lahadalia mendorong pengembangan ekosistem hidrogen	\N	https://www.cnbcindonesia.com/news/20260722124141-4-752883/ri-mau-garap-hidrogen-ini-4-isu-yang-perlu-kajian-lebih-dalam	aafb1e20-0136-41ff-8a49-5c469a422682	\N	\N	2026-07-22 09:57:01.751999+00	0	0	0	0	0	neutral	0	\N	{Umum}	{hidrogen,mau,garap,isu,perlu}	\N	0	t	f	2026-07-22 09:57:01.751999+00	2026-07-22 09:57:01.751999+00
68f02321-a0c9-4188-8b32-8ba716801453	rss	https://www.cnbcindonesia.com/news/20260722131712-4-752904/perang-dagang-as-bangkit-dari-kubur-trump-naikkan-tarif-ini-200	article	Perang Dagang AS 'Bangkit dari Kubur', Trump Naikkan Tarif Ini 200%\n\n<img src="https://akcdn.detik.net.id/visual/2025/04/03/presiden-as-donald-trump-memegang-perintah-eksekutif-yang-ditandatangani-tentang-tarif-di-rose-garden-di-gedung-putih-di-washi-1743649018107_169.jpeg?w=1200&amp;q=90" /> Perang dagang AS kembali memanas. Trump mengenakan tarif 25% ke Brasil dan 50% ke Kanada, dan merencanakan tarif untuk obat generik hingga 200%.	Perang Dagang AS 'Bangkit dari Kubur', Trump Naikkan Tarif Ini 200% <img src=" /> Perang dagang AS kembali memanas. Trump mengenakan tarif 25% ke Brasil dan 50% ke Kanada, dan merencanakan tarif untuk obat generik hingga 200%.	\N	https://www.cnbcindonesia.com/news/20260722131712-4-752904/perang-dagang-as-bangkit-dari-kubur-trump-naikkan-tarif-ini-200	aafb1e20-0136-41ff-8a49-5c469a422682	\N	\N	2026-07-22 09:57:01.785054+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI"}	{tarif,perang,dagang,trump,bangkit}	\N	0	t	f	2026-07-22 09:57:01.785054+00	2026-07-22 09:57:01.785054+00
e60fa4ac-5778-47cb-915a-480a1a3e8341	rss	https://www.cnbcindonesia.com/news/20260722124312-4-752884/ini-tantangan-berat-program-nyicil-rumah-sampai-40-tahun	article	Ini Tantangan Berat Program Nyicil Rumah Sampai 40 Tahun\n\n<img src="https://akcdn.detik.net.id/visual/2021/02/17/suasana-proyek-pembangunan-perumahan-di-depok-jawa-barat-rabu-1722021-harga-hunian-rumah-hunian-masih-menunjukkan-kenaikan-pad-16_169.jpeg?w=1200&amp;q=90" /> Rencana KPR tenor 40 tahun menawarkan cicilan lebih ringan, namun tantangan beratnya ini.	Ini Tantangan Berat Program Nyicil Rumah Sampai 40 Tahun <img src=" /> Rencana KPR tenor 40 tahun menawarkan cicilan lebih ringan, namun tantangan beratnya ini.	\N	https://www.cnbcindonesia.com/news/20260722124312-4-752884/ini-tantangan-berat-program-nyicil-rumah-sampai-40-tahun	aafb1e20-0136-41ff-8a49-5c469a422682	\N	\N	2026-07-22 09:57:01.828159+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI"}	{tantangan,tahun,berat,program,nyicil}	\N	0	t	f	2026-07-22 09:57:01.828159+00	2026-07-22 09:57:01.828159+00
4b76c6e0-e74e-40f0-afeb-1758bb85c295	rss	https://www.cnbcindonesia.com/news/20260722132101-4-752901/ini-bocoran-pertemuan-purbaya-dan-gus-yahya-di-kantor-pbnu	article	Ini Bocoran Pertemuan Purbaya dan Gus Yahya di Kantor PBNU\n\n<img src="https://akcdn.detik.net.id/visual/2026/07/22/menteri-keuangan-purbaya-yudhi-sadewa-bertemu-dengan-ketua-umum-pengurus-besar-nahdlatul-ulama-yahya-cholil-staquf-cnbc-indone-1784700430637_169.jpeg?w=1200&amp;q=90" /> Menkeu Purbaya Yudhi Sadewa bertemu Gus Yahya dari PBNU untuk membahas kerja sama dalam pengelolaan sampah dan investasi demi kesejahteraan masyarakat.	Ini Bocoran Pertemuan Purbaya dan Gus Yahya di Kantor PBNU <img src=" /> Menkeu Purbaya Yudhi Sadewa bertemu Gus Yahya dari PBNU untuk membahas kerja sama dalam pengelolaan sampah dan investasi demi kesejahteraan masyarakat.	\N	https://www.cnbcindonesia.com/news/20260722132101-4-752901/ini-bocoran-pertemuan-purbaya-dan-gus-yahya-di-kantor-pbnu	aafb1e20-0136-41ff-8a49-5c469a422682	\N	\N	2026-07-22 09:57:01.674492+00	0	0	0	0	0	neutral	0	\N	{"Ekonomi & Bisnis","Sosial & Budaya"}	{purbaya,gus,yahya,pbnu,bocoran}	\N	0	t	f	2026-07-22 09:57:01.674492+00	2026-07-22 10:19:04.96969+00
51300e14-e1ef-48bc-8cb0-fa877c50232a	rss	https://www.cnnindonesia.com/nasional/20260722142330-20-1383651/polda-sulsel-identifikasi-2-jasad-diduga-korban-km-nurul-salsa	article	Polda Sulsel Identifikasi 2 Jasad Diduga Korban KM Nurul Salsa\n\n<img src="https://akcdn.detik.net.id/visual/2026/07/22/evakuasi-korban-km-nurul-salsa-1784695523822_169.jpeg?w=360&amp;q=90" /> Tim SAR menemukan dua jasad diduga korban KM Nurul Salsa. Proses identifikasi dilakukan di RS Makassar Sulsel menggunakan sidik jari dan DNA.	Polda Sulsel Identifikasi 2 Jasad Diduga Korban KM Nurul Salsa <img src=" /> Tim SAR menemukan dua jasad diduga korban KM Nurul Salsa. Proses identifikasi dilakukan di RS Makassar Sulsel menggunakan sidik jari dan DNA.	\N	https://www.cnnindonesia.com/nasional/20260722142330-20-1383651/polda-sulsel-identifikasi-2-jasad-diduga-korban-km-nurul-salsa	c8537df0-902d-45bd-8db9-5729e6869541	\N	\N	2026-07-22 09:57:01.916611+00	0	0	0	0	0	neutral	0	\N	{Umum}	{sulsel,identifikasi,jasad,diduga,korban}	\N	0	t	f	2026-07-22 09:57:01.916611+00	2026-07-22 10:19:05.264287+00
67b5807c-7b49-428d-b399-51232c709dbd	rss	https://www.cnnindonesia.com/nasional/20260722153131-12-1383676/bobrok-kaderisasi-dan-buruk-integritas-di-balik-ott-kepala-daerah	article	Bobrok Kaderisasi dan Buruk Integritas di Balik OTT Kepala Daerah\n\n<img src="https://akcdn.detik.net.id/visual/2026/07/21/kpk-tahan-bupati-lombok-barat-1784639460244_169.jpeg?w=360&amp;q=90" /> Kasus korupsi 11 kepala daerah yang diungkap KPK mencerminkan masalah tata kelola politik. Perlu reformasi sistem rekrutmen dan transparansi biaya politik.	Bobrok Kaderisasi dan Buruk Integritas di Balik OTT Kepala Daerah <img src=" /> Kasus korupsi 11 kepala daerah yang diungkap KPK mencerminkan masalah tata kelola politik. Perlu reformasi sistem rekrutmen dan transparansi biaya politik.	\N	https://www.cnnindonesia.com/nasional/20260722153131-12-1383676/bobrok-kaderisasi-dan-buruk-integritas-di-balik-ott-kepala-daerah	c8537df0-902d-45bd-8db9-5729e6869541	\N	\N	2026-07-22 09:57:01.966426+00	0	0	0	0	0	negative	-1	\N	{"Politik & Pemerintahan","Hukum & Keamanan"}	{kepala,daerah,politik,bobrok,kaderisasi}	\N	0	t	f	2026-07-22 09:57:01.966426+00	2026-07-22 10:19:05.051727+00
14ff688b-04df-473b-9cbb-8bf90c69feed	rss	https://www.cnnindonesia.com/nasional/20260722153012-12-1383675/polisi-tak-ada-cctv-rekam-penculikan-atlet-golf-jesslyn	article	Polisi: Tak Ada CCTV Rekam Penculikan Atlet Golf Jesslyn\n\n<img src="https://akcdn.detik.net.id/visual/2016/04/13/51d46d49-d875-45a6-9ef7-cb8d52cb59ee_169.jpg?w=360&amp;q=90" /> Polisi menyelidiki dugaan penculikan atlet golf Jesslyn Wijaya Lay di Jakarta. Tidak ada CCTV yang merekam, dan korban kini diketahui berada di Malaysia.	Polisi: Tak Ada CCTV Rekam Penculikan Atlet Golf Jesslyn <img src=" /> Polisi menyelidiki dugaan penculikan atlet golf Jesslyn Wijaya Lay di Jakarta. Tidak ada CCTV yang merekam, dan korban kini diketahui berada di Malaysia.	\N	https://www.cnnindonesia.com/nasional/20260722153012-12-1383675/polisi-tak-ada-cctv-rekam-penculikan-atlet-golf-jesslyn	c8537df0-902d-45bd-8db9-5729e6869541	\N	\N	2026-07-22 09:57:02.024238+00	0	0	0	0	0	neutral	0	\N	{"Hukum & Keamanan"}	{polisi,cctv,penculikan,atlet,golf}	\N	0	t	f	2026-07-22 09:57:02.024238+00	2026-07-22 10:19:05.123397+00
29f601f7-4ae4-49c1-8ef9-8bdf5488d894	rss	https://www.cnnindonesia.com/nasional/20260722150850-12-1383672/istri-di-bali-dipolisikan-suami-perkara-melahirkan-di-rs-lain	article	Istri di Bali Dipolisikan Suami Perkara Melahirkan di RS Lain\n\n<img src="https://akcdn.detik.net.id/visual/2023/01/31/ilustrasi-tangan-bayi-dan-orang-tua_169.jpeg?w=360&amp;q=90" /> KC dilaporkan suaminya ke Polresta Denpasar atas dugaan penggelapan asal-usul orang. Kasus ini berawal dari persalinan di rumah sakit berbeda lebih awal.	Istri di Bali Dipolisikan Suami Perkara Melahirkan di RS Lain <img src=" /> KC dilaporkan suaminya ke Polresta Denpasar atas dugaan penggelapan asal-usul orang. Kasus ini berawal dari persalinan di rumah sakit berbeda lebih awal.	\N	https://www.cnnindonesia.com/nasional/20260722150850-12-1383672/istri-di-bali-dipolisikan-suami-perkara-melahirkan-di-rs-lain	c8537df0-902d-45bd-8db9-5729e6869541	\N	\N	2026-07-22 09:57:02.057521+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI","Ekonomi & Bisnis","Hukum & Keamanan"}	{istri,bali,dipolisikan,suami,perkara}	\N	0	t	f	2026-07-22 09:57:02.057521+00	2026-07-22 10:19:05.167745+00
1c8b1625-cab5-4345-a7a3-78164646aba9	rss	https://www.cnnindonesia.com/nasional/20260722145746-12-1383662/pwi-terima-permintaan-maaf-hotman-paris-tapi-proses-hukum-tetap-jalan	article	PWI Terima Permintaan Maaf Hotman Paris: Tapi Proses Hukum Tetap Jalan\n\n<img src="https://akcdn.detik.net.id/visual/2026/07/17/hotman-paris-tiba-di-kejagung-1784258101915_169.jpeg?w=360&amp;q=90" /> PWI terima permintaan maaf Hotman Paris terkait pernyataannya yang menghina wartawan, namun proses hukum di polisi tetap berlanjut.	PWI Terima Permintaan Maaf Hotman Paris: Tapi Proses Hukum Tetap Jalan <img src=" /> PWI terima permintaan maaf Hotman Paris terkait pernyataannya yang menghina wartawan, namun proses hukum di polisi tetap berlanjut.	\N	https://www.cnnindonesia.com/nasional/20260722145746-12-1383662/pwi-terima-permintaan-maaf-hotman-paris-tapi-proses-hukum-tetap-jalan	c8537df0-902d-45bd-8db9-5729e6869541	\N	\N	2026-07-22 09:57:02.091138+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI","Hukum & Keamanan"}	{pwi,terima,permintaan,maaf,hotman}	\N	0	t	f	2026-07-22 09:57:02.091138+00	2026-07-22 10:19:05.189632+00
dde0b2f2-b337-45af-af87-27357db2376a	rss	https://www.cnnindonesia.com/nasional/20260722150104-20-1383669/petugas-perlintasan-diduga-tertidur-truk-nyaris-tertabrak-ka-brantas	article	Petugas Perlintasan Diduga Tertidur, Truk Nyaris Tertabrak KA Brantas\n\n<img src="https://akcdn.detik.net.id/visual/2015/02/13/c2ab92a0-fd89-4e44-8b0c-76f1b7c03057_169.jpg?w=360&amp;q=90" /> Penjaga perlintasan KA di Kediri diduga tertidur, menyebabkan palang pintu tidak tertutup. Sebuah truk nyaris tertabrak kereta.	Petugas Perlintasan Diduga Tertidur, Truk Nyaris Tertabrak KA Brantas <img src=" /> Penjaga perlintasan KA di Kediri diduga tertidur, menyebabkan palang pintu tidak tertutup. Sebuah truk nyaris tertabrak kereta.	\N	https://www.cnnindonesia.com/nasional/20260722150104-20-1383669/petugas-perlintasan-diduga-tertidur-truk-nyaris-tertabrak-ka-brantas	c8537df0-902d-45bd-8db9-5729e6869541	\N	\N	2026-07-22 09:57:02.11423+00	0	0	0	0	0	neutral	0	\N	{Umum}	{perlintasan,diduga,tertidur,truk,nyaris}	\N	0	t	f	2026-07-22 09:57:02.11423+00	2026-07-22 10:19:05.212147+00
b99a681e-f529-458f-a84b-32fdd6c7eece	rss	https://www.cnnindonesia.com/nasional/20260722134343-20-1383631/mukjizat-selembar-gabus-dan-dekapan-suami-di-laut-selayar	article	Mukjizat Selembar Gabus dan Dekapan Suami di Laut Selayar\n\n<img src="https://akcdn.detik.net.id/visual/2016/02/15/32ed4395-5fe4-476e-83db-599bed2df606_169.jpg?w=360&amp;q=90" /> Sitti Amang (47) terapung 4 hari di atas gabus rapuh. Ia tak bisa berenang. Empat orang lain yang ikut bertahan di atas gabus tenggelam diempas gelombang.	Mukjizat Selembar Gabus dan Dekapan Suami di Laut Selayar <img src=" /> Sitti Amang (47) terapung 4 hari di atas gabus rapuh. Ia tak bisa berenang. Empat orang lain yang ikut bertahan di atas gabus tenggelam diempas gelombang.	\N	https://www.cnnindonesia.com/nasional/20260722134343-20-1383631/mukjizat-selembar-gabus-dan-dekapan-suami-di-laut-selayar	c8537df0-902d-45bd-8db9-5729e6869541	\N	\N	2026-07-22 09:57:02.074125+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI"}	{gabus,atas,mukjizat,selembar,dekapan}	\N	0	t	f	2026-07-22 09:57:02.074125+00	2026-07-22 10:19:05.140059+00
78749dce-1a07-4b73-b131-14b5e3903b70	rss	https://www.cnnindonesia.com/nasional/20260722131510-20-1383598/cerita-paling-sedih-km-nurul-salsa-kakek-relakan-pelampung-demi-cucu	article	Cerita Paling Sedih KM Nurul Salsa, Kakek Relakan Pelampung Demi Cucu\n\n<img src="https://akcdn.detik.net.id/visual/2023/05/30/ilustrasi-kapal-tenggelam_169.jpeg?w=360&amp;q=90" /> Video viral dari peristiwa KM Nurul Salsa yang karam di Sulsel memperlihatkan kakek mengenakan pelampung terakhir untuk cucu sebelum kapal itu tenggelam.<br /><br />	Cerita Paling Sedih KM Nurul Salsa, Kakek Relakan Pelampung Demi Cucu <img src=" /> Video viral dari peristiwa KM Nurul Salsa yang karam di Sulsel memperlihatkan kakek mengenakan pelampung terakhir untuk cucu sebelum kapal itu tenggelam.<br /><br />	\N	https://www.cnnindonesia.com/nasional/20260722131510-20-1383598/cerita-paling-sedih-km-nurul-salsa-kakek-relakan-pelampung-demi-cucu	c8537df0-902d-45bd-8db9-5729e6869541	\N	\N	2026-07-22 09:57:02.104092+00	0	0	0	0	0	neutral	0	\N	{Umum}	{nurul,salsa,kakek,pelampung,cucu}	\N	0	t	f	2026-07-22 09:57:02.104092+00	2026-07-22 10:19:05.179652+00
d703f498-bb36-471b-a456-b639848cac9e	rss	https://www.cnnindonesia.com/nasional/20260722131039-20-1383595/anak-pejabat-gayo-lues-aceh-kena-tegur-gara-gara-konten-flexing	article	Nevi Rizal Pejabat Gayo Lues Minta Maaf dan Tegur Anaknya Rajin Flexing\n\n<img src="https://akcdn.detik.net.id/visual/2015/07/24/0676200f-0af8-4c87-a754-bff6467e55d7_169.jpg?w=360&amp;q=90" /> Anak seorang pejabat di Kabupaten Gayo Lues, Aceh kena tegur ayahnya sendiri gara-gara kerap mengunggah konten media sosial yang menampilkan gaya hidup mewah.<br /><br />	Nevi Rizal Pejabat Gayo Lues Minta Maaf dan Tegur Anaknya Rajin Flexing <img src=" /> Anak seorang pejabat di Kabupaten Gayo Lues, Aceh kena tegur ayahnya sendiri gara-gara kerap mengunggah konten media sosial yang menampilkan gaya hidup mewah.<br /><br />	\N	https://www.cnnindonesia.com/nasional/20260722131039-20-1383595/anak-pejabat-gayo-lues-aceh-kena-tegur-gara-gara-konten-flexing	c8537df0-902d-45bd-8db9-5729e6869541	\N	\N	2026-07-22 09:57:02.131672+00	0	0	0	0	0	neutral	0	\N	{"Sosial & Budaya"}	{pejabat,gayo,lues,tegur,gara}	\N	0	t	f	2026-07-22 09:57:02.131672+00	2026-07-22 10:19:05.201938+00
71f01ab4-6abe-4c42-9c69-d87b313acca2	rss	https://www.cnnindonesia.com/nasional/20260722141557-20-1383643/basarnas-sisir-pulau-sabalana-hingga-laut-ntb-cari-korban-km-salsa	article	Basarnas Sisir Pulau Sabalana hingga Laut NTB Cari Korban KM Salsa\n\n<img src="https://akcdn.detik.net.id/visual/2026/07/22/basarnas-sisir-pulau-tak-berpenghuni-hingga-laut-ntb-cari-korban-km-nurul-salsa-1784704763400_169.jpeg?w=360&amp;q=90" /> Tim SAR fokus mencari korban KM Nurul Salsa yang tenggelam di perairan Selayar. Pencarian melibatkan dua sektor dengan tantangan cuaca dan gelombang tinggi.	Basarnas Sisir Pulau Sabalana hingga Laut NTB Cari Korban KM Salsa <img src=" /> Tim SAR fokus mencari korban KM Nurul Salsa yang tenggelam di perairan Selayar. Pencarian melibatkan dua sektor dengan tantangan cuaca dan gelombang tinggi.	\N	https://www.cnnindonesia.com/nasional/20260722141557-20-1383643/basarnas-sisir-pulau-sabalana-hingga-laut-ntb-cari-korban-km-salsa	c8537df0-902d-45bd-8db9-5729e6869541	\N	\N	2026-07-22 09:57:01.951191+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI"}	{korban,salsa,basarnas,sisir,pulau}	\N	0	t	f	2026-07-22 09:57:01.951191+00	2026-07-22 10:19:05.297215+00
2af9012c-55df-42ca-ade6-3db09f3a746f	rss	https://www.cnnindonesia.com/nasional/20260722140732-20-1383639/cerita-warga-bandung-pesan-3-ojol-antar-pulang-karena-takut-begal	article	Cerita Warga Bandung Pesan 3 Ojol Antar Pulang karena Takut Begal\n\n<img src="https://akcdn.detik.net.id/visual/2026/05/19/ilustrasi-begal-motor-1779177807472_169.jpeg?w=360&amp;q=90" /> Claudia (21) memesan tiga driver ojek online (ojol) untuk mengawal pulang usai nobar final Piala Dunia 2026 karena ia takut dengan ancaman begal.	Cerita Warga Bandung Pesan 3 Ojol Antar Pulang karena Takut Begal <img src=" /> Claudia (21) memesan tiga driver ojek online (ojol) untuk mengawal pulang usai nobar final Piala Dunia 2026 karena ia takut dengan ancaman begal.	\N	https://www.cnnindonesia.com/nasional/20260722140732-20-1383639/cerita-warga-bandung-pesan-3-ojol-antar-pulang-karena-takut-begal	c8537df0-902d-45bd-8db9-5729e6869541	\N	\N	2026-07-22 09:57:01.98499+00	0	0	0	0	0	negative	-1	\N	{"Teknologi & AI"}	{ojol,pulang,karena,takut,begal}	\N	0	t	f	2026-07-22 09:57:01.98499+00	2026-07-22 10:19:05.334339+00
a21193fb-9b92-4e41-b260-4520ad48e639	rss	https://www.cnnindonesia.com/nasional/20260722133923-20-1383630/cholil-erk-gabung-badan-pengawas-kontras-eka-the-brandals-pengurus	article	Cholil ERK Gabung Badan Pengawas KontraS, Eka The Brandals Pengurus\n\n<img src="https://akcdn.detik.net.id/visual/2023/07/28/penampilan-efek-rumah-kaca-dalam-konser-bertajuk-rimpang-1_169.jpeg?w=360&amp;q=90" /> KontraS umumkan badan pengawas dan pengurus baru periode 2026-2030, termasuk musisi Cholil Mahmud dan Eka Annash.	Cholil ERK Gabung Badan Pengawas KontraS, Eka The Brandals Pengurus <img src=" /> KontraS umumkan badan pengawas dan pengurus baru periode 2026-2030, termasuk musisi Cholil Mahmud dan Eka Annash.	\N	https://www.cnnindonesia.com/nasional/20260722133923-20-1383630/cholil-erk-gabung-badan-pengawas-kontras-eka-the-brandals-pengurus	c8537df0-902d-45bd-8db9-5729e6869541	\N	\N	2026-07-22 09:57:02.011285+00	0	0	0	0	0	neutral	0	\N	{Umum}	{cholil,badan,pengawas,kontras,eka}	\N	0	t	f	2026-07-22 09:57:02.011285+00	2026-07-22 10:19:05.360947+00
90663598-bfbd-4c38-a8a8-18041344bd2b	rss	https://www.cnnindonesia.com/nasional/20260722122215-12-1383560/prabowo-teken-keppres-wakil-jaksa-agung-asep-nana-jampidsus-kuntadi	article	Prabowo Teken Keppres: Wakil Jaksa Agung Asep Nana, Jampidsus Kuntadi\n\n<img src="https://akcdn.detik.net.id/visual/2026/07/20/taklimat-presiden-prabowo-1784535872798_169.png?w=360&amp;q=90" /> Presiden Prabowo Subianto resmi meneken Keppres pengangkatan sejumlah pejabat di Kejaksaan Agung termasuk Wakil Jaksa Agung dan Jampidsus.	Prabowo Teken Keppres: Wakil Jaksa Agung Asep Nana, Jampidsus Kuntadi <img src=" /> Presiden Prabowo Subianto resmi meneken Keppres pengangkatan sejumlah pejabat di Kejaksaan Agung termasuk Wakil Jaksa Agung dan Jampidsus.	\N	https://www.cnnindonesia.com/nasional/20260722122215-12-1383560/prabowo-teken-keppres-wakil-jaksa-agung-asep-nana-jampidsus-kuntadi	c8537df0-902d-45bd-8db9-5729e6869541	\N	\N	2026-07-22 09:57:02.250962+00	0	0	0	0	0	neutral	0	\N	{"Politik & Pemerintahan"}	{agung,prabowo,keppres,wakil,jaksa}	\N	0	t	f	2026-07-22 09:57:02.250962+00	2026-07-22 09:57:02.250962+00
cf80b74e-1c58-4c7c-87a0-5a370baf98cb	rss	https://www.cnnindonesia.com/nasional/20260722114939-12-1383545/tni-ad-tidak-ada-penugasan-baru-babinsa-di-bidang-perpajakan	article	TNI AD: Tidak Ada Penugasan Baru Babinsa di Bidang Perpajakan\n\n<img src="https://akcdn.detik.net.id/visual/2023/02/14/bantuan-sepeda-motor-untuk-babinsa-3_169.jpeg?w=360&amp;q=90" /> TNI Angkatan Darat buka suara soal informasi pelibatan Bintara Pembina Desa (Babinsa) dalam pengawasan wajib pajak.	TNI AD: Tidak Ada Penugasan Baru Babinsa di Bidang Perpajakan <img src=" /> TNI Angkatan Darat buka suara soal informasi pelibatan Bintara Pembina Desa (Babinsa) dalam pengawasan wajib pajak.	\N	https://www.cnnindonesia.com/nasional/20260722114939-12-1383545/tni-ad-tidak-ada-penugasan-baru-babinsa-di-bidang-perpajakan	c8537df0-902d-45bd-8db9-5729e6869541	\N	\N	2026-07-22 09:57:02.285151+00	0	0	0	0	0	neutral	0	\N	{Umum}	{tni,babinsa,penugasan,baru,bidang}	\N	0	t	f	2026-07-22 09:57:02.285151+00	2026-07-22 09:57:02.285151+00
e88eb607-1e7e-4a72-8755-1ac96735cb31	rss	https://www.cnnindonesia.com/nasional/20260722114158-20-1383540/sdn-kebayoran-lama-roboh-terbengkalai-2-tahun-ratusan-siswa-ngungsi	article	SDN Kebayoran Lama Roboh Terbengkalai 2 Tahun, Ratusan Siswa Ngungsi\n\n<img src="https://akcdn.detik.net.id/visual/2026/07/21/pemprov-dki-jakarta-segera-perbaiki-sekolah-ambruk-1784633131161_169.jpeg?w=360&amp;q=90" /> SDN Kebayoran Lama Selatan 09 di Jakarta sudah 2 tahun roboh. Orang tua siswa resah menanti perbaikan, ratusan siswa terpaksa menumpang sekolah lain.	SDN Kebayoran Lama Roboh Terbengkalai 2 Tahun, Ratusan Siswa Ngungsi <img src=" /> SDN Kebayoran Lama Selatan 09 di Jakarta sudah 2 tahun roboh. Orang tua siswa resah menanti perbaikan, ratusan siswa terpaksa menumpang sekolah lain.	\N	https://www.cnnindonesia.com/nasional/20260722114158-20-1383540/sdn-kebayoran-lama-roboh-terbengkalai-2-tahun-ratusan-siswa-ngungsi	c8537df0-902d-45bd-8db9-5729e6869541	\N	\N	2026-07-22 09:57:02.309132+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI"}	{siswa,sdn,kebayoran,lama,roboh}	\N	0	t	f	2026-07-22 09:57:02.309132+00	2026-07-22 09:57:02.309132+00
8f313ee7-90d7-4bfa-9896-dd2ecd03670c	rss	https://www.cnnindonesia.com/nasional/20260722120556-20-1383557/gempa-magnitudo-56-di-gayo-lues-aceh-getaran-sampai-medan	article	Gempa Magnitudo 5,6 di Gayo Lues Aceh, Getaran Sampai Medan\n\n<img src="https://akcdn.detik.net.id/visual/2019/11/16/b3e62e4b-2f8e-464f-baf0-ff9778ac6d64_169.jpeg?w=360&amp;q=90" /> Gempa magnitudo 5,6 mengguncang Gayo Lues, Aceh, pada Rabu (22/7). Getaran dirasakan hingga Medan. BMKG mencatat lima gempa susulan, tanpa potensi tsunami.	Gempa Magnitudo 5,6 di Gayo Lues Aceh, Getaran Sampai Medan <img src=" /> Gempa magnitudo 5,6 mengguncang Gayo Lues, Aceh, pada Rabu (22/7). Getaran dirasakan hingga Medan. BMKG mencatat lima gempa susulan, tanpa potensi tsunami.	\N	https://www.cnnindonesia.com/nasional/20260722120556-20-1383557/gempa-magnitudo-56-di-gayo-lues-aceh-getaran-sampai-medan	c8537df0-902d-45bd-8db9-5729e6869541	\N	\N	2026-07-22 09:57:02.342667+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI"}	{gempa,magnitudo,gayo,lues,aceh}	\N	0	t	f	2026-07-22 09:57:02.342667+00	2026-07-22 09:57:02.342667+00
9e6eb531-801e-4524-a090-1bac628f877c	rss	https://www.cnnindonesia.com/nasional/20260720185859-22-1382855/foto-evakuasi-jenazah-korban-km-nurul-salsa-yang-karam-di-sulsel	article	FOTO: Evakuasi Jenazah Korban KM Nurul Salsa yang Karam di Sulsel\n\n<img src="https://akcdn.detik.net.id/visual/2026/07/22/evakuasi-korban-km-nurul-salsa-1784695523822_169.jpeg?w=360&amp;q=90" /> Dua jenazah korban kecelakaan KM Nurul Salsa ditemukan pada hari ketujuh operasi SAR dan dievakuasi ke Pelabuhan Soekarno-Hatta, Makassar.	FOTO: Evakuasi Jenazah Korban KM Nurul Salsa yang Karam di Sulsel <img src=" /> Dua jenazah korban kecelakaan KM Nurul Salsa ditemukan pada hari ketujuh operasi SAR dan dievakuasi ke Pelabuhan Soekarno-Hatta, Makassar.	\N	https://www.cnnindonesia.com/nasional/20260720185859-22-1382855/foto-evakuasi-jenazah-korban-km-nurul-salsa-yang-karam-di-sulsel	c8537df0-902d-45bd-8db9-5729e6869541	\N	\N	2026-07-22 09:57:02.174576+00	0	0	0	0	0	neutral	0	\N	{Umum}	{jenazah,korban,nurul,salsa,foto}	\N	0	t	f	2026-07-22 09:57:02.174576+00	2026-07-22 10:19:05.282662+00
ac29f49e-9d7d-4789-b900-493c99887c33	rss	https://www.cnnindonesia.com/nasional/20260722123904-20-1383569/sudaryono-kepala-bgn-pengganti-nanik-berharta-rp3139-miliar	article	Sudaryono Kepala BGN Pengganti Nanik Berharta Rp31,39 Miliar\n\n<img src="https://akcdn.detik.net.id/visual/2026/07/22/sudaryono-1784694379877_169.png?w=360&amp;q=90" /> Sudaryono ditunjuk sebagai Kepala Badan Gizi Nasional, menggantikan Nanik S Deyang, tercatat memiliki harta Rp31,39 miliar.	Sudaryono Kepala BGN Pengganti Nanik Berharta Rp31,39 Miliar <img src=" /> Sudaryono ditunjuk sebagai Kepala Badan Gizi Nasional, menggantikan Nanik S Deyang, tercatat memiliki harta Rp31,39 miliar.	\N	https://www.cnnindonesia.com/nasional/20260722123904-20-1383569/sudaryono-kepala-bgn-pengganti-nanik-berharta-rp3139-miliar	c8537df0-902d-45bd-8db9-5729e6869541	\N	\N	2026-07-22 09:57:02.213934+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI"}	{sudaryono,kepala,nanik,miliar,bgn}	\N	0	t	f	2026-07-22 09:57:02.213934+00	2026-07-22 10:19:05.318078+00
9934a173-be36-425e-b861-5b3d7946d5ae	twitter	tw_8180021	post	Sistem Social Intelligence Engine (SCIE) mampu memetakan hubungan antar entitas dan komunitas pengguna di berbagai jaringan digital.	Sistem Social Intelligence Engine (SCIE) mampu memetakan hubungan antar entitas dan komunitas pengguna di berbagai jaringan digital.	\N	https://x.com/scie_official/status/tw_8180021	12cc99f4-3fe9-4d08-b686-b8c0f5cc9e37	\N	\N	2026-07-22 09:57:02.235252+00	919	5	321	9154	0	neutral	0	\N	{"Teknologi & AI","Sosial & Budaya"}	{sistem,social,intelligence,engine,scie}	\N	5.08	t	f	2026-07-22 09:57:02.235252+00	2026-07-22 09:57:02.235252+00
2bb2c28f-b307-400c-a4ea-59bfc2da44fb	twitter	tw_2866793	post	Teknologi AI berkembang sangat pesat di Indonesia. Banyak startup lokal yang mulai memanfaatkan LLM dan Knowledge Graph untuk analisis data bisnis.	Teknologi AI berkembang sangat pesat di Indonesia. Banyak startup lokal yang mulai memanfaatkan LLM dan Knowledge Graph untuk analisis data bisnis.	\N	https://x.com/tech_indo/status/tw_2866793	9a809d23-af44-4980-a970-3b4e142ee14c	\N	\N	2026-07-22 09:57:02.255153+00	362	17	100	2828	0	positive	1	\N	{"Teknologi & AI","Ekonomi & Bisnis"}	{teknologi,berkembang,pesat,indonesia,banyak}	\N	1.83	t	f	2026-07-22 09:57:02.255153+00	2026-07-22 09:57:02.255153+00
d3046bc1-c668-4d6c-860f-47538474e117	rss	https://www.cnnindonesia.com/nasional/20260722131652-20-1383606/gubernur-dki-minta-maaf-sdn-kebayoran-lama-roboh-terbengkalai-2-tahun	article	Gubernur DKI Minta Maaf SDN Kebayoran Lama Roboh Terbengkalai 2 Tahun\n\n<img src="https://akcdn.detik.net.id/visual/2026/05/19/gubernur-dki-jakarta-pramono-anung-1779165561037_169.jpeg?w=360&amp;q=90" /> Gubernur DKI Jakarta Pramono Anung minta maaf atas robohnya SDN Kebayoran Lama Selatan 09 Pagi. Ia berjanji segera membangun kembali demi kenyamanan siswa.	Gubernur DKI Minta Maaf SDN Kebayoran Lama Roboh Terbengkalai 2 Tahun <img src=" /> Gubernur DKI Jakarta Pramono Anung minta maaf atas robohnya SDN Kebayoran Lama Selatan 09 Pagi. Ia berjanji segera membangun kembali demi kenyamanan siswa.	\N	https://www.cnnindonesia.com/nasional/20260722131652-20-1383606/gubernur-dki-minta-maaf-sdn-kebayoran-lama-roboh-terbengkalai-2-tahun	c8537df0-902d-45bd-8db9-5729e6869541	\N	\N	2026-07-22 09:57:02.160572+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI"}	{gubernur,dki,minta,maaf,sdn}	\N	0	t	f	2026-07-22 09:57:02.160572+00	2026-07-22 10:19:05.223568+00
82e66f1c-7116-4ea5-ba57-fd62db7b3554	rss	https://www.cnnindonesia.com/nasional/20260722125319-32-1383588/daftar-lengkap-5-pejabat-baru-kejagung-yang-ditunjuk-prabowo	article	Daftar Lengkap 5 Pejabat Baru Kejagung yang Ditunjuk Prabowo\n\n<img src="https://akcdn.detik.net.id/visual/2023/08/15/kejaksaan-agung_169.png?w=360&amp;q=90" /> Presiden Prabowo Subianto terbitkan Keppres pengangkatan sejumlah pejabat di Kejaksaan Agung. Berikut daftarnya.	Daftar Lengkap 5 Pejabat Baru Kejagung yang Ditunjuk Prabowo <img src=" /> Presiden Prabowo Subianto terbitkan Keppres pengangkatan sejumlah pejabat di Kejaksaan Agung. Berikut daftarnya.	\N	https://www.cnnindonesia.com/nasional/20260722125319-32-1383588/daftar-lengkap-5-pejabat-baru-kejagung-yang-ditunjuk-prabowo	c8537df0-902d-45bd-8db9-5729e6869541	\N	\N	2026-07-22 09:57:02.1977+00	0	0	0	0	0	neutral	0	\N	{"Politik & Pemerintahan"}	{pejabat,prabowo,daftar,lengkap,baru}	\N	0	t	f	2026-07-22 09:57:02.1977+00	2026-07-22 10:19:05.253536+00
31ba4bc5-91cd-437c-9b53-2dd87bbf36f3	rss	https://www.cnnindonesia.com/nasional/20260722114821-20-1383542/daftar-penerima-adhi-makayasa-2026	article	Daftar Penerima Adhi Makayasa 2026\n\n<img src="https://akcdn.detik.net.id/visual/2025/07/23/prabowo-lantik-2000-taruna-akmil-akpol-jadi-perwira-tni-polri-1753236153972_169.jpeg?w=360&amp;q=90" /> Sebanyak empat perwira meraih penghargaan Adhi Makayasa 2026 sebagai lulusan terbaik Akademi TNI dan Akademi Kepolisian.	Daftar Penerima Adhi Makayasa 2026 <img src=" /> Sebanyak empat perwira meraih penghargaan Adhi Makayasa 2026 sebagai lulusan terbaik Akademi TNI dan Akademi Kepolisian.	\N	https://www.cnnindonesia.com/nasional/20260722114821-20-1383542/daftar-penerima-adhi-makayasa-2026	c8537df0-902d-45bd-8db9-5729e6869541	\N	\N	2026-07-22 09:57:02.376907+00	0	0	0	0	0	positive	1	\N	{"Teknologi & AI","Ekonomi & Bisnis","Hukum & Keamanan"}	{adhi,makayasa,akademi,daftar,penerima}	\N	0	t	f	2026-07-22 09:57:02.376907+00	2026-07-22 09:57:02.376907+00
1d1990d6-d914-405b-9bc9-3ff4a4caaf3e	rss	https://www.cnnindonesia.com/nasional/20260722113253-12-1383537/densus-88-tangkap-penyebar-propaganda-teror-di-bandar-lampung	article	Densus 88 Tangkap Penyebar Propaganda Teror di Bandar Lampung\n\n<img src="https://akcdn.detik.net.id/visual/2024/08/01/densus-88-antiteror-mabes-polri-menangkap-tiga-orang-terduga-teroris-di-kota-batu-3_169.jpeg?w=360&amp;q=90" /> Densus 88 Antiteror Polri menangkap seorang pria di Bandar Lampung diduga terlibat dalam aktivitas propaganda, rekrutmen hingga penghasutan lewat media sosial.	Densus 88 Tangkap Penyebar Propaganda Teror di Bandar Lampung <img src=" /> Densus 88 Antiteror Polri menangkap seorang pria di Bandar Lampung diduga terlibat dalam aktivitas propaganda, rekrutmen hingga penghasutan lewat media sosial.	\N	https://www.cnnindonesia.com/nasional/20260722113253-12-1383537/densus-88-tangkap-penyebar-propaganda-teror-di-bandar-lampung	c8537df0-902d-45bd-8db9-5729e6869541	\N	\N	2026-07-22 09:57:02.402126+00	0	0	0	0	0	neutral	0	\N	{"Sosial & Budaya"}	{densus,propaganda,bandar,lampung,tangkap}	\N	0	t	f	2026-07-22 09:57:02.402126+00	2026-07-22 09:57:02.402126+00
9e35b5b8-5338-450a-afaf-e42a939c6371	twitter	tw_6553998	post	Layanan publik digital di tingkat pemerintah daerah kini semakin terintegrasi dengan teknologi AI dan analisis sentimen warga.	Layanan publik digital di tingkat pemerintah daerah kini semakin terintegrasi dengan teknologi AI dan analisis sentimen warga.	\N	https://x.com/gov_tech_id/status/tw_6553998	20c345da-5a68-47c3-9a2f-87cc1c6bf89d	\N	\N	2026-07-22 09:57:02.42493+00	434	23	111	4010	0	positive	1	\N	{"Teknologi & AI","Politik & Pemerintahan","Sosial & Budaya"}	{layanan,publik,digital,tingkat,pemerintah}	\N	2.12	t	f	2026-07-22 09:57:02.42493+00	2026-07-22 09:57:02.42493+00
3c67725c-a6c2-4830-861a-328c1e091459	twitter	tw_6858608	post	Pentingnya transparansi dan pengolahan informasi digital di media sosial agar masyarakat tidak terjerat isu hoaks dan disinformasi.	Pentingnya transparansi dan pengolahan informasi digital di media sosial agar masyarakat tidak terjerat isu hoaks dan disinformasi.	\N	https://x.com/cyber_watch/status/tw_6858608	838d83a1-3fd1-49db-98e9-1b380370b23c	\N	\N	2026-07-22 09:57:02.441699+00	565	20	211	7626	0	negative	-1	\N	{"Teknologi & AI","Sosial & Budaya"}	{pentingnya,transparansi,pengolahan,informasi,digital}	\N	3.36	t	f	2026-07-22 09:57:02.441699+00	2026-07-22 09:57:02.441699+00
a96b9bae-0476-4511-b010-0ed9796f1934	rss	https://www.cnbcindonesia.com/news/20260722154823-4-752959/terbaru-ri-berhasil-uji-produksi-minyak-sumur-akasia-maju-410-barel	article	Terbaru! RI Berhasil Uji Produksi Minyak Sumur Akasia Maju 410 Barel\n\n<img src="https://awsimages.detik.net.id/visual/2023/12/16/pt-pertamina-ep-temukan-2-sumber-migar-baru-pt-pertamina-ep-1_169.jpeg?w=1200&amp;q=90" /> Sumur pengembangan Akasia Maju yang dioperasikan PT Pertamina EP berhasol uji produksi 410,4 barel	Terbaru! RI Berhasil Uji Produksi Minyak Sumur Akasia Maju 410 Barel <img src=" /> Sumur pengembangan Akasia Maju yang dioperasikan PT Pertamina EP berhasol uji produksi 410,4 barel	\N	https://www.cnbcindonesia.com/news/20260722154823-4-752959/terbaru-ri-berhasil-uji-produksi-minyak-sumur-akasia-maju-410-barel	aafb1e20-0136-41ff-8a49-5c469a422682	\N	\N	2026-07-22 10:19:04.227881+00	0	0	0	0	0	positive	1	\N	{Umum}	{uji,produksi,sumur,akasia,maju}	\N	0	t	f	2026-07-22 10:19:04.227881+00	2026-07-22 10:19:04.227881+00
3930d0be-096e-4b60-a3e7-aee92a0f3b24	rss	https://www.cnbcindonesia.com/news/20260722162954-7-752988/terjadi-di-jakarta-harga-telur-naik-usai-libur-sekolah-kini-rp30000	article	Terjadi di Jakarta: Harga Telur Naik Usai Libur Sekolah, Kini Rp30.000\n\n<img src="https://awsimages.detik.net.id/visual/2026/07/22/harga-telur-ayam-di-pasar-tradisional-di-pasar-kebayoran-lama-jakarta-kembali-mengalami-kenaikan-setelah-masa-libur-sekolah-be-1784711754630_169.jpeg?w=1200&amp;q=90" /> Harga telur ayam di Pasar Kebayoran Lama naik hingga Rp29.000-Rp30.000/kg usai libur sekolah berakhir, membuat daya beli masyarakat mulai menurun.	Terjadi di Jakarta: Harga Telur Naik Usai Libur Sekolah, Kini Rp30.000 <img src=" /> Harga telur ayam di Pasar Kebayoran Lama naik hingga Rp29.000-Rp30.000/kg usai libur sekolah berakhir, membuat daya beli masyarakat mulai menurun.	\N	https://www.cnbcindonesia.com/news/20260722162954-7-752988/terjadi-di-jakarta-harga-telur-naik-usai-libur-sekolah-kini-rp30000	aafb1e20-0136-41ff-8a49-5c469a422682	\N	\N	2026-07-22 10:19:04.260641+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI","Ekonomi & Bisnis","Sosial & Budaya"}	{harga,telur,naik,usai,libur}	\N	0	t	f	2026-07-22 10:19:04.260641+00	2026-07-22 10:19:04.260641+00
92020bb5-a802-4950-86e2-ec920c118065	rss	https://www.cnbcindonesia.com/news/20260722165543-4-753004/ribuan-asn-pu-main-judol-manipulasi-absen-menteri-dody-lapor-bos-bkn	article	Ribuan ASN PU Main Judol-Manipulasi Absen, Menteri Dody Lapor Bos BKN\n\n<img src="https://awsimages.detik.net.id/visual/2026/07/22/menteri-pekerjaan-umum-pu-dody-hanggodo-saat-ditemui-di-kantor-kementerian-pekerjaan-umum-jakarta-rabu-2272026-1784705530566_169.jpeg?w=1200&amp;q=90" /> Menteri PU Dody Hanggodo bertemu Kepala BKN Zudan Arif untuk membahas penguatan ASN di Kementerian PU. Ini masalah ASN di PU.	Ribuan ASN PU Main Judol-Manipulasi Absen, Menteri Dody Lapor Bos BKN <img src=" /> Menteri PU Dody Hanggodo bertemu Kepala BKN Zudan Arif untuk membahas penguatan ASN di Kementerian PU. Ini masalah ASN di PU.	\N	https://www.cnbcindonesia.com/news/20260722165543-4-753004/ribuan-asn-pu-main-judol-manipulasi-absen-menteri-dody-lapor-bos-bkn	aafb1e20-0136-41ff-8a49-5c469a422682	\N	\N	2026-07-22 10:19:04.293626+00	0	0	0	0	0	negative	-1	\N	{"Teknologi & AI"}	{asn,menteri,dody,bkn,ribuan}	\N	0	t	f	2026-07-22 10:19:04.293626+00	2026-07-22 10:19:04.293626+00
4cb55bb8-0574-4019-ade8-d8268e90cad1	rss	https://www.cnbcindonesia.com/news/20260722160503-4-752974/korupsi-proyek-desa-rp-913-juta-terbongkar-6-orang-ditangkap	article	Korupsi Proyek Desa Rp 913 Juta Terbongkar, 6 Orang Ditangkap\n\n<img src="https://awsimages.detik.net.id/visual/2026/07/22/punjab-rural-municipal-services-company-prmsc-1784712014714_169.png?w=1200&amp;q=90" /> Enam orang ditangkap dalam skandal korupsi proyek desa. Dugaan penggunaan material berkualitas rendah terungkap setelah inspeksi mendadak.	Korupsi Proyek Desa Rp 913 Juta Terbongkar, 6 Orang Ditangkap <img src=" /> Enam orang ditangkap dalam skandal korupsi proyek desa. Dugaan penggunaan material berkualitas rendah terungkap setelah inspeksi mendadak.	\N	https://www.cnbcindonesia.com/news/20260722160503-4-752974/korupsi-proyek-desa-rp-913-juta-terbongkar-6-orang-ditangkap	aafb1e20-0136-41ff-8a49-5c469a422682	\N	\N	2026-07-22 10:19:04.330418+00	0	0	0	0	0	negative	-1	\N	{"Hukum & Keamanan"}	{korupsi,proyek,desa,orang,ditangkap}	\N	0	t	f	2026-07-22 10:19:04.330418+00	2026-07-22 10:19:04.330418+00
2f4c3b1c-a549-4904-ac60-67db7cefb1ad	rss	https://www.cnbcindonesia.com/news/20260722160229-4-752970/jalur-maut-terus-makan-korban-143-penumpang-kapal-tewas-dan-hilang	article	Jalur Maut Terus Makan Korban, 143 Penumpang Kapal Tewas dan Hilang\n\n<img src="https://akcdn.detik.net.id/visual/2023/03/01/gaun-seorang-gadis-kecil-yang-diduga-tewas-dalam-tenggelamnya-kapal-migran-tertinggal-di-antara-puing-puing-kapal-di-pantai-te_169.jpeg?w=1200&amp;q=90" /> Tragedi di lepas pantai Mauritania: 143 pengungsi tewas atau hilang saat berusaha mencapai Eropa. UNHCR mendesak peningkatan akses pendidikan dan pekerjaan.	Jalur Maut Terus Makan Korban, 143 Penumpang Kapal Tewas dan Hilang <img src=" /> Tragedi di lepas pantai Mauritania: 143 pengungsi tewas atau hilang saat berusaha mencapai Eropa. UNHCR mendesak peningkatan akses pendidikan dan pekerjaan.	\N	https://www.cnbcindonesia.com/news/20260722160229-4-752970/jalur-maut-terus-makan-korban-143-penumpang-kapal-tewas-dan-hilang	aafb1e20-0136-41ff-8a49-5c469a422682	\N	\N	2026-07-22 09:57:01.427286+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI","Sosial & Budaya"}	{tewas,hilang,jalur,maut,terus}	\N	0	t	f	2026-07-22 09:57:01.427286+00	2026-07-22 10:19:04.313119+00
682a7c6a-0504-4e92-9b6b-dbcf326f2b87	rss	https://www.cnbcindonesia.com/news/20260722140335-4-752917/media-asing-sorot-nanik-mundur-dari-kepala-bgn-diganti-sudaryono	article	Media Asing Sorot Nanik Mundur dari Kepala BGN Diganti Sudaryono\n\n<img src="https://akcdn.detik.net.id/visual/2026/06/08/presiden-prabowo-subianto-melantik-kepala-kepala-bgn-nanik-sudaryati-deyang-di-istana-negara-jakarta-senin-862026-1780913946713_169.jpeg?w=1200&amp;q=90" /> Sejumlah media asing menyoroti pengunduran diri Nanik Deyang dari posisi Kepala BGN.	Media Asing Sorot Nanik Mundur dari Kepala BGN Diganti Sudaryono <img src=" /> Sejumlah media asing menyoroti pengunduran diri Nanik Deyang dari posisi Kepala BGN.	\N	https://www.cnbcindonesia.com/news/20260722140335-4-752917/media-asing-sorot-nanik-mundur-dari-kepala-bgn-diganti-sudaryono	aafb1e20-0136-41ff-8a49-5c469a422682	\N	\N	2026-07-22 09:57:01.65181+00	0	0	0	0	0	neutral	0	\N	{Umum}	{media,asing,nanik,kepala,bgn}	\N	0	t	f	2026-07-22 09:57:01.65181+00	2026-07-22 10:19:04.708933+00
a9bf7835-439b-41a8-934f-937bfe6e1ee8	rss	https://www.cnnindonesia.com/nasional/20260722164036-25-1383707/pasar-rakyat-budaya-jateng-2026-dibuka-suguhkan-ratusan-karya-seni	article	Pasar Rakyat dan Budaya Jateng 2026 Dibuka, Suguhkan Ratusan Karya Seni\n\n<img src="https://akcdn.detik.net.id/visual/2026/07/22/pemprov-jateng-1784712736973_169.jpeg?w=360&amp;q=90" /> Pasar Raya Jawa Tengah 2026 dibuka di Taman Budaya Surakarta, ajang ini menampilkan ratusan karya seni, pertunjukan, dan bazaar UMKM.	Pasar Rakyat dan Budaya Jateng 2026 Dibuka, Suguhkan Ratusan Karya Seni <img src=" /> Pasar Raya Jawa Tengah 2026 dibuka di Taman Budaya Surakarta, ajang ini menampilkan ratusan karya seni, pertunjukan, dan bazaar UMKM.	\N	https://www.cnnindonesia.com/nasional/20260722164036-25-1383707/pasar-rakyat-budaya-jateng-2026-dibuka-suguhkan-ratusan-karya-seni	c8537df0-902d-45bd-8db9-5729e6869541	\N	\N	2026-07-22 10:19:04.741189+00	0	0	0	0	0	neutral	0	\N	{"Ekonomi & Bisnis","Sosial & Budaya"}	{pasar,budaya,dibuka,ratusan,karya}	\N	0	t	f	2026-07-22 10:19:04.741189+00	2026-07-22 10:19:04.741189+00
a1fc4875-5398-4204-b9c4-2a5399c42ca0	rss	https://www.cnnindonesia.com/nasional/20260722170533-25-1383725/gubernur-jateng-dorong-tegal-business-forum-hasilkan-investasi-nyata	article	Gubernur Jateng Dorong Tegal Business Forum Hasilkan Investasi Nyata\n\n<img src="https://akcdn.detik.net.id/visual/2026/07/22/pemprov-jateng-1784714865834_169.jpeg?w=360&amp;q=90" /> ajang Tegal Business Forum 2026 yang mempertemukan pemerintah daerah, pelaku usaha, dan perbankan itu diharapkan mampu menumbuhkan perekonomian daerah.	Gubernur Jateng Dorong Tegal Business Forum Hasilkan Investasi Nyata <img src=" /> ajang Tegal Business Forum 2026 yang mempertemukan pemerintah daerah, pelaku usaha, dan perbankan itu diharapkan mampu menumbuhkan perekonomian daerah.	\N	https://www.cnnindonesia.com/nasional/20260722170533-25-1383725/gubernur-jateng-dorong-tegal-business-forum-hasilkan-investasi-nyata	c8537df0-902d-45bd-8db9-5729e6869541	\N	\N	2026-07-22 10:19:04.77835+00	0	0	0	0	0	neutral	0	\N	{"Ekonomi & Bisnis","Politik & Pemerintahan"}	{tegal,business,forum,daerah,gubernur}	\N	0	t	f	2026-07-22 10:19:04.77835+00	2026-07-22 10:19:04.77835+00
d81446cf-e7ec-4bf0-a969-8aa38f9e8779	rss	https://www.cnnindonesia.com/nasional/20260722155858-20-1383686/profil-donny-ermawan-dan-yos-petinggi-universitas-republik-indonesia	article	Profil Donny Ermawan dan Yos, Petinggi Universitas Republik Indonesia\n\n<img src="https://akcdn.detik.net.id/visual/2026/07/22/prabowo-lantik-donny-ermawan-jadi-gubernur-universitas-republik-indonesia-1784710023130_169.jpeg?w=360&amp;q=90" /> Presiden Prabowo melantik Donny Ermawan Taufanto dan Yos Sunitoyoso sebagai Gubernur dan Wakil Gubernur Universitas Republik Indonesia di Istana Kepresidenan.	Profil Donny Ermawan dan Yos, Petinggi Universitas Republik Indonesia <img src=" /> Presiden Prabowo melantik Donny Ermawan Taufanto dan Yos Sunitoyoso sebagai Gubernur dan Wakil Gubernur Universitas Republik Indonesia di Istana Kepresidenan.	\N	https://www.cnnindonesia.com/nasional/20260722155858-20-1383686/profil-donny-ermawan-dan-yos-petinggi-universitas-republik-indonesia	c8537df0-902d-45bd-8db9-5729e6869541	\N	\N	2026-07-22 10:19:04.816632+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI","Politik & Pemerintahan","Sosial & Budaya"}	{donny,ermawan,yos,universitas,republik}	\N	0	t	f	2026-07-22 10:19:04.816632+00	2026-07-22 10:19:04.816632+00
33fb6ff2-a7ca-4793-96ba-bf46127c0d39	rss	https://www.cnnindonesia.com/nasional/20260722164429-12-1383721/prabowo-teken-keppres-leonard-eben-ezer-jadi-jampidum	article	Prabowo Teken Keppres Leonard Eben Ezer Jadi Jampidum\n\n<img src="https://akcdn.detik.net.id/visual/2021/11/09/leonard-eben-ezer-simanjuntak_169.jpeg?w=360&amp;q=90" /> Presiden Prabowo Subianto menandatangani Keppres pengangkatan pejabat baru di Kejaksaan Agung, termasuk Jaksa Agung Muda Bidang Tindak Pidana Umum (Jampidum).	Prabowo Teken Keppres Leonard Eben Ezer Jadi Jampidum <img src=" /> Presiden Prabowo Subianto menandatangani Keppres pengangkatan pejabat baru di Kejaksaan Agung, termasuk Jaksa Agung Muda Bidang Tindak Pidana Umum (Jampidum).	\N	https://www.cnnindonesia.com/nasional/20260722164429-12-1383721/prabowo-teken-keppres-leonard-eben-ezer-jadi-jampidum	c8537df0-902d-45bd-8db9-5729e6869541	\N	\N	2026-07-22 10:19:04.853256+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI","Politik & Pemerintahan"}	{prabowo,keppres,jampidum,agung,teken}	\N	0	t	f	2026-07-22 10:19:04.853256+00	2026-07-22 10:19:04.853256+00
d2cc684d-deb7-4448-8a25-62775c3d7cbd	rss	https://www.cnnindonesia.com/nasional/20260722161418-24-1383694/palang-perlintasan-tak-ditutup-truk-nyaris-tabrak-ka-brantas	article	Palang Perlintasan Tak Ditutup, Truk Nyaris Tabrak KA Brantas\n\n<img src="https://akcdn.detik.net.id/visual/2026/07/22/thumbnail-video-1784711926321_169.jpeg?w=360&amp;q=90" /> Penjaga perlintasan kereta api (KA)Simpang Mengkreng, Kecamatan Purwoasri, Kabupaten Kediri, diduga tertidur saat KA Brantas melintas.	Palang Perlintasan Tak Ditutup, Truk Nyaris Tabrak KA Brantas <img src=" /> Penjaga perlintasan kereta api (KA)Simpang Mengkreng, Kecamatan Purwoasri, Kabupaten Kediri, diduga tertidur saat KA Brantas melintas.	\N	https://www.cnnindonesia.com/nasional/20260722161418-24-1383694/palang-perlintasan-tak-ditutup-truk-nyaris-tabrak-ka-brantas	c8537df0-902d-45bd-8db9-5729e6869541	\N	\N	2026-07-22 10:19:04.883856+00	0	0	0	0	0	neutral	0	\N	{Umum}	{perlintasan,brantas,palang,tak,ditutup}	\N	0	t	f	2026-07-22 10:19:04.883856+00	2026-07-22 10:19:04.883856+00
bcb2c8f5-9d24-4c1e-b230-00e3b7aa4d8d	rss	https://www.cnbcindonesia.com/news/20260722140508-4-752918/jepang-catat-hari-sangat-kejam-suhu-mendidih-tembus-40-derajat	article	Jepang Catat 'Hari Sangat Kejam', Suhu Mendidih-Tembus 40 Derajat\n\n<img src="https://akcdn.detik.net.id/visual/2025/08/05/gelombang-panas-melanda-sejumlah-wilayah-di-jepang-selasa-582025-waktu-setempat-1754397161423_169.jpeg?w=1200&amp;q=90" /> Jepang mencatat rekor "hari panas sangat kejam" dengan suhu di atas 40°C. Gelombang panas ekstrem ini berdampak pada kesehatan	Jepang Catat 'Hari Sangat Kejam', Suhu Mendidih-Tembus 40 Derajat <img src=" /> Jepang mencatat rekor "hari panas sangat kejam" dengan suhu di atas 40°C. Gelombang panas ekstrem ini berdampak pada kesehatan	\N	https://www.cnbcindonesia.com/news/20260722140508-4-752918/jepang-catat-hari-sangat-kejam-suhu-mendidih-tembus-40-derajat	aafb1e20-0136-41ff-8a49-5c469a422682	\N	\N	2026-07-22 09:57:01.42483+00	0	0	0	0	0	neutral	0	\N	{"Sosial & Budaya"}	{jepang,hari,kejam,suhu,panas}	\N	0	t	f	2026-07-22 09:57:01.42483+00	2026-07-22 10:19:04.360311+00
e50bbdef-787b-41cf-9044-820ce0af5710	rss	https://www.cnbcindonesia.com/news/20260722163614-4-752986/menteri-dody-temukan-praktik-surat-cuti-bodong-manipulasi-absen-di-pu	article	Menteri Dody Temukan Praktik Surat Cuti Bodong-Manipulasi Absen di PU\n\n<img src="https://akcdn.detik.net.id/visual/2026/07/22/menteri-pekerjaan-umum-pu-dody-hanggodo-saat-ditemui-di-kantor-kementerian-pekerjaan-umum-jakarta-rabu-2272026-1784705530566_169.jpeg?w=1200&amp;q=90" /> Menteri PU Dody Hanggodo mengungkap masalah ASN di Kementerian PU, termasuk absensi dan dugaan cuti palsu.	Menteri Dody Temukan Praktik Surat Cuti Bodong-Manipulasi Absen di PU <img src=" /> Menteri PU Dody Hanggodo mengungkap masalah ASN di Kementerian PU, termasuk absensi dan dugaan cuti palsu.	\N	https://www.cnbcindonesia.com/news/20260722163614-4-752986/menteri-dody-temukan-praktik-surat-cuti-bodong-manipulasi-absen-di-pu	aafb1e20-0136-41ff-8a49-5c469a422682	\N	\N	2026-07-22 09:57:01.216417+00	0	0	0	0	0	negative	-1	\N	{Umum}	{menteri,dody,cuti,temukan,praktik}	\N	0	t	f	2026-07-22 09:57:01.216417+00	2026-07-22 10:19:04.440066+00
dd6f59de-4436-4ab4-8dd1-78c524c839c8	rss	https://www.cnbcindonesia.com/news/20260722145520-4-752934/jadi-kepala-bgn-sudaryono-lepas-jabatan-wamentan	article	Jadi Kepala BGN, Sudaryono Lepas Jabatan Wamentan\n\n<img src="https://akcdn.detik.net.id/visual/2026/07/22/wakil-menteri-pertanian-wamentan-sudaryono-saat-tiba-di-istana-merdeka-jakarta-rabu-2272026-1784705977454_169.jpeg?w=1200&amp;q=90" /> Sudaryono mengatakan, dirinya akan melepaskan jabatan Wakil Menteri Pertanian yang saat ini diembannya. Dia tidak diperbolehkan rangkap jabatan.	Jadi Kepala BGN, Sudaryono Lepas Jabatan Wamentan <img src=" /> Sudaryono mengatakan, dirinya akan melepaskan jabatan Wakil Menteri Pertanian yang saat ini diembannya. Dia tidak diperbolehkan rangkap jabatan.	\N	https://www.cnbcindonesia.com/news/20260722145520-4-752934/jadi-kepala-bgn-sudaryono-lepas-jabatan-wamentan	aafb1e20-0136-41ff-8a49-5c469a422682	\N	\N	2026-07-22 09:57:01.691719+00	0	0	0	0	0	neutral	0	\N	{Umum}	{jabatan,sudaryono,jadi,kepala,bgn}	\N	0	t	f	2026-07-22 09:57:01.691719+00	2026-07-22 10:19:04.729152+00
1642e118-d110-4ce8-b475-f3dc5485bd0f	rss	https://www.cnnindonesia.com/nasional/20260722164737-25-1383720/terima-dubes-iran-luthfi-sampaikan-duka-atas-wafatnya-ali-khamenei	article	Terima Dubes Iran, Luthfi Sampaikan Duka atas Wafatnya Ali Khamenei\n\n<img src="https://akcdn.detik.net.id/visual/2026/07/22/pemprov-jateng-1784712852635_169.jpeg?w=360&amp;q=90" /> Gubernur Jateng Ahmad Luthfi menyampaikan belasungkawa atas wafatnya Ali Khamenei dan pesan perdamaian dari Presiden Prabowo kepada Dubes Iran.	Terima Dubes Iran, Luthfi Sampaikan Duka atas Wafatnya Ali Khamenei <img src=" /> Gubernur Jateng Ahmad Luthfi menyampaikan belasungkawa atas wafatnya Ali Khamenei dan pesan perdamaian dari Presiden Prabowo kepada Dubes Iran.	\N	https://www.cnnindonesia.com/nasional/20260722164737-25-1383720/terima-dubes-iran-luthfi-sampaikan-duka-atas-wafatnya-ali-khamenei	c8537df0-902d-45bd-8db9-5729e6869541	\N	\N	2026-07-22 10:19:04.995403+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI","Politik & Pemerintahan"}	{dubes,iran,luthfi,atas,wafatnya}	\N	0	t	f	2026-07-22 10:19:04.995403+00	2026-07-22 10:19:04.995403+00
36f82a37-06a5-43ca-aa0e-f3c71021969f	rss	https://www.cnnindonesia.com/nasional/20260722132244-12-1383603/21-saksi-diperiksa-dugaan-kelebihan-muatan-km-nurul-salsa	article	21 Saksi Diperiksa Dugaan Kelebihan Muatan KM Nurul Salsa\n\n<img src="https://akcdn.detik.net.id/visual/2026/07/22/evakuasi-korban-km-nurul-salsa-1784695523907_169.jpeg?w=360&amp;q=90" /> Pihak kepolisian masih menyelidiki dugaan kelalaian atas tenggelamnya KM Nurul Salsa di Perairan Kabupaten Kepulauan Selayar, Sulawesi Selatan.	21 Saksi Diperiksa Dugaan Kelebihan Muatan KM Nurul Salsa <img src=" /> Pihak kepolisian masih menyelidiki dugaan kelalaian atas tenggelamnya KM Nurul Salsa di Perairan Kabupaten Kepulauan Selayar, Sulawesi Selatan.	\N	https://www.cnnindonesia.com/nasional/20260722132244-12-1383603/21-saksi-diperiksa-dugaan-kelebihan-muatan-km-nurul-salsa	c8537df0-902d-45bd-8db9-5729e6869541	\N	\N	2026-07-22 10:19:05.049823+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI","Hukum & Keamanan"}	{dugaan,nurul,salsa,saksi,diperiksa}	\N	0	t	f	2026-07-22 10:19:05.049823+00	2026-07-22 10:19:05.049823+00
fc2dfedf-07cf-4138-8a7c-ef0ebaeba2f3	rss	https://www.cnnindonesia.com/nasional/20260722133155-22-1383607/foto-upacara-prasetya-perwira-tni-polri	article	FOTO: Upacara Prasetya Perwira TNI-Polri\n\n<img src="https://akcdn.detik.net.id/visual/2026/07/22/upacara-prasetya-perwira-tni-polri-1784701860928_169.jpeg?w=360&amp;q=90" /> Presiden Prabowo Subianto melantik dan mengambil sumpah 1.177 calon perwira remaja (capaja) TNI dan Polri.	FOTO: Upacara Prasetya Perwira TNI-Polri <img src=" /> Presiden Prabowo Subianto melantik dan mengambil sumpah 1.177 calon perwira remaja (capaja) TNI dan Polri.	\N	https://www.cnnindonesia.com/nasional/20260722133155-22-1383607/foto-upacara-prasetya-perwira-tni-polri	c8537df0-902d-45bd-8db9-5729e6869541	\N	\N	2026-07-22 09:57:01.999798+00	0	0	0	0	0	neutral	0	\N	{"Politik & Pemerintahan"}	{perwira,tni,polri,foto,upacara}	\N	0	t	f	2026-07-22 09:57:01.999798+00	2026-07-22 10:19:05.081347+00
ef2da995-ce21-4db2-9b98-6b0f3168efb6	rss	https://www.cnnindonesia.com/nasional/20260722151755-20-1383673/prabowo-lantik-donny-ermawan-gubernur-universitas-republik-indonesia	article	Prabowo Lantik Donny Ermawan Gubernur Universitas Republik Indonesia\n\n<img src="https://akcdn.detik.net.id/visual/2026/07/22/prabowo-lantik-donny-ermawan-gubernur-universitas-republik-indonesia-1784709013305_169.png?w=360&amp;q=90" /> Presiden RI Prabowo Subianto melantik Donny Ermawan Taufanto sebagai Gubernur Universitas Republik Indonesia (URI).	Prabowo Lantik Donny Ermawan Gubernur Universitas Republik Indonesia <img src=" /> Presiden RI Prabowo Subianto melantik Donny Ermawan Taufanto sebagai Gubernur Universitas Republik Indonesia (URI).	\N	https://www.cnnindonesia.com/nasional/20260722151755-20-1383673/prabowo-lantik-donny-ermawan-gubernur-universitas-republik-indonesia	c8537df0-902d-45bd-8db9-5729e6869541	\N	\N	2026-07-22 09:57:02.143367+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI","Politik & Pemerintahan","Sosial & Budaya"}	{prabowo,donny,ermawan,gubernur,universitas}	\N	0	t	f	2026-07-22 09:57:02.143367+00	2026-07-22 10:19:05.235245+00
ecf3f646-4cd1-46cd-af3d-b6e7e0bbb5d9	rss	https://www.cnnindonesia.com/nasional/20260722161828-12-1383702/polisi-olah-tkp-rumah-grand-polonia-medan-usai-ledakan	article	Polisi Olah TKP Rumah Grand Polonia Medan Usai Ledakan\n\n<img src="https://akcdn.detik.net.id/visual/2026/07/21/ledakan-di-rumah-grand-polonia-dua-korban-tewas-sudah-ditemukan-1784627622751_169.jpeg?w=360&amp;q=90" /> Polrestabes Medan melakukan olah TKP ledakan di rumah Grand Polonia yang menewaskan tiga orang.	Polisi Olah TKP Rumah Grand Polonia Medan Usai Ledakan <img src=" /> Polrestabes Medan melakukan olah TKP ledakan di rumah Grand Polonia yang menewaskan tiga orang.	\N	https://www.cnnindonesia.com/nasional/20260722161828-12-1383702/polisi-olah-tkp-rumah-grand-polonia-medan-usai-ledakan	c8537df0-902d-45bd-8db9-5729e6869541	\N	\N	2026-07-22 09:57:01.887746+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI","Hukum & Keamanan"}	{olah,tkp,rumah,grand,polonia}	\N	0	t	f	2026-07-22 09:57:01.887746+00	2026-07-22 10:19:04.927961+00
74fe7f61-7fda-4853-b311-1f49b0697849	rss	https://www.cnnindonesia.com/nasional/20260722144251-20-1383654/walhi-jatim-soal-kebakaran-tpa-benowo-surabaya-bukan-insiden-biasa	article	Walhi Jatim soal Kebakaran TPA Benowo Surabaya: Bukan Insiden Biasa\n\n<img src="https://akcdn.detik.net.id/visual/2026/07/20/kebakaran-tpa-benowo-surabaya-diduga-imbas-flare-suporter-1784532695781_169.jpeg?w=360&amp;q=90" /> Kebakaran di TPA Benowo Surabaya dinilai menunjukkan kegagalan pengelolaan sampah. Walhi Jatim mendesak evaluasi sistem open dumping.	Walhi Jatim soal Kebakaran TPA Benowo Surabaya: Bukan Insiden Biasa <img src=" /> Kebakaran di TPA Benowo Surabaya dinilai menunjukkan kegagalan pengelolaan sampah. Walhi Jatim mendesak evaluasi sistem open dumping.	\N	https://www.cnnindonesia.com/nasional/20260722144251-20-1383654/walhi-jatim-soal-kebakaran-tpa-benowo-surabaya-bukan-insiden-biasa	c8537df0-902d-45bd-8db9-5729e6869541	\N	\N	2026-07-22 09:57:01.93748+00	0	0	0	0	0	neutral	0	\N	{"Teknologi & AI"}	{walhi,jatim,kebakaran,tpa,benowo}	\N	0	t	f	2026-07-22 09:57:01.93748+00	2026-07-22 10:19:05.015453+00
8ee80d98-7525-4ff5-b1f1-a763b8ab166f	rss	https://www.cnnindonesia.com/nasional/20260722124027-22-1383572/foto-dilanda-kekeringan-warga-bangkalan-antre-bantuan-air	article	FOTO: Dilanda Kekeringan, Warga Bangkalan Antre Bantuan Air\n\n<img src="https://akcdn.detik.net.id/visual/2026/07/22/dilanda-kekeringan-warga-bangkalan-antre-bantuan-air-1784698767137_169.jpeg?w=360&amp;q=90" /> Krisis air bersih akibat kemarau panjang kian meluas di Bangkalan, Jawa Timur. Warga mengandalkan bantuan air bersih atau beli air dengan harga mahal.	FOTO: Dilanda Kekeringan, Warga Bangkalan Antre Bantuan Air <img src=" /> Krisis air bersih akibat kemarau panjang kian meluas di Bangkalan, Jawa Timur. Warga mengandalkan bantuan air bersih atau beli air dengan harga mahal.	\N	https://www.cnnindonesia.com/nasional/20260722124027-22-1383572/foto-dilanda-kekeringan-warga-bangkalan-antre-bantuan-air	c8537df0-902d-45bd-8db9-5729e6869541	\N	\N	2026-07-22 09:57:02.03787+00	0	0	0	0	0	negative	-1	\N	{"Teknologi & AI","Ekonomi & Bisnis"}	{air,warga,bangkalan,bantuan,bersih}	\N	0	t	f	2026-07-22 09:57:02.03787+00	2026-07-22 10:19:05.100348+00
104a8a74-cf67-43bb-9c81-739c0e304d44	twitter	tw_1449626	post	Teknologi AI berkembang sangat pesat di Indonesia. Banyak startup lokal yang mulai memanfaatkan LLM dan Knowledge Graph untuk analisis data bisnis.	Teknologi AI berkembang sangat pesat di Indonesia. Banyak startup lokal yang mulai memanfaatkan LLM dan Knowledge Graph untuk analisis data bisnis.	\N	https://x.com/tech_indo/status/tw_1449626	9a809d23-af44-4980-a970-3b4e142ee14c	\N	\N	2026-07-22 10:19:05.348391+00	362	11	107	3435	0	positive	1	\N	{"Teknologi & AI","Ekonomi & Bisnis"}	{teknologi,berkembang,pesat,indonesia,banyak}	\N	1.86	t	f	2026-07-22 10:19:05.348391+00	2026-07-22 10:19:05.348391+00
bb747984-986a-417c-947c-1f1212e575ac	twitter	tw_7215239	post	Sistem Social Intelligence Engine (SCIE) mampu memetakan hubungan antar entitas dan komunitas pengguna di berbagai jaringan digital.	Sistem Social Intelligence Engine (SCIE) mampu memetakan hubungan antar entitas dan komunitas pengguna di berbagai jaringan digital.	\N	https://x.com/scie_official/status/tw_7215239	12cc99f4-3fe9-4d08-b686-b8c0f5cc9e37	\N	\N	2026-07-22 10:19:05.369985+00	912	37	314	2720	0	neutral	0	\N	{"Teknologi & AI","Sosial & Budaya"}	{sistem,social,intelligence,engine,scie}	\N	5.19	t	f	2026-07-22 10:19:05.369985+00	2026-07-22 10:19:05.369985+00
0a8f9c21-9ecd-4f68-9461-256af47a72c0	twitter	tw_2350514	post	Pentingnya transparansi dan pengolahan informasi digital di media sosial agar masyarakat tidak terjerat isu hoaks dan disinformasi.	Pentingnya transparansi dan pengolahan informasi digital di media sosial agar masyarakat tidak terjerat isu hoaks dan disinformasi.	\N	https://x.com/cyber_watch/status/tw_2350514	838d83a1-3fd1-49db-98e9-1b380370b23c	\N	\N	2026-07-22 10:19:05.383658+00	566	30	229	8386	0	negative	-1	\N	{"Teknologi & AI","Sosial & Budaya"}	{pentingnya,transparansi,pengolahan,informasi,digital}	\N	3.6	t	f	2026-07-22 10:19:05.383658+00	2026-07-22 10:19:05.383658+00
845600ed-6ba9-4eae-8c99-682081a19119	twitter	tw_3318736	post	Layanan publik digital di tingkat pemerintah daerah kini semakin terintegrasi dengan teknologi AI dan analisis sentimen warga.	Layanan publik digital di tingkat pemerintah daerah kini semakin terintegrasi dengan teknologi AI dan analisis sentimen warga.	\N	https://x.com/gov_tech_id/status/tw_3318736	20c345da-5a68-47c3-9a2f-87cc1c6bf89d	\N	\N	2026-07-22 10:19:05.403918+00	438	7	109	8088	0	positive	1	\N	{"Teknologi & AI","Politik & Pemerintahan","Sosial & Budaya"}	{layanan,publik,digital,tingkat,pemerintah}	\N	2.01	t	f	2026-07-22 10:19:05.403918+00	2026-07-22 10:19:05.403918+00
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: public; Owner: scie
--

COPY public.refresh_tokens (id, user_id, token_hash, expires_at, is_revoked, created_at, user_agent, ip_address) FROM stdin;
b70d0033-f7c9-46da-aa34-ebc794eff094	00000000-0000-0000-0000-000000000002	65d558b563158547a13ea59614c90a45bee3682a7a010b09932c635ddddd58e8	2026-08-21 02:18:08.143335+00	f	2026-07-22 10:18:07.74359+00	curl/8.5.0	127.0.0.1
24a1c21c-015a-4eaa-a4d7-2b1384ccd4ec	00000000-0000-0000-0000-000000000002	8f08d15c9eda4ad2d5cfe374148034084fa579a6ab4eb46c7029ef8962eacf62	2026-08-21 02:42:39.129879+00	f	2026-07-22 10:42:38.73911+00	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	127.0.0.1
dedd96f9-7bbc-4264-ab09-f81e53b8dd4d	00000000-0000-0000-0000-000000000002	f4206d70eebeaf88c2821737904392ded1c3276a2611643ac4726be0df884938	2026-08-21 02:44:18.922166+00	f	2026-07-22 10:44:18.55818+00	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	127.0.0.1
\.


--
-- Data for Name: social_accounts; Type: TABLE DATA; Schema: public; Owner: scie
--

COPY public.social_accounts (id, platform, platform_id, username, display_name, bio, follower_count, following_count, post_count, is_verified, profile_image, location, language, account_age_days, bot_score, influence_score, community_id, collected_at, updated_at) FROM stdin;
4119984d-09e2-4d96-9c57-672c243b2d01	news	law	Antara News — Hukum	Antara News — Hukum	\N	0	0	0	f	\N	\N	\N	\N	0	0	\N	2026-07-21 17:28:04.560193+00	2026-07-21 17:28:04.758026+00
c29b0cad-cf1e-40be-b1d2-9d0f986841dc	news	politics	Antara News — Politik	Antara News — Politik	\N	0	0	0	f	\N	\N	\N	\N	0	0	\N	2026-07-21 17:28:03.972589+00	2026-07-21 17:28:04.292945+00
ec636367-716f-47e0-8cc7-242409a1bc03	news	economy	CNBC Indonesia	CNBC Indonesia	\N	0	0	0	f	\N	\N	\N	\N	0	0	\N	2026-07-21 17:28:04.309718+00	2026-07-21 17:28:05.414144+00
40001e07-40c6-44ab-aa57-90b1d7e3bba1	rss	Antara News	Antara News	Antara News	\N	0	0	0	f	\N	\N	\N	\N	0	0	\N	2026-07-22 09:57:00.696642+00	2026-07-22 09:57:00.696642+00
aafb1e20-0136-41ff-8a49-5c469a422682	rss	CNBC Indonesia	CNBC Indonesia	CNBC Indonesia	\N	0	0	0	f	\N	\N	\N	\N	0	0	\N	2026-07-22 09:57:01.216417+00	2026-07-22 09:57:01.216417+00
c8537df0-902d-45bd-8db9-5729e6869541	rss	CNN Indonesia	CNN Indonesia	CNN Indonesia	\N	0	0	0	f	\N	\N	\N	\N	0	0	\N	2026-07-22 09:57:01.848791+00	2026-07-22 09:57:01.848791+00
6e9c0ef4-3ed9-4abf-817b-fdebb740ee27	news	news	Antara News — Topik Utama	Antara News — Topik Utama	\N	0	0	0	f	\N	\N	\N	\N	0	0	\N	2026-07-21 17:28:03.566978+00	2026-07-21 17:28:03.955856+00
12cc99f4-3fe9-4d08-b686-b8c0f5cc9e37	twitter	scie_official	scie_official	SCIE Platform	\N	0	0	0	f	\N	\N	\N	\N	0	0	\N	2026-07-22 09:57:02.235252+00	2026-07-22 09:57:02.235252+00
9a809d23-af44-4980-a970-3b4e142ee14c	twitter	tech_indo	tech_indo	Tech Indonesia	\N	0	0	0	f	\N	\N	\N	\N	0	0	\N	2026-07-22 09:57:02.255153+00	2026-07-22 09:57:02.255153+00
20c345da-5a68-47c3-9a2f-87cc1c6bf89d	twitter	gov_tech_id	gov_tech_id	GovTech Indonesia	\N	0	0	0	f	\N	\N	\N	\N	0	0	\N	2026-07-22 09:57:02.42493+00	2026-07-22 09:57:02.42493+00
838d83a1-3fd1-49db-98e9-1b380370b23c	twitter	cyber_watch	cyber_watch	Cyber Watch ID	\N	0	0	0	f	\N	\N	\N	\N	0	0	\N	2026-07-22 09:57:02.441699+00	2026-07-22 09:57:02.441699+00
\.


--
-- Data for Name: topic_volume; Type: TABLE DATA; Schema: public; Owner: scie
--

COPY public.topic_volume ("time", topic, platform, count, sentiment_avg, engagement_sum) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: scie
--

COPY public.users (id, organization_id, email, username, hashed_password, full_name, role, is_active, is_verified, last_login, created_at, updated_at) FROM stdin;
00000000-0000-0000-0000-000000000002	00000000-0000-0000-0000-000000000001	admin@scie.com	admin	$2b$12$IfCep2qc1oIQaITu0lO3Xer8ESgoXkhrZR3KS.AylCT7gE23jshNa	SCIE Administrator	admin	t	t	2026-07-22 02:44:18.922401+00	2026-07-21 17:23:12.564109+00	2026-07-22 10:44:18.55818+00
\.


--
-- Name: bgw_job_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: scie
--

SELECT pg_catalog.setval('_timescaledb_catalog.bgw_job_id_seq', 1000, false);


--
-- Name: chunk_column_stats_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: scie
--

SELECT pg_catalog.setval('_timescaledb_catalog.chunk_column_stats_id_seq', 1, false);


--
-- Name: chunk_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: scie
--

SELECT pg_catalog.setval('_timescaledb_catalog.chunk_id_seq', 1, false);


--
-- Name: dimension_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: scie
--

SELECT pg_catalog.setval('_timescaledb_catalog.dimension_id_seq', 33, true);


--
-- Name: dimension_slice_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: scie
--

SELECT pg_catalog.setval('_timescaledb_catalog.dimension_slice_id_seq', 1, false);


--
-- Name: hypertable_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: scie
--

SELECT pg_catalog.setval('_timescaledb_catalog.hypertable_id_seq', 33, true);


--
-- Name: api_keys api_keys_key_hash_key; Type: CONSTRAINT; Schema: public; Owner: scie
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_key_hash_key UNIQUE (key_hash);


--
-- Name: api_keys api_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: scie
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_pkey PRIMARY KEY (id);


--
-- Name: data_sources data_sources_pkey; Type: CONSTRAINT; Schema: public; Owner: scie
--

ALTER TABLE ONLY public.data_sources
    ADD CONSTRAINT data_sources_pkey PRIMARY KEY (id);


--
-- Name: entities entities_normalized_name_type_key; Type: CONSTRAINT; Schema: public; Owner: scie
--

ALTER TABLE ONLY public.entities
    ADD CONSTRAINT entities_normalized_name_type_key UNIQUE (normalized_name, type);


--
-- Name: entities entities_pkey; Type: CONSTRAINT; Schema: public; Owner: scie
--

ALTER TABLE ONLY public.entities
    ADD CONSTRAINT entities_pkey PRIMARY KEY (id);


--
-- Name: hashtags hashtags_pkey; Type: CONSTRAINT; Schema: public; Owner: scie
--

ALTER TABLE ONLY public.hashtags
    ADD CONSTRAINT hashtags_pkey PRIMARY KEY (id);


--
-- Name: hashtags hashtags_text_platform_key; Type: CONSTRAINT; Schema: public; Owner: scie
--

ALTER TABLE ONLY public.hashtags
    ADD CONSTRAINT hashtags_text_platform_key UNIQUE (text, platform);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: scie
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_slug_key; Type: CONSTRAINT; Schema: public; Owner: scie
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_slug_key UNIQUE (slug);


--
-- Name: post_entities post_entities_pkey; Type: CONSTRAINT; Schema: public; Owner: scie
--

ALTER TABLE ONLY public.post_entities
    ADD CONSTRAINT post_entities_pkey PRIMARY KEY (post_id, entity_id);


--
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: scie
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: posts posts_platform_platform_id_key; Type: CONSTRAINT; Schema: public; Owner: scie
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_platform_platform_id_key UNIQUE (platform, platform_id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: scie
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_hash_key; Type: CONSTRAINT; Schema: public; Owner: scie
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_hash_key UNIQUE (token_hash);


--
-- Name: social_accounts social_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: scie
--

ALTER TABLE ONLY public.social_accounts
    ADD CONSTRAINT social_accounts_pkey PRIMARY KEY (id);


--
-- Name: social_accounts social_accounts_platform_platform_id_key; Type: CONSTRAINT; Schema: public; Owner: scie
--

ALTER TABLE ONLY public.social_accounts
    ADD CONSTRAINT social_accounts_platform_platform_id_key UNIQUE (platform, platform_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: scie
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: scie
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: scie
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: entity_mentions_ts_time_idx; Type: INDEX; Schema: public; Owner: scie
--

CREATE INDEX entity_mentions_ts_time_idx ON public.entity_mentions_ts USING btree ("time" DESC);


--
-- Name: idx_entities_name_trgm; Type: INDEX; Schema: public; Owner: scie
--

CREATE INDEX idx_entities_name_trgm ON public.entities USING gin (normalized_name public.gin_trgm_ops);


--
-- Name: idx_posts_author; Type: INDEX; Schema: public; Owner: scie
--

CREATE INDEX idx_posts_author ON public.posts USING btree (author_id);


--
-- Name: idx_posts_keywords; Type: INDEX; Schema: public; Owner: scie
--

CREATE INDEX idx_posts_keywords ON public.posts USING gin (keywords);


--
-- Name: idx_posts_platform; Type: INDEX; Schema: public; Owner: scie
--

CREATE INDEX idx_posts_platform ON public.posts USING btree (platform);


--
-- Name: idx_posts_sentiment; Type: INDEX; Schema: public; Owner: scie
--

CREATE INDEX idx_posts_sentiment ON public.posts USING btree (sentiment_label);


--
-- Name: idx_posts_text_search; Type: INDEX; Schema: public; Owner: scie
--

CREATE INDEX idx_posts_text_search ON public.posts USING gin (to_tsvector('indonesian'::regconfig, COALESCE(text, ''::text)));


--
-- Name: idx_posts_timestamp; Type: INDEX; Schema: public; Owner: scie
--

CREATE INDEX idx_posts_timestamp ON public.posts USING btree ("timestamp" DESC);


--
-- Name: idx_posts_topics; Type: INDEX; Schema: public; Owner: scie
--

CREATE INDEX idx_posts_topics ON public.posts USING gin (topics);


--
-- Name: idx_social_accounts_platform; Type: INDEX; Schema: public; Owner: scie
--

CREATE INDEX idx_social_accounts_platform ON public.social_accounts USING btree (platform, platform_id);


--
-- Name: platform_metrics_time_idx; Type: INDEX; Schema: public; Owner: scie
--

CREATE INDEX platform_metrics_time_idx ON public.platform_metrics USING btree ("time" DESC);


--
-- Name: topic_volume_time_idx; Type: INDEX; Schema: public; Owner: scie
--

CREATE INDEX topic_volume_time_idx ON public.topic_volume USING btree ("time" DESC);


--
-- Name: api_keys api_keys_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: scie
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: api_keys api_keys_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: scie
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: data_sources data_sources_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: scie
--

ALTER TABLE ONLY public.data_sources
    ADD CONSTRAINT data_sources_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: post_entities post_entities_entity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: scie
--

ALTER TABLE ONLY public.post_entities
    ADD CONSTRAINT post_entities_entity_id_fkey FOREIGN KEY (entity_id) REFERENCES public.entities(id) ON DELETE CASCADE;


--
-- Name: post_entities post_entities_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: scie
--

ALTER TABLE ONLY public.post_entities
    ADD CONSTRAINT post_entities_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- Name: posts posts_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: scie
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.social_accounts(id);


--
-- Name: posts posts_original_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: scie
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_original_post_id_fkey FOREIGN KEY (original_post_id) REFERENCES public.posts(id);


--
-- Name: posts posts_parent_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: scie
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_parent_post_id_fkey FOREIGN KEY (parent_post_id) REFERENCES public.posts(id);


--
-- Name: refresh_tokens refresh_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: scie
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: users users_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: scie
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict idxD4CC0E91mnSN4mRkUC34mthLBc1IiY62HfNdwY0Z4bU0qzcCZiaGCJOoZ8g4

