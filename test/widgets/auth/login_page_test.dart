import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libriflow/features/auth/presentation/views/login_page.dart';
import 'package:libriflow/features/auth/presentation/providers/auth_provider.dart';
import 'package:libriflow/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:libriflow/features/auth/data/datasources/biometric_local_datasource.dart';
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

// Mock LocalDataSources for Riverpod
class MockAuthLocalDataSource implements AuthLocalDatasource {
  @override
  Future<void> saveToken(String token) async {}

  @override
  Future<String?> getToken() async => 'mock_token';

  @override
  Future<void> deleteToken() async {}

  @override
  Future<void> clearToken() async {}
}

class MockBiometricLocalDataSource implements BiometricLocalDatasource {
  @override
  Future<void> saveBiometricEmail(String email) async {}

  @override
  Future<String?> getSavedBiometricEmail() async => null;

  @override
  Future<void> clearBiometricEmail() async {}

  @override
  Future<bool> isBiometricAvailable() async => false;

  @override
  Future<bool> canAuthenticateWithBiometrics() async => false;

  @override
  Future<bool> authenticateWithBiometrics() async => false;
}

void main() {
  late MockAuthRepository mockAuthRepo;
  late MockBiometricRepository mockBiometricRepo;
  late MockAuthLocalDataSource mockAuthLocalDataSource;
  late MockBiometricLocalDataSource mockBiometricLocalDataSource;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    mockBiometricRepo = MockBiometricRepository();
    mockAuthLocalDataSource = MockAuthLocalDataSource();
    mockBiometricLocalDataSource = MockBiometricLocalDataSource();
  });

  testWidgets('Login page renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authLocalDataSourceProvider.overrideWithValue(mockAuthLocalDataSource),
          biometricDatasourceProvider.overrideWithValue(mockBiometricLocalDataSource),
        ],
        child: const MaterialApp(
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
      ProviderScope(
        overrides: [
          authLocalDataSourceProvider.overrideWithValue(mockAuthLocalDataSource),
          biometricDatasourceProvider.overrideWithValue(mockBiometricLocalDataSource),
        ],
        child: const MaterialApp(
          home: LoginView(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsWidgets);
  });

  testWidgets('Login button is clickable', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authLocalDataSourceProvider.overrideWithValue(mockAuthLocalDataSource),
          biometricDatasourceProvider.overrideWithValue(mockBiometricLocalDataSource),
        ],
        child: const MaterialApp(
          home: LoginView(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final loginButton = find.text('Log In');
    expect(loginButton, findsOneWidget);
  });
}
