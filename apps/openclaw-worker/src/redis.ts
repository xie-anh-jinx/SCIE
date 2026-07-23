import Redis from 'ioredis';

const REDIS_HOST = process.env.REDIS_HOST || '127.0.0.1';
const REDIS_PORT = parseInt(process.env.REDIS_PORT || '6381', 10);
const STREAM_NAME = process.env.REDIS_STREAM_RAW_POSTS || 'stream:raw_posts';

export const redisClient = new Redis({
  host: REDIS_HOST,
  port: REDIS_PORT,
  maxRetriesPerRequest: 3,
});

export interface RawScrapedPost {
  platform: 'facebook' | 'instagram' | 'tiktok';
  platform_id: string;
  author_username: string;
  author_display_name?: string;
  text: string;
  url?: string;
  timestamp?: string;
  metrics?: {
    likes?: number;
    comments?: number;
    shares?: number;
    views?: number;
  };
  location_name?: string;
  province?: string;
}

export async function pushToRawPostsStream(post: RawScrapedPost): Promise<string> {
  const fields = [
    'platform', post.platform,
    'platform_id', post.platform_id,
    'author_username', post.author_username,
    'author_display_name', post.author_display_name || post.author_username,
    'text', post.text,
    'url', post.url || '',
    'timestamp', post.timestamp || new Date().toISOString(),
    'location_name', post.location_name || 'Makassar',
    'province', post.province || 'Sulawesi Selatan',
    'metrics', JSON.stringify(post.metrics || { likes: 12, comments: 4, shares: 2 }),
  ];

  const streamId = await redisClient.xadd(STREAM_NAME, '*', ...fields);
  console.log(`[OpenClaw Worker] Pushed ${post.platform} post from ${post.location_name} to ${STREAM_NAME} (ID: ${streamId})`);
  return streamId || '';
}
