import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:libriflow/features/scanner/data/datasources/scanner_remote_datasource.dart';
import 'package:libriflow/features/scanner/data/repositories/scanner_repository_impl.dart';

class MockScannerRemoteDataSource extends Mock
    implements ScannerRemoteDataSource {}

void main() {
  late ScannerRepositoryImpl repository;
  late MockScannerRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockScannerRemoteDataSource();
    repository =
        ScannerRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  group('Scanner Repository Tests', () {
    test('borrowByQRCode should return borrow data', () async {
      // Arrange
      final mockResponse = {
        'success': true,
        'message': 'Book borrowed successfully',
        'bookId': 'book123',
        'dueDate': '2026-03-15',
      };

      when(() => mockRemoteDataSource.borrowByQRCode(any()))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await repository.borrowByQRCode('QR123456');

      // Assert
      expect(result, mockResponse);
      expect(result['success'], true);
      expect(result['bookId'], 'book123');
      verify(() => mockRemoteDataSource.borrowByQRCode('QR123456')).called(1);
    });

    test('borrowByQRCode should handle API errors', () async {
      // Arrange
      when(() => mockRemoteDataSource.borrowByQRCode(any()))
          .thenThrow(Exception('Book not available'));

      // Act & Assert
      expect(
        () => repository.borrowByQRCode('INVALID_QR'),
        throwsException,
      );
    });

    test('borrowByQRCode should handle invalid QR codes', () async {
      // Arrange
      when(() => mockRemoteDataSource.borrowByQRCode(any()))
          .thenThrow(Exception('Invalid QR code'));

      // Act & Assert
      expect(
        () => repository.borrowByQRCode(''),
        throwsException,
      );
    });

    test('borrowByQRCode should handle already borrowed books', () async {
      // Arrange
      final mockResponse = {
        'success': false,
        'message': 'Book already borrowed',
      };

      when(() => mockRemoteDataSource.borrowByQRCode(any()))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await repository.borrowByQRCode('QR123456');

      // Assert
      expect(result['success'], false);
      expect(result['message'], contains('already borrowed'));
    });
  });
}
