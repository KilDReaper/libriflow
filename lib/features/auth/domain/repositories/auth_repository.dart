abstract class AuthRepository {
  Future<void> login(String email, String password);
  Future<void> signup(String email, String password);
  bool isLoggedIn();
  void logout();
}
