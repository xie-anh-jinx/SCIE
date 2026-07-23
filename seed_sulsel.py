import asyncio, uuid
from app.core.database import AsyncSessionLocal
from sqlalchemy import text as sa_text

sulsel_events = [
    {
        'platform': 'rss',
        'platform_id': 'sulsel_bmkg_010',
        'text': 'BMKG Wilayah IV Makassar mengeluarkan peringatan dini hujan lebat dan angin kencang di Pesisir Barat Sulawesi Selatan (Makassar, Maros, Pangkep).',
        'text_cleaned': 'BMKG Wilayah IV Makassar mengeluarkan peringatan dini hujan lebat dan angin kencang di Pesisir Barat Sulawesi Selatan.',
        'sentiment_label': 'negative',
        'sentiment_score': -0.45,
        'topics': ['BMKG', 'Cuaca', 'Bencana', 'Sulsel'],
        'virality_score': 8.7,
        'latitude': -5.1477,
        'longitude': 119.4327,
        'location_name': 'Makassar',
        'province': 'Sulawesi Selatan',
        'layer_category': 'bencana'
    },
    {
        'platform': 'rss',
        'platform_id': 'sulsel_tni_011',
        'text': 'Kodam XIV/Hasanuddin bersama Lantamal VI Makassar mengelar siaga penuh pengamanan instalasi vital dan jalur maritim Selat Makassar.',
        'text_cleaned': 'Kodam XIV/Hasanuddin bersama Lantamal VI Makassar mengelar siaga penuh pengamanan instalasi vital dan jalur maritim Selat Makassar.',
        'sentiment_label': 'positive',
        'sentiment_score': 0.75,
        'topics': ['Kodam Hasanuddin', 'TNI', 'Obvitnas', 'Makassar'],
        'virality_score': 7.9,
        'latitude': -5.1320,
        'longitude': 119.4480,
        'location_name': 'Lantamal VI Makassar',
        'province': 'Sulawesi Selatan',
        'layer_category': 'pangkalan'
    },
    {
        'platform': 'rss',
        'platform_id': 'sulsel_maritim_012',
        'text': 'Pantauan lalu lintas pelayaran dan armada nelayan di Perairan Kepulauan Selayar berjalan aman dan terkendali.',
        'text_cleaned': 'Pantauan lalu lintas pelayaran dan armada nelayan di Perairan Kepulauan Selayar berjalan aman dan terkendali.',
        'sentiment_label': 'positive',
        'sentiment_score': 0.8,
        'topics': ['Selayar', 'Maritim', 'Laut', 'Sulsel'],
        'virality_score': 6.8,
        'latitude': -6.1172,
        'longitude': 120.4632,
        'location_name': 'Kepulauan Selayar',
        'province': 'Sulawesi Selatan',
        'layer_category': 'perairan'
    },
    {
        'platform': 'rss',
        'platform_id': 'sulsel_pangan_013',
        'text': 'Dinas Perdagangan Sulsel melaporkan pasokan beras dan minyak goreng di Pasar Terong Makassar dan Pasar Minasa Maupa Gowa mencukupi.',
        'text_cleaned': 'Dinas Perdagangan Sulsel melaporkan pasokan beras dan minyak goreng di Pasar Terong Makassar dan Pasar Minasa Maupa Gowa mencukupi.',
        'sentiment_label': 'positive',
        'sentiment_score': 0.65,
        'topics': ['Ekonomi', 'Pangan', 'Beras', 'Makassar', 'Gowa'],
        'virality_score': 7.2,
        'latitude': -5.2000,
        'longitude': 119.4500,
        'location_name': 'Gowa',
        'province': 'Sulawesi Selatan',
        'layer_category': 'ekonomi'
    },
    {
        'platform': 'rss',
        'platform_id': 'sulsel_pln_014',
        'text': 'PLN UID Sulselrabr melakukan optimalisasi jaringan pemeliharaan Pembangkit Listrik Tello Makassar demi pemulihan daya penuh.',
        'text_cleaned': 'PLN UID Sulselrabr melakukan optimalisasi jaringan pemeliharaan Pembangkit Listrik Tello Makassar demi pemulihan daya penuh.',
        'sentiment_label': 'neutral',
        'sentiment_score': 0.2,
        'topics': ['PLN', 'Infrastruktur', 'Listrik', 'Makassar'],
        'virality_score': 7.6,
        'latitude': -5.1380,
        'longitude': 119.4600,
        'location_name': 'PLTU Tello Makassar',
        'province': 'Sulawesi Selatan',
        'layer_category': 'infrastruktur'
    },
    {
        'platform': 'twitter',
        'platform_id': 'sulsel_hotspot_015',
        'text': 'Perbincangan hangat warga netizen Sulawesi Selatan mengenai percepatan pembangunan infrastruktur jalan daerah Maros - Bone.',
        'text_cleaned': 'Perbincangan hangat warga netizen Sulawesi Selatan mengenai percepatan pembangunan infrastruktur jalan daerah Maros - Bone.',
        'sentiment_label': 'positive',
        'sentiment_score': 0.7,
        'topics': ['Netizen', 'Maros', 'Bone', 'Sulsel'],
        'virality_score': 8.9,
        'latitude': -4.8386,
        'longitude': 119.6450,
        'location_name': 'Maros - Bone',
        'province': 'Sulawesi Selatan',
        'layer_category': 'hotspot'
    },
    {
        'platform': 'rss',
        'platform_id': 'sulsel_polres_016',
        'text': 'Polrestabes Makassar meningkatkan kegiatan patroli malam dan razia ketertiban di wilayah Panakkukang dan Tamalate.',
        'text_cleaned': 'Polrestabes Makassar meningkatkan kegiatan patroli malam dan razia ketertiban di wilayah Panakkukang dan Tamalate.',
        'sentiment_label': 'positive',
        'sentiment_score': 0.55,
        'topics': ['Polrestabes', 'Keamanan', 'Makassar', 'Sulsel'],
        'virality_score': 7.4,
        'latitude': -5.1500,
        'longitude': 119.4400,
        'location_name': 'Panakkukang Makassar',
        'province': 'Sulawesi Selatan',
        'layer_category': 'konflik'
    },
    {
        'platform': 'rss',
        'platform_id': 'sulsel_parepare_017',
        'text': 'Pelabuhan Nusantara Parepare mencatat lonjakan pengiriman komoditas pertanian unggulan Sulawesi Selatan.',
        'text_cleaned': 'Pelabuhan Nusantara Parepare mencatat lonjakan pengiriman komoditas pertanian unggulan Sulawesi Selatan.',
        'sentiment_label': 'positive',
        'sentiment_score': 0.82,
        'topics': ['Parepare', 'Pelabuhan', 'Ekonomi', 'Sulsel'],
        'virality_score': 6.9,
        'latitude': -4.0133,
        'longitude': 119.6244,
        'location_name': 'Parepare',
        'province': 'Sulawesi Selatan',
        'layer_category': 'ekonomi'
    },
    {
        'platform': 'rss',
        'platform_id': 'sulsel_palopo_018',
        'text': 'Pemerintah Kota Palopo dan Luwu menggelar gladi simulasi penanggulangan banjir tanah longsor.',
        'text_cleaned': 'Pemerintah Kota Palopo dan Luwu menggelar gladi simulasi penanggulangan banjir tanah longsor.',
        'sentiment_label': 'neutral',
        'sentiment_score': 0.3,
        'topics': ['Palopo', 'Luwu', 'Bencana', 'Sulsel'],
        'virality_score': 6.5,
        'latitude': -2.9944,
        'longitude': 120.1947,
        'location_name': 'Palopo',
        'province': 'Sulawesi Selatan',
        'layer_category': 'bencana'
    }
]

async def seed_sulsel():
    async with AsyncSessionLocal() as db:
        for item in sulsel_events:
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
        print('SUCCESS: Seeded 9 South Sulawesi regional events into PostgreSQL!')

if __name__ == '__main__':
    asyncio.run(seed_sulsel())
