import 'package:hive/hive.dart';
import 'package:local_auth/local_auth.dart';

abstract class BiometricLocalDatasource {
  Future<bool> isBiometricAvailable();
  Future<bool> canAuthenticateWithBiometrics();
  Future<bool> authenticateWithBiometrics();
  Future<void> saveBiometricEmail(String email);
  Future<String?> getSavedBiometricEmail();
  Future<void> clearBiometricEmail();
}

class BiometricLocalDatasourceImpl implements BiometricLocalDatasource {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final Box _box;

  BiometricLocalDatasourceImpl(this._box);

  @override
  Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> canAuthenticateWithBiometrics() async {
    try {
      if (!await _localAuth.canCheckBiometrics) {
        return false;
      }
      
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      return availableBiometrics.contains(BiometricType.fingerprint);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate using your fingerprint',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> saveBiometricEmail(String email) async {
    await _box.put('biometric_email', email);
  }

  @override
  Future<String?> getSavedBiometricEmail() async {
    return _box.get('biometric_email') as String?;
  }

  @override
  Future<void> clearBiometricEmail() async {
    await _box.delete('biometric_email');
  }
}
