import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:libriflow/features/auth/domain/entities/auth_user.dart';
import 'package:libriflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:libriflow/features/auth/domain/usecases/signup_user.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignupUser useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignupUser(mockRepository);
  });

  group('Signup UseCase Tests', () {
    const testUser = AuthUser(
      id: '123',
      email: 'new@test.com',
      username: 'newuser',
      phone: '+1234567890',
      token: 'test_token',
    );

    test('should create new user successfully', () async {
      // Arrange
      when(() => mockRepository.signup(
            any(),
            any(),
            any(),
            any(),
            any(),
          )).thenAnswer((_) async => testUser);

      // Act
      final result = await useCase.call(
        'new@test.com',
        'newuser',
        '+1234567890',
        'password123',
        'password123',
      );

      // Assert
      expect(result, testUser);
      expect(result.email, 'new@test.com');
      verify(() => mockRepository.signup(
            'new@test.com',
            'newuser',
            '+1234567890',
            'password123',
            'password123',
          )).called(1);
    });

    test('should validate password match', () async {
      // Arrange
      when(() => mockRepository.signup(
            any(),
            any(),
            any(),
            any(),
            any(),
          )).thenThrow(Exception('Passwords do not match'));

      // Act & Assert
      expect(
        () => useCase.call(
          'new@test.com',
          'newuser',
          '+1234567890',
          'password123',
          'differentPassword',
        ),
        throwsException,
      );
    });

    test('should check email uniqueness', () async {
      // Arrange
      when(() => mockRepository.signup(
            any(),
            any(),
            any(),
            any(),
            any(),
          )).thenThrow(Exception('Email already exists'));

      // Act & Assert
      expect(
        () => useCase.call(
          'existing@test.com',
          'newuser',
          '+1234567890',
          'password123',
          'password123',
        ),
        throwsException,
      );
    });

    test('should handle network errors', () async {
      // Arrange
      when(() => mockRepository.signup(
            any(),
            any(),
            any(),
            any(),
            any(),
          )).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => useCase.call(
          'new@test.com',
          'newuser',
          '+1234567890',
          'password123',
          'password123',
        ),
        throwsException,
      );
    });
  });
}
