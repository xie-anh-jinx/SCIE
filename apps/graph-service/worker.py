"""
Graph Service Worker — Listens to stream:enriched_posts and updates Neo4j Knowledge Graph.
"""
import asyncio
import json
import os
import redis.asyncio as aioredis
import structlog

from ingesters.neo4j_ingester import Neo4jGraphIngester

log = structlog.get_logger()

REDIS_URL = os.getenv("REDIS_URL", "redis://localhost:6379/0")
STREAM_ENRICHED = os.getenv("REDIS_STREAM_ENRICHED_POSTS", "stream:enriched_posts")
NEO4J_URI = os.getenv("NEO4J_URI", "bolt://localhost:7687")
NEO4J_USER = os.getenv("NEO4J_USER", "neo4j")
NEO4J_PASSWORD = os.getenv("NEO4J_PASSWORD", "scie_neo4j_password")
CONSUMER_GROUP = "graph_workers_group"
CONSUMER_NAME = f"graph_worker_{os.getpid()}"


async def process_graph_stream():
    redis = aioredis.from_url(REDIS_URL, encoding="utf-8", decode_responses=True)
    ingester = Neo4jGraphIngester(uri=NEO4J_URI, user=NEO4J_USER, password=NEO4J_PASSWORD)

    log.info("Graph Service Worker starting", stream=STREAM_ENRICHED)

    try:
        await redis.xgroup_create(STREAM_ENRICHED, CONSUMER_GROUP, id="0", mkstream=True)
    except Exception:
        pass

    while True:
        try:
            entries = await redis.xreadgroup(
                groupname=CONSUMER_GROUP,
                consumername=CONSUMER_NAME,
                streams={STREAM_ENRICHED: ">"},
                count=10,
                block=2000,
            )

            if not entries:
                await asyncio.sleep(0.5)
                continue

            for stream_name, messages in entries:
                for msg_id, data in messages:
                    payload_raw = data.get("payload")
                    if payload_raw:
                        try:
                            enriched_post = json.loads(payload_raw)
                            await ingester.ingest_enriched_post(enriched_post)
                            await redis.xack(STREAM_ENRICHED, CONSUMER_GROUP, msg_id)
                        except Exception as e:
                            log.error("Failed graph ingestion", msg_id=msg_id, error=str(e))
                            await redis.xack(STREAM_ENRICHED, CONSUMER_GROUP, msg_id)

        except Exception as e:
            log.error("Error in graph worker loop", error=str(e))
            await asyncio.sleep(2)

if __name__ == "__main__":
    asyncio.run(process_graph_stream())
