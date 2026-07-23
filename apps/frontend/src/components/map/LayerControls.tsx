'use client';

export interface LayerConfig {
  id: string;
  name: string;
  icon: string;
  color: string;
  description: string;
}

export const INDONESIA_LAYERS: LayerConfig[] = [
  { id: 'politik', name: 'Politik & Kebijakan', icon: '🏛️', color: '#8b5cf6', description: 'Pilkada, Pemilu, Kebijakan Daerah, DPRD, & KPU/Bawaslu' },
  { id: 'konflik', name: 'Konflik & Keamanan', icon: '⚔️', color: '#ef4444', description: 'Keamanan Daerah, Terorisme, & Perbatasan' },
  { id: 'hotspot', name: 'Hotspots Disinformasi', icon: '🔥', color: '#f97316', description: 'Isu Viral, Hoaks Media Sosial, & Opini Publik' },
  { id: 'pangkalan', name: 'Pangkalan & Obvitnas', icon: '🛡️', color: '#3b82f6', description: 'Pos TNI/Polri & Objek Vital Nasional' },
  { id: 'infrastruktur', name: 'Infrastruktur & Outage', icon: '⚡', color: '#eab308', description: 'PLN, Internet Telkom/Indosat, & Fasilitas Publik' },
  { id: 'ekonomi', name: 'Ekonomi & Pangan', icon: '💹', color: '#10b981', description: 'Harga Sembako, Inflasi Daerah, & Pasar' },
  { id: 'perairan', name: 'Perairan & Selat', icon: '🌊', color: '#06b6d4', description: 'Laut Natuna Utara, Selat Malaka, & Maritim' },
  { id: 'bencana', name: 'Bencana & BMKG Cuaca', icon: '🌋', color: '#a855f7', description: 'Gempa Bumi BMKG, Banjir, Karhutla, & Erupsi' },
];

interface LayerControlsProps {
  activeLayers: string[];
  onToggleLayer: (layerId: string) => void;
  layerCounts: Record<string, number>;
}

export default function LayerControls({ activeLayers, onToggleLayer, layerCounts }: LayerControlsProps) {
  return (
    <div className="bg-gray-900/90 backdrop-blur-md border border-gray-800 rounded-xl p-3 shadow-2xl space-y-2">
      <div className="flex items-center justify-between px-1 mb-1">
        <div className="flex items-center gap-2">
          <span className="w-2 h-2 rounded-full bg-emerald-500 animate-ping" />
          <span className="text-xs font-bold uppercase tracking-wider text-gray-300">
            Situational Layers (Indonesia)
          </span>
        </div>
        <span className="text-[10px] text-gray-500 font-mono">8 Active Layers</span>
      </div>

      <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-8 gap-1.5">

        {INDONESIA_LAYERS.map((layer) => {
          const isActive = activeLayers.includes(layer.id);
          const count = layerCounts[layer.id] || 0;

          return (
            <button
              key={layer.id}
              onClick={() => onToggleLayer(layer.id)}
              className={`flex items-center justify-between px-2.5 py-1.5 rounded-lg border text-xs font-medium transition-all ${
                isActive
                  ? 'bg-gray-800 border-gray-600 text-white shadow-sm'
                  : 'bg-gray-950/60 border-gray-800/80 text-gray-500 hover:text-gray-300 hover:bg-gray-900'
              }`}
              title={layer.description}
            >
              <div className="flex items-center gap-1.5 truncate">
                <span>{layer.icon}</span>
                <span className="truncate">{layer.name}</span>
              </div>
              <span
                className="ml-1.5 px-1.5 py-0.2 rounded-full text-[10px] font-mono font-semibold"
                style={{
                  backgroundColor: isActive ? `${layer.color}25` : '#1f2937',
                  color: isActive ? layer.color : '#6b7280',
                  border: `1px solid ${isActive ? layer.color + '40' : '#374151'}`,
                }}
              >
                {count}
              </span>
            </button>
          );
        })}
      </div>
    </div>
  );
}
