'use client';

import { useAuth } from '@/contexts/AuthContext';
import { useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';
import { analyticsApi, TrendItem, InfluencerItem } from '@/lib/api';

export default function AnalyticsPage() {
  const { user, logout, isLoading } = useAuth();
  const router = useRouter();

  const [trends, setTrends] = useState<TrendItem[]>([]);
  const [influencers, setInfluencers] = useState<InfluencerItem[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!isLoading && !user) {
      router.push('/login');
    }
  }, [user, isLoading, router]);

  useEffect(() => {
    if (user) {
      Promise.all([analyticsApi.getTrends(), analyticsApi.getInfluencers()])
        .then(([tData, iData]) => {
          setTrends(tData.trends || []);
          setInfluencers(iData.influencers || []);
        })
        .finally(() => setLoading(false));
    }
  }, [user]);

  if (isLoading || !user) {
    return (
      <div className="min-h-screen bg-gray-950 flex items-center justify-center">
        <div className="text-gray-400 animate-pulse">Memuat...</div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-950">
      {/* Sidebar */}
      <aside className="fixed left-0 top-0 h-full w-64 bg-gray-900 border-r border-gray-800 flex flex-col z-20">
        <div className="p-6 border-b border-gray-800">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-lg bg-gradient-to-br from-violet-600 to-blue-600 flex items-center justify-center text-white font-bold">
              S
            </div>
            <div>
              <div className="font-bold text-white text-sm">SCIE</div>
              <div className="text-xs text-gray-500">Social Intelligence</div>
            </div>
          </div>
        </div>

        <nav className="flex-1 p-4 space-y-1">
          {[
            { icon: '🏠', label: 'Dashboard', href: '/dashboard', active: false },
            { icon: '📊', label: 'Analytics', href: '/analytics', active: true },
            { icon: '🕸️', label: 'Knowledge Graph', href: '/graph', active: false },
            { icon: '📡', label: 'Data Sources', href: '/sources', active: false },
            { icon: '🔔', label: 'Alerts', href: '/alerts', active: false },
            { icon: '🦙', label: 'AI Chat (Llama)', href: '/chat', active: false },
          ].map((item) => (
            <a
              key={item.href}
              href={item.href}
              className={`flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-colors ${
                item.active
                  ? 'bg-violet-600/20 text-violet-300 border border-violet-500/20 font-medium'
                  : 'text-gray-400 hover:text-gray-200 hover:bg-gray-800'
              }`}
            >
              <span>{item.icon}</span>
              <span>{item.label}</span>
            </a>
          ))}
        </nav>

        <div className="p-4 border-t border-gray-800">
          <button onClick={logout} className="w-full text-xs text-gray-500 hover:text-red-400 py-1 text-left">
            ← Keluar
          </button>
        </div>
      </aside>

      {/* Main Content */}
      <main className="ml-64 p-8">
        <div className="mb-8">
          <div className="flex items-center gap-3 mb-1">
            <h1 className="text-2xl font-bold text-white">Analytics & Trend Engine</h1>
            <span className="px-2 py-0.5 rounded-full text-xs bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
              Fase 3 — Social Network Analysis
            </span>
          </div>
          <p className="text-gray-500 text-sm">
            Deteksi tren topik, skor virilitas, dan peringkat influencer berpengaruh secara real-time.
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          {/* Trending Topics Card */}
          <div className="p-6 bg-gray-900 border border-gray-800 rounded-2xl">
            <h2 className="text-base font-semibold text-white mb-4 flex items-center justify-between">
              <span>🔥 Topik Trending Saat Ini</span>
              <span className="text-xs text-gray-500 font-normal">Real-time Volume</span>
            </h2>

            {loading ? (
              <div className="space-y-3">
                {[...Array(4)].map((_, i) => (
                  <div key={i} className="h-14 bg-gray-800 rounded-xl animate-pulse" />
                ))}
              </div>
            ) : (
              <div className="space-y-3">
                {trends.map((t, idx) => (
                  <div
                    key={t.topic}
                    className="p-4 bg-gray-950/80 border border-gray-800 rounded-xl flex items-center justify-between"
                  >
                    <div className="flex items-center gap-3">
                      <span className="w-6 h-6 rounded-md bg-violet-600/20 text-violet-400 flex items-center justify-center text-xs font-bold">
                        #{idx + 1}
                      </span>
                      <div>
                        <div className="text-sm font-semibold text-white">{t.topic}</div>
                        <div className="text-xs text-gray-500">{t.volume} postingan diproses</div>
                      </div>
                    </div>

                    <div className="text-right">
                      <div className="text-sm font-bold text-emerald-400">Score: {t.trend_score}</div>
                      <div className="text-xs text-gray-500">Sentimen: {t.avg_sentiment}</div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>

          {/* Key Influencer Leaderboard Card */}
          <div className="p-6 bg-gray-900 border border-gray-800 rounded-2xl">
            <h2 className="text-base font-semibold text-white mb-4 flex items-center justify-between">
              <span>👑 Aktor Kunci / Influencer</span>
              <span className="text-xs text-gray-500 font-normal">PageRank & Influence Score</span>
            </h2>

            {loading ? (
              <div className="space-y-3">
                {[...Array(4)].map((_, i) => (
                  <div key={i} className="h-14 bg-gray-800 rounded-xl animate-pulse" />
                ))}
              </div>
            ) : (
              <div className="space-y-3">
                {influencers.map((inf) => (
                  <div
                    key={inf.id}
                    className="p-4 bg-gray-950/80 border border-gray-800 rounded-xl flex items-center justify-between"
                  >
                    <div className="flex items-center gap-3">
                      <div className="w-9 h-9 rounded-full bg-gradient-to-br from-violet-500 to-blue-500 flex items-center justify-center text-white text-xs font-bold">
                        {inf.username[0].toUpperCase()}
                      </div>
                      <div>
                        <div className="text-sm font-semibold text-white">@{inf.username}</div>
                        <div className="text-xs text-gray-500">{inf.display_name}</div>
                      </div>
                    </div>

                    <div className="text-right">
                      <div className="text-sm font-bold text-violet-400">Reach: {inf.follower_count.toLocaleString()}</div>
                      <div className="text-xs text-gray-500">{inf.community_id}</div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </main>
    </div>
  );
}
