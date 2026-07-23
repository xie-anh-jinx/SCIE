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

// ─── Posts API ────────────────────────────────────────────────────────────────

export interface Post {
  id: string;
  platform: string;
  platform_id: string;
  type: string;
  text: string | null;
  text_cleaned: string | null;
  language: string | null;
  url: string | null;
  timestamp: string | null;
  likes: number;
  comments: number;
  shares: number;
  views: number;
  sentiment_label: string | null;
  sentiment_score: number | null;
  topics: string[];
  keywords: string[];
  virality_score: number;
  collected_at: string;
}

export interface PostStats {
  total_posts: number;
  platform_breakdown: Record<string, number>;
  sentiment_breakdown: Record<string, number>;
  top_topics: Array<{ topic: string; count: number }>;
  top_keywords: Array<{ keyword: string; count: number }>;
}

export const postsApi = {
  list: async (params?: {
    platform?: string;
    sentiment?: string;
    topic?: string;
    search?: string;
    page?: number;
    limit?: number;
  }) => {
    const res = await api.get<{ items: Post[]; total: number; page: number; pages: number }>('/posts', { params });
    return res.data;
  },

  getStats: async (): Promise<PostStats> => {
    const res = await api.get<PostStats>('/posts/stats');
    return res.data;
  },
};

// ─── Sources API ──────────────────────────────────────────────────────────────

export interface DataSource {
  id: string;
  name: string;
  platform: string;
  config: Record<string, any>;
  keywords: string[];
  is_active: boolean;
  last_run_at: string | null;
  posts_collected: number;
  status: string;
}

export const sourcesApi = {

  list: async (): Promise<DataSource[]> => {
    const res = await api.get<DataSource[]>('/sources');
    return res.data;
  },
  create: async (data: Partial<DataSource>): Promise<DataSource> => {
    const res = await api.post<DataSource>('/sources', data);
    return res.data;
  },
  toggle: async (id: string, is_active: boolean): Promise<DataSource> => {
    const res = await api.patch<DataSource>(`/sources/${id}`, { is_active });
    return res.data;
  },
};


// ─── Knowledge Graph API ──────────────────────────────────────────────────────

export interface GraphNode {
  id: string;
  label: string;
  type: 'User' | 'Post' | 'Topic' | 'Entity' | 'Actor' | 'Party' | 'Institution' | 'Narrative';
  color: string;
  size: number;
}

export interface GraphEdge {
  id: string;
  source: string;
  target: string;
  label: string;
}

export interface GraphData {
  nodes: GraphNode[];
  edges: GraphEdge[];
  total_nodes: number;
  total_edges: number;
}

export interface PoliticalClusterItem {
  id: string;
  name: string;
  dominant_actors: string[];
  share_percentage: number;
  sentiment: string;
  key_issues: string[];
}

export const graphApi = {
  get: async (view: 'general' | 'political' = 'general', limit: number = 60): Promise<GraphData> => {
    const res = await api.get<GraphData>('/graph', { params: { view, limit } });
    return res.data;
  },
  getClusters: async (): Promise<{ region: string; total_clusters: number; clusters: PoliticalClusterItem[] }> => {
    const res = await api.get<{ region: string; total_clusters: number; clusters: PoliticalClusterItem[] }>('/graph/clusters');
    return res.data;
  },
};


// ─── Analytics API ────────────────────────────────────────────────────────────

export interface TrendItem {
  topic: string;
  volume: number;
  trend_score: number;
  avg_sentiment: number;
  status: string;
}

export interface InfluencerItem {
  id: string;
  platform: string;
  username: string;
  display_name: string;
  follower_count: number;
  influence_score: number;
  community_id: string;
}

export const analyticsApi = {
  getTrends: async (): Promise<{ trends: TrendItem[] }> => {
    const res = await api.get<{ trends: TrendItem[] }>('/analytics/trends');
    return res.data;
  },

  getInfluencers: async (): Promise<{ influencers: InfluencerItem[] }> => {
    const res = await api.get<{ influencers: InfluencerItem[] }>('/analytics/influencers');
    return res.data;
  },
};

// ─── AI Chat API ──────────────────────────────────────────────────────────────

export interface ChatResponseData {
  answer: string;
  model: string;
  sources_count: number;
  context_used: Array<{ platform: string; text: string; sentiment: string; topics: string[] }>;
}

export const chatApi = {
  ask: async (prompt: string): Promise<ChatResponseData> => {
    const res = await api.post<ChatResponseData>('/chat', { prompt });
    return res.data;
  },
};

// ─── Alerts API ──────────────────────────────────────────────────────────────

export interface AlertItem {
  id: string;
  type: string;
  severity: 'HIGH' | 'MEDIUM' | 'INFO';
  title: string;
  description: string;
  created_at: string;
  status: string;
}

export const alertsApi = {
  list: async (): Promise<{ alerts: AlertItem[]; total_active: number }> => {
    const res = await api.get<{ alerts: AlertItem[]; total_active: number }>('/alerts');
    return res.data;
  },
};

// ─── Reports API ─────────────────────────────────────────────────────────────

export interface ExecutiveReportData {
  title: string;
  generated_at: string;
  author: string;
  province?: string;
  total_posts: number;
  sentiment_stats: { positive: number; neutral: number; negative: number };
  layer_distribution?: Record<string, number>;
  executive_narrative: string;
}

export interface AIReportResponse {
  title: string;
  generated_at: string;
  province: string;
  model_used: string;
  total_sources_analyzed: number;
  ai_report_narrative: string;
}

export const reportsApi = {
  getSummary: async (province: string = 'Sulawesi Selatan'): Promise<ExecutiveReportData> => {
    const res = await api.get<ExecutiveReportData>('/reports/summary', { params: { province } });
    return res.data;
  },

  generateAiBriefing: async (province: string = 'Sulawesi Selatan'): Promise<AIReportResponse> => {
    const res = await api.post<AIReportResponse>('/reports/generate', null, { params: { province } });
    return res.data;
  },
};


// ─── Geospatial Map API ──────────────────────────────────────────────────────


export interface MapEventItem {
  id: string;
  title: string;
  full_text?: string;
  platform: string;
  latitude: number;
  longitude: number;
  location_name: string;
  province: string;
  layer_category: 'konflik' | 'hotspot' | 'pangkalan' | 'infrastruktur' | 'ekonomi' | 'perairan' | 'bencana';
  sentiment_label: string;
  sentiment_score: number;
  virality_score: number;
  topics: string[];
  url?: string;
  timestamp?: string;
}

export interface MapSummaryData {
  region: string;
  layers: Record<string, number>;
  top_provinces: Array<{ province: string; count: number }>;
}

export const mapApi = {
  getEvents: async (layers?: string, province?: string, limit: number = 250): Promise<{ total_events: number; events: MapEventItem[] }> => {
    const params: Record<string, any> = { limit };
    if (layers) params.layers = layers;
    if (province) params.province = province;
    const res = await api.get<{ total_events: number; events: MapEventItem[] }>('/map/events', { params });
    return res.data;
  },
  getSummary: async (): Promise<MapSummaryData> => {
    const res = await api.get<MapSummaryData>('/map/summary');
    return res.data;
  },
};

export default api;







