import '../repositories/biometric_repository.dart';

class AuthenticateWithBiometric {
  final BiometricRepository repository;

  AuthenticateWithBiometric(this.repository);

  Future<bool> call() async {
    return repository.authenticateWithBiometrics();
  }
}

class CheckBiometricAvailability {
  final BiometricRepository repository;

  CheckBiometricAvailability(this.repository);

  Future<bool> call() async {
    return repository.canAuthenticateWithBiometrics();
  }
}

class GetSavedBiometricEmail {
  final BiometricRepository repository;

  GetSavedBiometricEmail(this.repository);

  Future<String?> call() async {
    return repository.getSavedBiometricEmail();
  }
}

class SaveBiometricEmail {
  final BiometricRepository repository;

  SaveBiometricEmail(this.repository);

  Future<void> call(String email) async {
    return repository.saveBiometricEmail(email);
  }
}

class ClearBiometricEmail {
  final BiometricRepository repository;

  ClearBiometricEmail(this.repository);

  Future<void> call() async {
    return repository.clearBiometricEmail();
  }
}
