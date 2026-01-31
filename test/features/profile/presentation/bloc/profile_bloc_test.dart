import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:libriflow/features/profile/domain/entities/user.dart';
import 'package:libriflow/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:libriflow/features/profile/presentation/bloc/profile_event.dart';
import 'package:libriflow/features/profile/presentation/bloc/profile_state.dart';
import 'package:libriflow/features/profile/domain/usecases/get_profile.dart';
import 'package:libriflow/features/profile/domain/usecases/update_profile.dart';
import 'package:libriflow/features/profile/domain/usecases/upload_profile_image.dart';

class MockGetProfile extends Mock implements GetProfile {}
class MockUpdateProfile extends Mock implements UpdateProfile {}
class MockUploadProfileImage extends Mock implements UploadProfileImage {}
class FakeString extends Fake {}
void main() {
  setUpAll(() {
    registerFallbackValue(FakeString());
  });

  late MockGetProfile mockGet;
  late MockUpdateProfile mockUpdate;
  late MockUploadProfileImage mockUpload;

  final testUser = User(
    id: '1',
    name: 'John',
    email: 'john@test.com',
    phoneNumber: '1234567890',
    avatarUrl: 'http://example.com/avatar.jpg',
  );

  setUp(() {
    mockGet = MockGetProfile();
    mockUpdate = MockUpdateProfile();
    mockUpload = MockUploadProfileImage();
  });

  blocTest<ProfileBloc, ProfileState>(
    'emits [ProfileLoading, ProfileLoaded] when GetProfileEvent is added',
    build: () {
      when(() => mockGet()).thenAnswer((_) async => testUser);
      return ProfileBloc(
        getProfile: mockGet,
        updateProfile: mockUpdate,
        uploadProfileImage: mockUpload,
      );
    },
    act: (bloc) => bloc.add(GetProfileEvent()),
    expect: () => [
      isA<ProfileLoading>(),
      isA<ProfileLoaded>()
          .having((s) => s.user.name, 'name', 'John'),
    ],
  );

  blocTest<ProfileBloc, ProfileState>(
    'emits [ProfileLoading, ProfileUpdated] when UpdateProfileEvent succeeds',
    build: () {
      when(() => mockUpdate(
            name: any(named: 'name'),
            email: any(named: 'email'),
            password: any(named: 'password'),
            confirmPassword: any(named: 'confirmPassword'),
          )).thenAnswer((_) async => testUser);

      return ProfileBloc(
        getProfile: mockGet,
        updateProfile: mockUpdate,
        uploadProfileImage: mockUpload,
      );
    },
    act: (bloc) => bloc.add(
      UpdateProfileEvent(
        name: 'John',
        email: 'john@test.com',
      ),
    ),
    expect: () => [
      isA<ProfileLoading>(),
      isA<ProfileUpdated>(),
    ],
  );

  blocTest<ProfileBloc, ProfileState>(
    'emits [ProfileLoading, ProfileUpdated] when UploadProfileImageEvent succeeds',
    build: () {
      when(() => mockUpload(any()))
          .thenAnswer((_) async => testUser);

      return ProfileBloc(
        getProfile: mockGet,
        updateProfile: mockUpdate,
        uploadProfileImage: mockUpload,
      );
    },
    act: (bloc) =>
        bloc.add(UploadProfileImageEvent('path/to/image.jpg')),
    expect: () => [
      isA<ProfileLoading>(),
      isA<ProfileUpdated>()
          .having((s) => s.user.avatarUrl, 'avatarUrl',
              'http://example.com/avatar.jpg'),
    ],
  );
  blocTest<ProfileBloc, ProfileState>(
  'emits [ProfileLoading, ProfileError] when UpdateProfileEvent fails',
  build: () {
    when(() => mockUpdate(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
          confirmPassword: any(named: 'confirmPassword'),
        )).thenThrow(Exception('Update failed'));

    return ProfileBloc(
      getProfile: mockGet,
      updateProfile: mockUpdate,
      uploadProfileImage: mockUpload,
    );
  },
  act: (bloc) => bloc.add(
    UpdateProfileEvent(
      name: 'John',
      email: 'john@test.com',
    ),
  ),
  expect: () => [
    isA<ProfileLoading>(),
    isA<ProfileError>()
        .having((s) => s.message, 'message', contains('Update failed')),
  ],
);
blocTest<ProfileBloc, ProfileState>(
  'emits [ProfileLoading, ProfileError] when UploadProfileImageEvent fails',
  build: () {
    when(() => mockUpload(any()))
        .thenThrow(Exception('Upload failed'));

    return ProfileBloc(
      getProfile: mockGet,
      updateProfile: mockUpdate,
      uploadProfileImage: mockUpload,
    );
  },
  act: (bloc) =>
      bloc.add(UploadProfileImageEvent('path/to/image.jpg')),
  expect: () => [
    isA<ProfileLoading>(),
    isA<ProfileError>()
        .having((s) => s.message, 'message', contains('Upload failed')),
  ],
);
}
