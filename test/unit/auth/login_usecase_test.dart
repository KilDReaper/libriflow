import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:libriflow/features/auth/domain/entities/auth_user.dart';
import 'package:libriflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:libriflow/features/auth/domain/usecases/login_user.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUser useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUser(mockRepository);
  });

  group('Login UseCase Tests', () {
    const testUser = AuthUser(
      id: '123',
      email: 'test@test.com',
      username: 'testuser',
      phone: '+1234567890',
      token: 'test_token',
    );

    test('should execute login successfully', () async {
      // Arrange
      when(() => mockRepository.login(any(), any()))
          .thenAnswer((_) async => testUser);

      // Act
      final result = await useCase.call('test@test.com', 'password123');

      // Assert
      expect(result, testUser);
      expect(result.email, 'test@test.com');
      verify(() => mockRepository.login('test@test.com', 'password123'))
          .called(1);
    });

    test('should validate email format', () async {
      // Arrange
      when(() => mockRepository.login(any(), any()))
          .thenThrow(Exception('Invalid email format'));

      // Act & Assert
      expect(
        () => useCase.call('invalid-email', 'password123'),
        throwsException,
      );
    });

    test('should handle network errors', () async {
      // Arrange
      when(() => mockRepository.login(any(), any()))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => useCase.call('test@test.com', 'password123'),
        throwsException,
      );
    });

    test('should handle invalid credentials', () async {
      // Arrange
      when(() => mockRepository.login(any(), any()))
          .thenThrow(Exception('Invalid credentials'));

      // Act & Assert
      expect(
        () => useCase.call('test@test.com', 'wrongpassword'),
        throwsException,
      );
    });
  });
}
