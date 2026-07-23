import asyncio, uuid, json
from app.core.database import AsyncSessionLocal
from sqlalchemy import text as sa_text

sulsel_instagram_accounts = [
    {
        'username': 'rakyatsulseldotco',
        'display_name': 'RAKYAT SULSEL',
        'platform': 'instagram',
        'follower_count': 43800,
        'following_count': 63,
        'post_count': 10817,
        'is_verified': True,
        'bio': 'Akun Resmi RAKYATSULSEL.CO Promosi dan Kerja Sama DM Admin',
        'profile_url': 'https://www.instagram.com/rakyatsulseldotco',
        'category': 'Media'
    },
    {
        'username': 'sulselprov',
        'display_name': 'Pemprov Sulawesi Selatan',
        'platform': 'instagram',
        'follower_count': 78600,
        'following_count': 120,
        'post_count': 4400,
        'is_verified': True,
        'bio': 'Akun Resmi Kehumasan Pemerintah Provinsi Sulawesi Selatan / PPID Utama Sulsel',
        'profile_url': 'https://www.instagram.com/sulselprov',
        'category': 'Pemerintah'
    },
    {
        'username': 'suharmika',
        'display_name': 'Andi Suharmika Hasir',
        'platform': 'instagram',
        'follower_count': 2000,
        'following_count': 609,
        'post_count': 55,
        'is_verified': False,
        'bio': 'Wakil Ketua DPRD Kota Makassar • Sekretaris DPD Golkar Kota Makassar',
        'profile_url': 'https://www.instagram.com/suharmika',
        'category': 'Legislatif / Partai Golkar'
    },
    {
        'username': 'gerindrasulawesiselatan',
        'display_name': 'Gerindra Sulawesi Selatan',
        'platform': 'instagram',
        'follower_count': 3800,
        'following_count': 85,
        'post_count': 420,
        'is_verified': True,
        'bio': 'Akun resmi DPD Partai Gerindra Sulawesi Selatan',
        'profile_url': 'https://www.instagram.com/gerindrasulawesiselatan',
        'category': 'Partai Politik'
    },
    {
        'username': 'kpu_makassar',
        'display_name': 'KPU Kota Makassar',
        'platform': 'instagram',
        'follower_count': 15900,
        'following_count': 554,
        'post_count': 2814,
        'is_verified': True,
        'bio': 'Akun Resmi Komisi Pemilihan Umum Kota Makassar',
        'profile_url': 'https://www.instagram.com/kpu_makassar',
        'category': 'Penyelenggara Pemilu'
    },
    {
        'username': 'psi.makassar',
        'display_name': 'DPD PSI Kota Makassar',
        'platform': 'instagram',
        'follower_count': 526,
        'following_count': 378,
        'post_count': 64,
        'is_verified': False,
        'bio': 'Akun Resmi DPD Partai Solidaritas Indonesia Kota Makassar',
        'profile_url': 'https://www.instagram.com/psi.makassar',
        'category': 'Partai Politik'
    },
    {
        'username': 'anditenriujii',
        'display_name': 'Andi Tenri Uji Idris',
        'platform': 'instagram',
        'follower_count': 1850,
        'following_count': 210,
        'post_count': 90,
        'is_verified': False,
        'bio': 'Tokoh Publik & Politisi Makassar',
        'profile_url': 'https://www.instagram.com/anditenriujii',
        'category': 'Tokoh Publik'
    },
    {
        'username': 'pdiperjuangan.makassar',
        'display_name': 'DPC PDI Perjuangan Makassar',
        'platform': 'instagram',
        'follower_count': 1200,
        'following_count': 183,
        'post_count': 840,
        'is_verified': False,
        'bio': 'Akun Resmi DPC PDI Perjuangan Kota Makassar. Jl. Muhammad Tahir No. 54',
        'profile_url': 'https://www.instagram.com/pdiperjuangan.makassar',
        'category': 'Partai Politik'
    }
]

async def seed_instagram_sources_and_accounts():
    async with AsyncSessionLocal() as db:
        for acc in sulsel_instagram_accounts:
            # 1. Insert/Update social_accounts table
            acc_id = str(uuid.uuid4())
            sql_acc = sa_text(
                "INSERT INTO social_accounts (id, platform, platform_id, username, display_name, bio, "
                "follower_count, following_count, is_verified, influence_score, collected_at, updated_at) "
                "VALUES (:id, :platform, :platform_id, :username, :display_name, :bio, "
                ":follower_count, :following_count, :is_verified, :influence_score, NOW(), NOW()) "
                "ON CONFLICT (platform, platform_id) DO UPDATE SET "
                "follower_count = EXCLUDED.follower_count, display_name = EXCLUDED.display_name, "
                "bio = EXCLUDED.bio, updated_at = NOW()"
            )
            await db.execute(sql_acc, {
                'id': acc_id,
                'platform': acc['platform'],
                'platform_id': acc['username'],
                'username': acc['username'],
                'display_name': acc['display_name'],
                'bio': acc['bio'],
                'follower_count': acc['follower_count'],
                'following_count': acc['following_count'],
                'is_verified': acc['is_verified'],
                'influence_score': round(acc['follower_count'] / 1000.0, 2)
            })

            # 2. Register into data_sources table
            src_id = str(uuid.uuid4())
            src_name = f"Instagram Official: {acc['display_name']}"
            config_json = json.dumps({'username': acc['username'], 'url': acc['profile_url'], 'province': 'Sulawesi Selatan'})
            keywords_list = ['sulsel', 'makassar', acc['username'], 'politik', 'pilihan']

            res_src = await db.execute(sa_text("SELECT id FROM data_sources WHERE name = :name").params(name=src_name))
            if not res_src.first():
                await db.execute(
                    sa_text(
                        "INSERT INTO data_sources (id, name, platform, config, keywords, is_active, status, created_at, updated_at) "
                        "VALUES (:id, :name, 'instagram', :config, :keywords, true, 'active', NOW(), NOW())"
                    ).params(id=src_id, name=src_name, config=config_json, keywords=keywords_list)
                )

        await db.commit()
        print('SUCCESS: Seeded 8 official South Sulawesi Instagram accounts & sources into PostgreSQL!')

if __name__ == '__main__':
    asyncio.run(seed_instagram_sources_and_accounts())
