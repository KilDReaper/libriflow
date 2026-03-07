import '../entities/reservation.dart';
import '../repositories/reservation_repository.dart';

class GetMyReservations {
  final ReservationRepository repository;
  GetMyReservations(this.repository);

  Future<List<Reservation>> call() {
    return repository.getMyReservations();
  }
}
