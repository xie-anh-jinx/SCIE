'use client';

import { MapEventItem } from '@/lib/api';

interface IntelTickerProps {
  events: MapEventItem[];
  onSelectEvent?: (event: MapEventItem) => void;
}

export default function IntelTicker({ events, onSelectEvent }: IntelTickerProps) {
  const getBadgeStyle = (layer: string) => {
    switch (layer) {
      case 'politik':
        return 'bg-violet-500/20 text-violet-300 border-violet-500/30 font-bold';
      case 'konflik':
        return 'bg-red-500/20 text-red-400 border-red-500/30';
      case 'hotspot':
        return 'bg-orange-500/20 text-orange-400 border-orange-500/30';
      case 'pangkalan':
        return 'bg-blue-500/20 text-blue-400 border-blue-500/30';
      case 'infrastruktur':
        return 'bg-yellow-500/20 text-yellow-400 border-yellow-500/30';
      case 'ekonomi':
        return 'bg-emerald-500/20 text-emerald-400 border-emerald-500/30';
      case 'perairan':
        return 'bg-cyan-500/20 text-cyan-400 border-cyan-500/30';
      case 'bencana':
        return 'bg-purple-500/20 text-purple-400 border-purple-500/30';
      default:
        return 'bg-gray-800 text-gray-400 border-gray-700';
    }
  };


  return (
    <div className="bg-gray-900 border border-gray-800 rounded-xl p-4 flex flex-col h-full">
      <div className="flex items-center justify-between pb-3 border-b border-gray-800 mb-3">
        <div className="flex items-center gap-2">
          <span className="w-2.5 h-2.5 rounded-full bg-red-500 animate-pulse" />
          <h2 className="text-sm font-bold text-white tracking-wide">LIVE INTEL FEED (INDONESIA)</h2>
        </div>
        <span className="text-xs text-gray-500 font-mono">{events.length} Feeds</span>
      </div>

      <div className="flex-1 overflow-y-auto space-y-2.5 max-h-[520px] pr-1">
        {events.length === 0 ? (
          <div className="py-8 text-center text-xs text-gray-500 animate-pulse">
            Memuat telemetri intelijen...
          </div>
        ) : (
          events.map((evt) => (
            <div
              key={evt.id}
              onClick={() => onSelectEvent && onSelectEvent(evt)}
              className="p-3 bg-gray-950/70 hover:bg-gray-800/80 border border-gray-800/90 rounded-lg transition-all cursor-pointer group"
            >
              <div className="flex items-center justify-between gap-2 mb-1.5">
                <span className={`px-2 py-0.5 rounded text-[10px] font-bold uppercase border ${getBadgeStyle(evt.layer_category)}`}>
                  {evt.layer_category}
                </span>
                <span className="text-[10px] text-gray-500 font-mono">
                  📍 {evt.province || 'Indonesia'}
                </span>
              </div>

              <p className="text-xs text-gray-200 font-medium line-clamp-2 group-hover:text-white transition-colors leading-relaxed">
                {evt.full_text || evt.title}
              </p>

              <div className="flex items-center justify-between mt-2 pt-2 border-t border-gray-800/50 text-[10px] text-gray-500">
                <span className="capitalize">{evt.platform}</span>
                <span className={evt.sentiment_label === 'positive' ? 'text-emerald-400' : evt.sentiment_label === 'negative' ? 'text-red-400' : 'text-gray-400'}>
                  Sentimen: {evt.sentiment_label}
                </span>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
