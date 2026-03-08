import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';
import 'package:libriflow/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:libriflow/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:libriflow/features/auth/data/models/auth_user_model.dart';
import 'package:libriflow/features/auth/data/repositories/auth_repository_impl.dart';

class MockAuthRemoteDatasource extends Mock implements AuthRemoteDatasource {}
class MockAuthLocalDatasource extends Mock implements AuthLocalDatasource {}

const MethodChannel _connectivityChannel =
    MethodChannel('dev.fluttercommunity.plus/connectivity');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthRepositoryImpl repository;
  late MockAuthRemoteDatasource mockRemote;
  late MockAuthLocalDatasource mockLocal;

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_connectivityChannel, (MethodCall methodCall) async {
      if (methodCall.method == 'check') {
        return <String>['wifi'];
      }
      return null;
    });
  });

  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_connectivityChannel, null);
  });

  setUp(() {
    mockRemote = MockAuthRemoteDatasource();
    mockLocal = MockAuthLocalDatasource();
    repository = AuthRepositoryImpl(remote: mockRemote, local: mockLocal);
  });

  group('AuthRepository Tests', () {
    const testUserModel = AuthUserModel(
      id: '123',
      email: 'test@test.com',
      username: 'testuser',
      phone: '+1234567890',
      token: 'test_token',
    );

    test('should login user with valid credentials', () async {
      // Arrange
      when(() => mockRemote.login(any(), any()))
          .thenAnswer((_) async => testUserModel);
      when(() => mockLocal.saveToken(any())).thenAnswer((_) async => {});

      // Act
      final result = await repository.login('test@test.com', 'password123');

      // Assert
      expect(result.email, 'test@test.com');
      expect(result.token, 'test_token');
      verify(() => mockRemote.login('test@test.com', 'password123')).called(1);
      verify(() => mockLocal.saveToken('test_token')).called(1);
    });

    test('should throw exception with invalid credentials', () async {
      // Arrange
      when(() => mockRemote.login(any(), any()))
          .thenThrow(Exception('Invalid credentials'));

      // Act & Assert
      expect(
        () => repository.login('wrong@test.com', 'wrong'),
        throwsException,
      );
    });

    test('should save token after successful login', () async {
      // Arrange
      when(() => mockRemote.login(any(), any()))
          .thenAnswer((_) async => testUserModel);
      when(() => mockLocal.saveToken(any())).thenAnswer((_) async => {});

      // Act
      await repository.login('test@test.com', 'password123');

      // Assert
      verify(() => mockLocal.saveToken('test_token')).called(1);
    });

    test('should signup user with valid data', () async {
      // Arrange
      when(() => mockRemote.signup(any(), any(), any(), any(), any()))
          .thenAnswer((_) async => testUserModel);
      when(() => mockRemote.login(any(), any()))
          .thenAnswer((_) async => testUserModel);
      when(() => mockLocal.saveToken(any())).thenAnswer((_) async {});

      // Act
      final result = await repository.signup(
        'new@test.com',
        'newuser',
        '+1234567890',
        'password123',
        'password123',
      );

      // Assert
      expect(result.email, 'test@test.com');
      verify(() => mockRemote.signup(
            'new@test.com',
            'newuser',
            '+1234567890',
            'password123',
            'password123',
          )).called(1);
      verify(() => mockRemote.login('new@test.com', 'password123')).called(1);
    });

    test('should throw exception when passwords do not match', () async {
      // Act & Assert
      expect(
        () => repository.signup(
          'test@test.com',
          'user',
          '+1234567890',
          'password123',
          'differentPassword',
        ),
        throwsA(predicate((e) =>
            e is Exception && e.toString().contains('Passwords do not match'))),
      );
    });

    test('isLoggedIn should return true when token exists', () async {
      // Arrange
      when(() => mockLocal.getToken()).thenAnswer((_) async => 'test_token');

      // Act
      final result = await repository.isLoggedIn();

      // Assert
      expect(result, true);
      verify(() => mockLocal.getToken()).called(1);
    });

    test('isLoggedIn should return false when token is null', () async {
      // Arrange
      when(() => mockLocal.getToken()).thenAnswer((_) async => null);

      // Act
      final result = await repository.isLoggedIn();

      // Assert
      expect(result, false);
      verify(() => mockLocal.getToken()).called(1);
    });

    test('getToken should return token from local datasource', () async {
      // Arrange
      when(() => mockLocal.getToken()).thenAnswer((_) async => 'test_token');

      // Act
      final result = await repository.getToken();

      // Assert
      expect(result, 'test_token');
      verify(() => mockLocal.getToken()).called(1);
    });

    test('logout should clear token from local datasource', () async {
      // Arrange
      when(() => mockLocal.clearToken()).thenAnswer((_) async {});

      // Act
      await repository.logout();

      // Assert
      verify(() => mockLocal.clearToken()).called(1);
    });
  });
}
