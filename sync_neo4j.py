import asyncio
from app.core.database import get_neo4j_driver, AsyncSessionLocal
from sqlalchemy import select
from app.models.models import Post

async def sync_neo4j():
    driver = get_neo4j_driver()
    async with AsyncSessionLocal() as db:
        res = await db.execute(select(Post).where(Post.is_deleted == False))
        posts = res.scalars().all()

        async with driver.session() as session:
            for p in posts:
                author_name = p.location_name or 'makassar_user'
                author_username = author_name.lower().replace(' ', '_').replace('-', '_')
                text_clean = (p.text or '')[:100]
                sentiment = p.sentiment_label or 'neutral'
                layer = p.layer_category or 'hotspot'
                province = p.province or 'Sulawesi Selatan'

                # 1. Merge User and Post
                cypher_user = (
                    "MERGE (u:User {username: $uname}) "
                    "ON CREATE SET u.display_name = $dname, u.platform = $platform "
                    "MERGE (p:Post {id: $pid}) "
                    "ON CREATE SET p.text = $text, p.sentiment = $sentiment, p.layer = $layer, p.province = $province "
                    "MERGE (u)-[:WROTE]->(p)"
                )
                await session.run(
                    cypher_user,
                    uname=author_username,
                    dname=author_name,
                    platform=p.platform,
                    pid=p.id,
                    text=text_clean,
                    sentiment=sentiment,
                    layer=layer,
                    province=province,
                )

                # 2. Merge Topics
                for topic in (p.topics or []):
                    if topic:
                        cypher_topic = (
                            "MATCH (p:Post {id: $pid}) "
                            "MERGE (t:Topic {name: $tname}) "
                            "MERGE (p)-[:HAS_TOPIC]->(t)"
                        )
                        await session.run(cypher_topic, pid=p.id, tname=topic)

                # 3. Merge Location Entity (using name property for merge)
                if p.location_name:
                    cypher_loc = (
                        "MATCH (p:Post {id: $pid}) "
                        "MERGE (e:Entity {name: $loc}) "
                        "ON CREATE SET e.type = 'Location' "
                        "MERGE (p)-[:LOCATED_IN]->(e)"
                    )
                    await session.run(cypher_loc, pid=p.id, loc=p.location_name)

        print(f'SUCCESS: Synced {len(posts)} real posts into Neo4j Knowledge Graph!')

if __name__ == '__main__':
    asyncio.run(sync_neo4j())
