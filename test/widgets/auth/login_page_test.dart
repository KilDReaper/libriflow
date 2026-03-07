import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:libriflow/features/auth/presentation/views/login_page.dart';
import 'package:libriflow/features/auth/presentation/providers/auth_provider.dart';
import 'package:libriflow/features/auth/domain/usecases/login_user.dart';
import 'package:libriflow/features/auth/domain/usecases/signup_user.dart';
import 'package:libriflow/features/auth/domain/usecases/biometric_usecases.dart';
import 'package:libriflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:libriflow/features/auth/domain/repositories/biometric_repository.dart';
import 'package:libriflow/features/auth/domain/entities/auth_user.dart';

// Mock AuthRepository
class MockAuthRepository implements AuthRepository {
  @override
  Future<AuthUser> login(String email, String password) async {
    return AuthUser(
      id: '1',
      email: email,
      username: 'Test User',
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
    return AuthUser(
      id: '1',
      email: email,
      username: username,
      phone: phone,
      token: 'mock_token',
    );
  }

  @override
  Future<bool> isLoggedIn() async => false;

  @override
  Future<void> logout() async {}

  @override
  Future<String?> getToken() async => 'mock_token';
}

// Mock BiometricRepository
class MockBiometricRepository implements BiometricRepository {
  @override
  Future<bool> isBiometricAvailable() async => false;

  @override
  Future<bool> canAuthenticateWithBiometrics() async => false;

  @override
  Future<bool> authenticateWithBiometrics() async => false;

  @override
  Future<void> saveBiometricEmail(String email) async {}

  @override
  Future<String?> getSavedBiometricEmail() async => null;

  @override
  Future<void> clearBiometricEmail() async {}
}

void main() {
  late AuthProvider authProvider;

  setUp(() {
    final mockAuthRepo = MockAuthRepository();
    final mockBiometricRepo = MockBiometricRepository();

    authProvider = AuthProvider(
      loginUser: LoginUser(mockAuthRepo),
      signupUser: SignupUser(mockAuthRepo),
      repository: mockAuthRepo,
      authenticateWithBiometric: AuthenticateWithBiometric(mockBiometricRepo),
      checkBiometricAvailability: CheckBiometricAvailability(mockBiometricRepo),
      getSavedBiometricEmail: GetSavedBiometricEmail(mockBiometricRepo),
      saveBiometricEmail: SaveBiometricEmail(mockBiometricRepo),
      clearBiometricEmail: ClearBiometricEmail(mockBiometricRepo),
    );
  });

  testWidgets('Login page renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: authProvider,
        child: MaterialApp(
          home: LoginView(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Log In'), findsOneWidget);
    expect(find.byIcon(Icons.mail), findsOneWidget);
    expect(find.byIcon(Icons.lock), findsOneWidget);
  });

  testWidgets('Email and password fields are present', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: authProvider,
        child: MaterialApp(
          home: LoginView(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsWidgets);
  });

  testWidgets('Login button is clickable', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: authProvider,
        child: MaterialApp(
          home: LoginView(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final loginButton = find.text('Log In');
    expect(loginButton, findsOneWidget);
  });
}
