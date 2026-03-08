import 'package:hive/hive.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

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
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!isDeviceSupported || !canCheck) {
        return false;
      }

      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> authenticateWithBiometrics() async {
    if (!await canAuthenticateWithBiometrics()) {
      throw Exception('Biometric authentication is not available on this device.');
    }

    try {
      final result = await _localAuth.authenticate(
        localizedReason: 'Authenticate using your fingerprint',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );

      if (!result) {
        throw Exception('Biometric authentication was cancelled.');
      }

      return true;
    } on PlatformException catch (e) {
      switch (e.code) {
        case auth_error.notAvailable:
          throw Exception('Biometric hardware is not available on this device.');
        case auth_error.notEnrolled:
          throw Exception('No fingerprint/biometric is enrolled on this device.');
        case auth_error.lockedOut:
          throw Exception('Biometric is temporarily locked. Try again in a moment.');
        case auth_error.permanentlyLockedOut:
          throw Exception('Biometric is locked. Unlock your phone with PIN/pattern first.');
        default:
          throw Exception('Biometric authentication failed: ${e.message ?? e.code}.');
      }
    } catch (e) {
      throw Exception('Biometric authentication failed. ${e.toString().replaceAll('Exception: ', '')}');
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
