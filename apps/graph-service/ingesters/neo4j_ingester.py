"""
Neo4j Graph Ingester — Converts enriched post payloads into Graph Nodes and Relationships.
"""
from typing import Any
import structlog
from neo4j import AsyncDriver, AsyncGraphDatabase

log = structlog.get_logger()


class Neo4jGraphIngester:
    def __init__(self, uri: str = "bolt://localhost:7687", user: str = "neo4j", password: str = "scie_neo4j_password"):
        self.uri = uri
        self.user = user
        self.password = password
        self.driver: AsyncDriver | None = None

    async def connect(self):
        if not self.driver:
            self.driver = AsyncGraphDatabase.driver(self.uri, auth=(self.user, self.password))
            await self.driver.verify_connectivity()
            log.info("Neo4j Ingester connected to Neo4j database")
            await self.init_schema()

    async def init_schema(self):
        """Create constraints and indexes for fast graph traversal."""
        assert self.driver is not None
        async with self.driver.session() as session:
            constraints = [
                "CREATE CONSTRAINT user_id IF NOT EXISTS FOR (u:User) REQUIRE u.id IS UNIQUE",
                "CREATE CONSTRAINT post_id IF NOT EXISTS FOR (p:Post) REQUIRE p.id IS UNIQUE",
                "CREATE CONSTRAINT topic_id IF NOT EXISTS FOR (t:Topic) REQUIRE t.name IS UNIQUE",
                "CREATE CONSTRAINT entity_id IF NOT EXISTS FOR (e:Entity) REQUIRE e.name IS UNIQUE",
            ]
            for c in constraints:
                try:
                    await session.run(c)
                except Exception as e:
                    log.debug("Constraint init notice", detail=str(e))

    async def ingest_enriched_post(self, post_data: dict[str, Any]):
        """Create or update User, Post, Topic, and Entity nodes + relationships in Neo4j."""
        if not self.driver:
            await self.connect()

        assert self.driver is not None

        platform = post_data.get("platform", "unknown")
        platform_id = str(post_data.get("platform_id", ""))
        post_uuid = f"{platform}_{platform_id}"
        username = post_data.get("author_username", "anonymous")
        display_name = post_data.get("author_display_name", username)
        text = post_data.get("text_cleaned", post_data.get("text", ""))
        sentiment_score = post_data.get("sentiment_score", 0.0)
        virality_score = post_data.get("virality_score", 0.0)

        topics = post_data.get("topics", [])
        entities = post_data.get("entities", [])
        keywords = post_data.get("keywords", [])

        cypher = """
        // 1. Merge User Node
        MERGE (u:User {username: $username})
        ON CREATE SET u.id = $username, u.display_name = $display_name, u.platform = $platform
        ON MATCH SET u.display_name = $display_name

        // 2. Merge Post Node
        MERGE (p:Post {id: $post_uuid})
        ON CREATE SET p.platform = $platform, p.text = $text, p.sentiment_score = $sentiment_score,
                      p.virality_score = $virality_score, p.created_at = datetime()

        // 3. Create WROTE Relationship
        MERGE (u)-[:WROTE]->(p)

        // 4. Merge Topics & Connect
        WITH p
        UNWIND $topics AS topic_name
        MERGE (t:Topic {name: topic_name})
        MERGE (p)-[:HAS_TOPIC]->(t)

        // 5. Merge Entities & Connect
        WITH p
        UNWIND $entities AS ent
        MERGE (e:Entity {name: ent.name})
        ON CREATE SET e.type = ent.type
        MERGE (p)-[:MENTIONS {confidence: ent.confidence}]->(e)
        """

        async with self.driver.session() as session:
            await session.run(
                cypher,
                username=username,
                display_name=display_name,
                platform=platform,
                post_uuid=post_uuid,
                text=text[:300],
                sentiment_score=sentiment_score,
                virality_score=virality_score,
                topics=topics,
                entities=entities,
            )

        log.info("Ingested post into Neo4j Knowledge Graph", post_id=post_uuid, username=username)

    async def close(self):
        if self.driver:
            await self.driver.close()
            self.driver = None
