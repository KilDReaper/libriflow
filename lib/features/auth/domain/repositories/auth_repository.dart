import '../entities/auth_user.dart';

abstract class AuthRepository {
  Future<AuthUser> login(String email, String password);
  Future<AuthUser> signup(
    String email,
    String username,
    String phone,
    String password,
    String confirmPassword,
  );
  Future<bool> isLoggedIn();
  Future<void> logout();
}
