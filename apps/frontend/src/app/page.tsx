'use client';

import Link from 'next/link';
import { useEffect, useState } from 'react';

export default function HomePage() {
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  return (
    <main className="min-h-screen bg-gray-950 flex flex-col items-center justify-center relative overflow-hidden">
      {/* Background gradient orbs */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute -top-40 -left-40 w-96 h-96 bg-violet-600/20 rounded-full blur-3xl animate-pulse" />
        <div className="absolute top-1/3 -right-32 w-80 h-80 bg-blue-600/15 rounded-full blur-3xl animate-pulse delay-1000" />
        <div className="absolute -bottom-32 left-1/3 w-72 h-72 bg-indigo-600/10 rounded-full blur-3xl animate-pulse delay-2000" />
      </div>

      {/* Grid pattern overlay */}
      <div
        className="absolute inset-0 opacity-[0.03]"
        style={{
          backgroundImage: `linear-gradient(rgba(255,255,255,0.1) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,0.1) 1px, transparent 1px)`,
          backgroundSize: '50px 50px',
        }}
      />

      <div
        className={`relative z-10 text-center px-6 max-w-4xl transition-all duration-1000 ${
          mounted ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-8'
        }`}
      >
        {/* Badge */}
        <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full border border-violet-500/30 bg-violet-500/10 text-violet-300 text-sm font-medium mb-8">
          <span className="w-2 h-2 bg-violet-400 rounded-full animate-pulse" />
          Social Intelligence Engine · v0.1 · Fase 1
        </div>

        {/* Title */}
        <h1 className="text-6xl md:text-7xl font-extrabold mb-6 leading-tight">
          <span className="bg-gradient-to-r from-white via-violet-200 to-blue-300 bg-clip-text text-transparent">
            SCIE
          </span>
        </h1>

        <p className="text-xl md:text-2xl text-gray-300 font-light mb-4 max-w-2xl mx-auto">
          Social Intelligence Engine
        </p>

        <p className="text-gray-500 text-base md:text-lg mb-12 max-w-xl mx-auto leading-relaxed">
          Mengubah jutaan percakapan digital menjadi pengetahuan yang terstruktur,
          dapat dianalisis, dan digunakan sebagai dasar pengambilan keputusan.
        </p>

        {/* CTA Buttons */}
        <div className="flex flex-col sm:flex-row gap-4 justify-center mb-16">
          <Link
            href="/login"
            className="px-8 py-3.5 bg-violet-600 hover:bg-violet-500 text-white rounded-xl font-semibold transition-all duration-200 hover:shadow-lg hover:shadow-violet-500/25 hover:-translate-y-0.5"
          >
            Masuk ke Dashboard
          </Link>
          <Link
            href="/register"
            className="px-8 py-3.5 border border-gray-700 hover:border-gray-500 text-gray-300 hover:text-white rounded-xl font-semibold transition-all duration-200 hover:-translate-y-0.5"
          >
            Buat Akun
          </Link>
        </div>

        {/* Feature grid */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 max-w-3xl mx-auto">
          {[
            { icon: '🧠', label: 'NLP Pipeline', desc: 'Sentiment · NER · Topics' },
            { icon: '🕸️', label: 'Knowledge Graph', desc: 'Neo4j · Relationships' },
            { icon: '📊', label: 'Analytics', desc: 'Trends · Influencers' },
            { icon: '🦙', label: 'Llama AI', desc: 'Self-hosted · Private' },
          ].map((f) => (
            <div
              key={f.label}
              className="p-4 rounded-xl border border-gray-800 bg-gray-900/50 backdrop-blur-sm hover:border-gray-600 transition-colors"
            >
              <div className="text-2xl mb-2">{f.icon}</div>
              <div className="text-sm font-semibold text-gray-200">{f.label}</div>
              <div className="text-xs text-gray-500 mt-1">{f.desc}</div>
            </div>
          ))}
        </div>
      </div>

      {/* Footer */}
      <div className="absolute bottom-6 text-gray-600 text-xs">
        SCIE · Social Intelligence Engine · Fase 1 — Fondasi & Infrastruktur
      </div>
    </main>
  );
}
