import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:libriflow/features/auth/data/datasources/biometric_local_datasource.dart';
import 'package:libriflow/features/auth/data/repositories/biometric_repository_impl.dart';

class MockBiometricLocalDatasource extends Mock
    implements BiometricLocalDatasource {}

void main() {
  late BiometricRepositoryImpl repository;
  late MockBiometricLocalDatasource mockLocalDatasource;

  setUp(() {
    mockLocalDatasource = MockBiometricLocalDatasource();
    repository = BiometricRepositoryImpl(mockLocalDatasource);
  });

  group('Biometric Repository Tests', () {
    test('isBiometricAvailable should return true when available', () async {
      // Arrange
      when(() => mockLocalDatasource.isBiometricAvailable())
          .thenAnswer((_) async => true);

      // Act
      final result = await repository.isBiometricAvailable();

      // Assert
      expect(result, true);
      verify(() => mockLocalDatasource.isBiometricAvailable()).called(1);
    });

    test('isBiometricAvailable should return false when not available',
        () async {
      // Arrange
      when(() => mockLocalDatasource.isBiometricAvailable())
          .thenAnswer((_) async => false);

      // Act
      final result = await repository.isBiometricAvailable();

      // Assert
      expect(result, false);
    });

    test('canAuthenticateWithBiometrics should return true if enrolled',
        () async {
      // Arrange
      when(() => mockLocalDatasource.canAuthenticateWithBiometrics())
          .thenAnswer((_) async => true);

      // Act
      final result = await repository.canAuthenticateWithBiometrics();

      // Assert
      expect(result, true);
      verify(() => mockLocalDatasource.canAuthenticateWithBiometrics())
          .called(1);
    });

    test('authenticateWithBiometrics should return true on success', () async {
      // Arrange
      when(() => mockLocalDatasource.authenticateWithBiometrics())
          .thenAnswer((_) async => true);

      // Act
      final result = await repository.authenticateWithBiometrics();

      // Assert
      expect(result, true);
      verify(() => mockLocalDatasource.authenticateWithBiometrics()).called(1);
    });

    test('authenticateWithBiometrics should return false on failure', () async {
      // Arrange
      when(() => mockLocalDatasource.authenticateWithBiometrics())
          .thenAnswer((_) async => false);

      // Act
      final result = await repository.authenticateWithBiometrics();

      // Assert
      expect(result, false);
    });

    test('saveBiometricEmail should save email to local datasource', () async {
      // Arrange
      when(() => mockLocalDatasource.saveBiometricEmail(any()))
          .thenAnswer((_) async => {});

      // Act
      await repository.saveBiometricEmail('test@test.com');

      // Assert
      verify(() => mockLocalDatasource.saveBiometricEmail('test@test.com'))
          .called(1);
    });

    test('getSavedBiometricEmail should return saved email', () async {
      // Arrange
      when(() => mockLocalDatasource.getSavedBiometricEmail())
          .thenAnswer((_) async => 'saved@test.com');

      // Act
      final result = await repository.getSavedBiometricEmail();

      // Assert
      expect(result, 'saved@test.com');
      verify(() => mockLocalDatasource.getSavedBiometricEmail()).called(1);
    });

    test('getSavedBiometricEmail should return null if not saved', () async {
      // Arrange
      when(() => mockLocalDatasource.getSavedBiometricEmail())
          .thenAnswer((_) async => null);

      // Act
      final result = await repository.getSavedBiometricEmail();

      // Assert
      expect(result, null);
    });

    test('clearBiometricEmail should clear saved email', () async {
      // Arrange
      when(() => mockLocalDatasource.clearBiometricEmail())
          .thenAnswer((_) async => {});

      // Act
      await repository.clearBiometricEmail();

      // Assert
      verify(() => mockLocalDatasource.clearBiometricEmail()).called(1);
    });
  });
}
