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
      if (!isDeviceSupported && !canCheck) {
        return false;
      }

      // Some OEM builds can return an empty biometric list even when auth works.
      // Treat support/check flags as enough for availability and let authenticate
      // surface exact errors like not enrolled / locked out.
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> authenticateWithBiometrics() async {
    try {
      final result = await _localAuth.authenticate(
        localizedReason: 'Authenticate using your fingerprint',
        options: const AuthenticationOptions(
          stickyAuth: false,
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );

      if (!result) {
        throw Exception('Biometric authentication was cancelled.');
      }

      return true;
    } on PlatformException catch (e) {
      final code = e.code.toLowerCase();
      switch (code) {
        case auth_error.notAvailable:
        case 'notavailable':
        case 'biometric_unavailable':
          throw Exception('Biometric hardware is not available on this device.');
        case auth_error.notEnrolled:
        case 'notenrolled':
        case 'biometric_not_enrolled':
          throw Exception('No fingerprint/biometric is enrolled on this device.');
        case auth_error.lockedOut:
        case 'lockedout':
        case 'temporarylockout':
          throw Exception('Biometric is temporarily locked. Try again in a moment.');
        case auth_error.permanentlyLockedOut:
        case 'permanentlylockedout':
          throw Exception('Biometric is locked. Unlock your phone with PIN/pattern first.');
        case 'passcode_not_set':
          throw Exception('Set a screen lock (PIN/Pattern/Password) to use biometrics.');
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
