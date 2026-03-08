import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:libriflow/features/reservations/data/datasources/reservation_remote_datasource.dart';
import 'package:libriflow/features/reservations/data/models/reservation_model.dart';
import 'package:libriflow/features/reservations/data/repositories/reservation_repository_impl.dart';

class MockReservationRemoteDataSource extends Mock
    implements ReservationRemoteDataSource {}

void main() {
  late ReservationRepositoryImpl repository;
  late MockReservationRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockReservationRemoteDataSource();
    repository = ReservationRepositoryImpl(mockRemoteDataSource);
  });

  group('Reservation Repository Tests', () {
    final testReservations = [
      ReservationModel(
        id: '1',
        bookId: 'book1',
        bookTitle: 'Test Book 1',
        status: 'active',
        queuePosition: 1,
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      ),
      ReservationModel(
        id: '2',
        bookId: 'book2',
        bookTitle: 'Test Book 2',
        status: 'pending',
        queuePosition: 2,
        expiresAt: DateTime.now().add(const Duration(days: 5)),
      ),
    ];

    test('getMyReservations should return list of reservations', () async {
      // Arrange
      when(() => mockRemoteDataSource.getMyReservations())
          .thenAnswer((_) async => testReservations);

      // Act
      final result = await repository.getMyReservations();

      // Assert
      expect(result, testReservations);
      expect(result.length, 2);
      verify(() => mockRemoteDataSource.getMyReservations()).called(1);
    });

    test('getMyReservations should handle empty list', () async {
      // Arrange
      when(() => mockRemoteDataSource.getMyReservations())
          .thenAnswer((_) async => []);

      // Act
      final result = await repository.getMyReservations();

      // Assert
      expect(result, isEmpty);
      verify(() => mockRemoteDataSource.getMyReservations()).called(1);
    });

    test('createReservation should return created reservation', () async {
      // Arrange
      final newReservation = ReservationModel(
        id: '3',
        bookId: 'book3',
        bookTitle: 'New Book',
        status: 'pending',
        queuePosition: 1,
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      );

      when(() => mockRemoteDataSource.createReservation(
            bookId: any(named: 'bookId'),
            bookTitle: any(named: 'bookTitle'),
          )).thenAnswer((_) async => newReservation);

      // Act
      final result = await repository.createReservation(
        bookId: 'book3',
        bookTitle: 'New Book',
      );

      // Assert
      expect(result, newReservation);
      expect(result.bookId, 'book3');
      expect(result.bookTitle, 'New Book');
      verify(() => mockRemoteDataSource.createReservation(
            bookId: 'book3',
            bookTitle: 'New Book',
          )).called(1);
    });

    test('createReservation should handle API errors', () async {
      // Arrange
      when(() => mockRemoteDataSource.createReservation(
            bookId: any(named: 'bookId'),
            bookTitle: any(named: 'bookTitle'),
          )).thenThrow(Exception('Book not available'));

      // Act & Assert
      expect(
        () => repository.createReservation(
          bookId: 'book3',
          bookTitle: 'New Book',
        ),
        throwsException,
      );
    });

    test('cancelReservation should call remote datasource', () async {
      // Arrange
      when(() => mockRemoteDataSource.cancelReservation(any()))
          .thenAnswer((_) async => {});

      // Act
      await repository.cancelReservation('1');

      // Assert
      verify(() => mockRemoteDataSource.cancelReservation('1')).called(1);
    });

    test('cancelReservation should handle API errors', () async {
      // Arrange
      when(() => mockRemoteDataSource.cancelReservation(any()))
          .thenThrow(Exception('Reservation not found'));

      // Act & Assert
      expect(
        () => repository.cancelReservation('999'),
        throwsException,
      );
    });
  });
}
