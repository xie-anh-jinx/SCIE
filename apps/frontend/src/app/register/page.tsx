'use client';

import { useAuth } from '@/contexts/AuthContext';
import { parseApiError } from '@/lib/errors';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { useState } from 'react';

export default function RegisterPage() {
  const [form, setForm] = useState({
    email: '',
    username: '',
    password: '',
    fullName: '',
  });
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const { register } = useAuth();
  const router = useRouter();

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setSuccess('');
    setIsLoading(true);
    try {
      await register(form.email, form.username, form.password, form.fullName);
      setSuccess('Akun berhasil dibuat! Mengarahkan ke halaman login...');
      setTimeout(() => router.push('/login'), 2000);
    } catch (err: unknown) {
      setError(parseApiError(err, 'Registrasi gagal. Coba lagi.'));
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-950 flex items-center justify-center px-4 relative overflow-hidden">
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[600px] h-[400px] bg-violet-600/10 blur-3xl rounded-full pointer-events-none" />

      <div className="w-full max-w-md relative">
        <div className="text-center mb-8">
          <Link href="/" className="inline-flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-violet-600 to-blue-600 flex items-center justify-center text-white font-bold text-lg">
              S
            </div>
            <span className="text-2xl font-bold text-white">SCIE</span>
          </Link>
          <p className="text-gray-500 mt-2 text-sm">Social Intelligence Engine</p>
        </div>

        <div className="bg-gray-900 border border-gray-800 rounded-2xl p-8 shadow-2xl">
          <h1 className="text-xl font-semibold text-white mb-1">Buat akun baru</h1>
          <p className="text-gray-500 text-sm mb-6">
            Sudah punya akun?{' '}
            <Link href="/login" className="text-violet-400 hover:text-violet-300">
              Masuk di sini
            </Link>
          </p>

          {error && (
            <div className="mb-4 px-4 py-3 rounded-lg bg-red-500/10 border border-red-500/20 text-red-400 text-sm">
              {error}
            </div>
          )}
          {success && (
            <div className="mb-4 px-4 py-3 rounded-lg bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-sm">
              {success}
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-4">
            {[
              { id: 'fullName', label: 'Nama Lengkap', type: 'text', placeholder: 'John Doe', required: false },
              { id: 'email', label: 'Email', type: 'email', placeholder: 'you@example.com', required: true },
              { id: 'username', label: 'Username', type: 'text', placeholder: 'johndoe', required: true },
              { id: 'password', label: 'Password', type: 'password', placeholder: '••••••••', required: true },
            ].map((field) => (
              <div key={field.id}>
                <label className="block text-sm font-medium text-gray-400 mb-1.5">
                  {field.label} {field.required && <span className="text-red-500">*</span>}
                </label>
                <input
                  id={field.id}
                  name={field.id}
                  type={field.type}
                  value={form[field.id as keyof typeof form]}
                  onChange={handleChange}
                  required={field.required}
                  placeholder={field.placeholder}
                  className="w-full px-4 py-2.5 bg-gray-800 border border-gray-700 rounded-lg text-white placeholder-gray-600 focus:outline-none focus:border-violet-500 focus:ring-1 focus:ring-violet-500/50 transition-colors text-sm"
                />
              </div>
            ))}

            <button
              type="submit"
              id="register-submit"
              disabled={isLoading}
              className="w-full py-2.5 bg-violet-600 hover:bg-violet-500 disabled:bg-violet-600/50 text-white rounded-lg font-semibold transition-all duration-200 disabled:cursor-not-allowed text-sm mt-2"
            >
              {isLoading ? 'Membuat akun...' : 'Buat Akun'}
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}
