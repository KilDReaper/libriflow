import { apiClient } from '../httpClient';
import { recommendationService } from './recommendationService';
import type {
  ApiResponse,
  ExplainRecommendationResponse,
} from '../../types/api';
import type {
  Book,
  RecommendationBook,
  RecommendationExplanation,
} from '../../types/models';

const BOOKS_BASE = '/books';

const toBook = (item: RecommendationBook): Book => ({
  id: item._id,
  title: item.title,
  author: item.author,
  genre: item.genre,
  description: item.description,
  imageUrl: item.coverImageUrl,
  averageRating: item.rating,
  availableCopies: item.availableQuantity,
});

export const bookService = {
  async getRecommendations(limit?: number): Promise<Book[]> {
    const items = await recommendationService.getMainRecommendations({ limit });
    return items.map(toBook);
  },

  async getTrendingRecommendations(limit?: number): Promise<Book[]> {
    const items = await recommendationService.getTrendingRecommendations({
      limit,
    });
    return items.map(toBook);
  },

  async getGenreRecommendations(genre: string, limit?: number): Promise<Book[]> {
    const items = await recommendationService.getAcademicRecommendations({
      course: genre,
      limit,
    });
    return items.map(toBook);
  },

  async getSimilarBooks(bookId: string): Promise<Book[]> {
    const items = await recommendationService.getSimilarRecommendations({
      bookId,
      limit: 10,
    });
    return items.map(toBook);
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
