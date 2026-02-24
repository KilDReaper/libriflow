import '../repositories/reservation_repository.dart';

class CancelReservation {
  final ReservationRepository repository;
  CancelReservation(this.repository);

  Future<void> call(String reservationId) {
    return repository.cancelReservation(reservationId);
  }
}
