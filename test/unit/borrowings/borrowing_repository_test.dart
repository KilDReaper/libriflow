import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:libriflow/features/borrowings/data/datasources/borrowing_remote_datasource.dart';
import 'package:libriflow/features/borrowings/data/models/borrowing_model.dart';
import 'package:libriflow/features/borrowings/data/repositories/borrowing_repository_impl.dart';

class MockBorrowingRemoteDataSource extends Mock
    implements BorrowingRemoteDataSource {}

void main() {
  late BorrowingRepositoryImpl repository;
  late MockBorrowingRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockBorrowingRemoteDataSource();
    repository =
        BorrowingRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  group('Borrowing Repository Tests', () {
    final testBook = BookModel(
      id: 'book1',
      title: 'Test Book',
      author: 'Test Author',
      isbn: '1234567890',
      coverImage: 'https://example.com/cover.jpg',
    );

    final testUser = UserModel(
      id: 'user1',
      username: 'testuser',
      email: 'test@test.com',
      profileImage: null,
    );

    final testBorrowings = [
      BorrowingModel(
        id: '1',
        book: testBook,
        user: testUser,
        borrowDate: DateTime.now().subtract(const Duration(days: 7)),
        dueDate: DateTime.now().add(const Duration(days: 7)),
        returnedDate: null,
        status: 'active',
        fineAmount: 0.0,
        finePaid: false,
      ),
      BorrowingModel(
        id: '2',
        book: testBook,
        user: testUser,
        borrowDate: DateTime.now().subtract(const Duration(days: 14)),
        dueDate: DateTime.now().subtract(const Duration(days: 7)),
        returnedDate: null,
        status: 'overdue',
        fineAmount: 5.0,
        finePaid: false,
      ),
    ];

    test('should fetch borrowed books', () async {
      // Arrange
      when(() => mockRemoteDataSource.getMyBorrowings())
          .thenAnswer((_) async => testBorrowings);

      // Act
      final result = await repository.getMyBorrowings();

      // Assert
      expect(result, testBorrowings);
      expect(result.length, 2);
      verify(() => mockRemoteDataSource.getMyBorrowings()).called(1);
    });

    test('should fetch active borrowings only', () async {
      // Arrange
      final activeBorrowings = [testBorrowings[0]];
      when(() => mockRemoteDataSource.getActiveBorrowings())
          .thenAnswer((_) async => activeBorrowings);

      // Act
      final result = await repository.getActiveBorrowings();

      // Assert
      expect(result, activeBorrowings);
      expect(result.length, 1);
      expect(result[0].status, 'active');
      verify(() => mockRemoteDataSource.getActiveBorrowings()).called(1);
    });

    test('should fetch borrowing details by id', () async {
      // Arrange
      final borrowing = testBorrowings[0];
      when(() => mockRemoteDataSource.getBorrowingDetails(any()))
          .thenAnswer((_) async => borrowing);

      // Act
      final result = await repository.getBorrowingDetails('1');

      // Assert
      expect(result, borrowing);
      expect(result.id, '1');
      verify(() => mockRemoteDataSource.getBorrowingDetails('1')).called(1);
    });

    test('should return book', () async {
      // Arrange
      final returnedBorrowing = BorrowingModel(
        id: '1',
        book: testBook,
        user: testUser,
        borrowDate: DateTime.now().subtract(const Duration(days: 7)),
        dueDate: DateTime.now().add(const Duration(days: 7)),
        returnedDate: DateTime.now(),
        status: 'returned',
        fineAmount: 0.0,
        finePaid: false,
      );

      when(() => mockRemoteDataSource.returnBorrowing(any()))
          .thenAnswer((_) async => returnedBorrowing);

      // Act
      final result = await repository.returnBorrowing('1');

      // Assert
      expect(result.status, 'returned');
      expect(result.returnedDate, isNotNull);
      verify(() => mockRemoteDataSource.returnBorrowing('1')).called(1);
    });

    test('should calculate borrowing stats', () async {
      // Arrange
      const stats = BorrowingStatsModel(
        activeBorrowings: 2,
        returnedBorrowings: 5,
        overdueBorrowings: 1,
        totalFines: 10.0,
        paidFines: 5.0,
        unpaidFines: 5.0,
      );

      when(() => mockRemoteDataSource.getBorrowingStats())
          .thenAnswer((_) async => stats);

      // Act
      final result = await repository.getBorrowingStats();

      // Assert
      expect(result, stats);
      expect(result.activeBorrowings, 2);
      expect(result.overdueBorrowings, 1);
      expect(result.unpaidFines, 5.0);
      verify(() => mockRemoteDataSource.getBorrowingStats()).called(1);
    });

    test('should handle empty borrowings list', () async {
      // Arrange
      when(() => mockRemoteDataSource.getMyBorrowings())
          .thenAnswer((_) async => []);

      // Act
      final result = await repository.getMyBorrowings();

      // Assert
      expect(result, isEmpty);
      verify(() => mockRemoteDataSource.getMyBorrowings()).called(1);
    });

    test('should handle API errors gracefully', () async {
      // Arrange
      when(() => mockRemoteDataSource.getMyBorrowings())
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(() => repository.getMyBorrowings(), throwsException);
    });
  });
}
