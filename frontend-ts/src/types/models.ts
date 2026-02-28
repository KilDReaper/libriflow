export type Role = 'member' | 'admin';

export interface User {
  id: string;
  name: string;
  email: string;
  role: Role;
  createdAt: string;
  updatedAt: string;
}

export interface Book {
  id: string;
  title: string;
  author: string;
  isbn?: string;
  genre?: string;
  description?: string;
  imageUrl?: string;
  averageRating?: number;
  totalRatings?: number;
  totalCopies?: number;
  availableCopies?: number;
  isAvailable?: boolean;
  publishedAt?: string;
  createdAt?: string;
  updatedAt?: string;
}

export interface RecommendationExplanation {
  reason: string;
  confidence?: number;
  signals?: string[];
}

export type ReservationStatus = 'approved' | 'queued' | 'cancelled' | 'expired' | 'completed';

export interface Reservation {
  id: string;
  userId: string;
  bookId: string;
  book?: Book;
  status: ReservationStatus;
  queuePosition?: number;
  isInstantApproval?: boolean;
  expiresAt?: string;
  createdAt: string;
  updatedAt: string;
}

export interface BookQueueStatus {
  bookId: string;
  queueLength: number;
  myPosition?: number;
  nextAvailableEstimate?: string;
}

export type BorrowingStatus = 'active' | 'returned' | 'overdue';

export interface Borrowing {
  id: string;
  userId: string;
  bookId: string;
  book?: Book;
  issuedAt: string;
  dueDate: string;
  returnedAt?: string;
  status: BorrowingStatus;
  daysOverdue?: number;
  fineAmount?: number;
  createdAt: string;
  updatedAt: string;
}

export type PaymentGateway = 'khalti' | 'esewa' | 'stripe' | 'cash';
export type PaymentStatus = 'pending' | 'success' | 'failed' | 'cancelled' | 'refunded';

export interface Payment {
  id: string;
  userId: string;
  borrowingId?: string;
  reservationId?: string;
  amount: number;
  currency: string;
  gateway: PaymentGateway;
  status: PaymentStatus;
  transactionId?: string;
  referenceId?: string;
  paidAt?: string;
  createdAt: string;
  updatedAt: string;
}

export interface FineSummary {
  totalFine: number;
  totalOverdueBooks: number;
  overdueBorrowings: Borrowing[];
}
