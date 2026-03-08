import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:libriflow/features/auth/domain/repositories/biometric_repository.dart';
import 'package:libriflow/features/auth/domain/usecases/biometric_usecases.dart';

class MockBiometricRepository extends Mock implements BiometricRepository {}

void main() {
  late MockBiometricRepository mockRepository;

  setUp(() {
    mockRepository = MockBiometricRepository();
  });

  group('Biometric UseCase Tests', () {
    group('CheckBiometricAvailability', () {
      late CheckBiometricAvailability useCase;

      setUp(() {
        useCase = CheckBiometricAvailability(mockRepository);
      });

      test('should check biometric availability', () async {
        // Arrange
        when(() => mockRepository.canAuthenticateWithBiometrics())
            .thenAnswer((_) async => true);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result, true);
        verify(() => mockRepository.canAuthenticateWithBiometrics()).called(1);
      });

      test('should return false when biometric not available', () async {
        // Arrange
        when(() => mockRepository.canAuthenticateWithBiometrics())
            .thenAnswer((_) async => false);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result, false);
      });
    });

    group('AuthenticateWithBiometric', () {
      late AuthenticateWithBiometric useCase;

      setUp(() {
        useCase = AuthenticateWithBiometric(mockRepository);
      });

      test('should authenticate with fingerprint', () async {
        // Arrange
        when(() => mockRepository.authenticateWithBiometrics())
            .thenAnswer((_) async => true);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result, true);
        verify(() => mockRepository.authenticateWithBiometrics()).called(1);
      });

      test('should handle authentication failure', () async {
        // Arrange
        when(() => mockRepository.authenticateWithBiometrics())
            .thenAnswer((_) async => false);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result, false);
      });
    });

    group('SaveBiometricEmail', () {
      late SaveBiometricEmail useCase;

      setUp(() {
        useCase = SaveBiometricEmail(mockRepository);
      });

      test('should save biometric email', () async {
        // Arrange
        when(() => mockRepository.saveBiometricEmail(any()))
            .thenAnswer((_) async => {});

        // Act
        await useCase.call('test@test.com');

        // Assert
        verify(() => mockRepository.saveBiometricEmail('test@test.com'))
            .called(1);
      });
    });

    group('GetSavedBiometricEmail', () {
      late GetSavedBiometricEmail useCase;

      setUp(() {
        useCase = GetSavedBiometricEmail(mockRepository);
      });

      test('should retrieve saved email', () async {
        // Arrange
        when(() => mockRepository.getSavedBiometricEmail())
            .thenAnswer((_) async => 'saved@test.com');

        // Act
        final result = await useCase.call();

        // Assert
        expect(result, 'saved@test.com');
        verify(() => mockRepository.getSavedBiometricEmail()).called(1);
      });

      test('should return null when no email saved', () async {
        // Arrange
        when(() => mockRepository.getSavedBiometricEmail())
            .thenAnswer((_) async => null);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result, null);
      });
    });

    group('ClearBiometricEmail', () {
      late ClearBiometricEmail useCase;

      setUp(() {
        useCase = ClearBiometricEmail(mockRepository);
      });

      test('should clear saved email', () async {
        // Arrange
        when(() => mockRepository.clearBiometricEmail())
            .thenAnswer((_) async => {});

        // Act
        await useCase.call();

        // Assert
        verify(() => mockRepository.clearBiometricEmail()).called(1);
      });
    });
  });
}
