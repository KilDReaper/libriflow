import '../../domain/repositories/biometric_repository.dart';
import '../datasources/biometric_local_datasource.dart';

class BiometricRepositoryImpl implements BiometricRepository {
  final BiometricLocalDatasource local;

  BiometricRepositoryImpl(this.local);

  @override
  Future<bool> isBiometricAvailable() {
    return local.isBiometricAvailable();
  }

  @override
  Future<bool> canAuthenticateWithBiometrics() {
    return local.canAuthenticateWithBiometrics();
  }

  @override
  Future<bool> authenticateWithBiometrics() {
    return local.authenticateWithBiometrics();
  }

  @override
  Future<void> saveBiometricEmail(String email) {
    return local.saveBiometricEmail(email);
  }

  @override
  Future<String?> getSavedBiometricEmail() {
    return local.getSavedBiometricEmail();
  }

  @override
  Future<void> clearBiometricEmail() {
    return local.clearBiometricEmail();
  }
}
