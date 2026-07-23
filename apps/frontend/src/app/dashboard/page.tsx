'use client';

import { useAuth } from '@/contexts/AuthContext';
import { useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';
import dynamic from 'next/dynamic';
import { mapApi, MapEventItem, MapSummaryData } from '@/lib/api';
import LayerControls, { INDONESIA_LAYERS } from '@/components/map/LayerControls';
import IntelTicker from '@/components/dashboard/IntelTicker';

// Dynamically import Leaflet Map Component with SSR disabled
const IndonesiaMapView = dynamic(() => import('@/components/map/IndonesiaMapView'), {
  ssr: false,
  loading: () => (
    <div className="w-full h-full min-h-[480px] bg-gray-950 flex items-center justify-center text-xs text-gray-500 rounded-2xl border border-gray-800 animate-pulse">
      Memuat Peta Situasional Indonesia...
    </div>
  ),
});

export default function DashboardPage() {
  const { user, logout, isLoading } = useAuth();
  const router = useRouter();

  const [selectedProvince, setSelectedProvince] = useState<string>('Sulawesi Selatan');
  const [activeLayers, setActiveLayers] = useState<string[]>([
    'konflik', 'hotspot', 'pangkalan', 'infrastruktur', 'ekonomi', 'perairan', 'bencana'
  ]);
  const [events, setEvents] = useState<MapEventItem[]>([]);
  const [summary, setSummary] = useState<MapSummaryData | null>(null);
  const [selectedEvent, setSelectedEvent] = useState<MapEventItem | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!isLoading && !user) {
      router.push('/login');
    }
  }, [user, isLoading, router]);

  useEffect(() => {
    if (user) {
      fetchMapData(selectedProvince);
    }
  }, [user, selectedProvince]);

  const fetchMapData = async (prov?: string) => {
    setLoading(true);
    try {
      const [eventsRes, summaryRes] = await Promise.all([
        mapApi.getEvents(undefined, prov || undefined),
        mapApi.getSummary(),
      ]);
      setEvents(eventsRes.events || []);
      setSummary(summaryRes);
    } catch (err) {
      console.error('Failed fetching map data:', err);
    } finally {
      setLoading(false);
    }
  };


  const handleToggleLayer = (layerId: string) => {
    if (activeLayers.includes(layerId)) {
      setActiveLayers(activeLayers.filter((l) => l !== layerId));
    } else {
      setActiveLayers([...activeLayers, layerId]);
    }
  };

  if (isLoading || !user) {
    return (
      <div className="min-h-screen bg-gray-950 flex items-center justify-center">
        <div className="text-gray-400 animate-pulse font-mono text-sm">Menginisialisasi Telemetri SCIE Indonesia...</div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-950 flex">
      {/* Sidebar Navigation */}
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
            { icon: '🗺️', label: 'Situational Map', href: '/dashboard', active: true },
            { icon: '📊', label: 'Analytics & Trends', href: '/analytics', active: false },
            { icon: '🕸️', label: 'Knowledge Graph', href: '/graph', active: false },
            { icon: '📡', label: 'Data Sources', href: '/sources', active: false },
            { icon: '🔔', label: 'Alerts & Anomalies', href: '/alerts', active: false },
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

      {/* Main Command Center Body */}
      <main className="flex-1 flex flex-col min-w-0 overflow-hidden bg-gray-950">
        {/* Header Bar */}
        <header className="px-6 py-4 bg-gray-900/60 border-b border-gray-800 flex items-center justify-between">
          <div>
            <div className="flex items-center gap-2">
              <h1 className="text-xl font-bold text-white tracking-wide">Pusat Situasi & Intelijen Nasional</h1>
              <span className="px-2 py-0.5 rounded-full text-[10px] bg-emerald-500/20 text-emerald-300 border border-emerald-500/30 font-mono font-semibold">
                Sabang - Merauke Active
              </span>
            </div>
            <p className="text-xs text-gray-500 mt-0.5">
              Pemantauan kejadian real-time 38 Provinsi, Wilayah Perbatasan, & Laut Natuna Utara
            </p>
          </div>

          <div className="flex items-center gap-3">
            <select
              value={selectedProvince}
              onChange={(e) => setSelectedProvince(e.target.value)}
              className="px-3 py-1.5 bg-gray-800 border border-gray-700 text-white rounded-lg text-xs font-semibold focus:outline-none focus:border-violet-500 cursor-pointer"
            >
              <option value="Sulawesi Selatan">📍 Fokus: Sulawesi Selatan</option>
              <option value="">🇮🇩 Seluruh Indonesia (38 Provinsi)</option>
              <option value="DKI Jakarta">📍 DKI Jakarta</option>
              <option value="Jawa Barat">📍 Jawa Barat</option>
              <option value="Jawa Timur">📍 Jawa Timur</option>
              <option value="Aceh">📍 Aceh</option>
              <option value="Papua">📍 Papua</option>
              <option value="Kalimantan Timur">📍 Kalimantan Timur (IKN)</option>
            </select>

            <button
              onClick={() => fetchMapData(selectedProvince)}
              className="px-3 py-1.5 bg-gray-800 hover:bg-gray-700 text-gray-200 rounded-lg text-xs font-medium transition-colors border border-gray-700 flex items-center gap-1.5"
            >
              🔄 Refresh Feeds
            </button>
          </div>
        </header>


        {/* Workspace Area */}
        <div className="flex-1 p-6 flex flex-col gap-4 overflow-y-auto">
          {/* Top Layer Control Bar */}
          <LayerControls
            activeLayers={activeLayers}
            onToggleLayer={handleToggleLayer}
            layerCounts={summary?.layers || {}}
          />

          {/* Split Pane: Interactive GIS Map + Live Telemetry Feed */}
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-4 flex-1 min-h-[520px]">
            {/* GIS Map Viewport (Spans 2 Columns) */}
            <div className="lg:col-span-2 flex flex-col gap-3 min-h-[520px]">
              <IndonesiaMapView
                events={events}
                activeLayers={activeLayers}
                onSelectEvent={setSelectedEvent}
              />

              {/* Selected Event Detail Inspection Card */}
              {selectedEvent && (
                <div className="p-4 bg-gray-900 border border-gray-800 rounded-xl flex flex-col md:flex-row items-start md:items-center justify-between gap-4 animate-fadeIn">
                  <div className="space-y-1">
                    <div className="flex items-center gap-2">
                      <span className="px-2 py-0.5 rounded text-[10px] font-bold uppercase bg-violet-600/20 text-violet-300 border border-violet-500/30">
                        {selectedEvent.layer_category}
                      </span>
                      <span className="text-xs text-gray-400">📍 {selectedEvent.location_name} ({selectedEvent.province})</span>
                    </div>
                    <h3 className="text-sm font-semibold text-white">{selectedEvent.title}</h3>
                    <p className="text-xs text-gray-400 line-clamp-2">{selectedEvent.full_text}</p>
                  </div>
                  <div className="flex items-center gap-2 shrink-0">
                    <a
                      href="/chat"
                      className="px-3 py-1.5 bg-violet-600 hover:bg-violet-500 text-white rounded-lg text-xs font-semibold transition-colors flex items-center gap-1"
                    >
                      🦙 Analisis Llama AI
                    </a>
                  </div>
                </div>
              )}
            </div>

            {/* Live Intel Telemetry Stream (Right Column) */}
            <div className="h-full min-h-[520px]">
              <IntelTicker
                events={events.filter((e) => activeLayers.includes(e.layer_category || 'hotspot'))}
                onSelectEvent={setSelectedEvent}
              />
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
