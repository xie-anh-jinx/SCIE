/**
 * SCIE API Client
 * Centralized HTTP client using axios with auth token injection.
 */
import axios, { AxiosInstance, AxiosRequestConfig, AxiosResponse } from 'axios';

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000';

// ─── Axios Instance ──────────────────────────────────────────────────────────

const api: AxiosInstance = axios.create({
  baseURL: `${API_URL}/api/v1`,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 30000,
});

// Request interceptor — inject access token
api.interceptors.request.use(
  (config) => {
    const token = getAccessToken();
    if (token) {
      config.headers['Authorization'] = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Response interceptor — handle 401, auto-refresh token
api.interceptors.response.use(
  (response: AxiosResponse) => response,
  async (error) => {
    const originalRequest = error.config;

    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;
      try {
        const refreshToken = getRefreshToken();
        if (refreshToken) {
          const response = await axios.post(`${API_URL}/api/v1/auth/refresh`, {
            refresh_token: refreshToken,
          });
          const { access_token } = response.data;
          setAccessToken(access_token);
          originalRequest.headers['Authorization'] = `Bearer ${access_token}`;
          return api(originalRequest);
        }
      } catch {
        clearTokens();
        window.location.href = '/login';
      }
    }
    return Promise.reject(error);
  }
);

// ─── Token Helpers ───────────────────────────────────────────────────────────

export const getAccessToken = (): string | null =>
  typeof window !== 'undefined' ? localStorage.getItem('scie_access_token') : null;

export const getRefreshToken = (): string | null =>
  typeof window !== 'undefined' ? localStorage.getItem('scie_refresh_token') : null;

export const setTokens = (access: string, refresh: string): void => {
  localStorage.setItem('scie_access_token', access);
  localStorage.setItem('scie_refresh_token', refresh);
};

export const setAccessToken = (access: string): void => {
  localStorage.setItem('scie_access_token', access);
};

export const clearTokens = (): void => {
  localStorage.removeItem('scie_access_token');
  localStorage.removeItem('scie_refresh_token');
};

// ─── Auth API ────────────────────────────────────────────────────────────────

export interface LoginPayload {
  email: string;
  password: string;
}

export interface RegisterPayload {
  email: string;
  username: string;
  password: string;
  full_name?: string;
}

export interface TokenResponse {
  access_token: string;
  refresh_token: string;
  token_type: string;
  expires_in: number;
}

export interface User {
  id: string;
  email: string;
  username: string;
  full_name: string | null;
  role: string;
  is_active: boolean;
  is_verified: boolean;
  organization_id: string | null;
  last_login: string | null;
  created_at: string;
}

export const authApi = {
  login: async (payload: LoginPayload): Promise<TokenResponse> => {
    const res = await api.post<TokenResponse>('/auth/login', payload);
    return res.data;
  },

  register: async (payload: RegisterPayload): Promise<User> => {
    const res = await api.post<User>('/auth/register', payload);
    return res.data;
  },

  refresh: async (refreshToken: string): Promise<{ access_token: string }> => {
    const res = await api.post('/auth/refresh', { refresh_token: refreshToken });
    return res.data;
  },

  logout: async (refreshToken: string): Promise<void> => {
    await api.post('/auth/logout', { refresh_token: refreshToken });
    clearTokens();
  },

  getMe: async (): Promise<User> => {
    const res = await api.get<User>('/auth/me');
    return res.data;
  },
};

// ─── Health API ───────────────────────────────────────────────────────────────

export const healthApi = {
  check: async () => {
    const res = await axios.get(`${API_URL}/health`);
    return res.data;
  },
};

export default api;
