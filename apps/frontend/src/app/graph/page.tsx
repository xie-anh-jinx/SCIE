'use client';

import { useAuth } from '@/contexts/AuthContext';
import { useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';
import { graphApi, GraphData, GraphNode, PoliticalClusterItem } from '@/lib/api';

export default function GraphPage() {
  const { user, logout, isLoading } = useAuth();
  const router = useRouter();

  const [viewMode, setViewMode] = useState<'political' | 'general'>('political');
  const [graphData, setGraphData] = useState<GraphData | null>(null);
  const [clusters, setClusters] = useState<PoliticalClusterItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedNode, setSelectedNode] = useState<GraphNode | null>(null);

  useEffect(() => {
    if (!isLoading && !user) {
      router.push('/login');
    }
  }, [user, isLoading, router]);

  useEffect(() => {
    if (user) {
      fetchGraphData(viewMode);
    }
  }, [user, viewMode]);

  const fetchGraphData = async (mode: 'political' | 'general') => {
    setLoading(true);
    try {
      const [gData, cData] = await Promise.all([
        graphApi.get(mode, 60),
        mode === 'political' ? graphApi.getClusters() : Promise.resolve({ clusters: [] }),
      ]);
      setGraphData(gData);
      setClusters(cData.clusters || []);
      if (gData.nodes.length > 0) setSelectedNode(gData.nodes[0]);
    } catch (err) {
      console.error('Failed to fetch graph data:', err);
    } finally {
      setLoading(false);
    }
  };

  if (isLoading || !user) {
    return (
      <div className="min-h-screen bg-gray-950 flex items-center justify-center">
        <div className="text-gray-400 animate-pulse font-mono text-sm">Menginisialisasi Graph Neo4j...</div>
      </div>
    );
  }

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
            { icon: '🕸️', label: 'Knowledge Graph', href: '/graph', active: true },
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

      {/* Main Graph Content */}
      <main className="flex-1 flex flex-col min-w-0 bg-gray-950">
        {/* Header Bar */}
        <header className="px-6 py-4 bg-gray-900/60 border-b border-gray-800 flex items-center justify-between">
          <div>
            <h1 className="text-xl font-bold text-white tracking-wide">Analisis Jaringan Aktor Politik & Narasi (Neo4j)</h1>
            <p className="text-xs text-gray-400 mt-0.5">
              Pemetaan Relasi Paslon, Partai Pengusung, KPU/Bawaslu, & Kluster Opini Publik Sulawesi Selatan
            </p>
          </div>

          <div className="flex items-center gap-2 bg-gray-900 p-1 border border-gray-800 rounded-lg">
            <button
              onClick={() => setViewMode('political')}
              className={`px-3 py-1.5 rounded-md text-xs font-semibold transition-all ${
                viewMode === 'political'
                  ? 'bg-violet-600 text-white shadow-sm'
                  : 'text-gray-400 hover:text-gray-200'
              }`}
            >
              🗳️ Aktor Politik & Narasi
            </button>
            <button
              onClick={() => setViewMode('general')}
              className={`px-3 py-1.5 rounded-md text-xs font-semibold transition-all ${
                viewMode === 'general'
                  ? 'bg-violet-600 text-white shadow-sm'
                  : 'text-gray-400 hover:text-gray-200'
              }`}
            >
              🌐 Topologi Graf Umum
            </button>
          </div>
        </header>

        {/* Graph & Inspector Workspace */}
        <div className="flex-1 p-6 grid grid-cols-1 lg:grid-cols-4 gap-6 overflow-hidden">
          {/* Main Network Graph Canvas (Spans 3 Cols) */}
          <div className="lg:col-span-3 bg-gray-900 border border-gray-800 rounded-2xl p-6 flex flex-col relative overflow-hidden shadow-2xl">
            {/* Graph Header Legend */}
            <div className="flex items-center justify-between pb-4 border-b border-gray-800 mb-4">
              <div className="flex items-center gap-2">
                <span className="w-2.5 h-2.5 rounded-full bg-violet-400 animate-ping" />
                <span className="text-xs font-bold text-white uppercase tracking-wider">
                  {viewMode === 'political' ? 'Jaringan Aktor Politik Sulsel' : 'Topology Graha General'}
                </span>
                <span className="text-[10px] text-gray-500 font-mono">
                  ({graphData?.total_nodes || 0} Nodes • {graphData?.total_edges || 0} Edges)
                </span>
              </div>

              <div className="flex items-center gap-3 text-[11px]">
                <span className="flex items-center gap-1"><span className="w-2.5 h-2.5 rounded-full bg-red-500 inline-block"/> Paslon</span>
                <span className="flex items-center gap-1"><span className="w-2.5 h-2.5 rounded-full bg-yellow-500 inline-block"/> Partai</span>
                <span className="flex items-center gap-1"><span className="w-2.5 h-2.5 rounded-full bg-emerald-500 inline-block"/> Lembaga/KPU</span>
                <span className="flex items-center gap-1"><span className="w-2.5 h-2.5 rounded-full bg-purple-500 inline-block"/> Narasi</span>
              </div>
            </div>

            {/* Interactive Node Graph Interactive Grid */}
            <div className="flex-1 bg-gray-950/80 rounded-xl border border-gray-800/80 p-4 overflow-y-auto min-h-[460px]">
              {loading ? (
                <div className="h-full flex items-center justify-center text-xs text-gray-500 animate-pulse font-mono">
                  Menghubungkan ke Neo4j Graph Database...
                </div>
              ) : (
                <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-3">
                  {graphData?.nodes.map((node) => {
                    const isSelected = selectedNode?.id === node.id;
                    return (
                      <div
                        key={node.id}
                        onClick={() => setSelectedNode(node)}
                        className={`p-3 rounded-xl border transition-all cursor-pointer flex flex-col justify-between ${
                          isSelected
                            ? 'bg-gray-800 border-violet-500 shadow-lg scale-105'
                            : 'bg-gray-900/90 border-gray-800 hover:border-gray-700 hover:bg-gray-800/60'
                        }`}
                      >
                        <div className="flex items-center justify-between mb-2">
                          <span
                            className="w-3 h-3 rounded-full shadow-sm"
                            style={{ backgroundColor: node.color || '#8b5cf6' }}
                          />
                          <span className="text-[10px] font-mono uppercase text-gray-500">{node.type}</span>
                        </div>
                        <h4 className="text-xs font-semibold text-white line-clamp-2 leading-tight">{node.label}</h4>
                      </div>
                    );
                  })}
                </div>
              )}
            </div>
          </div>

          {/* Right Inspector & Political Narrative Clusters Pane */}
          <div className="flex flex-col gap-4 overflow-y-auto">
            {/* Selected Node Inspector Card */}
            {selectedNode && (
              <div className="bg-gray-900 border border-gray-800 rounded-xl p-4 shadow-xl space-y-3">
                <div className="flex items-center justify-between border-b border-gray-800 pb-2">
                  <span className="text-[10px] font-mono text-violet-400 font-bold uppercase">Node Inspector</span>
                  <span
                    className="w-2.5 h-2.5 rounded-full"
                    style={{ backgroundColor: selectedNode.color }}
                  />
                </div>

                <div>
                  <h3 className="text-sm font-bold text-white">{selectedNode.label}</h3>
                  <p className="text-[11px] text-gray-400 font-mono mt-0.5">Tipe: {selectedNode.type}</p>
                </div>

                <div className="pt-2 border-t border-gray-800 text-xs space-y-1 text-gray-300">
                  <div className="flex justify-between"><span className="text-gray-500">ID Node:</span> <span className="font-mono">{selectedNode.id}</span></div>
                  <div className="flex justify-between"><span className="text-gray-500">Koneksi Relasi:</span> <span className="text-emerald-400 font-bold">Aktif di Neo4j</span></div>
                </div>
              </div>
            )}

            {/* Political Narrative Clusters (Option 2) */}
            {viewMode === 'political' && (
              <div className="bg-gray-900 border border-gray-800 rounded-xl p-4 flex-1 flex flex-col shadow-xl">
                <div className="flex items-center gap-2 pb-3 border-b border-gray-800 mb-3">
                  <span>🗳️</span>
                  <h3 className="text-xs font-bold text-white uppercase tracking-wider">Kluster Narasi Politik Sulsel</h3>
                </div>

                <div className="space-y-3 overflow-y-auto flex-1 pr-1">
                  {clusters.map((c) => (
                    <div key={c.id} className="p-3 bg-gray-950/80 border border-gray-800 rounded-lg space-y-2">
                      <div className="flex items-center justify-between">
                        <h4 className="text-xs font-bold text-white">{c.name}</h4>
                        <span className="text-xs font-mono font-bold text-violet-400">{c.share_percentage}%</span>
                      </div>

                      <div className="space-y-1">
                        <div className="text-[10px] text-gray-500">Aktor Utama:</div>
                        <div className="flex flex-wrap gap-1">
                          {c.dominant_actors.map((actor, idx) => (
                            <span key={idx} className="px-1.5 py-0.5 rounded bg-gray-800 text-[10px] text-gray-300">
                              {actor}
                            </span>
                          ))}
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        </div>
      </main>
    </div>
  );
}
