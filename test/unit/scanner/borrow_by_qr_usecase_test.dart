import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:libriflow/features/scanner/domain/repositories/scanner_repository.dart';
import 'package:libriflow/features/scanner/domain/usecases/borrow_by_qr_code.dart';

class MockScannerRepository extends Mock implements ScannerRepository {}

void main() {
  late BorrowByQRCodeUseCase useCase;
  late MockScannerRepository mockRepository;

  setUp(() {
    mockRepository = MockScannerRepository();
    useCase = BorrowByQRCodeUseCase(repository: mockRepository);
  });

  group('BorrowByQRCode UseCase Tests', () {
    test('should borrow book using QR code', () async {
      // Arrange
      final mockResponse = {
        'success': true,
        'message': 'Book borrowed successfully',
        'bookId': 'book123',
        'borrowingId': 'borrow456',
        'dueDate': '2026-03-15',
      };

      when(() => mockRepository.borrowByQRCode(any()))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await useCase.call('QR123456');

      // Assert
      expect(result, mockResponse);
      expect(result['success'], true);
      expect(result['bookId'], 'book123');
      verify(() => mockRepository.borrowByQRCode('QR123456')).called(1);
    });

    test('should handle invalid QR code', () async {
      // Arrange
      when(() => mockRepository.borrowByQRCode(any()))
          .thenThrow(Exception('Invalid QR code'));

      // Act & Assert
      expect(() => useCase.call('INVALID'), throwsException);
    });

    test('should handle book already borrowed', () async {
      // Arrange
      final mockResponse = {
        'success': false,
        'message': 'Book already borrowed',
      };

      when(() => mockRepository.borrowByQRCode(any()))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await useCase.call('QR123456');

      // Assert
      expect(result['success'], false);
      expect(result['message'], contains('already borrowed'));
    });

    test('should handle network errors', () async {
      // Arrange
      when(() => mockRepository.borrowByQRCode(any()))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(() => useCase.call('QR123456'), throwsException);
    });
  });
}
