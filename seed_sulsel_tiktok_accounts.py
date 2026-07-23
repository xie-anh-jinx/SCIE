import asyncio, uuid, json
from app.core.database import AsyncSessionLocal
from sqlalchemy import text as sa_text

sulsel_tiktok_accounts = [
    {
        'username': 'rakyatsulsel',
        'display_name': 'RAKYAT SULSEL',
        'platform': 'tiktok',
        'follower_count': 131500,
        'following_count': 120,
        'is_verified': True,
        'bio': 'Akun Resmi RAKYAT SULSEL. Media & Informasi Terkini Sulawesi Selatan.',
        'profile_url': 'https://www.tiktok.com/@rakyatsulsel',
        'location': 'Makassar, Sulawesi Selatan',
        'category': 'Media'
    },
    {
        'username': 'sulselprov',
        'display_name': 'Pemerintah Provinsi Sulawesi Selatan',
        'platform': 'tiktok',
        'follower_count': 3318,
        'following_count': 25,
        'is_verified': True,
        'bio': 'Akun Resmi Pemerintah Provinsi Sulawesi Selatan.',
        'profile_url': 'https://www.tiktok.com/@sulselprov',
        'location': 'Kantor Gubernur Sulsel, Makassar',
        'category': 'Pemerintah'
    },
    {
        'username': 'dprdprovinsi.sulsel',
        'display_name': 'DPRD PROVINSI SULSEL',
        'platform': 'tiktok',
        'follower_count': 1016,
        'following_count': 15,
        'is_verified': False,
        'bio': 'DPRD SULSEL NEWS. Jl. Urip Sumoharjo No.59, Makassar, Sulawesi Selatan.',
        'profile_url': 'https://www.tiktok.com/@dprdprovinsi.sulsel',
        'location': 'DPRD Sulsel, Makassar',
        'category': 'Legislatif'
    },
    {
        'username': 'pemerintahkotamakassar',
        'display_name': 'Pemerintah Kota Makassar',
        'platform': 'tiktok',
        'follower_count': 3034,
        'following_count': 18,
        'is_verified': True,
        'bio': 'Akun resmi Pemerintah Kota Makassar.',
        'profile_url': 'https://www.tiktok.com/@pemerintahkotamakassar',
        'location': 'Balai Kota Makassar, Sulawesi Selatan',
        'category': 'Pemerintah Daerah'
    }
]

async def seed_tiktok_sources_and_accounts():
    async with AsyncSessionLocal() as db:
        for acc in sulsel_tiktok_accounts:
            # 1. Insert/Update into social_accounts table
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
            src_name = f"TikTok Official: {acc['display_name']}"
            config_json = json.dumps({'username': acc['username'], 'url': acc['profile_url'], 'province': 'Sulawesi Selatan'})
            keywords_list = ['sulsel', 'makassar', acc['username'], 'politik', 'pemerintah']

            res_src = await db.execute(sa_text("SELECT id FROM data_sources WHERE name = :name").params(name=src_name))
            if not res_src.first():
                await db.execute(
                    sa_text(
                        "INSERT INTO data_sources (id, name, platform, config, keywords, is_active, status, created_at, updated_at) "
                        "VALUES (:id, :name, 'tiktok', :config, :keywords, true, 'active', NOW(), NOW())"
                    ).params(id=src_id, name=src_name, config=config_json, keywords=keywords_list)
                )

        await db.commit()
        print('SUCCESS: Seeded official South Sulawesi TikTok accounts & sources into PostgreSQL!')

if __name__ == '__main__':
    asyncio.run(seed_tiktok_sources_and_accounts())
