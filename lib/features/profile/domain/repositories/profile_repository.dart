import '../entities/user.dart';

abstract class ProfileRepository {
  Future<User> getProfile();

  Future<User> updateProfile({
    required String name,
    required String email,
    String? password,
    String? confirmPassword,
  });

  Future<User> uploadProfilePicture(String imagePath);
}