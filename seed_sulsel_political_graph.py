import asyncio
from app.core.database import get_neo4j_driver

async def seed_political_actor_graph():
    driver = get_neo4j_driver()
    async with driver.session() as session:
        # 1. Clear previous political actor nodes to avoid duplicates
        await session.run("MATCH (n:PoliticalActor) DETACH DELETE n")
        await session.run("MATCH (n:PoliticalParty) DETACH DELETE n")
        await session.run("MATCH (n:PoliticalInstitution) DETACH DELETE n")
        await session.run("MATCH (n:PoliticalNarrative) DETACH DELETE n")

        # 2. Insert Political Actors (Paslon / Tokoh)
        actors = [
            {"id": "paslon_gub_01", "name": "Paslon Gubernur Sulsel #01", "type": "Paslon", "color": "#ef4444", "size": 24},
            {"id": "paslon_gub_02", "name": "Paslon Gubernur Sulsel #02", "type": "Paslon", "color": "#3b82f6", "size": 24},
            {"id": "paslon_walkot_mks", "name": "Paslon Wali Kota Makassar", "type": "Paslon", "color": "#f59e0b", "size": 20},
        ]
        for a in actors:
            await session.run(
                "MERGE (n:PoliticalActor {id: $id}) "
                "ON CREATE SET n.name = $name, n.type = $type, n.color = $color, n.size = $size",
                id=a["id"], name=a["name"], type=a["type"], color=a["color"], size=a["size"]
            )

        # 3. Insert Political Parties
        parties = [
            {"id": "party_golkar", "name": "DPD Golkar Sulsel", "color": "#eab308", "size": 18},
            {"id": "party_nasdem", "name": "DPW NasDem Sulsel", "color": "#0284c7", "size": 18},
            {"id": "party_gerindra", "name": "DPD Gerindra Sulsel", "color": "#dc2626", "size": 18},
            {"id": "party_pdip", "name": "DPD PDI-P Sulsel", "color": "#b91c1c", "size": 18},
        ]
        for p in parties:
            await session.run(
                "MERGE (n:PoliticalParty {id: $id}) "
                "ON CREATE SET n.name = $name, n.color = $color, n.size = $size",
                id=p["id"], name=p["name"], color=p["color"], size=p["size"]
            )

        # 4. Insert Institutions
        institutions = [
            {"id": "inst_kpu_sulsel", "name": "KPU Provinsi Sulawesi Selatan", "color": "#10b981", "size": 20},
            {"id": "inst_bawaslu_sulsel", "name": "Bawaslu Sulsel", "color": "#10b981", "size": 20},
            {"id": "inst_pemprov_sulsel", "name": "Pemerintah Provinsi Sulsel", "color": "#6366f1", "size": 20},
        ]
        for i in institutions:
            await session.run(
                "MERGE (n:PoliticalInstitution {id: $id}) "
                "ON CREATE SET n.name = $name, n.color = $color, n.size = $size",
                id=i["id"], name=i["name"], color=i["color"], size=i["size"]
            )

        # 5. Insert Political Narratives / Topics
        narratives = [
            {"id": "narasi_pilkada_damai", "name": "#PilkadaDamaiSulsel", "color": "#a855f7", "size": 16},
            {"id": "narasi_netralitas_asn", "name": "#NetralitasASNSulsel", "color": "#a855f7", "size": 16},
            {"id": "narasi_debat_makassar", "name": "#DebatPilkadaMakassar", "color": "#a855f7", "size": 16},
            {"id": "narasi_maros_bone", "name": "#JalanMarosBone", "color": "#a855f7", "size": 16},
        ]
        for n in narratives:
            await session.run(
                "MERGE (n:PoliticalNarrative {id: $id}) "
                "ON CREATE SET n.name = $name, n.color = $color, n.size = $size",
                id=n["id"], name=n["name"], color=n["color"], size=n["size"]
            )

        # 6. Create Relationships
        edges = [
            ("party_golkar", "paslon_gub_01", "MENGUSUNG"),
            ("party_gerindra", "paslon_gub_01", "MENGUSUNG"),
            ("party_nasdem", "paslon_gub_02", "MENGUSUNG"),
            ("party_pdip", "paslon_gub_02", "MENGUSUNG"),
            ("inst_kpu_sulsel", "narasi_pilkada_damai", "MENGELOLA"),
            ("inst_bawaslu_sulsel", "narasi_netralitas_asn", "MENGAWASI"),
            ("paslon_gub_01", "narasi_maros_bone", "MENDORONG_ISU"),
            ("paslon_gub_02", "narasi_pilkada_damai", "MENDORONG_ISU"),
            ("paslon_walkot_mks", "narasi_debat_makassar", "MENDOMINASI_NARASI"),
        ]

        for source, target, rel_label in edges:
            cypher_edge = f"""
            MATCH (a), (b)
            WHERE a.id = $source AND b.id = $target
            MERGE (a)-[r:{rel_label}]->(b)
            """
            await session.run(cypher_edge, source=source, target=target)


        print("SUCCESS: Seeded South Sulawesi Political Actor Graph into Neo4j Database!")

if __name__ == '__main__':
    asyncio.run(seed_political_actor_graph())
