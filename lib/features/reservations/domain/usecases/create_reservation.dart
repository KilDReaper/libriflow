import '../entities/reservation.dart';
import '../repositories/reservation_repository.dart';

class CreateReservation {
  final ReservationRepository repository;
  CreateReservation(this.repository);

  Future<Reservation> call({
    required String bookId,
    required String bookTitle,
  }) {
    return repository.createReservation(
      bookId: bookId,
      bookTitle: bookTitle,
    );
  }
}
