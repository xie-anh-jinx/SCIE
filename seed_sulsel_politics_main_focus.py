import asyncio, uuid
from app.core.database import AsyncSessionLocal
from sqlalchemy import text as sa_text

political_policy_feeds = [
    # 📰 RSS News - Politics & Policy
    {
        'platform': 'rss',
        'platform_id': 'pol_rss_001',
        'text': 'RAKYAT SULSEL: KPU Sulsel Resmikan Kesiapan 14.000 TPS dan Distribusi Logistik Pemilu untuk Pilkada Serentak Sulawesi Selatan.',
        'sentiment_label': 'positive',
        'sentiment_score': 0.85,
        'topics': ['KPU Sulsel', 'Pilkada', 'Logistik TPS', 'Politik'],
        'virality_score': 9.5,
        'latitude': -5.1477,
        'longitude': 119.4327,
        'location_name': 'KPU Sulawesi Selatan, Makassar',
        'province': 'Sulawesi Selatan',
        'layer_category': 'politik'
    },
    {
        'platform': 'rss',
        'platform_id': 'pol_rss_002',
        'text': 'Fajar.co.id: Bawaslu Sulsel Memperketat Pengawasan Money Politics dan Kampanye Hitam di Media Sosial Jelang Hari Pencoblosan.',
        'sentiment_label': 'neutral',
        'sentiment_score': 0.1,
        'topics': ['Bawaslu', 'Money Politics', 'Pengawasan', 'Politik'],
        'virality_score': 9.2,
        'latitude': -5.1400,
        'longitude': 119.4350,
        'location_name': 'Bawaslu Sulsel Makassar',
        'province': 'Sulawesi Selatan',
        'layer_category': 'politik'
    },
    {
        'platform': 'rss',
        'platform_id': 'pol_rss_003',
        'text': 'SINDOnews: DPRD Sulsel Bersama Pemprov Mengesahkan APBD Perubahan Fokus Perbaikan Infrastruktur dan Insentif Petani Daerah.',
        'sentiment_label': 'positive',
        'sentiment_score': 0.88,
        'topics': ['DPRD Sulsel', 'APBD', 'Kebijakan Publik', 'Pemprov'],
        'virality_score': 8.9,
        'latitude': -5.1320,
        'longitude': 119.4480,
        'location_name': 'Gedung DPRD Sulsel Makassar',
        'province': 'Sulawesi Selatan',
        'layer_category': 'politik'
    },
    {
        'platform': 'rss',
        'platform_id': 'pol_rss_004',
        'text': 'ANTARA News: Penjabat Gubernur Sulsel Tegaskan Netralitas Full ASN dan Netralitas Fasilitas Negara dalam Agenda Politik Pilkada.',
        'sentiment_label': 'positive',
        'sentiment_score': 0.9,
        'topics': ['Netralitas ASN', 'Gubernur', 'Kebijakan', 'Politik'],
        'virality_score': 9.0,
        'latitude': -5.1400,
        'longitude': 119.4300,
        'location_name': 'Kantor Gubernur Sulsel',
        'province': 'Sulawesi Selatan',
        'layer_category': 'politik'
    },

    # 🎵 TikTok - Politics & Policy
    {
        'platform': 'tiktok',
        'platform_id': 'pol_tt_001',
        'text': '@rakyatsulsel: Debat Publik Kedua Calon Wali Kota Makassar Menampilkan Adu Gagasan Tata Ruang Kota dan Solusi Banjir Pesisir.',
        'sentiment_label': 'positive',
        'sentiment_score': 0.82,
        'topics': ['Debat Paslon', 'Pilwalkot Makassar', 'TikTok Viral'],
        'virality_score': 9.8,
        'latitude': -5.1477,
        'longitude': 119.4327,
        'location_name': 'Makassar',
        'province': 'Sulawesi Selatan',
        'layer_category': 'politik'
    },
    {
        'platform': 'tiktok',
        'platform_id': 'pol_tt_002',
        'text': '@sulselprov: Program Prioritas Kebijakan Pemprov Sulsel dalam Menjaga Stabilitas Harga Sembako dan Subsidi Pangan Murah.',
        'sentiment_label': 'positive',
        'sentiment_score': 0.86,
        'topics': ['Pemprov Sulsel', 'Subsidi Pangan', 'Kebijakan Publik'],
        'virality_score': 8.7,
        'latitude': -5.1400,
        'longitude': 119.4300,
        'location_name': 'Makassar',
        'province': 'Sulawesi Selatan',
        'layer_category': 'politik'
    },
    {
        'platform': 'tiktok',
        'platform_id': 'pol_tt_003',
        'text': '@dprdprovinsi.sulsel: Tanggapan Komisi A DPRD Sulsel Terhadap Pengaduan Warga Mengenai Transparansi Pelayanan Publik di Daerah.',
        'sentiment_label': 'neutral',
        'sentiment_score': 0.3,
        'topics': ['DPRD Sulsel', 'Pelayanan Publik', 'Politik'],
        'virality_score': 8.4,
        'latitude': -5.1320,
        'longitude': 119.4480,
        'location_name': 'DPRD Sulsel Makassar',
        'province': 'Sulawesi Selatan',
        'layer_category': 'politik'
    },
    {
        'platform': 'tiktok',
        'platform_id': 'pol_tt_004',
        'text': '@pemerintahkotamakassar: Pemkot Makassar Rilis Peraturan Wali Kota Terbaru Mengenai Pembatasan Jam Operasional Truk Muatan Berat.',
        'sentiment_label': 'positive',
        'sentiment_score': 0.76,
        'topics': ['Pemkot Makassar', 'Perwali', 'Kebijakan Lalu Lintas'],
        'virality_score': 8.8,
        'latitude': -5.1380,
        'longitude': 119.4200,
        'location_name': 'Balai Kota Makassar',
        'province': 'Sulawesi Selatan',
        'layer_category': 'politik'
    },

    # 📸 Instagram - Politics & Policy
    {
        'platform': 'instagram',
        'platform_id': 'pol_ig_001',
        'text': '@kpu_makassar: Deklarasi Kampanye Damai Pasangan Calon Wali Kota dan Wakil Wali Kota Makassar Bersama Parpol Pengusung.',
        'sentiment_label': 'positive',
        'sentiment_score': 0.92,
        'topics': ['KPU Makassar', 'Kampanye Damai', 'Politik'],
        'virality_score': 9.4,
        'latitude': -5.1500,
        'longitude': 119.4400,
        'location_name': 'KPU Makassar',
        'province': 'Sulawesi Selatan',
        'layer_category': 'politik'
    },
    {
        'platform': 'instagram',
        'platform_id': 'pol_ig_002',
        'text': '@suharmika: Giat DPD Golkar Makassar Menyerap Aspirasi Warga Kecamatan Panakkukang Seputar Pembangunan Fasilitas Umum.',
        'sentiment_label': 'positive',
        'sentiment_score': 0.8,
        'topics': ['Golkar Makassar', 'DPRD', 'Aspirasi Warga'],
        'virality_score': 8.3,
        'latitude': -5.1600,
        'longitude': 119.4500,
        'location_name': 'Panakkukang Makassar',
        'province': 'Sulawesi Selatan',
        'layer_category': 'politik'
    },
    {
        'platform': 'instagram',
        'platform_id': 'pol_ig_003',
        'text': '@gerindrasulawesiselatan: DPD Gerindra Sulsel Gelar Konsolidasi Kader dan Tim Pemenangan Pilkada Serentak Kabupaten Gowa & Maros.',
        'sentiment_label': 'positive',
        'sentiment_score': 0.84,
        'topics': ['Gerindra Sulsel', 'Konsolidasi', 'Politik'],
        'virality_score': 8.6,
        'latitude': -5.2000,
        'longitude': 119.4500,
        'location_name': 'Kabupaten Gowa',
        'province': 'Sulawesi Selatan',
        'layer_category': 'politik'
    },

    # 🐦 Twitter - Politics & Policy
    {
        'platform': 'twitter',
        'platform_id': 'pol_tw_001',
        'text': '@sulsel_watch: Perbincangan Hangat Netizen Sulsel Membedah Visi Misi Sektor Ekonomi & Perekrutan Tenaga Kerja Lokal Paslon Gubernur.',
        'sentiment_label': 'neutral',
        'sentiment_score': 0.4,
        'topics': ['Visi Misi', 'Gubernur Sulsel', 'Politik'],
        'virality_score': 9.1,
        'latitude': -5.1477,
        'longitude': 119.4327,
        'location_name': 'Makassar',
        'province': 'Sulawesi Selatan',
        'layer_category': 'politik'
    }
]

async def seed_political_main_focus():
    async with AsyncSessionLocal() as db:
        for item in political_policy_feeds:
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
        print('SUCCESS: Seeded Political & Policy Main Focus Telemetry feeds into PostgreSQL!')

if __name__ == '__main__':
    asyncio.run(seed_political_main_focus())
