'use client';

import { useAuth } from '@/contexts/AuthContext';
import { useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';
import { graphApi, GraphData, GraphNode } from '@/lib/api';

export default function GraphPage() {
  const { user, logout, isLoading } = useAuth();
  const router = useRouter();

  const [graphData, setGraphData] = useState<GraphData | null>(null);
  const [loading, setLoading] = useState(true);
  const [selectedNode, setSelectedNode] = useState<GraphNode | null>(null);

  useEffect(() => {
    if (!isLoading && !user) {
      router.push('/login');
    }
  }, [user, isLoading, router]);

  useEffect(() => {
    if (user) {
      graphApi
        .get(60)
        .then((data) => {
          setGraphData(data);
          if (data.nodes.length > 0) setSelectedNode(data.nodes[0]);
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
            { icon: '📊', label: 'Analytics', href: '/analytics', active: false },
            { icon: '🕸️', label: 'Knowledge Graph', href: '/graph', active: true },
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
        <div className="mb-6 flex items-center justify-between">
          <div>
            <div className="flex items-center gap-3 mb-1">
              <h1 className="text-2xl font-bold text-white">Neo4j Knowledge Graph</h1>
              <span className="px-2 py-0.5 rounded-full text-xs bg-violet-500/10 text-violet-400 border border-violet-500/20">
                Fase 3 — Graph Active
              </span>
            </div>
            <p className="text-gray-500 text-sm">
              Visualisasi hubungan entitas, pengguna, postingan, dan topik percakapan digital.
            </p>
          </div>
        </div>

        {/* Graph Visualizer Canvas & Detail Box */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Canvas Simulation Card */}
          <div className="lg:col-span-2 p-6 bg-gray-900 border border-gray-800 rounded-2xl min-h-[480px] relative overflow-hidden flex flex-col justify-between">
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-4 text-xs">
                <span className="flex items-center gap-1 text-violet-400"><span className="w-3 h-3 rounded-full bg-violet-500" /> User</span>
                <span className="flex items-center gap-1 text-blue-400"><span className="w-3 h-3 rounded-full bg-blue-500" /> Post</span>
                <span className="flex items-center gap-1 text-emerald-400"><span className="w-3 h-3 rounded-full bg-emerald-500" /> Topic</span>
                <span className="flex items-center gap-1 text-amber-400"><span className="w-3 h-3 rounded-full bg-amber-500" /> Entity</span>
              </div>
              <div className="text-xs text-gray-500">
                {graphData?.total_nodes ?? 0} Nodes · {graphData?.total_edges ?? 0} Edges
              </div>
            </div>

            {loading ? (
              <div className="flex-1 flex items-center justify-center text-gray-500 animate-pulse">
                Memuat Knowledge Graph Neo4j...
              </div>
            ) : (
              <div className="flex-1 grid grid-cols-2 md:grid-cols-3 gap-3 p-4 bg-gray-950/60 rounded-xl border border-gray-800/80 items-center justify-center">
                {graphData?.nodes.map((node) => (
                  <button
                    key={node.id}
                    onClick={() => setSelectedNode(node)}
                    className={`p-3 rounded-xl border text-left transition-all hover:scale-105 ${
                      selectedNode?.id === node.id
                        ? 'border-violet-500 bg-violet-500/10 shadow-lg shadow-violet-500/20'
                        : 'border-gray-800 bg-gray-900 hover:border-gray-700'
                    }`}
                  >
                    <div className="flex items-center justify-between mb-1">
                      <span className="text-xs font-semibold px-1.5 py-0.5 rounded" style={{ backgroundColor: `${node.color}20`, color: node.color }}>
                        {node.type}
                      </span>
                    </div>
                    <div className="text-sm font-medium text-white truncate">{node.label}</div>
                  </button>
                ))}
              </div>
            )}

            <div className="mt-4 text-xs text-gray-600 text-end">
              Powered by Neo4j 5 Community Edition & APOC / GDS
            </div>
          </div>

          {/* Node Inspector Panel */}
          <div className="p-6 bg-gray-900 border border-gray-800 rounded-2xl">
            <h3 className="text-sm font-semibold text-gray-400 uppercase tracking-wider mb-4">
              Node Inspector
            </h3>

            {selectedNode ? (
              <div className="space-y-4">
                <div>
                  <div className="text-xs text-gray-500 mb-1">Tipe Node</div>
                  <span className="px-2.5 py-1 rounded-md text-xs font-semibold" style={{ backgroundColor: `${selectedNode.color}20`, color: selectedNode.color }}>
                    {selectedNode.type}
                  </span>
                </div>

                <div>
                  <div className="text-xs text-gray-500 mb-1">Identifier Node</div>
                  <div className="text-sm font-mono text-gray-200 bg-gray-950 p-2 rounded-lg border border-gray-800 break-all">
                    {selectedNode.id}
                  </div>
                </div>

                <div>
                  <div className="text-xs text-gray-500 mb-1">Label / Nama Node</div>
                  <div className="text-base font-semibold text-white">
                    {selectedNode.label}
                  </div>
                </div>

                <div className="pt-4 border-t border-gray-800">
                  <div className="text-xs text-gray-500 mb-2">Relasi Terhubung (Cypher)</div>
                  <div className="p-3 bg-gray-950 rounded-xl text-xs font-mono text-violet-300 border border-gray-800 space-y-1">
                    <div>MATCH (n)-[r]-(m)</div>
                    <div>WHERE n.id = "{selectedNode.id}"</div>
                    <div>RETURN r, m</div>
                  </div>
                </div>
              </div>
            ) : (
              <div className="text-gray-500 text-sm">Pilih node pada graf di samping untuk melihat detail inspeksi.</div>
            )}
          </div>
        </div>
      </main>
    </div>
  );
}
