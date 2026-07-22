'use client';

import { useAuth } from '@/contexts/AuthContext';
import { useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';
import { reportsApi, ExecutiveReportData } from '@/lib/api';

export default function ReportsPage() {
  const { user, logout, isLoading } = useAuth();
  const router = useRouter();

  const [report, setReport] = useState<ExecutiveReportData | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!isLoading && !user) {
      router.push('/login');
    }
  }, [user, isLoading, router]);

  useEffect(() => {
    if (user) {
      reportsApi
        .getSummary()
        .then(setReport)
        .finally(() => setLoading(false));
    }
  }, [user]);

  const handlePrint = () => {
    window.print();
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
      <aside className="fixed left-0 top-0 h-full w-64 bg-gray-900 border-r border-gray-800 flex flex-col z-20 print:hidden">
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
            { icon: '🔔', label: 'Alerts', href: '/alerts', active: false },
            { icon: '🦙', label: 'AI Chat (Llama)', href: '/chat', active: false },
            { icon: '📄', label: 'Reports', href: '/reports', active: true },
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
      <main className="ml-64 p-8 max-w-4xl print:ml-0 print:p-0">
        <div className="mb-6 flex items-center justify-between print:hidden">
          <div>
            <h1 className="text-2xl font-bold text-white">Executive Intelligence Reports</h1>
            <p className="text-gray-500 text-sm">Laporan ringkasan analisis untuk pengambil keputusan.</p>
          </div>
          <button
            onClick={handlePrint}
            className="px-4 py-2 bg-violet-600 hover:bg-violet-500 text-white rounded-lg text-sm font-semibold transition-colors flex items-center gap-2"
          >
            🖨️ Cetak / Ekspor PDF
          </button>
        </div>

        {loading ? (
          <div className="h-64 bg-gray-900 border border-gray-800 rounded-2xl animate-pulse" />
        ) : report ? (
          <div className="p-8 bg-gray-900 border border-gray-800 rounded-2xl text-gray-200 print:bg-white print:text-black print:border-none space-y-6">
            <div className="border-b border-gray-800 print:border-gray-300 pb-6">
              <div className="text-xs uppercase tracking-wider text-violet-400 font-semibold mb-1">
                SCIE Executive Report
              </div>
              <h2 className="text-2xl font-bold text-white print:text-black mb-2">{report.title}</h2>
              <div className="text-xs text-gray-500 print:text-gray-600 flex items-center gap-4">
                <span>Penyusun: {report.author}</span>
                <span>Waktu Dibuat: {new Date(report.generated_at).toLocaleString('id-ID')}</span>
              </div>
            </div>

            <div className="grid grid-cols-3 gap-4 p-4 bg-gray-950/60 print:bg-gray-100 rounded-xl border border-gray-800 print:border-gray-300">
              <div className="text-center">
                <div className="text-xs text-gray-500">Total Percakapan</div>
                <div className="text-xl font-bold text-white print:text-black">{report.total_posts}</div>
              </div>
              <div className="text-center">
                <div className="text-xs text-emerald-400">Sentimen Positif</div>
                <div className="text-xl font-bold text-emerald-400">{report.sentiment_stats.positive}</div>
              </div>
              <div className="text-center">
                <div className="text-xs text-red-400">Sentimen Negatif</div>
                <div className="text-xl font-bold text-red-400">{report.sentiment_stats.negative}</div>
              </div>
            </div>

            <div>
              <h3 className="text-sm font-semibold text-white print:text-black mb-2">Narasi Eksekutif</h3>
              <p className="text-sm text-gray-300 print:text-gray-800 leading-relaxed whitespace-pre-line bg-gray-950/40 print:bg-gray-50 p-4 rounded-xl border border-gray-800 print:border-gray-300">
                {report.executive_narrative}
              </p>
            </div>
          </div>
        ) : null}
      </main>
    </div>
  );
}
