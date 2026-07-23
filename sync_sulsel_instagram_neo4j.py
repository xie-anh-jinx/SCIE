import asyncio
from app.core.database import get_neo4j_driver

async def sync_instagram_accounts_neo4j():
    driver = get_neo4j_driver()
    async with driver.session() as session:
        accounts = [
            {
                "username": "rakyatsulseldotco",
                "name": "RAKYAT SULSEL (@rakyatsulseldotco)",
                "type": "Media",
                "color": "#ec4899",
                "size": 22
            },
            {
                "username": "sulselprov_ig",
                "name": "Pemprov Sulsel IG (@sulselprov)",
                "type": "Pemerintah",
                "color": "#10b981",
                "size": 22
            },
            {
                "username": "suharmika",
                "name": "Andi Suharmika Hasir (@suharmika)",
                "type": "Tokoh Politik / Golkar",
                "color": "#eab308",
                "size": 18
            },
            {
                "username": "gerindrasulawesiselatan",
                "name": "Gerindra Sulsel (@gerindrasulawesiselatan)",
                "type": "Partai Politik",
                "color": "#dc2626",
                "size": 19
            },
            {
                "username": "kpu_makassar",
                "name": "KPU Makassar (@kpu_makassar)",
                "type": "Penyelenggara Pemilu",
                "color": "#10b981",
                "size": 20
            },
            {
                "username": "psi_makassar",
                "name": "DPD PSI Makassar (@psi.makassar)",
                "type": "Partai Politik",
                "color": "#f97316",
                "size": 17
            },
            {
                "username": "anditenriujii",
                "name": "Andi Tenri Uji Idris (@anditenriujii)",
                "type": "Tokoh Publik",
                "color": "#8b5cf6",
                "size": 17
            },
            {
                "username": "pdiperjuangan_makassar",
                "name": "DPC PDI-P Makassar (@pdiperjuangan.makassar)",
                "type": "Partai Politik",
                "color": "#b91c1c",
                "size": 18
            }
        ]

        for acc in accounts:
            await session.run(
                "MERGE (a:PoliticalActor {id: $id}) "
                "ON CREATE SET a.name = $name, a.type = $type, a.color = $color, a.size = $size",
                id=acc["username"], name=acc["name"], type=acc["type"], color=acc["color"], size=acc["size"]
            )

        # Relasi Aktor & Narasi
        edges = [
            ("rakyatsulseldotco", "narasi_debat_makassar", "LIPUTAN_INSTAGRAM"),
            ("kpu_makassar", "narasi_debat_makassar", "PENYELENGGARA_PILWALKOT"),
            ("suharmika", "narasi_debat_makassar", "PENGAWASAN_DPRD_MAKASSAR"),
            ("gerindrasulawesiselatan", "narasi_pilkada_damai", "DUKUNGAN_PARTAI"),
            ("pdiperjuangan_makassar", "narasi_debat_makassar", "KAMPANYE_PARTAI"),
            ("psi_makassar", "narasi_pilkada_damai", "DUKUNGAN_PARTAI"),
            ("sulselprov_ig", "narasi_netralitas_asn", "EDUKASI_PUBLIC"),
            ("anditenriujii", "narasi_debat_makassar", "OPINI_TOKOH"),
        ]

        for source, target, rel_label in edges:
            cypher_edge = f"""
            MATCH (a), (b)
            WHERE a.id = $source AND b.id = $target
            MERGE (a)-[r:{rel_label}]->(b)
            """
            await session.run(cypher_edge, source=source, target=target)

        print("SUCCESS: Synced 8 official South Sulawesi Instagram accounts to Neo4j Knowledge Graph!")

if __name__ == '__main__':
    asyncio.run(sync_instagram_accounts_neo4j())
