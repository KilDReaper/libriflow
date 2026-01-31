import '../../domain/entities/user.dart';
import '../../domain/repositories/profile_repository.dart';

class UploadProfileImage {
  final ProfileRepository repository;

  UploadProfileImage(this.repository);

  Future<User> call(String imagePath) {
    return repository.uploadProfilePicture(imagePath);
  }
}