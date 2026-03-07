abstract class BiometricRepository {
  Future<bool> isBiometricAvailable();
  Future<bool> canAuthenticateWithBiometrics();
  Future<bool> authenticateWithBiometrics();
  Future<void> saveBiometricEmail(String email);
  Future<String?> getSavedBiometricEmail();
  Future<void> clearBiometricEmail();
}
