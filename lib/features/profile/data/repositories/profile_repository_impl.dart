import '../../domain/entities/user.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remote;

  ProfileRepositoryImpl(this.remote);

  @override
  Future<User> getProfile() async {
    final userModel = await remote.getProfile();
    return userModel;
  }

  @override
  Future<User> updateProfile({
    required String name,
    required String email,
    String? password,
    String? confirmPassword,
  }) async {
    final userModel = await remote.updateProfile(
      name: name,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
    return userModel;
  }

  @override
  Future<User> uploadProfilePicture(String imageUrl) async {
    final userModel = await remote.uploadImage(imageUrl);
    return userModel;
  }
}