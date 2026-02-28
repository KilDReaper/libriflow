import { apiClient } from '../httpClient';
import type {
  ApiResponse,
  ExplainRecommendationResponse,
  RecommendationsResponse,
  SimilarBooksResponse,
} from '../../types/api';
import type { Book, RecommendationExplanation } from '../../types/models';

const BOOKS_BASE = '/books';

const extractBooks = (data?: ApiResponse<RecommendationsResponse | Book[]>): Book[] => {
  const payload = data?.data;
  if (!payload) return [];
  if (Array.isArray(payload)) return payload;
  if ('recommendations' in payload && Array.isArray(payload.recommendations)) {
    return payload.recommendations;
  }
  return [];
};

export const bookService = {
  async getRecommendations(limit?: number): Promise<Book[]> {
    const response = await apiClient.instance.get<ApiResponse<RecommendationsResponse | Book[]>>(
      `${BOOKS_BASE}/recommendations`,
      { params: { limit } },
    );
    return extractBooks(response.data);
  },

  async getTrendingRecommendations(limit?: number): Promise<Book[]> {
    const response = await apiClient.instance.get<ApiResponse<RecommendationsResponse | Book[]>>(
      `${BOOKS_BASE}/recommendations/trending`,
      { params: { limit } },
    );
    return extractBooks(response.data);
  },

  async getGenreRecommendations(genre: string, limit?: number): Promise<Book[]> {
    const response = await apiClient.instance.get<ApiResponse<RecommendationsResponse | Book[]>>(
      `${BOOKS_BASE}/recommendations/genre/${encodeURIComponent(genre)}`,
      { params: { limit } },
    );
    return extractBooks(response.data);
  },

  async getSimilarBooks(bookId: string): Promise<Book[]> {
    const response = await apiClient.instance.get<ApiResponse<SimilarBooksResponse | Book[]>>(
      `${BOOKS_BASE}/recommendations/similar/${encodeURIComponent(bookId)}`,
    );
    const payload = response.data.data;
    if (!payload) return [];
    if (Array.isArray(payload)) return payload;
    if ('similar' in payload && Array.isArray(payload.similar)) return payload.similar;
    return [];
  },

  async explainRecommendation(bookId: string): Promise<RecommendationExplanation | null> {
    const response = await apiClient.instance.get<ApiResponse<ExplainRecommendationResponse | RecommendationExplanation>>(
      `${BOOKS_BASE}/recommendations/explain/${encodeURIComponent(bookId)}`,
    );
    const payload = response.data.data;
    if (!payload) return null;
    if ('explanation' in (payload as ExplainRecommendationResponse)) {
      return (payload as ExplainRecommendationResponse).explanation;
    }
    return payload as RecommendationExplanation;
  },
};
