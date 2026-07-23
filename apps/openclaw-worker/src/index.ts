import { chromium } from 'playwright';
import { pushToRawPostsStream } from './redis';
import { SULSEL_TARGET_KEYWORDS } from './scrapers/sulsel_targets';

console.log('[SCIE OpenClaw Worker] Starting Headless Browser Scraper for South Sulawesi (FB/IG/TikTok)...');

async function runScraperLoop() {
  const browser = await chromium.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage'],
  });

  const context = await browser.newContext({
    userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
    viewport: { width: 1280, height: 720 },
  });

  console.log('[OpenClaw] Browser instance initialized cleanly.');

  // Mock / Simulated Headless Scraper Cycle for South Sulawesi Public Social Feeds
  const sampleSocialFeeds = [
    {
      platform: 'facebook' as const,
      platform_id: `fb_sulsel_${Date.now()}_1`,
      author_username: 'makassar_info_publik',
      author_display_name: 'Info Makassar & Sulsel',
      text: 'Update situasi Pantai Losari Makassar malam ini terpantau ramai lancar dan kondusif.',
      url: 'https://facebook.com/groups/makassarinfo',
      location_name: 'Makassar',
      province: 'Sulawesi Selatan',
      metrics: { likes: 145, comments: 32, shares: 18 },
    },
    {
      platform: 'instagram' as const,
      platform_id: `ig_sulsel_${Date.now()}_2`,
      author_username: 'kuliner_makassar_hits',
      author_display_name: 'Kuliner Makassar',
      text: 'Pemantauan aktivitas pedagang UMKM Pasar Terong Makassar jelang akhir pekan.',
      url: 'https://instagram.com/p/C3makassar_123',
      location_name: 'Makassar',
      province: 'Sulawesi Selatan',
      metrics: { likes: 230, comments: 14, shares: 5 },
    },
    {
      platform: 'tiktok' as const,
      platform_id: `tt_sulsel_${Date.now()}_3`,
      author_username: 'warga_gowa_official',
      author_display_name: 'Warga Gowa Terkini',
      text: 'Kondisi lalu lintas Jalan Sultan Hasanuddin Gowa menuju Makassar sore ini.',
      url: 'https://tiktok.com/@warga_gowa/video/73112233',
      location_name: 'Gowa',
      province: 'Sulawesi Selatan',
      metrics: { likes: 520, comments: 45, shares: 89, views: 3200 },
    },
  ];

  for (const feed of sampleSocialFeeds) {
    try {
      await pushToRawPostsStream(feed);
    } catch (err) {
      console.error('[OpenClaw Worker Error]', err);
    }
  }

  // Periodic interval loop every 30 seconds
  setInterval(async () => {
    const timestamp = Date.now();
    const dynamicFeed = {
      platform: ['facebook', 'instagram', 'tiktok'][Math.floor(Math.random() * 3)] as 'facebook' | 'instagram' | 'tiktok',
      platform_id: `openclaw_sulsel_${timestamp}`,
      author_username: `sulsel_watch_${Math.floor(Math.random() * 100)}`,
      author_display_name: 'Pantauan Media Sosial Sulsel',
      text: `[OpenClaw Feed] Pantauan postingan publik wilayah Sulawesi Selatan - Keyword: ${SULSEL_TARGET_KEYWORDS[Math.floor(Math.random() * SULSEL_TARGET_KEYWORDS.length)]}`,
      url: 'https://social-media.com/post/' + timestamp,
      location_name: ['Makassar', 'Gowa', 'Maros', 'Parepare', 'Palopo', 'Selayar'][Math.floor(Math.random() * 6)],
      province: 'Sulawesi Selatan',
      metrics: { likes: Math.floor(Math.random() * 100), comments: Math.floor(Math.random() * 20) },
    };

    await pushToRawPostsStream(dynamicFeed);
  }, 30000);
}

runScraperLoop().catch(console.error);
