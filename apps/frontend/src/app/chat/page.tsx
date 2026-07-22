'use client';

import { useAuth } from '@/contexts/AuthContext';
import { useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';
import { chatApi, ChatResponseData } from '@/lib/api';

interface MessageItem {
  id: string;
  sender: 'user' | 'ai';
  text: string;
  sources_count?: number;
  context?: Array<{ platform: string; text: string; sentiment: string; topics: string[] }>;
}

export default function ChatPage() {
  const { user, logout, isLoading } = useAuth();
  const router = useRouter();

  const [prompt, setPrompt] = useState('');
  const [messages, setMessages] = useState<MessageItem[]>([
    {
      id: 'm_welcome',
      sender: 'ai',
      text: 'Halo! Saya SCIE AI Assistant (berbasis Llama). Anda bisa menanyakan analisis percakapan digital, sentimen publik, aktor berpengaruh, atau isu terkini.',
    },
  ]);
  const [sending, setSending] = useState(false);

  useEffect(() => {
    if (!isLoading && !user) {
      router.push('/login');
    }
  }, [user, isLoading, router]);

  const handleSend = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!prompt.trim() || sending) return;

    const userText = prompt.trim();
    const userMsgId = `m_${Date.now()}`;
    setMessages((prev) => [...prev, { id: userMsgId, sender: 'user', text: userText }]);
    setPrompt('');
    setSending(true);

    try {
      const res = await chatApi.ask(userText);
      setMessages((prev) => [
        ...prev,
        {
          id: `m_ai_${Date.now()}`,
          sender: 'ai',
          text: res.answer,
          sources_count: res.sources_count,
          context: res.context_used,
        },
      ]);
    } catch {
      setMessages((prev) => [
        ...prev,
        {
          id: `m_err_${Date.now()}`,
          sender: 'ai',
          text: 'Maaf, terjadi kendala koneksi saat menghubungi model AI Llama. Silakan coba beberapa saat lagi.',
        },
      ]);
    } finally {
      setSending(false);
    }
  };

  if (isLoading || !user) {
    return (
      <div className="min-h-screen bg-gray-950 flex items-center justify-center">
        <div className="text-gray-400 animate-pulse">Memuat...</div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-950 flex flex-col">
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
            { icon: '🕸️', label: 'Knowledge Graph', href: '/graph', active: false },
            { icon: '📡', label: 'Data Sources', href: '/sources', active: false },
            { icon: '🔔', label: 'Alerts', href: '/alerts', active: false },
            { icon: '🦙', label: 'AI Chat (Llama)', href: '/chat', active: true },
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

      {/* Main Content Area */}
      <main className="ml-64 flex-1 flex flex-col p-8 max-w-5xl">
        {/* Header */}
        <div className="mb-6 border-b border-gray-800 pb-4">
          <div className="flex items-center gap-3 mb-1">
            <h1 className="text-2xl font-bold text-white">AI Intelligence Assistant</h1>
            <span className="px-2.5 py-0.5 rounded-full text-xs bg-violet-500/10 text-violet-400 border border-violet-500/20 font-medium">
              🦙 Llama 3.1 (Self-hosted)
            </span>
          </div>
          <p className="text-gray-500 text-sm">
            Tanyakan wawasan terstruktur berbasis data Knowledge Graph dan hasil analisis NLP.
          </p>
        </div>

        {/* Chat History Container */}
        <div className="flex-1 space-y-4 mb-6 overflow-y-auto min-h-[400px]">
          {messages.map((m) => (
            <div
              key={m.id}
              className={`flex gap-3 ${m.sender === 'user' ? 'justify-end' : 'justify-start'}`}
            >
              {m.sender === 'ai' && (
                <div className="w-8 h-8 rounded-full bg-violet-600/20 border border-violet-500/30 text-violet-300 flex items-center justify-center shrink-0 text-sm">
                  🦙
                </div>
              )}
              <div
                className={`p-4 rounded-2xl max-w-2xl text-sm leading-relaxed ${
                  m.sender === 'user'
                    ? 'bg-violet-600 text-white rounded-br-none'
                    : 'bg-gray-900 border border-gray-800 text-gray-200 rounded-bl-none'
                }`}
              >
                <div className="whitespace-pre-line">{m.text}</div>
                {m.context && m.context.length > 0 && (
                  <div className="mt-3 pt-3 border-t border-gray-800 text-xs text-gray-500">
                    <span className="font-semibold text-gray-400">RAG Context:</span> {m.sources_count} percakapan dianalisis dari {m.context.map(c => c.platform).join(', ')}.
                  </div>
                )}
              </div>
            </div>
          ))}
          {sending && (
            <div className="flex gap-3 justify-start">
              <div className="w-8 h-8 rounded-full bg-violet-600/20 border border-violet-500/30 text-violet-300 flex items-center justify-center text-sm animate-pulse">
                🦙
              </div>
              <div className="p-4 rounded-2xl bg-gray-900 border border-gray-800 text-gray-400 text-sm animate-pulse">
                Llama sedang menganalisis data percakapan...
              </div>
            </div>
          )}
        </div>

        {/* Input Bar */}
        <form onSubmit={handleSend} className="flex gap-3">
          <input
            type="text"
            placeholder="Tanyakan analisis sentimen, isu terpopuler, atau ringkasan opini..."
            value={prompt}
            onChange={(e) => setPrompt(e.target.value)}
            disabled={sending}
            className="flex-1 px-4 py-3 bg-gray-900 border border-gray-800 rounded-xl text-white placeholder-gray-600 text-sm focus:outline-none focus:border-violet-500"
          />
          <button
            type="submit"
            disabled={sending || !prompt.trim()}
            className="px-6 py-3 bg-violet-600 hover:bg-violet-500 disabled:bg-violet-600/40 text-white rounded-xl text-sm font-semibold transition-all"
          >
            Kirim
          </button>
        </form>
      </main>
    </div>
  );
}
