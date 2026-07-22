'use client';

import { useAuth } from '@/contexts/AuthContext';
import { useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';
import { healthApi, postsApi, Post, PostStats } from '@/lib/api';

interface ServiceStatus {
  status: 'ok' | 'degraded' | 'down';
  message?: string;
  latency_ms?: number;
}

interface HealthData {
  status: string;
  version: string;
  environment: string;
  services: Record<string, ServiceStatus>;
}

const SERVICE_LABELS: Record<string, { label: string; icon: string }> = {
  postgresql: { label: 'PostgreSQL', icon: '🗄️' },
  redis: { label: 'Redis Streams', icon: '⚡' },
  neo4j: { label: 'Neo4j Graph', icon: '🕸️' },
  ollama: { label: 'Llama (Ollama)', icon: '🦙' },
  elasticsearch: { label: 'Elasticsearch', icon: '🔍' },
  qdrant: { label: 'Qdrant Vectors', icon: '📐' },
};

export default function DashboardPage() {
  const { user, logout, isLoading } = useAuth();
  const router = useRouter();

  const [health, setHealth] = useState<HealthData | null>(null);
  const [healthLoading, setHealthLoading] = useState(true);

  const [posts, setPosts] = useState<Post[]>([]);
  const [stats, setStats] = useState<PostStats | null>(null);
  const [dataLoading, setDataLoading] = useState(true);

  const [sentimentFilter, setSentimentFilter] = useState<string>('');
  const [searchQuery, setSearchQuery] = useState<string>('');

  useEffect(() => {
    if (!isLoading && !user) {
      router.push('/login');
    }
  }, [user, isLoading, router]);

  useEffect(() => {
    const fetchHealth = async () => {
      try {
        const data = await healthApi.check();
        setHealth(data);
      } catch {
        setHealth(null);
      } finally {
        setHealthLoading(false);
      }
    };
    fetchHealth();
    const interval = setInterval(fetchHealth, 30000);
    return () => clearInterval(interval);
  }, []);

  const loadPostsData = async () => {
    setDataLoading(true);
    try {
      const [postsRes, statsRes] = await Promise.all([
        postsApi.list({ sentiment: sentimentFilter || undefined, search: searchQuery || undefined }),
        postsApi.getStats(),
      ]);
      setPosts(postsRes.items || []);
      setStats(statsRes);
    } catch {
      setPosts([]);
    } finally {
      setDataLoading(false);
    }
  };

  useEffect(() => {
    if (user) {
      loadPostsData();
    }
  }, [user, sentimentFilter]);

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    loadPostsData();
  };

  if (isLoading || !user) {
    return (
      <div className="min-h-screen bg-gray-950 flex items-center justify-center">
        <div className="text-gray-400 animate-pulse">Memuat...</div>
      </div>
    );
  }

  const statusColor = {
    ok: 'text-emerald-400 bg-emerald-400/10 border-emerald-500/20',
    degraded: 'text-amber-400 bg-amber-400/10 border-amber-500/20',
    down: 'text-red-400 bg-red-400/10 border-red-500/20',
  };

  const statusDot = {
    ok: 'bg-emerald-400',
    degraded: 'bg-amber-400 animate-pulse',
    down: 'bg-red-400',
  };

  const sentimentBadge = (label?: string | null) => {
    switch (label?.toLowerCase()) {
      case 'positive':
        return <span className="px-2 py-0.5 rounded text-xs bg-emerald-500/20 text-emerald-300 border border-emerald-500/30">😊 Positif</span>;
      case 'negative':
        return <span className="px-2 py-0.5 rounded text-xs bg-red-500/20 text-red-300 border border-red-500/30">😡 Negatif</span>;
      default:
        return <span className="px-2 py-0.5 rounded text-xs bg-gray-500/20 text-gray-300 border border-gray-500/30">😐 Netral</span>;
    }
  };

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
            { icon: '🏠', label: 'Dashboard', href: '/dashboard', active: true },
            { icon: '📊', label: 'Analytics', href: '/analytics', active: false },
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
          <div className="flex items-center gap-3 mb-3">
            <div className="w-8 h-8 rounded-full bg-gradient-to-br from-violet-500 to-blue-500 flex items-center justify-center text-white text-sm font-semibold">
              {user.username[0].toUpperCase()}
            </div>
            <div className="flex-1 min-w-0">
              <div className="text-sm font-medium text-white truncate">{user.username}</div>
              <div className="text-xs text-gray-500 capitalize">{user.role}</div>
            </div>
          </div>
          <button
            onClick={logout}
            className="w-full text-xs text-gray-500 hover:text-red-400 transition-colors py-1 text-left"
          >
            ← Keluar
          </button>
        </div>
      </aside>

      {/* Main Content */}
      <main className="ml-64 p-8">
        {/* Header */}
        <div className="mb-8 flex items-center justify-between">
          <div>
            <div className="flex items-center gap-3 mb-2">
              <h1 className="text-2xl font-bold text-white">Dashboard Monitoring</h1>
              <span className="px-2 py-0.5 rounded-full text-xs bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
                Fase 2 — Data & NLP Active
              </span>
            </div>
            <p className="text-gray-500">
              Selamat datang, <span className="text-gray-300">{user.full_name || user.username}</span>. 
              Data percakapan diproses secara otomatis melalui NLP pipeline.
            </p>
          </div>
          <button
            onClick={loadPostsData}
            className="px-4 py-2 bg-violet-600 hover:bg-violet-500 text-white rounded-lg text-sm font-medium transition-colors"
          >
            ↻ Refresh Data
          </button>
        </div>

        {/* Stats Metric Cards */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
          <div className="p-5 rounded-xl border border-gray-800 bg-gray-900">
            <div className="text-xs text-gray-500 mb-1 font-medium">Total Posts Diproses</div>
            <div className="text-3xl font-bold text-white">{stats?.total_posts ?? 0}</div>
            <div className="text-xs text-emerald-400 mt-2">Real-time Redis Streams</div>
          </div>
          <div className="p-5 rounded-xl border border-gray-800 bg-gray-900">
            <div className="text-xs text-gray-500 mb-1 font-medium">Sentimen Positif</div>
            <div className="text-3xl font-bold text-emerald-400">{stats?.sentiment_breakdown?.positive ?? 0}</div>
            <div className="text-xs text-gray-500 mt-2">IndoBERT / Lexicon Score &gt; 0.15</div>
          </div>
          <div className="p-5 rounded-xl border border-gray-800 bg-gray-900">
            <div className="text-xs text-gray-500 mb-1 font-medium">Sentimen Negatif</div>
            <div className="text-3xl font-bold text-red-400">{stats?.sentiment_breakdown?.negative ?? 0}</div>
            <div className="text-xs text-gray-500 mt-2">IndoBERT / Lexicon Score &lt; -0.15</div>
          </div>
          <div className="p-5 rounded-xl border border-gray-800 bg-gray-900">
            <div className="text-xs text-gray-500 mb-1 font-medium">Platform Aktif</div>
            <div className="text-3xl font-bold text-violet-400">
              {Object.keys(stats?.platform_breakdown || {}).length || 2}
            </div>
            <div className="text-xs text-gray-500 mt-2">RSS News & Twitter/X</div>
          </div>
        </div>

        {/* Live Social Content Feed & Filters */}
        <section className="mb-8">
          <div className="flex flex-col md:flex-row items-start md:items-center justify-between gap-4 mb-6">
            <h2 className="text-lg font-bold text-white">Live Intelligence Feed</h2>

            <div className="flex items-center gap-3 w-full md:w-auto">
              <form onSubmit={handleSearch} className="flex-1 md:w-64">
                <input
                  type="text"
                  placeholder="Cari kata kunci..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="w-full px-3 py-1.5 bg-gray-900 border border-gray-800 rounded-lg text-sm text-white placeholder-gray-600 focus:outline-none focus:border-violet-500"
                />
              </form>
              <select
                value={sentimentFilter}
                onChange={(e) => setSentimentFilter(e.target.value)}
                className="px-3 py-1.5 bg-gray-900 border border-gray-800 rounded-lg text-sm text-gray-300 focus:outline-none focus:border-violet-500"
              >
                <option value="">Semua Sentimen</option>
                <option value="positive">Positif</option>
                <option value="neutral">Netral</option>
                <option value="negative">Negatif</option>
              </select>
            </div>
          </div>

          {dataLoading ? (
            <div className="space-y-4">
              {[...Array(3)].map((_, i) => (
                <div key={i} className="h-32 bg-gray-900 border border-gray-800 rounded-xl animate-pulse" />
              ))}
            </div>
          ) : posts.length > 0 ? (
            <div className="space-y-4">
              {posts.map((post) => (
                <div
                  key={post.id}
                  className="p-5 bg-gray-900 border border-gray-800 hover:border-gray-700 rounded-xl transition-all"
                >
                  <div className="flex items-center justify-between mb-3">
                    <div className="flex items-center gap-2">
                      <span className="px-2 py-0.5 rounded text-xs uppercase bg-violet-500/10 text-violet-400 border border-violet-500/20 font-medium">
                        {post.platform}
                      </span>
                      {sentimentBadge(post.sentiment_label)}
                      {post.virality_score > 0 && (
                        <span className="text-xs text-amber-400 bg-amber-500/10 border border-amber-500/20 px-2 py-0.5 rounded">
                          🔥 Virality: {post.virality_score}
                        </span>
                      )}
                    </div>
                    <div className="text-xs text-gray-500">
                      {new Date(post.collected_at).toLocaleTimeString('id-ID', { hour: '2-digit', minute: '2-digit' })}
                    </div>
                  </div>

                  <p className="text-gray-200 text-sm mb-4 leading-relaxed whitespace-pre-line">
                    {post.text}
                  </p>

                  <div className="flex flex-wrap items-center gap-2 text-xs">
                    {post.topics?.map((topic) => (
                      <span key={topic} className="px-2 py-0.5 rounded bg-gray-800 text-gray-300">
                        #{topic}
                      </span>
                    ))}
                    {post.keywords?.map((kw) => (
                      <span key={kw} className="px-2 py-0.5 rounded bg-gray-800/50 text-gray-500">
                        {kw}
                      </span>
                    ))}
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="p-8 bg-gray-900 border border-gray-800 rounded-xl text-center text-gray-500 text-sm">
              Belum ada data percakapan. Jalankan ingestion runner untuk menarik berita dan postingan terbaru.
            </div>
          )}
        </section>

        {/* Services Health Status */}
        <section className="mb-8">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-sm font-semibold text-gray-400 uppercase tracking-wider">
              Status Infrastruktur Services
            </h2>
            {health && (
              <span className={`text-xs px-2 py-1 rounded-full border ${statusColor[health.status as keyof typeof statusColor] || statusColor.down}`}>
                {health.status === 'ok' ? '✓ Semua sistem normal' : `⚠ ${health.status}`}
              </span>
            )}
          </div>

          {healthLoading ? (
            <div className="grid grid-cols-2 lg:grid-cols-3 gap-4">
              {[...Array(6)].map((_, i) => (
                <div key={i} className="h-20 bg-gray-900 border border-gray-800 rounded-xl animate-pulse" />
              ))}
            </div>
          ) : health ? (
            <div className="grid grid-cols-2 lg:grid-cols-3 gap-4">
              {Object.entries(health.services).map(([key, svc]) => {
                const meta = SERVICE_LABELS[key] || { label: key, icon: '🔧' };
                const s = svc.status as 'ok' | 'degraded' | 'down';
                return (
                  <div
                    key={key}
                    className={`p-4 rounded-xl border bg-gray-900 ${statusColor[s]}`}
                  >
                    <div className="flex items-center justify-between mb-2">
                      <span className="text-lg">{meta.icon}</span>
                      <span className={`w-2 h-2 rounded-full ${statusDot[s]}`} />
                    </div>
                    <div className="text-sm font-medium text-gray-200">{meta.label}</div>
                    <div className="text-xs text-gray-500 mt-1 truncate">
                      {svc.message || (s === 'ok' ? 'Connected' : 'Unavailable')}
                    </div>
                  </div>
                );
              })}
            </div>
          ) : null}
        </section>
      </main>
    </div>
  );
}
