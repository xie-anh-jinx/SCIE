'use client';

import { useEffect, useRef } from 'react';
import { MapEventItem } from '@/lib/api';

interface IndonesiaMapViewProps {
  events: MapEventItem[];
  activeLayers: string[];
  onSelectEvent?: (event: MapEventItem) => void;
}

const LAYER_COLORS: Record<string, string> = {
  konflik: '#ef4444',
  hotspot: '#f97316',
  pangkalan: '#3b82f6',
  infrastruktur: '#eab308',
  ekonomi: '#10b981',
  perairan: '#06b6d4',
  bencana: '#a855f7',
};

const LAYER_EMOJIS: Record<string, string> = {
  konflik: '⚔️',
  hotspot: '🔥',
  pangkalan: '🛡️',
  infrastruktur: '⚡',
  ekonomi: '💹',
  perairan: '🌊',
  bencana: '🌋',
};

export default function IndonesiaMapView({ events, activeLayers, onSelectEvent }: IndonesiaMapViewProps) {
  const mapContainerRef = useRef<HTMLDivElement>(null);
  const mapInstanceRef = useRef<any>(null);
  const markersLayerRef = useRef<any>(null);

  useEffect(() => {
    if (typeof window === 'undefined' || !mapContainerRef.current) return;

    // Dynamically load Leaflet CSS and JS
    const loadLeaflet = async () => {
      const L = (await import('leaflet')).default;

      // Import Leaflet CSS dynamically if not injected
      if (!document.getElementById('leaflet-css')) {
        const link = document.createElement('link');
        link.id = 'leaflet-css';
        link.rel = 'stylesheet';
        link.href = 'https://unpkg.com/leaflet@1.9.4/dist/leaflet.css';
        document.head.appendChild(link);
      }

      if (!mapInstanceRef.current && mapContainerRef.current) {
        // Center on South Sulawesi / Makassar (Lat: -5.1477, Lon: 119.4327, Zoom: 8)
        const map = L.map(mapContainerRef.current, {
          center: [-5.1477, 119.4327],
          zoom: 8,
          minZoom: 4,
          maxZoom: 15,

          maxBounds: [
            [-13.0, 92.0], // South-West bound
            [9.0, 142.0],  // North-East bound
          ],

        });

        // Dark Matter Tile Layer (CartoDB)
        L.tileLayer('https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png', {
          attribution: '&copy; <a href="https://carto.com/">CARTO</a> &copy; OpenStreetMap',
          subdomains: 'abcd',
          maxZoom: 19,
        }).addTo(map);

        markersLayerRef.current = L.layerGroup().addTo(map);
        mapInstanceRef.current = map;
      }

      // Update Map Markers
      if (markersLayerRef.current && mapInstanceRef.current) {
        markersLayerRef.current.clearLayers();

        const filteredEvents = events.filter((e) => activeLayers.includes(e.layer_category || 'hotspot'));

        filteredEvents.forEach((evt) => {
          const color = LAYER_COLORS[evt.layer_category] || '#f97316';
          const iconEmoji = LAYER_EMOJIS[evt.layer_category] || '📍';

          const customIcon = L.divIcon({
            className: 'custom-map-pin',
            html: `
              <div class="relative flex items-center justify-center cursor-pointer group">
                <span class="absolute w-6 h-6 rounded-full opacity-40 animate-ping" style="background-color: ${color}"></span>
                <div class="w-7 h-7 rounded-full bg-gray-950 border-2 flex items-center justify-center text-xs shadow-lg transition-transform group-hover:scale-125" style="border-color: ${color}">
                  ${iconEmoji}
                </div>
              </div>
            `,
            iconSize: [28, 28],
            iconAnchor: [14, 14],
          });

          const marker = L.marker([evt.latitude, evt.longitude], { icon: customIcon });

          const platformEmoji = evt.platform === 'tiktok' ? '🎵 TikTok' : evt.platform === 'twitter' ? '🐦 Twitter' : evt.platform === 'facebook' ? '📘 Facebook' : evt.platform === 'instagram' ? '📸 Instagram' : '📰 RSS News';

          const popupContent = `
            <div style="background-color: #030712; color: #f3f4f6; border-radius: 12px; padding: 12px; border: 1px solid #1f2937; max-width: 280px; font-family: sans-serif;">
              <div style="display: flex; align-items: center; justify-content: space-between; gap: 8px; margin-bottom: 6px;">
                <span style="font-size: 10px; font-weight: 700; text-transform: uppercase; color: ${color}; background-color: ${color}20; padding: 2px 6px; border-radius: 4px;">
                  ${evt.layer_category.toUpperCase()}
                </span>
                <span style="font-size: 10px; font-weight: 600; color: #a855f7; background-color: #a855f715; padding: 2px 6px; border-radius: 4px;">
                  ${platformEmoji}
                </span>
              </div>
              <div style="font-size: 12px; font-weight: 600; color: #ffffff; margin-bottom: 6px; line-height: 1.3;">
                ${evt.title}
              </div>
              <div style="font-size: 11px; color: #9ca3af; margin-bottom: 8px;">
                📍 ${evt.location_name} • ${evt.province || 'Sulawesi Selatan'}
              </div>
              <div style="display: flex; align-items: center; justify-content: space-between; font-size: 10px; border-top: 1px solid #1f2937; padding-top: 6px;">
                <span style="color: ${evt.sentiment_label === 'positive' ? '#10b981' : evt.sentiment_label === 'negative' ? '#ef4444' : '#9ca3af'}">
                  Sentimen: ${evt.sentiment_label}
                </span>
                <span style="color: #8b5cf6;">Virality: ${evt.virality_score}/10</span>
              </div>
            </div>
          `;


          marker.bindPopup(popupContent, {
            className: 'custom-leaflet-popup',
          });


          marker.on('click', () => {
            if (onSelectEvent) onSelectEvent(evt);
          });

          markersLayerRef.current.addLayer(marker);
        });
      }
    };

    loadLeaflet();
  }, [events, activeLayers, onSelectEvent]);

  return (
    <div className="relative w-full h-full min-h-[480px] bg-gray-950 rounded-2xl overflow-hidden border border-gray-800 shadow-inner">
      <div ref={mapContainerRef} className="w-full h-full min-h-[480px] z-10" />

      {/* Region Indicator Overlay */}
      <div className="absolute top-4 right-4 z-20 bg-gray-900/90 backdrop-blur-md px-3 py-1.5 rounded-lg border border-gray-800 flex items-center gap-2 pointer-events-none shadow-xl">
        <span className="w-2 h-2 rounded-full bg-cyan-400 animate-pulse" />
        <span className="text-[11px] font-bold text-white tracking-wide">📍 FOKUS: SULAWESI SELATAN</span>
        <span className="text-[10px] text-gray-400 font-mono">MAKASSAR & DAERAH</span>
      </div>
    </div>
  );
}

