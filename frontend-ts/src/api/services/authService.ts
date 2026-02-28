import { apiClient } from '../httpClient';
import { tokenManager } from '../tokenManager';
import type {
  ApiResponse,
  AuthResponse,
  LoginRequest,
  RegisterRequest,
  RefreshTokenRequest,
} from '../../types/api';

const AUTH_BASE = '/auth';

export const authService = {
  async register(payload: RegisterRequest): Promise<AuthResponse> {
    const response = await apiClient.instance.post<ApiResponse<AuthResponse>>(
      `${AUTH_BASE}/register`,
      payload,
    );
    const data = response.data.data;
    if (!data) throw new Error('Invalid register response');
    tokenManager.setTokens(data.tokens);
    return data;
  },

  async login(payload: LoginRequest): Promise<AuthResponse> {
    const response = await apiClient.instance.post<ApiResponse<AuthResponse>>(
      `${AUTH_BASE}/login`,
      payload,
    );
    const data = response.data.data;
    if (!data) throw new Error('Invalid login response');
    tokenManager.setTokens(data.tokens);
    return data;
  },

  async refreshToken(payload?: RefreshTokenRequest): Promise<AuthResponse> {
    const refreshToken = payload?.refreshToken ?? tokenManager.getRefreshToken();
    if (!refreshToken) throw new Error('No refresh token available');

    const response = await apiClient.instance.post<ApiResponse<AuthResponse>>(
      `${AUTH_BASE}/refresh-token`,
      { refreshToken },
    );
    const data = response.data.data;
    if (!data) throw new Error('Invalid refresh-token response');
    tokenManager.setTokens(data.tokens);
    return data;
  },

  logout(): void {
    tokenManager.clearTokens();
  },
};
