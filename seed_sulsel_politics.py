import asyncio, uuid
from app.core.database import AsyncSessionLocal
from sqlalchemy import text as sa_text

sulsel_political_events = [
    {
        'platform': 'rss',
        'platform_id': 'sulsel_pol_020',
        'text': 'KPU Sulawesi Selatan dan Bawaslu Sulsel menggelar Rapat Pleno Terbuka rekapitulasi penetapan Daftar Pemilih Tetap (DPT) Pilkada Serentak.',
        'text_cleaned': 'KPU Sulawesi Selatan dan Bawaslu Sulsel menggelar Rapat Pleno Terbuka rekapitulasi penetapan Daftar Pemilih Tetap Pilkada Serentak.',
        'sentiment_label': 'positive',
        'sentiment_score': 0.7,
        'topics': ['Pilkada', 'KPU', 'Bawaslu', 'Sulsel', 'Politik'],
        'virality_score': 9.2,
        'latitude': -5.1477,
        'longitude': 119.4327,
        'location_name': 'Makassar',
        'province': 'Sulawesi Selatan',
        'layer_category': 'konflik'
    },
    {
        'platform': 'facebook',
        'platform_id': 'sulsel_pol_021',
        'text': 'Debat Publik Pasangan Calon Wali Kota dan Wakil Wali Kota Makassar menyedot perhatian ribuan netizen di media sosial.',
        'text_cleaned': 'Debat Publik Pasangan Calon Wali Kota dan Wakil Wali Kota Makassar menyedot perhatian ribuan netizen di media sosial.',
        'sentiment_label': 'positive',
        'sentiment_score': 0.8,
        'topics': ['Pilwalkot', 'Debat Paslon', 'Makassar', 'Politik'],
        'virality_score': 9.5,
        'latitude': -5.1500,
        'longitude': 119.4400,
        'location_name': 'Makassar',
        'province': 'Sulawesi Selatan',
        'layer_category': 'hotspot'
    },
    {
        'platform': 'rss',
        'platform_id': 'sulsel_pol_022',
        'text': 'DPRD Provinsi Sulawesi Selatan mengesahkan Peraturan Daerah (Perda) tentang Prioritas Pembangunan Infrastruktur Daerah.',
        'text_cleaned': 'DPRD Provinsi Sulawesi Selatan mengesahkan Peraturan Daerah tentang Prioritas Pembangunan Infrastruktur Daerah.',
        'sentiment_label': 'positive',
        'sentiment_score': 0.75,
        'topics': ['DPRD', 'Pemprov', 'Infrastruktur', 'Sulsel'],
        'virality_score': 8.4,
        'latitude': -5.1320,
        'longitude': 119.4480,
        'location_name': 'DPRD Sulsel Makassar',
        'province': 'Sulawesi Selatan',
        'layer_category': 'konflik'
    },
    {
        'platform': 'tiktok',
        'platform_id': 'sulsel_pol_023',
        'text': 'Imbauan KPU Kabupaten Gowa mengenai kewaspadaan disinformasi dan hoaks selama masa kampanye Pilkada.',
        'text_cleaned': 'Imbauan KPU Kabupaten Gowa mengenai kewaspadaan disinformasi dan hoaks selama masa kampanye Pilkada.',
        'sentiment_label': 'neutral',
        'sentiment_score': 0.1,
        'topics': ['KPU Gowa', 'Hoaks', 'Disinformasi', 'Gowa'],
        'virality_score': 8.8,
        'latitude': -5.2000,
        'longitude': 119.4500,
        'location_name': 'Gowa',
        'province': 'Sulawesi Selatan',
        'layer_category': 'hotspot'
    },
    {
        'platform': 'rss',
        'platform_id': 'sulsel_pol_024',
        'text': 'Penjabat Gubernur Sulawesi Selatan menginstruksikan seluruh jajaran ASN Pemprov untuk menjaga netralitas penuh.',
        'text_cleaned': 'Penjabat Gubernur Sulawesi Selatan menginstruksikan seluruh jajaran ASN Pemprov untuk menjaga netralitas penuh.',
        'sentiment_label': 'positive',
        'sentiment_score': 0.85,
        'topics': ['Gubernur', 'ASN', 'Netralitas', 'Pemprov Sulsel'],
        'virality_score': 8.6,
        'latitude': -5.1400,
        'longitude': 119.4300,
        'location_name': 'Kantor Gubernur Sulsel',
        'province': 'Sulawesi Selatan',
        'layer_category': 'konflik'
    }
]

async def seed_political_events():
    async with AsyncSessionLocal() as db:
        for item in sulsel_political_events:
            post_id = str(uuid.uuid4())
            sql = sa_text(
                "INSERT INTO posts (id, platform, platform_id, type, text, text_cleaned, "
                "sentiment_label, sentiment_score, topics, virality_score, latitude, longitude, "
                "location_name, province, layer_category, collected_at, processed_at) "
                "VALUES (:id, :platform, :platform_id, 'post', :text, :text_cleaned, "
                ":sentiment_label, :sentiment_score, :topics, :virality_score, :latitude, :longitude, "
                ":location_name, :province, :layer_category, NOW(), NOW()) "
                "ON CONFLICT (platform, platform_id) DO UPDATE SET "
                "latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, "
                "location_name = EXCLUDED.location_name, province = EXCLUDED.province, "
                "layer_category = EXCLUDED.layer_category"
            )
            params = {
                'id': post_id,
                'platform': item['platform'],
                'platform_id': item['platform_id'],
                'text': item['text'],
                'text_cleaned': item['text_cleaned'],
                'sentiment_label': item['sentiment_label'],
                'sentiment_score': item['sentiment_score'],
                'topics': item['topics'],
                'virality_score': item['virality_score'],
                'latitude': item['latitude'],
                'longitude': item['longitude'],
                'location_name': item['location_name'],
                'province': item['province'],
                'layer_category': item['layer_category'],
            }
            await db.execute(sql, params)
        await db.commit()
        print('SUCCESS: Seeded South Sulawesi political events into PostgreSQL!')

if __name__ == '__main__':
    asyncio.run(seed_political_events())
