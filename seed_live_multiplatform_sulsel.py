import asyncio, uuid
from app.core.database import AsyncSessionLocal
from sqlalchemy import text as sa_text

live_multiplatform_events = [
    # 🎵 TikTok Official & Citizen Feeds
    {
        'platform': 'tiktok',
        'platform_id': 'tt_live_sulsel_101',
        'text': 'RAKYAT SULSEL (@rakyatsulsel): Video liputan khusus debat perdana calon wali kota Makassar menarik perhatian 130 ribu pengikut di TikTok.',
        'sentiment_label': 'positive',
        'sentiment_score': 0.82,
        'topics': ['Pilkada', 'Makassar', 'TikTok Viral'],
        'virality_score': 9.6,
        'latitude': -5.1477,
        'longitude': 119.4327,
        'location_name': 'Pantai Losari Makassar',
        'province': 'Sulawesi Selatan',
        'layer_category': 'hotspot'
    },
    {
        'platform': 'tiktok',
        'platform_id': 'tt_live_sulsel_102',
        'text': 'Sulselprov (@sulselprov): Sosialisasi video arahan Pj Gubernur Sulsel mengenai komitmen netralitas ASN Pemprov Sulsel.',
        'sentiment_label': 'positive',
        'sentiment_score': 0.78,
        'topics': ['Pemprov Sulsel', 'Netralitas ASN', 'Gubernur'],
        'virality_score': 8.9,
        'latitude': -5.1400,
        'longitude': 119.4300,
        'location_name': 'Kantor Gubernur Sulsel',
        'province': 'Sulawesi Selatan',
        'layer_category': 'konflik'
    },
    {
        'platform': 'tiktok',
        'platform_id': 'tt_live_sulsel_103',
        'text': 'DPRD PROVINSI SULSEL (@dprdprovinsi.sulsel): Rapat dengar pendapat DPRD Sulsel membahas anggaran perbaikan akses jalan Poros Maros - Bone.',
        'sentiment_label': 'neutral',
        'sentiment_score': 0.2,
        'topics': ['DPRD Sulsel', 'Infrastruktur', 'Maros-Bone'],
        'virality_score': 8.5,
        'latitude': -5.1320,
        'longitude': 119.4480,
        'location_name': 'Gedung DPRD Sulsel Makassar',
        'province': 'Sulawesi Selatan',
        'layer_category': 'infrastruktur'
    },
    {
        'platform': 'tiktok',
        'platform_id': 'tt_live_sulsel_104',
        'text': 'Pemerintah Kota Makassar (@pemerintahkotamakassar): Pemantauan revitalisasi pedagang UMKM dan kebersihan kawasan wisata Kuliner Pasar Terong.',
        'sentiment_label': 'positive',
        'sentiment_score': 0.85,
        'topics': ['Pemkot Makassar', 'UMKM', 'Ekonomi Pangan'],
        'virality_score': 8.7,
        'latitude': -5.1380,
        'longitude': 119.4200,
        'location_name': 'Pasar Terong Makassar',
        'province': 'Sulawesi Selatan',
        'layer_category': 'ekonomi'
    },
    # 🐦 Twitter / X Feeds
    {
        'platform': 'twitter',
        'platform_id': 'tw_live_sulsel_201',
        'text': '@makassar_info: Peringatan Dini BMKG Wilayah IV Makassar mengenai potensi curah hujan sedang-lebat di pesisir barat Sulawesi Selatan.',
        'sentiment_label': 'negative',
        'sentiment_score': -0.4,
        'topics': ['BMKG', 'Cuaca Ekstrem', 'Makassar'],
        'virality_score': 9.1,
        'latitude': -5.1600,
        'longitude': 119.4350,
        'location_name': 'BMKG Wilayah IV Makassar',
        'province': 'Sulawesi Selatan',
        'layer_category': 'bencana'
    },
    {
        'platform': 'twitter',
        'platform_id': 'tw_live_sulsel_202',
        'text': '@sulsel_watch: Pemantauan aktivitas pelayaran armada nelayan dan kapal niaga di Selat Makassar dan Kepulauan Selayar terpantau aman.',
        'sentiment_label': 'positive',
        'sentiment_score': 0.7,
        'topics': ['Selat Makassar', 'Perairan', 'Selayar'],
        'virality_score': 8.0,
        'latitude': -6.1172,
        'longitude': 120.4632,
        'location_name': 'Perairan Kepulauan Selayar',
        'province': 'Sulawesi Selatan',
        'layer_category': 'perairan'
    },
    # 📰 RSS News Feeds
    {
        'platform': 'rss',
        'platform_id': 'rss_live_sulsel_301',
        'text': 'ANTARA News: Kodam XIV/Hasanuddin bersama Lantamal VI Makassar mengelar gladi pengamanan Objek Vital Nasional dan pangkalan maritim.',
        'sentiment_label': 'positive',
        'sentiment_score': 0.75,
        'topics': ['Kodam XIV', 'Lantamal VI', 'TNI Pangkalan'],
        'virality_score': 8.8,
        'latitude': -5.1100,
        'longitude': 119.4200,
        'location_name': 'Lantamal VI Makassar',
        'province': 'Sulawesi Selatan',
        'layer_category': 'pangkalan'
    },
    {
        'platform': 'rss',
        'platform_id': 'rss_live_sulsel_302',
        'text': 'Fajar.co.id: Pelabuhan Nusantara Parepare mencatat lonjakan aktivitas bongkar muat bahan pangan logistik antarisland.',
        'sentiment_label': 'positive',
        'sentiment_score': 0.8,
        'topics': ['Parepare', 'Logistik', 'Ekonomi'],
        'virality_score': 8.3,
        'latitude': -4.0133,
        'longitude': 119.6244,
        'location_name': 'Pelabuhan Nusantara Parepare',
        'province': 'Sulawesi Selatan',
        'layer_category': 'ekonomi'
    },
    {
        'platform': 'facebook',
        'platform_id': 'fb_live_sulsel_401',
        'text': 'Info Gowa & Makassar: Tim Gabungan Satpol PP dan Polrestabes tingkatkan patroli keamanan jelang masa tenang Pilkada.',
        'sentiment_label': 'neutral',
        'sentiment_score': 0.0,
        'topics': ['Gowa', 'Kamtibmas', 'Patroli'],
        'virality_score': 8.1,
        'latitude': -5.2000,
        'longitude': 119.4500,
        'location_name': 'Kabupaten Gowa',
        'province': 'Sulawesi Selatan',
        'layer_category': 'konflik'
    }
]

async def seed_multiplatform_situational_map():
    async with AsyncSessionLocal() as db:
        for item in live_multiplatform_events:
            post_id = str(uuid.uuid4())
            sql = sa_text(
                "INSERT INTO posts (id, platform, platform_id, type, text, text_cleaned, "
                "sentiment_label, sentiment_score, topics, virality_score, latitude, longitude, "
                "location_name, province, layer_category, collected_at, processed_at) "
                "VALUES (:id, :platform, :platform_id, 'post', :text, :text, "
                ":sentiment_label, :sentiment_score, :topics, :virality_score, :latitude, :longitude, "
                ":location_name, :province, :layer_category, NOW(), NOW()) "
                "ON CONFLICT (platform, platform_id) DO UPDATE SET "
                "latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, "
                "location_name = EXCLUDED.location_name, province = EXCLUDED.province, "
                "layer_category = EXCLUDED.layer_category, text = EXCLUDED.text"
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
            })

        await db.commit()
        print('SUCCESS: Seeded Multi-Platform Live Telemetry (TikTok, Twitter, RSS, FB) into Situational Maps PostgreSQL!')

if __name__ == '__main__':
    asyncio.run(seed_multiplatform_situational_map())
