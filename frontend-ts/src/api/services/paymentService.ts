import { apiClient } from '../httpClient';
import type {
  ApiResponse,
  InitiatePaymentRequest,
  InitiatePaymentResponse,
  PaymentsResponse,
  VerifyPaymentQuery,
  VerifyPaymentResponse,
} from '../../types/api';
import type { Payment } from '../../types/models';

const PAYMENTS_BASE = '/payments';

export const paymentService = {
  async getPaymentHistory(): Promise<Payment[]> {
    const response = await apiClient.instance.get<ApiResponse<PaymentsResponse | Payment[]>>(
      PAYMENTS_BASE,
    );
    const data = response.data.data;
    if (!data) return [];
    if (Array.isArray(data)) return data;
    return data.payments ?? [];
  },

  async initiatePayment(payload: InitiatePaymentRequest): Promise<InitiatePaymentResponse> {
    const response = await apiClient.instance.post<ApiResponse<InitiatePaymentResponse | Payment>>(
      `${PAYMENTS_BASE}/initiate`,
      payload,
    );
    const data = response.data.data;
    if (!data) throw new Error('Invalid payment initiation response');

    if ('payment' in (data as InitiatePaymentResponse)) {
      return data as InitiatePaymentResponse;
    }

    return { payment: data as Payment };
  },

  async verifyPayment(query: VerifyPaymentQuery): Promise<VerifyPaymentResponse> {
    const response = await apiClient.instance.get<ApiResponse<VerifyPaymentResponse | Payment>>(
      `${PAYMENTS_BASE}/verify`,
      { params: query },
    );
    const data = response.data.data;
    if (!data) throw new Error('Invalid payment verification response');

    if ('payment' in (data as VerifyPaymentResponse)) {
      return data as VerifyPaymentResponse;
    }

    return { payment: data as Payment };
  },
};
