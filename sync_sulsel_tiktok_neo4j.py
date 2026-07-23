import asyncio
from app.core.database import get_neo4j_driver

async def sync_tiktok_accounts_neo4j():
    driver = get_neo4j_driver()
    async with driver.session() as session:
        accounts = [
            {
                "username": "rakyatsulsel",
                "name": "RAKYAT SULSEL (@rakyatsulsel)",
                "followers": 131500,
                "likes": "4.2M",
                "type": "Media",
                "color": "#f97316",
                "size": 22
            },
            {
                "username": "sulselprov",
                "name": "Pemprov Sulsel (@sulselprov)",
                "followers": 3318,
                "likes": "22.8K",
                "type": "Pemerintah",
                "color": "#10b981",
                "size": 20
            },
            {
                "username": "dprdprovinsi.sulsel",
                "name": "DPRD Sulsel (@dprdprovinsi.sulsel)",
                "followers": 1016,
                "likes": "6.3K",
                "type": "Legislatif",
                "color": "#10b981",
                "size": 18
            },
            {
                "username": "pemerintahkotamakassar",
                "name": "Pemkot Makassar (@pemerintahkotamakassar)",
                "followers": 3034,
                "likes": "52.5K",
                "type": "Pemerintah Daerah",
                "color": "#3b82f6",
                "size": 19
            }
        ]

        for acc in accounts:
            # 1. Merge Influencer/Media Node
            await session.run(
                "MERGE (a:PoliticalActor {id: $id}) "
                "ON CREATE SET a.name = $name, a.type = $type, a.color = $color, a.size = $size, a.followers = $followers",
                id=acc["username"], name=acc["name"], type=acc["type"], color=acc["color"], size=acc["size"], followers=acc["followers"]
            )

        # 2. Connect to political narratives in Neo4j
        edges = [
            ("rakyatsulsel", "narasi_pilkada_damai", "PEMBERITAAN_UTAMA"),
            ("rakyatsulsel", "narasi_debat_makassar", "LIPUTAN_MEDIA"),
            ("sulselprov", "narasi_netralitas_asn", "SOSIALISASI_PEMPROV"),
            ("dprdprovinsi.sulsel", "narasi_maros_bone", "PENGAWASAN_LEGISLATIF"),
            ("pemerintahkotamakassar", "narasi_debat_makassar", "KOORDINASI_PEMKOT"),
        ]

        for source, target, rel_label in edges:
            cypher_edge = f"""
            MATCH (a), (b)
            WHERE a.id = $source AND b.id = $target
            MERGE (a)-[r:{rel_label}]->(b)
            """
            await session.run(cypher_edge, source=source, target=target)

        print("SUCCESS: Synced official South Sulawesi TikTok accounts to Neo4j Knowledge Graph!")

if __name__ == '__main__':
    asyncio.run(sync_tiktok_accounts_neo4j())
