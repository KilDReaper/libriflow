import type { AuthTokens } from '../types/api';
import { AUTH_STORAGE_KEYS } from './config';

export interface TokenStorage {
  getItem(key: string): string | null;
  setItem(key: string, value: string): void;
  removeItem(key: string): void;
}

class InMemoryStorage implements TokenStorage {
  private store = new Map<string, string>();

  getItem(key: string): string | null {
    return this.store.get(key) ?? null;
  }

  setItem(key: string, value: string): void {
    this.store.set(key, value);
  }

  removeItem(key: string): void {
    this.store.delete(key);
  }
}

const fallbackStorage = new InMemoryStorage();

const resolveStorage = (): TokenStorage => {
  if (typeof window !== 'undefined' && window.localStorage) {
    return window.localStorage;
  }
  return fallbackStorage;
};

export class TokenManager {
  private storage: TokenStorage;

  constructor(storage?: TokenStorage) {
    this.storage = storage ?? resolveStorage();
  }

  getAccessToken(): string | null {
    return this.storage.getItem(AUTH_STORAGE_KEYS.accessToken);
  }

  getRefreshToken(): string | null {
    return this.storage.getItem(AUTH_STORAGE_KEYS.refreshToken);
  }

  setTokens(tokens: AuthTokens): void {
    this.storage.setItem(AUTH_STORAGE_KEYS.accessToken, tokens.accessToken);
    this.storage.setItem(AUTH_STORAGE_KEYS.refreshToken, tokens.refreshToken);
  }

  clearTokens(): void {
    this.storage.removeItem(AUTH_STORAGE_KEYS.accessToken);
    this.storage.removeItem(AUTH_STORAGE_KEYS.refreshToken);
  }
}

export const tokenManager = new TokenManager();
