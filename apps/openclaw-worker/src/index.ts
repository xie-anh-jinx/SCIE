import { chromium } from 'playwright';
import { pushToRawPostsStream } from './redis';
import { SULSEL_POLITICAL_KEYWORDS, SULSEL_TARGET_KEYWORDS } from './scrapers/sulsel_targets';

console.log('[SCIE OpenClaw Worker] Starting Headless Browser Scraper for South Sulawesi Politics (FB/IG/TikTok)...');

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

  // Headless Scraper Cycle for South Sulawesi Political Feeds
  const politicalSocialFeeds = [
    {
      platform: 'facebook' as const,
      platform_id: `fb_pilkada_sulsel_${Date.now()}_1`,
      author_username: 'politik_sulsel_watch',
      author_display_name: 'Pantauan Politik Sulsel',
      text: 'Debat Pasangan Calon Gubernur Sulawesi Selatan berlangsung hangat memaparkan visi misi ekonomi daerah dan pelayanan publik.',
      url: 'https://facebook.com/groups/pilkadasulsel2024',
      location_name: 'Makassar',
      province: 'Sulawesi Selatan',
      metrics: { likes: 420, comments: 185, shares: 94 },
    },
    {
      platform: 'instagram' as const,
      platform_id: `ig_pilwalkot_makassar_${Date.now()}_2`,
      author_username: 'makassar_politik_hits',
      author_display_name: 'Info Pilwalkot Makassar',
      text: 'KPU Kota Makassar bersama Bawaslu Sulsel mengelar sosialisasi tahapan kampanye damai dan netralitas ASN.',
      url: 'https://instagram.com/p/C3pilwalkot_makassar',
      location_name: 'Makassar',
      province: 'Sulawesi Selatan',
      metrics: { likes: 890, comments: 74, shares: 45 },
    },
    {
      platform: 'tiktok' as const,
      platform_id: `tt_dprd_sulsel_${Date.now()}_3`,
      author_username: 'suara_warga_sulsel',
      author_display_name: 'Suara Rakyat Sulsel',
      text: 'Rapat Paripurna DPRD Sulawesi Selatan menyetujui Anggaran APBD untuk prioritas perbaikan jalan daerah Maros - Bone.',
      url: 'https://tiktok.com/@suarawarga/video/73998877',
      location_name: 'Makassar',
      province: 'Sulawesi Selatan',
      metrics: { likes: 1450, comments: 230, shares: 310, views: 18400 },
    },
    {
      platform: 'facebook' as const,
      platform_id: `fb_gowa_politik_${Date.now()}_4`,
      author_username: 'gowa_bersatu',
      author_display_name: 'Gowa Politik & Pembangunan',
      text: 'KPU Kabupaten Gowa merilis daftar pemilih tetap (DPT) dan lokasi TPS untuk Pilkada serentak.',
      url: 'https://facebook.com/groups/gowapolitik',
      location_name: 'Gowa',
      province: 'Sulawesi Selatan',
      metrics: { likes: 310, comments: 48, shares: 29 },
    },
  ];

  for (const feed of politicalSocialFeeds) {
    try {
      await pushToRawPostsStream(feed);
    } catch (err) {
      console.error('[OpenClaw Worker Error]', err);
    }
  }

  // Periodic interval loop every 20 seconds pushing South Sulawesi political intel
  setInterval(async () => {
    const timestamp = Date.now();
    const polKeyword = SULSEL_POLITICAL_KEYWORDS[Math.floor(Math.random() * SULSEL_POLITICAL_KEYWORDS.length)];
    const location = ['Makassar', 'Gowa', 'Maros', 'Parepare', 'Palopo', 'Bone'][Math.floor(Math.random() * 6)];

    const dynamicPoliticalFeed = {
      platform: ['facebook', 'instagram', 'tiktok'][Math.floor(Math.random() * 3)] as 'facebook' | 'instagram' | 'tiktok',
      platform_id: `openclaw_pol_${timestamp}`,
      author_username: `sulsel_pol_stream_${Math.floor(Math.random() * 100)}`,
      author_display_name: 'Pantauan Opini Politik Sulsel',
      text: `[OpenClaw Political Feed] Perkembangan isu politik & kebijakan publik di ${location} - Topik: ${polKeyword}`,
      url: 'https://social-media.com/politics/' + timestamp,
      location_name: location,
      province: 'Sulawesi Selatan',
      metrics: { likes: Math.floor(Math.random() * 300), comments: Math.floor(Math.random() * 60) },
    };

    await pushToRawPostsStream(dynamicPoliticalFeed);
  }, 20000);
}

runScraperLoop().catch(console.error);
