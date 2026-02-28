export const API_BASE_URL =
  process.env.LIBRIFLOW_API_URL?.trim() || 'http://localhost:5000/api';

export const API_TIMEOUT_MS = 30000;

export const AUTH_STORAGE_KEYS = {
  accessToken: 'libriflow.accessToken',
  refreshToken: 'libriflow.refreshToken',
} as const;
