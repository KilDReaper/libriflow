import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class LoginUser {
  final AuthRepository repository;

  LoginUser(this.repository);

  Future<AuthUser> call(String email, String password) {
    return repository.login(email, password);
  }
}
