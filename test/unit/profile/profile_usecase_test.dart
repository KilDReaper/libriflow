import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:libriflow/features/profile/domain/entities/user.dart';
import 'package:libriflow/features/profile/domain/repositories/profile_repository.dart';
import 'package:libriflow/features/profile/domain/usecases/get_profile.dart';
import 'package:libriflow/features/profile/domain/usecases/update_profile.dart';
import 'package:libriflow/features/profile/domain/usecases/upload_profile_image.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
  });

  group('Profile UseCase Tests', () {
    const testUser = User(
      id: '123',
      name: 'testuser',
      email: 'test@test.com',
      phoneNumber: '+1234567890',
      avatarUrl: 'https://example.com/profile.jpg',
    );

    group('GetProfile', () {
      late GetProfile useCase;

      setUp(() {
        useCase = GetProfile(mockRepository);
      });

      test('should get user profile', () async {
        // Arrange
        when(() => mockRepository.getProfile())
            .thenAnswer((_) async => testUser);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result, testUser);
        verify(() => mockRepository.getProfile()).called(1);
      });

      test('should handle errors when getting profile', () async {
        // Arrange
        when(() => mockRepository.getProfile())
            .thenThrow(Exception('Failed to fetch profile'));

        // Act & Assert
        expect(() => useCase.call(), throwsException);
      });
    });

    group('UpdateProfile', () {
      late UpdateProfile useCase;

      setUp(() {
        useCase = UpdateProfile(mockRepository);
      });

      test('should update profile', () async {
        // Arrange
        const updatedUser = User(
          id: '123',
          name: 'updateduser',
          email: 'updated@test.com',
          phoneNumber: '+1234567890',
          avatarUrl: 'https://example.com/profile.jpg',
        );

        when(() => mockRepository.updateProfile(
              name: any(named: 'name'),
              email: any(named: 'email'),
              password: any(named: 'password'),
              confirmPassword: any(named: 'confirmPassword'),
            )).thenAnswer((_) async => updatedUser);

        // Act
        final result = await useCase.call(
          name: 'updateduser',
          email: 'updated@test.com',
        );

        // Assert
        expect(result, updatedUser);
        verify(() => mockRepository.updateProfile(
              name: 'updateduser',
              email: 'updated@test.com',
              password: null,
              confirmPassword: null,
            )).called(1);
      });
    });

    group('UploadProfileImage', () {
      late UploadProfileImage useCase;

      setUp(() {
        useCase = UploadProfileImage(mockRepository);
      });

      test('should upload profile image', () async {
        // Arrange
        const userWithNewImage = User(
          id: '123',
          name: 'testuser',
          email: 'test@test.com',
          phoneNumber: '+1234567890',
          avatarUrl: 'https://example.com/new_profile.jpg',
        );

        when(() => mockRepository.uploadProfilePicture(any()))
            .thenAnswer((_) async => userWithNewImage);

          // Act
          final result =
            await useCase.call('https://example.com/new_profile.jpg');

          // Assert
          expect(result, userWithNewImage);
          expect(result.avatarUrl, 'https://example.com/new_profile.jpg');
          verify(() => mockRepository
              .uploadProfilePicture('https://example.com/new_profile.jpg'))
            .called(1);
      });
    });
  });
}
