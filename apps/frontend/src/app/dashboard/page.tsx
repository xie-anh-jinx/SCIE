'use client';

import { useAuth } from '@/contexts/AuthContext';
import { useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';
import { healthApi } from '@/lib/api';

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
    const interval = setInterval(fetchHealth, 30000); // refresh every 30s
    return () => clearInterval(interval);
  }, []);

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

  return (
    <div className="min-h-screen bg-gray-950">
      {/* Sidebar */}
      <aside className="fixed left-0 top-0 h-full w-64 bg-gray-900 border-r border-gray-800 flex flex-col">
        {/* Logo */}
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

        {/* Nav */}
        <nav className="flex-1 p-4 space-y-1">
          {[
            { icon: '🏠', label: 'Dashboard', href: '/dashboard', active: true },
            { icon: '📊', label: 'Analytics', href: '/analytics', active: false },
            { icon: '🕸️', label: 'Knowledge Graph', href: '/graph', active: false },
            { icon: '📡', label: 'Data Sources', href: '/sources', active: false },
            { icon: '🔔', label: 'Alerts', href: '/alerts', active: false },
            { icon: '🦙', label: 'AI Chat', href: '/chat', active: false },
            { icon: '📄', label: 'Reports', href: '/reports', active: false },
          ].map((item) => (
            <a
              key={item.href}
              href={item.href}
              className={`flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-colors ${
                item.active
                  ? 'bg-violet-600/20 text-violet-300 border border-violet-500/20'
                  : 'text-gray-400 hover:text-gray-200 hover:bg-gray-800'
              }`}
            >
              <span>{item.icon}</span>
              <span>{item.label}</span>
            </a>
          ))}
        </nav>

        {/* User info */}
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
            className="w-full text-xs text-gray-500 hover:text-red-400 transition-colors py-1"
          >
            Keluar
          </button>
        </div>
      </aside>

      {/* Main Content */}
      <main className="ml-64 p-8">
        {/* Header */}
        <div className="mb-8">
          <div className="flex items-center gap-3 mb-2">
            <h1 className="text-2xl font-bold text-white">Dashboard</h1>
            <span className="px-2 py-0.5 rounded-full text-xs bg-violet-500/10 text-violet-400 border border-violet-500/20">
              Fase 1 — Fondasi
            </span>
          </div>
          <p className="text-gray-500">
            Selamat datang, <span className="text-gray-300">{user.full_name || user.username}</span>. 
            Infrastruktur SCIE sedang aktif.
          </p>
        </div>

        {/* Services Health Grid */}
        <section className="mb-8">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-sm font-semibold text-gray-400 uppercase tracking-wider">
              Status Infrastruktur
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
                <div key={i} className="h-24 bg-gray-800 rounded-xl animate-pulse" />
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
                    {svc.latency_ms && (
                      <div className="text-xs text-gray-600 mt-0.5">{svc.latency_ms}ms</div>
                    )}
                  </div>
                );
              })}
            </div>
          ) : (
            <div className="p-6 bg-gray-900 border border-gray-800 rounded-xl text-gray-500 text-sm">
              ⚠ Tidak dapat terhubung ke API. Pastikan backend berjalan di port 8000.
            </div>
          )}
        </section>

        {/* Phase Progress */}
        <section>
          <h2 className="text-sm font-semibold text-gray-400 uppercase tracking-wider mb-4">
            Progress Pembangunan
          </h2>
          <div className="space-y-3">
            {[
              { phase: '1', label: 'Fondasi & Infrastruktur', progress: 85, status: 'active' },
              { phase: '2', label: 'Data Ingestion & NLP Core', progress: 0, status: 'pending' },
              { phase: '3', label: 'Knowledge Graph & Analytics', progress: 0, status: 'pending' },
              { phase: '4', label: 'Intelligence & AI (Llama)', progress: 0, status: 'pending' },
              { phase: '5', label: 'Scale & Enterprise', progress: 0, status: 'pending' },
            ].map((item) => (
              <div key={item.phase} className="flex items-center gap-4 p-4 bg-gray-900 border border-gray-800 rounded-xl">
                <div className={`w-8 h-8 rounded-lg flex items-center justify-center text-xs font-bold shrink-0 ${
                  item.status === 'active' ? 'bg-violet-600 text-white' : 'bg-gray-800 text-gray-500'
                }`}>
                  {item.phase}
                </div>
                <div className="flex-1">
                  <div className="flex items-center justify-between mb-1.5">
                    <span className={`text-sm font-medium ${item.status === 'active' ? 'text-white' : 'text-gray-500'}`}>
                      {item.label}
                    </span>
                    <span className="text-xs text-gray-500">{item.progress}%</span>
                  </div>
                  <div className="h-1.5 bg-gray-800 rounded-full overflow-hidden">
                    <div
                      className="h-full bg-gradient-to-r from-violet-600 to-blue-500 rounded-full transition-all duration-1000"
                      style={{ width: `${item.progress}%` }}
                    />
                  </div>
                </div>
              </div>
            ))}
          </div>
        </section>
      </main>
    </div>
  );
}
