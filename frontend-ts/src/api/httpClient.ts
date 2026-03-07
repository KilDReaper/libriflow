import axios, {
  AxiosError,
  AxiosHeaders,
  type AxiosInstance,
  type AxiosRequestConfig,
} from 'axios';
import { API_BASE_URL, API_TIMEOUT_MS } from './config';
import { tokenManager } from './tokenManager';
import type { ApiResponse, AuthResponse } from '../types/api';

type RetriableConfig = AxiosRequestConfig & { _retry?: boolean };

export class ApiClient {
  private readonly client: AxiosInstance;
  private refreshPromise: Promise<string | null> | null = null;

  constructor() {
    this.client = axios.create({
      baseURL: API_BASE_URL,
      timeout: API_TIMEOUT_MS,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    this.setupInterceptors();
  }

  get instance(): AxiosInstance {
    return this.client;
  }

  private setupInterceptors(): void {
    this.client.interceptors.request.use(
      (config) => {
        const accessToken = tokenManager.getAccessToken();
        if (accessToken) {
          const headers =
            config.headers instanceof AxiosHeaders
              ? config.headers
              : new AxiosHeaders(config.headers);
          headers.set('Authorization', `Bearer ${accessToken}`);
          config.headers = headers;
        }
        return config;
      },
      (error) => Promise.reject(error),
    );

    this.client.interceptors.response.use(
      (response) => response,
      async (error: AxiosError<ApiResponse<unknown>>) => {
        const originalRequest = error.config as RetriableConfig | undefined;

        if (!originalRequest || !error.response) {
          return Promise.reject(this.toApiError(error));
        }

        if (
          error.response.status === 401 &&
          !originalRequest._retry &&
          !String(originalRequest.url || '').includes('/auth/login') &&
          !String(originalRequest.url || '').includes('/auth/register') &&
          !String(originalRequest.url || '').includes('/auth/refresh-token')
        ) {
          originalRequest._retry = true;

          const newAccessToken = await this.refreshAccessToken();
          if (newAccessToken) {
            const headers =
              originalRequest.headers instanceof AxiosHeaders
                ? originalRequest.headers
                : new AxiosHeaders(originalRequest.headers);
            headers.set('Authorization', `Bearer ${newAccessToken}`);
            originalRequest.headers = headers;
            return this.client(originalRequest);
          }
        }

        return Promise.reject(this.toApiError(error));
      },
    );
  }

  private async refreshAccessToken(): Promise<string | null> {
    if (this.refreshPromise) {
      return this.refreshPromise;
    }

    this.refreshPromise = (async () => {
      const refreshToken = tokenManager.getRefreshToken();
      if (!refreshToken) {
        tokenManager.clearTokens();
        return null;
      }

      try {
        const response = await axios.post<ApiResponse<AuthResponse>>(
          `${API_BASE_URL}/auth/refresh-token`,
          { refreshToken },
          {
            timeout: API_TIMEOUT_MS,
            headers: { 'Content-Type': 'application/json' },
          },
        );

        const payload = response.data?.data;
        if (!payload?.tokens?.accessToken) {
          tokenManager.clearTokens();
          return null;
        }

        tokenManager.setTokens(payload.tokens);
        return payload.tokens.accessToken;
      } catch {
        tokenManager.clearTokens();
        return null;
      } finally {
        this.refreshPromise = null;
      }
    })();

    return this.refreshPromise;
  }

  private toApiError(error: AxiosError<ApiResponse<unknown>>): Error {
    const apiMessage = error.response?.data?.error?.message;
    const fallbackMessage = error.response?.data?.message;
    const message = apiMessage || fallbackMessage || error.message || 'Request failed';
    return new Error(message);
  }
}

export const apiClient = new ApiClient();
