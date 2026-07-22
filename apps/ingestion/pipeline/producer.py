"""
Redis Streams Producer — Publishes raw collected posts into stream:raw_posts.
"""
import json
import structlog
import redis.asyncio as aioredis

log = structlog.get_logger()


class RedisStreamProducer:
    def __init__(self, redis_url: str = "redis://localhost:6379/0", stream_key: str = "stream:raw_posts"):
        self.redis_url = redis_url
        self.stream_key = stream_key
        self.redis: aioredis.Redis | None = None

    async def connect(self):
        if not self.redis:
            self.redis = aioredis.from_url(self.redis_url, encoding="utf-8", decode_responses=True)
            log.info("Producer connected to Redis", stream_key=self.stream_key)

    async def publish_post(self, post_data: dict) -> str:
        """Publish a single raw post payload into Redis Stream."""
        if not self.redis:
            await self.connect()

        assert self.redis is not None
        payload_str = json.dumps(post_data)
        message_id = await self.redis.xadd(
            self.stream_key,
            fields={"payload": payload_str},
            maxlen=100000,
            approximate=True,
        )
        log.debug("Published raw post to stream", msg_id=message_id, platform=post_data.get("platform"))
        return message_id

    async def publish_batch(self, posts: list[dict]) -> int:
        """Publish a batch of raw posts into Redis Stream."""
        count = 0
        for post in posts:
            await self.publish_post(post)
            count += 1
        log.info("Published batch to Redis stream", count=count, stream=self.stream_key)
        return count

    async def close(self):
        if self.redis:
            await self.redis.aclose()
            self.redis = None
