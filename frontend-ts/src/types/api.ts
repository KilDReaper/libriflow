import type {
  Book,
  BookQueueStatus,
  Borrowing,
  FineSummary,
  Payment,
  PaymentGateway,
  Reservation,
  RecommendationExplanation,
  User,
} from './models';

export interface ApiError {
  message: string;
  code?: string;
  details?: unknown;
}

export interface ApiResponse<T> {
  success: boolean;
  message?: string;
  data?: T;
  items?: T;
  error?: ApiError;
}

export interface PaginatedResponse<T> {
  items: T[];
  total: number;
  page: number;
  limit: number;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface RegisterRequest {
  name: string;
  email: string;
  password: string;
}

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
}

export interface AuthResponse {
  user: User;
  tokens: AuthTokens;
}

export interface RefreshTokenRequest {
  refreshToken: string;
}

export interface RecommendationQuery {
  limit?: number;
}

export interface GenreRecommendationQuery {
  limit?: number;
}

export interface CreateReservationRequest {
  bookId: string;
}

export interface CreateReservationResponse {
  reservation: Reservation;
  queueStatus?: BookQueueStatus;
}

export interface CancelReservationResponse {
  reservation: Reservation;
}

export interface CreateBorrowingRequest {
  bookId: string;
}

export interface ReturnBorrowingResponse {
  borrowing: Borrowing;
  fineAmount?: number;
}

export interface InitiatePaymentRequest {
  gateway: PaymentGateway;
  amount: number;
  borrowingId?: string;
  reservationId?: string;
  metadata?: Record<string, string | number | boolean>;
}

export interface InitiatePaymentResponse {
  payment: Payment;
  paymentUrl?: string;
  referenceId?: string;
}

export interface VerifyPaymentQuery {
  gateway: PaymentGateway;
  referenceId?: string;
  transactionId?: string;
  paymentId?: string;
}

export interface VerifyPaymentResponse {
  payment: Payment;
}

export interface QRBorrowRequest {
  qrCode: string;
  userId?: string;
}

export interface QRBorrowResponse {
  borrowing: Borrowing;
}

export interface RecommendationsResponse {
  recommendations: Book[];
}

export interface SimilarBooksResponse {
  similar: Book[];
}

export interface ExplainRecommendationResponse {
  explanation: RecommendationExplanation;
}

export interface ReservationsResponse {
  reservations: Reservation[];
}

export interface BorrowingsResponse {
  borrowings: Borrowing[];
  fineSummary?: FineSummary;
}

export interface PaymentsResponse {
  payments: Payment[];
}
