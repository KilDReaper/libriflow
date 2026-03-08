import 'package:flutter_test/flutter_test.dart';
import 'package:libriflow/features/reservations/domain/entities/reservation.dart';

void main() {
  test('Reservation isExpired is true when expiration is in the past', () {
    final reservation = Reservation(
      id: 'r1',
      bookId: 'b1',
      bookTitle: 'Book',
      status: 'active',
      queuePosition: 1,
      expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
    );

    expect(reservation.isExpired, isTrue);
  });

  test('Reservation isExpired is false when expiration is in the future', () {
    final reservation = Reservation(
      id: 'r2',
      bookId: 'b2',
      bookTitle: 'Book 2',
      status: 'active',
      queuePosition: 2,
      expiresAt: DateTime.now().add(const Duration(minutes: 1)),
    );

    expect(reservation.isExpired, isFalse);
  });
}
