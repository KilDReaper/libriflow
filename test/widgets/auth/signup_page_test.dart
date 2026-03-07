import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:libriflow/features/auth/presentation/views/signup_page.dart';
import 'package:libriflow/features/auth/presentation/providers/auth_provider.dart';
import 'package:libriflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:libriflow/features/auth/domain/repositories/biometric_repository.dart';
import 'package:libriflow/features/auth/domain/entities/auth_user.dart';
import 'package:libriflow/features/auth/domain/usecases/login_user.dart';
import 'package:libriflow/features/auth/domain/usecases/signup_user.dart';
import 'package:libriflow/features/auth/domain/usecases/biometric_usecases.dart';

// Mock implementations
class MockAuthRepository implements AuthRepository {
  @override
  Future<AuthUser> login(String email, String password) async {
    return const AuthUser(
      id: 'mock_id',
      email: 'test@test.com',
      username: 'testuser',
      phone: '1234567890',
      token: 'mock_token',
    );
  }

  @override
  Future<AuthUser> signup(
    String email,
    String username,
    String phone,
    String password,
    String confirmPassword,
  ) async {
    return const AuthUser(
      id: 'mock_id',
      email: 'test@test.com',
      username: 'testuser',
      phone: '1234567890',
      token: 'mock_token',
    );
  }

  @override
  Future<bool> isLoggedIn() async {
    return false;
  }

  @override
  Future<void> logout() async {}

  @override
  Future<String?> getToken() async {
    return 'mock_token';
  }
}

class MockBiometricRepository implements BiometricRepository {
  @override
  Future<bool> isBiometricAvailable() async {
    return false;
  }

  @override
  Future<bool> canAuthenticateWithBiometrics() async {
    return false;
  }

  @override
  Future<bool> authenticateWithBiometrics() async {
    return false;
  }

  @override
  Future<void> saveBiometricEmail(String email) async {}

  @override
  Future<String?> getSavedBiometricEmail() async {
    return null;
  }

  @override
  Future<void> clearBiometricEmail() async {}
}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockBiometricRepository mockBiometricRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockBiometricRepository = MockBiometricRepository();
  });

  testWidgets('Signup page renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => AuthProvider(
            loginUser: LoginUser(mockAuthRepository),
            signupUser: SignupUser(mockAuthRepository),
            repository: mockAuthRepository,
            authenticateWithBiometric: AuthenticateWithBiometric(mockBiometricRepository),
            checkBiometricAvailability: CheckBiometricAvailability(mockBiometricRepository),
            getSavedBiometricEmail: GetSavedBiometricEmail(mockBiometricRepository),
            saveBiometricEmail: SaveBiometricEmail(mockBiometricRepository),
            clearBiometricEmail: ClearBiometricEmail(mockBiometricRepository),
          ),
          child: const SignupView(),
        ),
      ),
    );

    expect(find.text('Sign Up'), findsWidgets);
  });

  testWidgets('All signup fields are present', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => AuthProvider(
            loginUser: LoginUser(mockAuthRepository),
            signupUser: SignupUser(mockAuthRepository),
            repository: mockAuthRepository,
            authenticateWithBiometric: AuthenticateWithBiometric(mockBiometricRepository),
            checkBiometricAvailability: CheckBiometricAvailability(mockBiometricRepository),
            getSavedBiometricEmail: GetSavedBiometricEmail(mockBiometricRepository),
            saveBiometricEmail: SaveBiometricEmail(mockBiometricRepository),
            clearBiometricEmail: ClearBiometricEmail(mockBiometricRepository),
          ),
          child: const SignupView(),
        ),
      ),
    );

    expect(find.byType(TextField), findsWidgets);
  });

  testWidgets('Signup button is present', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => AuthProvider(
            loginUser: LoginUser(mockAuthRepository),
            signupUser: SignupUser(mockAuthRepository),
            repository: mockAuthRepository,
            authenticateWithBiometric: AuthenticateWithBiometric(mockBiometricRepository),
            checkBiometricAvailability: CheckBiometricAvailability(mockBiometricRepository),
            getSavedBiometricEmail: GetSavedBiometricEmail(mockBiometricRepository),
            saveBiometricEmail: SaveBiometricEmail(mockBiometricRepository),
            clearBiometricEmail: ClearBiometricEmail(mockBiometricRepository),
          ),
          child: const SignupView(),
        ),
      ),
    );

    expect(find.text('Sign Up'), findsWidgets);
  });
}
