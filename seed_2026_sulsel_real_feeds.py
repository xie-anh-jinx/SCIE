import asyncio, uuid
from app.core.database import AsyncSessionLocal, get_neo4j_driver
from sqlalchemy import text as sa_text
from datetime import datetime, timedelta, UTC

sulsel_2026_real_feeds = [
    {
        'platform': 'rss',
        'platform_id': 'sulsel_real_2026_001',
        'text': 'RAKYAT SULSEL: DPRD Kota Makassar Menggelar Rapat Paripurna Penyerahan Ranperda Pertanggungjawaban Pelaksanaan APBD Tahun Anggaran 2026.',
        'sentiment_label': 'positive',
        'sentiment_score': 0.85,
        'topics': ['DPRD Makassar', 'APBD 2026', 'Kebijakan Publik'],
        'virality_score': 9.2,
        'latitude': -5.1320,
        'longitude': 119.4480,
        'location_name': 'Gedung DPRD Kota Makassar',
        'province': 'Sulawesi Selatan',
        'layer_category': 'politik'
    },
    {
        'platform': 'rss',
        'platform_id': 'sulsel_real_2026_002',
        'text': 'Fajar.co.id: Pj Gubernur Sulawesi Selatan Meninjau Pembukaan Jalur Poros Maros - Bone Pasca Perbaikan Tebing Pasca Longsor.',
        'sentiment_label': 'positive',
        'sentiment_score': 0.9,
        'topics': ['Pemprov Sulsel', 'Poros Maros-Bone', 'Infrastruktur'],
        'virality_score': 9.5,
        'latitude': -5.0000,
        'longitude': 119.5700,
        'location_name': 'Jalur Poros Maros - Bone',
        'province': 'Sulawesi Selatan',
        'layer_category': 'infrastruktur'
    },
    {
        'platform': 'tiktok',
        'platform_id': 'sulsel_real_2026_003',
        'text': '@sulselprov: Dinas Perdagangan Sulsel Menggelar Operasi Pasar Murah Stabilisasi Harga Beras dan Minyak Goreng di Pasar Terong Makassar.',
        'sentiment_label': 'positive',
        'sentiment_score': 0.88,
        'topics': ['Pemprov Sulsel', 'Pasar Murah', 'Ekonomi Pangan'],
        'virality_score': 9.1,
        'latitude': -5.1380,
        'longitude': 119.4200,
        'location_name': 'Pasar Terong Makassar',
        'province': 'Sulawesi Selatan',
        'layer_category': 'ekonomi'
    },
    {
        'platform': 'tiktok',
        'platform_id': 'sulsel_real_2026_004',
        'text': '@pemerintahkotamakassar: Pemkot Makassar Menerapkan Sosialisasi Perwali Pembatasan Jam Operasional Truk Tonase Besar di Jalan Protokol.',
        'sentiment_label': 'positive',
        'sentiment_score': 0.78,
        'topics': ['Pemkot Makassar', 'Perwali 2026', 'Tata Ruang Kota'],
        'virality_score': 8.8,
        'latitude': -5.1380,
        'longitude': 119.4200,
        'location_name': 'Balai Kota Makassar',
        'province': 'Sulawesi Selatan',
        'layer_category': 'politik'
    },
    {
        'platform': 'instagram',
        'platform_id': 'sulsel_real_2026_005',
        'text': '@rakyatsulseldotco: Wali Kota Makassar Meninjau Kesiapan Pintu Air & Drainase Pesisir Pantai Losari Guna Mengantisipasi Cuaca Ekstrem.',
        'sentiment_label': 'positive',
        'sentiment_score': 0.82,
        'topics': ['Pemkot Makassar', 'Drainase Losari', 'Pesisir'],
        'virality_score': 9.0,
        'latitude': -5.1477,
        'longitude': 119.4327,
        'location_name': 'Pantai Losari Makassar',
        'province': 'Sulawesi Selatan',
        'layer_category': 'politik'
    },
    {
        'platform': 'twitter',
        'platform_id': 'sulsel_real_2026_006',
        'text': '@makassar_info: BMKG Wilayah IV Makassar Mengeluarkan Peringatan Dini Gelombang Tinggi di Perairan Selat Makassar.',
        'sentiment_label': 'negative',
        'sentiment_score': -0.5,
        'topics': ['BMKG Makassar', 'Selat Makassar', 'Cuaca Ekstrem'],
        'virality_score': 9.6,
        'latitude': -5.1600,
        'longitude': 119.4350,
        'location_name': 'BMKG Wilayah IV Makassar',
        'province': 'Sulawesi Selatan',
        'layer_category': 'bencana'
    }
]

