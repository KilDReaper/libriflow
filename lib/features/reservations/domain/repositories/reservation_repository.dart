import '../entities/reservation.dart';

abstract class ReservationRepository {
  Future<List<Reservation>> getMyReservations();
  Future<Reservation> createReservation({
    required String bookId,
    required String bookTitle,
  });
  Future<void> cancelReservation(String reservationId);
}
