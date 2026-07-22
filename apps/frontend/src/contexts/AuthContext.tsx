'use client';

import { authApi, clearTokens, getAccessToken, setTokens } from '@/lib/api';
import { createContext, useContext, useEffect, useState, ReactNode } from 'react';

interface User {
  id: string;
  email: string;
  username: string;
  full_name: string | null;
  role: string;
  is_active: boolean;
  created_at: string;
}

interface AuthContextType {
  user: User | null;
  isLoading: boolean;
  isAuthenticated: boolean;
  login: (email: string, password: string) => Promise<void>;
  register: (email: string, username: string, password: string, fullName?: string) => Promise<User>;
  logout: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  // On mount, try to load user from stored token
  useEffect(() => {
    const token = getAccessToken();
    if (token) {
      authApi
        .getMe()
        .then(setUser)
        .catch((_err: unknown) => {
          clearTokens();
          setUser(null);
        })
        .finally(() => setIsLoading(false));
    } else {
      setIsLoading(false);
    }
  }, []);

  const login = async (email: string, password: string) => {
    const tokens = await authApi.login({ email, password });
    setTokens(tokens.access_token, tokens.refresh_token);
    const me = await authApi.getMe();
    setUser(me);
  };

  const register = async (
    email: string,
    username: string,
    password: string,
    fullName?: string
  ) => {
    const newUser = await authApi.register({ email, username, password, full_name: fullName });
    return newUser;
  };

  const logout = async () => {
    const refreshToken = localStorage.getItem('scie_refresh_token') || '';
    try {
      await authApi.logout(refreshToken);
    } finally {
      clearTokens();
      setUser(null);
    }
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        isLoading,
        isAuthenticated: !!user,
        login,
        register,
        logout,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used within AuthProvider');
  return ctx;
}
