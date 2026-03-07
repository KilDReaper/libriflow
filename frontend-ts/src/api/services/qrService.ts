import { apiClient } from '../httpClient';
import type { ApiResponse, QRBorrowRequest, QRBorrowResponse } from '../../types/api';
import type { Borrowing } from '../../types/models';

export const qrService = {
  async issueBookByQr(payload: QRBorrowRequest): Promise<QRBorrowResponse> {
    const response = await apiClient.instance.post<ApiResponse<QRBorrowResponse | Borrowing>>(
      '/borrow/scan',
      payload,
    );
    const data = response.data.data;
    if (!data) throw new Error('Invalid QR borrow response');
    if ('borrowing' in (data as QRBorrowResponse)) {
      return data as QRBorrowResponse;
    }
    return { borrowing: data as Borrowing };
  },
};
