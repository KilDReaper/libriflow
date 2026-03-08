import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:libriflow/features/reservations/domain/entities/reservation.dart';
import 'package:libriflow/features/reservations/domain/repositories/reservation_repository.dart';
import 'package:libriflow/features/reservations/domain/usecases/create_reservation.dart';
import 'package:libriflow/features/reservations/domain/usecases/cancel_reservation.dart';
import 'package:libriflow/features/reservations/domain/usecases/get_my_reservations.dart';

class MockReservationRepository extends Mock
    implements ReservationRepository {}

void main() {
  late MockReservationRepository mockRepository;

  setUp(() {
    mockRepository = MockReservationRepository();
  });

  group('Reservation UseCase Tests', () {
    final testReservation = Reservation(
      id: '1',
      bookId: 'book1',
      bookTitle: 'Test Book',
      status: 'active',
      queuePosition: 1,
      expiresAt: DateTime.now().add(const Duration(days: 7)),
    );

    group('CreateReservation', () {
      late CreateReservation useCase;

      setUp(() {
        useCase = CreateReservation(mockRepository);
      });

      test('should create book reservation', () async {
        // Arrange
        when(() => mockRepository.createReservation(
              bookId: any(named: 'bookId'),
              bookTitle: any(named: 'bookTitle'),
            )).thenAnswer((_) async => testReservation);

        // Act
        final result = await useCase.call(
          bookId: 'book1',
          bookTitle: 'Test Book',
        );

        // Assert
        expect(result, testReservation);
        expect(result.bookId, 'book1');
        verify(() => mockRepository.createReservation(
              bookId: 'book1',
              bookTitle: 'Test Book',
            )).called(1);
      });

      test('should handle reservation errors', () async {
        // Arrange
        when(() => mockRepository.createReservation(
              bookId: any(named: 'bookId'),
              bookTitle: any(named: 'bookTitle'),
            )).thenThrow(Exception('Book not available for reservation'));

        // Act & Assert
        expect(
          () => useCase.call(
            bookId: 'book1',
            bookTitle: 'Test Book',
          ),
          throwsException,
        );
      });
    });

    group('CancelReservation', () {
      late CancelReservation useCase;

      setUp(() {
        useCase = CancelReservation(mockRepository);
      });

      test('should cancel reservation', () async {
        // Arrange
        when(() => mockRepository.cancelReservation(any()))
            .thenAnswer((_) async => {});

        // Act
        await useCase.call('1');

        // Assert
        verify(() => mockRepository.cancelReservation('1')).called(1);
      });

      test('should handle cancellation errors', () async {
        // Arrange
        when(() => mockRepository.cancelReservation(any()))
            .thenThrow(Exception('Reservation not found'));

        // Act & Assert
        expect(() => useCase.call('999'), throwsException);
      });
    });

    group('GetMyReservations', () {
      late GetMyReservations useCase;

      setUp(() {
        useCase = GetMyReservations(mockRepository);
      });

      test('should fetch user reservations', () async {
        // Arrange
        final reservations = [testReservation];
        when(() => mockRepository.getMyReservations())
            .thenAnswer((_) async => reservations);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result, reservations);
        expect(result.length, 1);
        verify(() => mockRepository.getMyReservations()).called(1);
      });

      test('should handle empty reservations list', () async {
        // Arrange
        when(() => mockRepository.getMyReservations())
            .thenAnswer((_) async => []);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result, isEmpty);
      });
    });
  });
}
