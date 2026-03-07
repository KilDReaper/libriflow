import type { AxiosRequestConfig } from 'axios';

import { apiClient } from '../httpClient';
import type { RecommendationBook } from '../../types/models';

const RECOMMENDATIONS_BASE = '/books/recommendations';

export type RecommendationSource = 'academic' | 'trending' | 'external' | 'none';

export interface RecommendationRequestOptions {
  limit?: number;
  token?: string;
}

export interface AcademicRecommendationRequest extends RecommendationRequestOptions {
  course?: string;
  classLevel?: string;
}

export interface SimilarRecommendationRequest extends RecommendationRequestOptions {
  bookId: string;
}

export interface ExternalRecommendationRequest extends RecommendationRequestOptions {
  query: string;
}

export interface RecommendationFallbackResult {
  source: RecommendationSource;
  items: RecommendationBook[];
}

export interface AcademicFormSubmitOptions {
  courseInput: string;
  classInput: string;
  limit?: number;
  token?: string;
  setLoading: (loading: boolean) => void;
  setItems: (items: RecommendationBook[]) => void;
  setError: (message: string | null) => void;
  setIsEmpty: (isEmpty: boolean) => void;
}

const toNumber = (value: unknown, fallback = 0): number => {
  if (typeof value === 'number' && Number.isFinite(value)) return value;
  if (typeof value === 'string') {
    const parsed = Number(value);
    if (Number.isFinite(parsed)) return parsed;
  }
  return fallback;
};

const toStringSafe = (value: unknown, fallback = ''): string => {
  if (typeof value === 'string') {
    const trimmed = value.trim();
    return trimmed.length > 0 ? trimmed : fallback;
  }
  if (value == null) return fallback;
  const next = String(value).trim();
  return next.length > 0 ? next : fallback;
};

