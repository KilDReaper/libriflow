import 'package:flutter/material.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/usecases/cancel_reservation.dart';
import '../../domain/usecases/create_reservation.dart';
import '../../domain/usecases/get_my_reservations.dart';

enum ReservationStatus { initial, loading, success, error }

enum ReservationAction { none, fetch, reserve, cancel }

class ReservationProvider extends ChangeNotifier {
  final GetMyReservations getMyReservations;
  final CreateReservation createReservation;
  final CancelReservation cancelReservationUseCase;

  ReservationStatus _status = ReservationStatus.initial;
  ReservationAction _action = ReservationAction.none;
  List<Reservation> _reservations = const [];
  String? _errorMessage;
  String? _successMessage;

  ReservationProvider({
    required this.getMyReservations,
    required this.createReservation,
    required this.cancelReservationUseCase,
  });

  ReservationStatus get status => _status;
  ReservationAction get action => _action;
  List<Reservation> get reservations => _reservations;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  bool get isLoading => _status == ReservationStatus.loading;
  bool get isFetching => isLoading && _action == ReservationAction.fetch;
  bool get isReserving => isLoading && _action == ReservationAction.reserve;
  bool get isCancelling => isLoading && _action == ReservationAction.cancel;

  Future<void> fetchMyReservations() async {
    _status = ReservationStatus.loading;
    _action = ReservationAction.fetch;
    _errorMessage = null;
    notifyListeners();

    try {
      _reservations = await getMyReservations();
      _status = ReservationStatus.success;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = ReservationStatus.error;
      notifyListeners();
    }
  }

  Future<void> reserveBook({
    required String bookId,
    required String bookTitle,
  }) async {
    _status = ReservationStatus.loading;
    _action = ReservationAction.reserve;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final reservation = await createReservation(
        bookId: bookId,
        bookTitle: bookTitle,
      );
      _reservations = [reservation, ..._reservations];
      _status = ReservationStatus.success;
      _successMessage = 'Reservation created successfully';
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = ReservationStatus.error;
      notifyListeners();
    }
  }

  Future<void> cancelReservation(String reservationId) async {
    _status = ReservationStatus.loading;
    _action = ReservationAction.cancel;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await cancelReservationUseCase(reservationId);
      _reservations = _reservations
          .map(
            (reservation) => reservation.id == reservationId
                ? Reservation(
                    id: reservation.id,
                    bookId: reservation.bookId,
                    bookTitle: reservation.bookTitle,
                    status: 'cancelled',
                    queuePosition: reservation.queuePosition,
                    expiresAt: reservation.expiresAt,
                  )
                : reservation,
          )
          .toList();
      _status = ReservationStatus.success;
      _successMessage = 'Reservation cancelled';
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = ReservationStatus.error;
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
