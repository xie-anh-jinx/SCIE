import asyncio
from app.core.database import AsyncSessionLocal
from sqlalchemy import text as sa_text

async def update_politik_layer():
    async with AsyncSessionLocal() as db:
        sql = sa_text(
            "UPDATE posts SET layer_category = 'politik' "
            "WHERE is_deleted = false AND ("
            "text ILIKE '%pilkada%' OR text ILIKE '%pemilu%' OR text ILIKE '%gubernur%' OR "
            "text ILIKE '%dprd%' OR text ILIKE '%politik%' OR text ILIKE '%paslon%' OR "
            "text ILIKE '%kampanye%' OR text ILIKE '%kpu%' OR text ILIKE '%bawaslu%' OR "
            "text ILIKE '%debat%' OR text ILIKE '%pemprov%' OR text ILIKE '%pemkot%' OR "
            "text ILIKE '%partai%')"
        )
        res = await db.execute(sql)
        await db.commit()
        print(f"SUCCESS: Updated {res.rowcount} political posts to dedicated 'politik' Situational Layer in PostgreSQL!")

if __name__ == '__main__':
    asyncio.run(update_politik_layer())