const normalizeCoverUrl = (value: unknown): string => {
  const raw = toStringSafe(value);
  if (!raw) return '';
  if (raw.startsWith('//')) return `https:${raw}`;
  if (/^https?:\/\//i.test(raw)) return raw;
  if (raw.startsWith('www.')) return `https://${raw}`;
  return raw;
};

const pickFirstString = (value: unknown, fallback = 'Unknown'): string => {
  if (Array.isArray(value)) {
    const first = value.find((item) => typeof item === 'string' && item.trim().length > 0);
    return first ? String(first).trim() : fallback;
  }
  return toStringSafe(value, fallback);
};

const normalizeRecommendationBook = (raw: unknown): RecommendationBook | null => {
  if (!raw || typeof raw !== 'object') {
    return null;
  }

  const item = raw as Record<string, unknown>;
  const id = toStringSafe(item._id ?? item.id);
  if (!id) return null;

  const genreValue = item.genre ?? item.section ?? item.category;
  const authorValue = item.author ?? item.authors;

  return {
    _id: id,
    title: toStringSafe(item.title ?? item.bookTitle ?? item.name, 'Untitled'),
    author: pickFirstString(authorValue, 'Unknown'),
    genre: pickFirstString(genreValue, 'General'),
    description: toStringSafe(item.description),
    coverImageUrl: normalizeCoverUrl(
      item.coverImageUrl ??
        item.coverUrl ??
        item.imageUrl ??
        item.image ??
        item.thumbnail,
    ),
    rating: toNumber(item.rating ?? item.averageRating, 0),
    availableQuantity: Math.max(
      0,
      Math.trunc(toNumber(item.availableQuantity ?? item.availableCopies ?? item.stockQuantity, 0)),
    ),
    reason: toStringSafe(item.reason),
    recommendationScore: toNumber(item.recommendationScore ?? item.score, 0),
  };
};

const extractRecommendationArray = (responseData: unknown): unknown[] => {
  const root = (responseData ?? {}) as Record<string, unknown>;

  const dataNode = (root.data ?? root.items ?? null) as Record<string, unknown> | null;
  const nestedDataNode =
    dataNode && typeof dataNode === 'object'
      ? ((dataNode.data ?? dataNode.items ?? null) as Record<string, unknown> | null)
      : null;

  const candidates: unknown[] = [
    nestedDataNode?.recommendations,
    nestedDataNode?.books,
    nestedDataNode?.similar,
    dataNode?.recommendations,
    dataNode?.books,
    dataNode?.similar,
    root.recommendations,
    root.books,
    root.similar,
  ];

  for (const candidate of candidates) {
    if (Array.isArray(candidate)) {
      return candidate;
    }
  }

  if (Array.isArray(root.data)) {
    return root.data;
  }

  return [];
};

const toHeaderConfig = (
  params: Record<string, unknown>,
  token?: string,
): AxiosRequestConfig => {
  const config: AxiosRequestConfig = { params };
  if (token && token.trim()) {
    config.headers = {
      Authorization: `Bearer ${token.trim()}`,
    };
  }
  return config;
};

const debugRequest = (path: string, params: Record<string, unknown>, token?: string): void => {
  const finalUrl = apiClient.instance.getUri({ url: path, params });
  console.debug('[recommendationService] request', {
    finalUrl,
    params,
    hasToken: Boolean(token && token.trim()),
  });
};

const debugParseCount = (label: string, items: RecommendationBook[]): void => {
  console.debug('[recommendationService] parsed', {
    label,
    count: items.length,
  });
};

const parseResponseRecommendations = (responseData: unknown, label: string): RecommendationBook[] => {
  const rawItems = extractRecommendationArray(responseData);
  const items = rawItems
    .map(normalizeRecommendationBook)
    .filter((item): item is RecommendationBook => item != null);

  debugParseCount(label, items);
  return items;
};

export const recommendationService = {
  async getMainRecommendations(options: RecommendationRequestOptions = {}): Promise<RecommendationBook[]> {
    const { limit = 10, token } = options;
    const path = RECOMMENDATIONS_BASE;
    const params = { limit };

    debugRequest(path, params, token);
    const response = await apiClient.instance.get(path, toHeaderConfig(params, token));
    return parseResponseRecommendations(response.data, 'main');
  },

  async getTrendingRecommendations(
    options: RecommendationRequestOptions = {},
  ): Promise<RecommendationBook[]> {
    const { limit = 10, token } = options;
    const path = `${RECOMMENDATIONS_BASE}/trending`;
    const params = { limit };

    debugRequest(path, params, token);
    const response = await apiClient.instance.get(path, toHeaderConfig(params, token));
    return parseResponseRecommendations(response.data, 'trending');
  },

  async getSimilarRecommendations({
    bookId,
    limit = 10,
    token,
  }: SimilarRecommendationRequest): Promise<RecommendationBook[]> {
    const safeBookId = toStringSafe(bookId);
    if (!safeBookId) {
      return [];
    }

    const path = `${RECOMMENDATIONS_BASE}/similar/${encodeURIComponent(safeBookId)}`;
    const params = { limit };

    debugRequest(path, params, token);
    const response = await apiClient.instance.get(path, toHeaderConfig(params, token));
    return parseResponseRecommendations(response.data, 'similar');
  },

  async getExternalRecommendations({
    query,
    limit = 10,
    token,
  }: ExternalRecommendationRequest): Promise<RecommendationBook[]> {
    const safeQuery = toStringSafe(query);
    if (!safeQuery) {
      return [];
    }

    const path = `${RECOMMENDATIONS_BASE}/external`;
    const params = { q: safeQuery, limit };

    debugRequest(path, params, token);
    const response = await apiClient.instance.get(path, toHeaderConfig(params, token));
    return parseResponseRecommendations(response.data, 'external');
  },

  async getAcademicRecommendations({
    course,
    classLevel,
    limit = 10,
    token,
  }: AcademicRecommendationRequest): Promise<RecommendationBook[]> {
    const safeCourse = toStringSafe(course);
    const safeClass = toStringSafe(classLevel);
    const genre = safeCourse || 'Academic';

    const path = `${RECOMMENDATIONS_BASE}/genre/${encodeURIComponent(genre)}`;
    const params: Record<string, unknown> = {
      dataType: 'academic',
      course: safeCourse || undefined,
      class: safeClass || undefined,
      limit,
    };

    debugRequest(path, params, token);
    const response = await apiClient.instance.get(path, toHeaderConfig(params, token));
    return parseResponseRecommendations(response.data, 'academic');
  },

  async getAcademicRecommendationsWithFallback(
    request: AcademicRecommendationRequest,
  ): Promise<RecommendationFallbackResult> {
    const academic = await this.getAcademicRecommendations(request);
    if (academic.length > 0) {
      return { source: 'academic', items: academic };
    }

    const trending = await this.getTrendingRecommendations({
      limit: request.limit,
      token: request.token,
    });
    if (trending.length > 0) {
      return { source: 'trending', items: trending };
    }

    const query = `${toStringSafe(request.course)} ${toStringSafe(request.classLevel)}`.trim();
    if (!query) {
      return { source: 'none', items: [] };
    }

    const external = await this.getExternalRecommendations({
      query,
      limit: request.limit,
      token: request.token,
    });

    if (external.length > 0) {
      return { source: 'external', items: external };
    }

    return { source: 'none', items: [] };
  },

  async submitAcademicRecommendationForm({
    courseInput,
    classInput,
    limit = 10,
    token,
    setLoading,
    setItems,
    setError,
    setIsEmpty,
  }: AcademicFormSubmitOptions): Promise<void> {
    setLoading(true);
    setError(null);

    try {
      const result = await this.getAcademicRecommendationsWithFallback({
        course: courseInput,
        classLevel: classInput,
        limit,
        token,
      });

      setItems(result.items);
      setIsEmpty(result.items.length === 0);

      if (result.items.length === 0) {
        setError('No recommendations found for your current inputs.');
      }
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Failed to load recommendations';
      setItems([]);
      setIsEmpty(true);
      setError(message);
    } finally {
      setLoading(false);
    }
  },
};