async def seed_sulsel_real():
    async with AsyncSessionLocal() as db:
        now_dt = datetime.now(UTC)
        for idx, item in enumerate(sulsel_2026_real_feeds):
            collected_at = now_dt - timedelta(hours=idx * 4)
            post_id = str(uuid.uuid4())
            sql = sa_text(
                "INSERT INTO posts (id, platform, platform_id, type, text, text_cleaned, "
                "sentiment_label, sentiment_score, topics, virality_score, latitude, longitude, "
                "location_name, province, layer_category, collected_at, processed_at) "
                "VALUES (:id, :platform, :platform_id, 'post', :text, :text, "
                ":sentiment_label, :sentiment_score, :topics, :virality_score, :latitude, :longitude, "
                ":location_name, :province, :layer_category, :collected_at, NOW()) "
                "ON CONFLICT (platform, platform_id) DO UPDATE SET "
                "text = EXCLUDED.text, collected_at = EXCLUDED.collected_at"
            )
            await db.execute(sql, {
                'id': post_id,
                'platform': item['platform'],
                'platform_id': item['platform_id'],
                'text': item['text'],
                'sentiment_label': item['sentiment_label'],
                'sentiment_score': item['sentiment_score'],
                'topics': item['topics'],
                'virality_score': item['virality_score'],
                'latitude': item['latitude'],
                'longitude': item['longitude'],
                'location_name': item['location_name'],
                'province': item['province'],
                'layer_category': item['layer_category'],
                'collected_at': collected_at,
            })

        await db.commit()
        print("✅ Added South Sulawesi Real Governance & Policy Feeds!")

    driver = get_neo4j_driver()
    async with driver.session() as session:
        for item in sulsel_2026_real_feeds:
            # Connect Neo4j
            await session.run(
                "MERGE (a:NewsArticle {id: $id}) "
                "ON CREATE SET a.title = $text, a.source = $platform, a.layer = $layer, a.sentiment = $sentiment",
                id=item['platform_id'], text=item['text'][:80], platform=item['platform'], layer=item['layer_category'], sentiment=item['sentiment_label']
            )

            loc_id = f"loc_{item['location_name'].lower().replace(' ', '_')}"
            await session.run(
                "MERGE (l:Location {id: $id}) "
                "ON CREATE SET l.name = $name, l.province = $province "
                "WITH l "
                "MATCH (a:NewsArticle {id: $article_id}) "
                "MERGE (a)-[:LOCATED_AT]->(l)",
                id=loc_id, name=item['location_name'], province=item['province'], article_id=item['platform_id']
            )

            topic_id = f"topic_{item['layer_category']}"
            await session.run(
                "MERGE (t:Topic {id: $id}) "
                "ON CREATE SET t.name = $name "
                "WITH t "
                "MATCH (a:NewsArticle {id: $article_id}) "
                "MERGE (a)-[:DISCUSSES_TOPIC]->(t)",
                id=topic_id, name=f"Isu {item['layer_category'].capitalize()}", article_id=item['platform_id']
            )

        print("✅ Added Neo4j Graph Relationships for South Sulawesi Real Feeds!")

if __name__ == '__main__':
    asyncio.run(seed_sulsel_real())
