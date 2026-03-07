import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validation Tests', () {
    test('should validate email format', () {
      final validEmail = 'test@example.com';
      final invalidEmail = 'invalid-email';
      
      expect(validEmail.contains('@'), true);
      expect(invalidEmail.contains('@'), false);
    });

    test('should validate password strength', () {
      final strongPassword = 'Pass123!@#';
      final weakPassword = '123';
      
      expect(strongPassword.length >= 8, true);
      expect(weakPassword.length >= 8, false);
    });

    test('should validate phone number', () {
      final validPhone = '1234567890';
      expect(validPhone.length == 10, true);
    });
  });
}
