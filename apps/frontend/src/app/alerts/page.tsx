'use client';

import { useAuth } from '@/contexts/AuthContext';
import { useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';
import { alertsApi, AlertItem } from '@/lib/api';

export default function AlertsPage() {
  const { user, logout, isLoading } = useAuth();
  const router = useRouter();

  const [province, setProvince] = useState('Sulawesi Selatan');
  const [alerts, setAlerts] = useState<AlertItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [dispatchStatus, setDispatchStatus] = useState<Record<string, string>>({});

  useEffect(() => {
    if (!isLoading && !user) {
      router.push('/login');
    }
  }, [user, isLoading, router]);

  useEffect(() => {
    if (user) {
      fetchAlerts(province);
    }
  }, [user, province]);

  const fetchAlerts = async (targetProv: string) => {
    setLoading(true);
    try {
      const res = await alertsApi.list(targetProv, 7);
      setAlerts(res.alerts || []);
    } catch (err) {
      console.error('Failed to fetch alerts:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleDispatch = async (alertId: string) => {
    setDispatchStatus((prev) => ({ ...prev, [alertId]: 'SENDING...' }));
    try {
      const res = await alertsApi.dispatch(alertId);
      setDispatchStatus((prev) => ({ ...prev, [alertId]: '✅ TERKIRIM KE TELEGRAM' }));
    } catch (err) {
      console.error('Failed to dispatch alert:', err);
      setDispatchStatus((prev) => ({ ...prev, [alertId]: '❌ GAGAL' }));
    }
  };

  if (isLoading || !user) {
    return (
      <div className="min-h-screen bg-gray-950 flex items-center justify-center">
        <div className="text-gray-400 animate-pulse font-mono text-sm">Menginisialisasi Alerts Engine...</div>
      </div>
    );
  }

  const severityBadge = (severity: string) => {
    switch (severity) {
      case 'HIGH':
        return <span className="px-2.5 py-0.5 rounded text-xs bg-red-500/20 text-red-400 border border-red-500/30 font-bold">🔴 High Volatility</span>;
      case 'MEDIUM':
        return <span className="px-2.5 py-0.5 rounded text-xs bg-amber-500/20 text-amber-400 border border-amber-500/30 font-semibold">🟡 Medium</span>;
      default:
        return <span className="px-2.5 py-0.5 rounded text-xs bg-emerald-500/20 text-emerald-400 border border-emerald-500/30">🟢 Operational Info</span>;
    }
  };

  return (
    <div className="min-h-screen bg-gray-950 flex">
      {/* Sidebar */}
      <aside className="w-64 bg-gray-900 border-r border-gray-800 flex flex-col shrink-0">
        <div className="p-6 border-b border-gray-800">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-lg bg-gradient-to-br from-violet-600 to-blue-600 flex items-center justify-center text-white font-bold">
              S
            </div>
            <div>
              <div className="font-bold text-white text-sm">SCIE INDONESIA</div>
              <div className="text-[10px] text-emerald-400 font-mono">National Command Center</div>
            </div>
          </div>
        </div>

        <nav className="flex-1 p-4 space-y-1">
          {[
            { icon: '🗺️', label: 'Situational Map', href: '/dashboard', active: false },
            { icon: '📊', label: 'Analytics & Trends', href: '/analytics', active: false },
            { icon: '🕸️', label: 'Knowledge Graph', href: '/graph', active: false },
            { icon: '📡', label: 'Data Sources', href: '/sources', active: false },
            { icon: '🔔', label: 'Alerts & Anomalies', href: '/alerts', active: true },
            { icon: '🦙', label: 'AI Intelligence (Llama)', href: '/chat', active: false },
            { icon: '📄', label: 'Executive Reports', href: '/reports', active: false },
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
            ← Keluar ({user.username})
          </button>
        </div>
      </aside>

      {/* Main Content */}
      <main className="flex-1 flex flex-col min-w-0 bg-gray-950 p-8">
        <header className="flex flex-col md:flex-row items-start md:items-center justify-between gap-4 pb-6 border-b border-gray-800">
          <div>
            <h1 className="text-2xl font-bold text-white tracking-wide">Peringatan Dini Anomali & Volatilitas (Phase 2)</h1>
            <p className="text-xs text-gray-400 mt-1">
              Deteksi Otomatis Lonjakan Virallitas (&gt;8.5), Pergeseran Sentimen Negatif, &amp; Isu Pilkada (7 Hari Terakhir)

            </p>
          </div>

          <div className="flex items-center gap-3">
            <select
              value={province}
              onChange={(e) => setProvince(e.target.value)}
              className="px-3 py-2 bg-gray-900 border border-gray-800 text-white rounded-lg text-xs font-semibold focus:outline-none focus:border-violet-500 cursor-pointer"
            >
              <option value="Sulawesi Selatan">📍 Sulawesi Selatan (Makassar)</option>
              <option value="DKI Jakarta">📍 DKI Jakarta</option>
              <option value="Papua">📍 Papua</option>
              <option value="Nasional">🇮🇩 Skala Nasional (38 Provinsi)</option>
            </select>

            <button
              onClick={() => fetchAlerts(province)}
              className="px-3 py-2 bg-gray-800 hover:bg-gray-700 text-gray-200 rounded-lg text-xs font-medium border border-gray-700"
            >
              🔄 Refresh Alerts
            </button>
          </div>
        </header>

        {/* Alert Cards Feed */}
        <div className="mt-6 space-y-4 max-w-5xl">
          {loading ? (
            <div className="py-12 text-center text-xs text-gray-500 animate-pulse font-mono">
              Memproses Anomaly Detection Engine...
            </div>
          ) : alerts.length === 0 ? (
            <div className="py-12 text-center text-xs text-gray-500">
              Tidak ada anomali berisiko tinggi ditemukan dalam 7 hari terakhir.
            </div>
          ) : (
            alerts.map((a) => (
              <div
                key={a.id}
                className="bg-gray-900 border border-gray-800 rounded-xl p-5 shadow-xl flex flex-col md:flex-row items-start md:items-center justify-between gap-4 transition-all hover:border-gray-700"
              >
                <div className="space-y-1.5 flex-1">
                  <div className="flex items-center gap-2">
                    {severityBadge(a.severity)}
                    <span className="text-[10px] font-mono text-gray-500 uppercase">{a.type}</span>
                    <span className="text-[10px] font-mono text-gray-500">
                      • {new Date(a.created_at).toLocaleTimeString('id-ID', { hour: '2-digit', minute: '2-digit' })}
                    </span>
                  </div>
                  <h3 className="text-sm font-bold text-white">{a.title}</h3>
                  <p className="text-xs text-gray-400 leading-relaxed">{a.description}</p>
                </div>

                <div className="flex items-center gap-3 shrink-0">
                  {dispatchStatus[a.id] ? (
                    <span className="text-xs font-mono font-bold text-emerald-400">{dispatchStatus[a.id]}</span>
                  ) : (
                    <button
                      onClick={() => handleDispatch(a.id)}
                      className="px-3.5 py-2 bg-violet-600 hover:bg-violet-500 text-white rounded-lg text-xs font-bold transition-all shadow-md flex items-center gap-1.5"
                    >
                      📱 Kirim ke Telegram Bot
                    </button>
                  )}
                </div>
              </div>
            ))
          )}
        </div>
      </main>
    </div>
  );
}
