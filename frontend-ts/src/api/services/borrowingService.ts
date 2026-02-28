import { apiClient } from '../httpClient';
import type {
  ApiResponse,
  BorrowingsResponse,
  CreateBorrowingRequest,
  ReturnBorrowingResponse,
} from '../../types/api';
import type { Borrowing } from '../../types/models';

const BORROWINGS_BASE = '/borrowings';

export const borrowingService = {
  async getBorrowings(): Promise<Borrowing[]> {
    const response = await apiClient.instance.get<ApiResponse<BorrowingsResponse | Borrowing[]>>(
      BORROWINGS_BASE,
    );
    const data = response.data.data;
    if (!data) return [];
    if (Array.isArray(data)) return data;
    return data.borrowings ?? [];
  },

  async createBorrowing(payload: CreateBorrowingRequest): Promise<Borrowing> {
    const response = await apiClient.instance.post<ApiResponse<Borrowing | { borrowing: Borrowing }>>(
      BORROWINGS_BASE,
      payload,
    );
    const data = response.data.data;
    if (!data) throw new Error('Invalid create borrowing response');
    if ('borrowing' in (data as { borrowing: Borrowing })) {
      return (data as { borrowing: Borrowing }).borrowing;
    }
    return data as Borrowing;
  },

  async returnBorrowing(borrowingId: string): Promise<ReturnBorrowingResponse> {
    const response = await apiClient.instance.patch<ApiResponse<ReturnBorrowingResponse | Borrowing>>(
      `${BORROWINGS_BASE}/${encodeURIComponent(borrowingId)}/return`,
    );
    const data = response.data.data;
    if (!data) throw new Error('Invalid return borrowing response');
    if ('borrowing' in (data as ReturnBorrowingResponse)) {
      return data as ReturnBorrowingResponse;
    }
    return { borrowing: data as Borrowing };
  },
};
