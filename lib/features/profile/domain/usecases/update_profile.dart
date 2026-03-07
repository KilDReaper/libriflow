import 'package:libriflow/features/profile/domain/entities/user.dart';
import 'package:libriflow/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfile {
  final ProfileRepository repository;

  UpdateProfile(this.repository);

  Future<User> call({
    required String name,
    required String email,
    String? password,
    String? confirmPassword,
  }) {
    return repository.updateProfile(
      name: name,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
  }
}