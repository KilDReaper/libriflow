import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:libriflow/features/profile/data/model/user_model.dart';
import 'package:libriflow/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:libriflow/features/profile/data/repositories/profile_repository_impl.dart';

class MockProfileRemoteDataSource extends Mock
    implements ProfileRemoteDataSource {}

void main() {
  late ProfileRepositoryImpl repository;
  late MockProfileRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockProfileRemoteDataSource();
    repository = ProfileRepositoryImpl(mockRemoteDataSource);
  });

  group('Profile Repository Tests', () {
    final testUser = UserModel(
      id: '123',
      name: 'testuser',
      email: 'test@test.com',
      phoneNumber: '+1234567890',
      avatarUrl: 'https://example.com/profile.jpg',
    );

    test('should fetch user profile', () async {
      // Arrange
      when(() => mockRemoteDataSource.getProfile())
          .thenAnswer((_) async => testUser);

      // Act
      final result = await repository.getProfile();

      // Assert
      expect(result, testUser);
      expect(result.email, 'test@test.com');
      expect(result.name, 'testuser');
      verify(() => mockRemoteDataSource.getProfile()).called(1);
    });

    test('should handle getProfile errors', () async {
      // Arrange
      when(() => mockRemoteDataSource.getProfile())
          .thenThrow(Exception('Failed to fetch profile'));

      // Act & Assert
      expect(() => repository.getProfile(), throwsException);
    });

    test('should update profile information', () async {
      // Arrange
      final updatedUser = UserModel(
        id: '123',
        name: 'updateduser',
        email: 'updated@test.com',
        phoneNumber: '+1234567890',
        avatarUrl: 'https://example.com/profile.jpg',
      );

      when(() => mockRemoteDataSource.updateProfile(
            name: any(named: 'name'),
            email: any(named: 'email'),
            password: any(named: 'password'),
            confirmPassword: any(named: 'confirmPassword'),
          )).thenAnswer((_) async => updatedUser);

      // Act
      final result = await repository.updateProfile(
        name: 'updateduser',
        email: 'updated@test.com',
      );

      // Assert
      expect(result, updatedUser);
      expect(result.name, 'updateduser');
      expect(result.email, 'updated@test.com');
      verify(() => mockRemoteDataSource.updateProfile(
            name: 'updateduser',
            email: 'updated@test.com',
            password: null,
            confirmPassword: null,
          )).called(1);
    });

    test('should update profile with password', () async {
      // Arrange
      when(() => mockRemoteDataSource.updateProfile(
            name: any(named: 'name'),
            email: any(named: 'email'),
            password: any(named: 'password'),
            confirmPassword: any(named: 'confirmPassword'),
          )).thenAnswer((_) async => testUser);

      // Act
      await repository.updateProfile(
        name: 'testuser',
        email: 'test@test.com',
        password: 'newpassword',
        confirmPassword: 'newpassword',
      );

      // Assert
      verify(() => mockRemoteDataSource.updateProfile(
            name: 'testuser',
            email: 'test@test.com',
            password: 'newpassword',
            confirmPassword: 'newpassword',
          )).called(1);
    });

    test('should upload profile image', () async {
      // Arrange
      final userWithNewImage = UserModel(
        id: '123',
        name: 'testuser',
        email: 'test@test.com',
        phoneNumber: '+1234567890',
        avatarUrl: 'https://example.com/new_profile.jpg',
      );

      when(() => mockRemoteDataSource.uploadImage(any()))
          .thenAnswer((_) async => userWithNewImage);

      // Act
        final result = await repository
          .uploadProfilePicture('https://example.com/new_profile.jpg');

        // Assert
        expect(result, userWithNewImage);
        expect(result.avatarUrl, 'https://example.com/new_profile.jpg');
        verify(() =>
            mockRemoteDataSource.uploadImage('https://example.com/new_profile.jpg'))
          .called(1);
    });

    test('should handle upload image errors', () async {
      // Arrange
      when(() => mockRemoteDataSource.uploadImage(any()))
          .thenThrow(Exception('Upload failed'));

      // Act & Assert
      expect(
        () => repository.uploadProfilePicture('invalid_url'),
        throwsException,
      );
    });
  });
}
