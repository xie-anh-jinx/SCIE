'use client';

import { useAuth } from '@/contexts/AuthContext';
import { useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';
import { alertsApi, AlertItem } from '@/lib/api';

export default function AlertsPage() {
  const { user, logout, isLoading } = useAuth();
  const router = useRouter();

  const [alerts, setAlerts] = useState<AlertItem[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!isLoading && !user) {
      router.push('/login');
    }
  }, [user, isLoading, router]);

  useEffect(() => {
    if (user) {
      alertsApi
        .list()
        .then((res) => setAlerts(res.alerts || []))
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

  const severityBadge = (severity: string) => {
    switch (severity) {
      case 'HIGH':
        return <span className="px-2.5 py-0.5 rounded text-xs bg-red-500/20 text-red-400 border border-red-500/30 font-bold">🔴 High Severity</span>;
      case 'MEDIUM':
        return <span className="px-2.5 py-0.5 rounded text-xs bg-amber-500/20 text-amber-400 border border-amber-500/30 font-semibold">🟡 Medium</span>;
      default:
        return <span className="px-2.5 py-0.5 rounded text-xs bg-blue-500/20 text-blue-400 border border-blue-500/30">🔵 Info</span>;
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
            { icon: '🏠', label: 'Dashboard', href: '/dashboard', active: false },
            { icon: '📊', label: 'Analytics', href: '/analytics', active: false },
            { icon: '🕸️', label: 'Knowledge Graph', href: '/graph', active: false },
            { icon: '📡', label: 'Data Sources', href: '/sources', active: false },
            { icon: '🔔', label: 'Alerts', href: '/alerts', active: true },
            { icon: '🦙', label: 'AI Chat (Llama)', href: '/chat', active: false },
            { icon: '📄', label: 'Reports', href: '/reports', active: false },
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
      <main className="ml-64 p-8 max-w-5xl">
        <div className="mb-8">
          <div className="flex items-center gap-3 mb-1">
            <h1 className="text-2xl font-bold text-white">Alerts & Anomaly Detection</h1>
            <span className="px-2 py-0.5 rounded-full text-xs bg-red-500/10 text-red-400 border border-red-500/20">
              Real-time Alerting
            </span>
          </div>
          <p className="text-gray-500 text-sm">
            Notifikasi otomatis saat terjadi lonjakan volume percakapan, pergeseran sentimen, atau pergerakan aktor publik.
          </p>
        </div>

        {loading ? (
          <div className="space-y-4">
            {[...Array(3)].map((_, i) => (
              <div key={i} className="h-28 bg-gray-900 border border-gray-800 rounded-xl animate-pulse" />
            ))}
          </div>
        ) : (
          <div className="space-y-4">
            {alerts.map((a) => (
              <div
                key={a.id}
                className="p-5 bg-gray-900 border border-gray-800 rounded-xl hover:border-gray-700 transition-all flex flex-col md:flex-row items-start md:items-center justify-between gap-4"
              >
                <div className="space-y-2">
                  <div className="flex items-center gap-3">
                    {severityBadge(a.severity)}
                    <span className="text-xs text-gray-500 font-mono">{a.type}</span>
                  </div>
                  <h3 className="text-base font-semibold text-white">{a.title}</h3>
                  <p className="text-sm text-gray-400">{a.description}</p>
                </div>

                <div className="text-right shrink-0">
                  <div className="text-xs text-gray-500 mb-2">
                    {new Date(a.created_at).toLocaleString('id-ID')}
                  </div>
                  <span className={`px-3 py-1 rounded-full text-xs font-semibold ${
                    a.status === 'ACTIVE' ? 'bg-emerald-500/20 text-emerald-300' : 'bg-gray-800 text-gray-400'
                  }`}>
                    {a.status}
                  </span>
                </div>
              </div>
            ))}
          </div>
        )}
      </main>
    </div>
  );
}
