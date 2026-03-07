import { apiClient } from '../httpClient';
import type {
  ApiResponse,
  BookQueueStatus,
  CancelReservationResponse,
  CreateReservationRequest,
  CreateReservationResponse,
  ReservationsResponse,
} from '../../types/api';
import type { Reservation } from '../../types/models';

const RESERVATIONS_BASE = '/reservations';

export const reservationService = {
  async createReservation(payload: CreateReservationRequest): Promise<CreateReservationResponse> {
    const response = await apiClient.instance.post<ApiResponse<CreateReservationResponse | Reservation>>(
      RESERVATIONS_BASE,
      payload,
    );

    const data = response.data.data;
    if (!data) throw new Error('Invalid reservation response');

    if ('reservation' in (data as CreateReservationResponse)) {
      return data as CreateReservationResponse;
    }

    return { reservation: data as Reservation };
  },

  async getMyReservations(): Promise<Reservation[]> {
    const response = await apiClient.instance.get<ApiResponse<ReservationsResponse | Reservation[]>>(
      `${RESERVATIONS_BASE}/my`,
    );
    const data = response.data.data;
    if (!data) return [];
    if (Array.isArray(data)) return data;
    return data.reservations ?? [];
  },

  async cancelReservation(reservationId: string): Promise<Reservation> {
    const response = await apiClient.instance.patch<ApiResponse<CancelReservationResponse | Reservation>>(
      `${RESERVATIONS_BASE}/${encodeURIComponent(reservationId)}/cancel`,
    );
    const data = response.data.data;
    if (!data) throw new Error('Invalid cancel response');
    if ('reservation' in (data as CancelReservationResponse)) {
      return (data as CancelReservationResponse).reservation;
    }
    return data as Reservation;
  },

  async getBookQueueStatus(bookId: string): Promise<BookQueueStatus> {
    const response = await apiClient.instance.get<ApiResponse<BookQueueStatus>>(
      `${RESERVATIONS_BASE}/book/${encodeURIComponent(bookId)}/queue`,
    );
    const data = response.data.data;
    if (!data) throw new Error('Invalid queue response');
    return data;
  },
};
