'use client';

import { useAuth } from '@/contexts/AuthContext';
import { useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';
import { reportsApi, ExecutiveReportData, AIReportResponse } from '@/lib/api';

export default function ReportsPage() {
  const { user, logout, isLoading } = useAuth();
  const router = useRouter();

  const [province, setProvince] = useState('Sulawesi Selatan');
  const [summaryData, setSummaryData] = useState<ExecutiveReportData | null>(null);
  const [aiReport, setAiReport] = useState<AIReportResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [generatingAi, setGeneratingAi] = useState(false);

  useEffect(() => {
    if (!isLoading && !user) {
      router.push('/login');
    }
  }, [user, isLoading, router]);

  useEffect(() => {
    if (user) {
      fetchSummary(province);
    }
  }, [user, province]);

  const fetchSummary = async (targetProvince: string) => {
    setLoading(true);
    try {
      const data = await reportsApi.getSummary(targetProvince);
      setSummaryData(data);
    } catch (err) {
      console.error('Failed to fetch report summary:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleGenerateAiBriefing = async () => {
    setGeneratingAi(true);
    try {
      const aiData = await reportsApi.generateAiBriefing(province);
      setAiReport(aiData);
    } catch (err) {
      console.error('Failed to generate AI briefing:', err);
    } finally {
      setGeneratingAi(false);
    }
  };

  const handlePrint = () => {
    if (typeof window !== 'undefined') {
      window.print();
    }
  };

  if (isLoading || !user) {
    return (
      <div className="min-h-screen bg-gray-950 flex items-center justify-center">
        <div className="text-gray-400 animate-pulse font-mono text-sm">Menginisialisasi Laporan Intelijen...</div>
      </div>
    );
  }

  const activeNarrative = aiReport?.ai_report_narrative || summaryData?.executive_narrative || '';

  return (
    <div className="min-h-screen bg-gray-950 flex">
      {/* Sidebar Navigation */}
      <aside className="w-64 bg-gray-900 border-r border-gray-800 flex flex-col shrink-0 print:hidden">
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
            { icon: '🔔', label: 'Alerts & Anomalies', href: '/alerts', active: false },
            { icon: '🦙', label: 'AI Intelligence (Llama)', href: '/chat', active: false },
            { icon: '📄', label: 'Executive Reports', href: '/reports', active: true },
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

      {/* Main Content Area */}
      <main className="flex-1 flex flex-col min-w-0 overflow-y-auto bg-gray-950 p-8">
        {/* Header Control Bar */}
        <div className="flex flex-col md:flex-row items-start md:items-center justify-between gap-4 pb-6 border-b border-gray-800 print:hidden">
          <div>
            <h1 className="text-2xl font-bold text-white tracking-wide">Laporan Intelijen Eksekutif Harian</h1>
            <p className="text-xs text-gray-400 mt-1">
              Dokumen Analisis Situasional & Keamanan Berbasis Ollama Llama3 RAG
            </p>
          </div>

          <div className="flex flex-wrap items-center gap-3">
            <select
              value={province}
              onChange={(e) => setProvince(e.target.value)}
              className="px-3 py-2 bg-gray-900 border border-gray-800 text-white rounded-lg text-xs font-semibold focus:outline-none focus:border-violet-500 cursor-pointer"
            >
              <option value="Sulawesi Selatan">📍 Sulawesi Selatan (Makassar)</option>
              <option value="DKI Jakarta">📍 DKI Jakarta</option>
              <option value="Jawa Barat">📍 Jawa Barat</option>
              <option value="Jawa Timur">📍 Jawa Timur</option>
              <option value="Aceh">📍 Aceh</option>
              <option value="Papua">📍 Papua</option>
              <option value="Nasional">🇮🇩 Skala Nasional (38 Provinsi)</option>
            </select>

            <button
              onClick={handleGenerateAiBriefing}
              disabled={generatingAi}
              className="px-4 py-2 bg-gradient-to-r from-violet-600 to-indigo-600 hover:from-violet-500 hover:to-indigo-500 text-white rounded-lg text-xs font-bold transition-all flex items-center gap-2 shadow-lg disabled:opacity-50"
            >
              {generatingAi ? (
                <>
                  <span className="w-3 h-3 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                  <span>Memproses Llama3 RAG...</span>
                </>
              ) : (
                <>
                  <span>🦙 Hasilkan Briefing AI</span>
                </>
              )}
            </button>

            <button
              onClick={handlePrint}
              className="px-3 py-2 bg-gray-800 hover:bg-gray-700 text-gray-200 rounded-lg text-xs font-medium transition-colors border border-gray-700 flex items-center gap-1.5"
            >
              🖨️ Cetak Dokumen
            </button>
          </div>
        </div>

        {/* Report Preview Document Card */}
        <div className="mt-6 max-w-4xl mx-auto w-full bg-gray-900 border border-gray-800 rounded-2xl p-8 shadow-2xl space-y-6 print:border-none print:shadow-none print:bg-white print:text-black">
          {/* Document Header Stamp */}
          <div className="flex items-center justify-between border-b border-gray-800 pb-6 print:border-gray-300">
            <div>
              <div className="flex items-center gap-2">
                <span className="px-2.5 py-1 rounded bg-violet-600/20 text-violet-300 border border-violet-500/30 text-xs font-mono font-bold uppercase print:bg-violet-100 print:text-violet-900">
                  {aiReport ? 'AI GENERATED (LLAMA3 RAG)' : 'STRICTLY CONFIDENTIAL'}
                </span>
                <span className="text-xs text-gray-500 font-mono">ID: BRIEF-{Date.now().toString().slice(-6)}</span>
              </div>
              <h2 className="text-xl font-bold text-white mt-2 print:text-black">
                {aiReport ? aiReport.title : (summaryData?.title || `Laporan Intelijen Eksekutif — ${province}`)}
              </h2>
              <p className="text-xs text-gray-400 mt-1 print:text-gray-600">
                Pusat Situasi & Intelijen Geospasial SCIE Indonesia • Wilayah: {province}
              </p>
            </div>

            <div className="text-right text-xs text-gray-400 font-mono space-y-1 print:text-gray-700">
              <div>Tanggal: {new Date().toLocaleDateString('id-ID', { day: 'numeric', month: 'long', year: 'numeric' })}</div>
              <div>Analis: {user.full_name || user.username}</div>
              <div>Model: {aiReport ? aiReport.model_used : 'Local RAG Engine'}</div>
            </div>
          </div>

          {/* Key Metrics Strip */}
          {summaryData && (
            <div className="grid grid-cols-3 gap-4 p-4 bg-gray-950/80 rounded-xl border border-gray-800/80 print:bg-gray-100 print:border-gray-300">
              <div className="text-center border-r border-gray-800/80 print:border-gray-300">
                <div className="text-xs text-gray-500 print:text-gray-700 font-medium">Total Sumber Telemetri</div>
                <div className="text-lg font-bold text-white print:text-black">{summaryData.total_posts} Events</div>
              </div>
              <div className="text-center border-r border-gray-800/80 print:border-gray-300">
                <div className="text-xs text-gray-500 print:text-gray-700 font-medium">Sentimen Positif / Netral</div>
                <div className="text-lg font-bold text-emerald-400 print:text-emerald-700">
                  {summaryData.sentiment_stats.positive + summaryData.sentiment_stats.neutral} Signals
                </div>
              </div>
              <div className="text-center">
                <div className="text-xs text-gray-500 print:text-gray-700 font-medium">Peringatan / Sentimen Negatif</div>
                <div className="text-lg font-bold text-red-400 print:text-red-700">{summaryData.sentiment_stats.negative} Anomalies</div>
              </div>
            </div>
          )}

          {/* Narrative Body */}
          <div className="prose prose-invert max-w-none text-sm text-gray-200 leading-relaxed font-sans whitespace-pre-line print:text-black">
            {loading ? (
              <div className="py-12 text-center text-xs text-gray-500 animate-pulse">
                Memuat narasi laporan intelijen...
              </div>
            ) : (
              activeNarrative
            )}
          </div>

          {/* Document Footer Signature */}
          <div className="border-t border-gray-800 pt-6 flex items-center justify-between text-[11px] text-gray-500 font-mono print:border-gray-300 print:text-gray-600">
            <div>Dihasilkan secara otomatis oleh SCIE National Command Center</div>
            <div>Halaman 1 dari 1 • Dokumen Resmi Internal</div>
          </div>
        </div>
      </main>
    </div>
  );
}
