'use client';

import { useAuth } from '@/contexts/AuthContext';
import { useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';
import { sourcesApi, DataSource } from '@/lib/api';

export default function SourcesPage() {
  const { user, logout, isLoading } = useAuth();
  const router = useRouter();

  const [sources, setSources] = useState<DataSource[]>([]);
  const [loading, setLoading] = useState(true);
  const [triggeringId, setTriggeringId] = useState<string | null>(null);

  // New source form state
  const [name, setName] = useState('');
  const [platform, setPlatform] = useState('rss');
  const [feedUrl, setFeedUrl] = useState('');
  const [keywords, setKeywords] = useState('');
  const [creating, setCreating] = useState(false);

  useEffect(() => {
    if (!isLoading && !user) {
      router.push('/login');
    }
  }, [user, isLoading, router]);

  const loadSources = async () => {
    try {
      const data = await sourcesApi.list();
      setSources(data || []);
    } catch {
      setSources([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (user) loadSources();
  }, [user]);

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim()) return;

    setCreating(true);
    try {
      await sourcesApi.create({
        name,
        platform,
        config: { url: feedUrl },
        keywords: keywords.split(',').map((k) => k.trim()).filter(Boolean),
        is_active: true,
      });
      setName('');
      setFeedUrl('');
      setKeywords('');
      await loadSources();
    } catch {
      alert('Gagal menambahkan data source.');
    } finally {
      setCreating(false);
    }
  };

  const handleTrigger = async (id: string) => {
    setTriggeringId(id);
    try {
      await sourcesApi.trigger(id);
      alert('Job pengumpulan data berhasil dimasukkan ke antrean Redis Stream!');
      await loadSources();
    } catch {
      alert('Gagal memicu pengumpulan data.');
    } finally {
      setTriggeringId(null);
    }
  };

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
            { icon: '📊', label: 'Analytics', href: '/analytics', active: false },
            { icon: '🕸️', label: 'Knowledge Graph', href: '/graph', active: false },
            { icon: '📡', label: 'Data Sources', href: '/sources', active: true },
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
            <h1 className="text-2xl font-bold text-white">Data Sources & Connectors</h1>
            <span className="px-2 py-0.5 rounded-full text-xs bg-violet-500/10 text-violet-400 border border-violet-500/20">
              Ingestion Pipeline Active
            </span>
          </div>
          <p className="text-gray-500 text-sm">
            Kelola sumber berita RSS, feed media sosial, dan pemicu pengumpulan data otomatis.
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Add New Source Form */}
          <div className="p-6 bg-gray-900 border border-gray-800 rounded-2xl">
            <h2 className="text-base font-semibold text-white mb-4">Tambah Data Source Baru</h2>
            <form onSubmit={handleCreate} className="space-y-4">
              <div>
                <label className="block text-xs font-medium text-gray-400 mb-1">Nama Connector</label>
                <input
                  type="text"
                  placeholder="Contoh: Antara News RSS"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  required
                  className="w-full px-3 py-2 bg-gray-950 border border-gray-800 rounded-lg text-sm text-white focus:outline-none focus:border-violet-500"
                />
              </div>

              <div>
                <label className="block text-xs font-medium text-gray-400 mb-1">Platform</label>
                <select
                  value={platform}
                  onChange={(e) => setPlatform(e.target.value)}
                  className="w-full px-3 py-2 bg-gray-950 border border-gray-800 rounded-lg text-sm text-white focus:outline-none focus:border-violet-500"
                >
                  <option value="rss">RSS / News Feed</option>
                  <option value="twitter">Twitter / X Stream</option>
                  <option value="news">Web Scraper</option>
                </select>
              </div>

              {platform === 'rss' && (
                <div>
                  <label className="block text-xs font-medium text-gray-400 mb-1">URL RSS Feed</label>
                  <input
                    type="url"
                    placeholder="https://www.antaranews.com/rss/terkini.xml"
                    value={feedUrl}
                    onChange={(e) => setFeedUrl(e.target.value)}
                    className="w-full px-3 py-2 bg-gray-950 border border-gray-800 rounded-lg text-sm text-white focus:outline-none focus:border-violet-500"
                  />
                </div>
              )}

              <div>
                <label className="block text-xs font-medium text-gray-400 mb-1">Target Kata Kunci (Dipisah koma)</label>
                <input
                  type="text"
                  placeholder="ekonomi, teknologi, kebijakan"
                  value={keywords}
                  onChange={(e) => setKeywords(e.target.value)}
                  className="w-full px-3 py-2 bg-gray-950 border border-gray-800 rounded-lg text-sm text-white focus:outline-none focus:border-violet-500"
                />
              </div>

              <button
                type="submit"
                disabled={creating || !name.trim()}
                className="w-full py-2.5 bg-violet-600 hover:bg-violet-500 disabled:bg-violet-600/40 text-white rounded-lg text-sm font-semibold transition-all"
              >
                {creating ? 'Menyimpan...' : 'Simpan Connector'}
              </button>
            </form>
          </div>

          {/* Active Sources List */}
          <div className="lg:col-span-2 p-6 bg-gray-900 border border-gray-800 rounded-2xl">
            <h2 className="text-base font-semibold text-white mb-4">Data Source Terdaftar</h2>

            {loading ? (
              <div className="space-y-3">
                {[...Array(3)].map((_, i) => (
                  <div key={i} className="h-20 bg-gray-800 rounded-xl animate-pulse" />
                ))}
              </div>
            ) : sources.length > 0 ? (
              <div className="space-y-3">
                {sources.map((s) => (
                  <div
                    key={s.id}
                    className="p-4 bg-gray-950/80 border border-gray-800 rounded-xl flex items-center justify-between"
                  >
                    <div>
                      <div className="flex items-center gap-2 mb-1">
                        <span className="text-sm font-semibold text-white">{s.name}</span>
                        <span className="px-2 py-0.5 rounded text-xs uppercase bg-violet-500/10 text-violet-400 border border-violet-500/20">
                          {s.platform}
                        </span>
                      </div>
                      <div className="text-xs text-gray-500">
                        Diproses: {s.posts_collected || 0} postingan · Terakhir: {s.last_run_at ? new Date(s.last_run_at).toLocaleString('id-ID') : 'Belum pernah'}
                      </div>
                    </div>

                    <button
                      onClick={() => handleTrigger(s.id)}
                      disabled={triggeringId === s.id}
                      className="px-3 py-1.5 bg-gray-800 hover:bg-gray-700 text-gray-200 rounded-lg text-xs font-medium border border-gray-700 transition-colors"
                    >
                      {triggeringId === s.id ? 'Memulai...' : '▶ Jalankan Sekarang'}
                    </button>
                  </div>
                ))}
              </div>
            ) : (
              <div className="p-8 bg-gray-950 border border-gray-800 rounded-xl text-center text-gray-500 text-sm">
                Belum ada Data Source kustom. Gunakan formulir di samping untuk mendaftarkan RSS atau Twitter connector.
              </div>
            )}
          </div>
        </div>
      </main>
    </div>
  );
}
