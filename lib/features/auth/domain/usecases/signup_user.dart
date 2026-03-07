import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class SignupUser {
  final AuthRepository repository;

  SignupUser(this.repository);

  Future<AuthUser> call(
    String email,
    String username,
    String phone,
    String password,
    String confirmPassword,
  ) {
    return repository.signup(
      email,
      username,
      phone,
      password,
      confirmPassword,
    );
  }
}
