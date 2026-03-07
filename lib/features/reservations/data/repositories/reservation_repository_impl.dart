import '../../domain/entities/reservation.dart';
import '../../domain/repositories/reservation_repository.dart';
import '../datasources/reservation_remote_datasource.dart';

class ReservationRepositoryImpl implements ReservationRepository {
  final ReservationRemoteDataSource remote;

  ReservationRepositoryImpl(this.remote);

  @override
  Future<List<Reservation>> getMyReservations() async {
    final models = await remote.getMyReservations();
    return models;
  }

  @override
  Future<Reservation> createReservation({
    required String bookId,
    required String bookTitle,
  }) async {
    final model = await remote.createReservation(
      bookId: bookId,
      bookTitle: bookTitle,
    );
    return model;
  }

  @override
  Future<void> cancelReservation(String reservationId) async {
    await remote.cancelReservation(reservationId);
  }
}
