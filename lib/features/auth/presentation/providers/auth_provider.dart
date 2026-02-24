import 'package:flutter/material.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/signup_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/network/api_client.dart';

enum AuthStatus { initial, loading, loggedIn, loggedOut, error }

class AuthProvider extends ChangeNotifier {
  final LoginUser loginUser;
  final SignupUser signupUser;
  final AuthRepository repository;

  AuthStatus _status = AuthStatus.initial;
  String? _token;
  String? _errorMessage;

  AuthProvider({
    required this.loginUser,
    required this.signupUser,
    required this.repository,
  });

  // Getters
  AuthStatus get status => _status;
  String? get token => _token;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isLoggedIn => _status == AuthStatus.loggedIn;

  // Login
  Future<void> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await loginUser(email, password);
      _token = user.token;
      ApiClient().setToken(user.token);
      _status = AuthStatus.loggedIn;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _status = AuthStatus.error;
      notifyListeners();
    }
  }

  // Signup
  Future<void> signup({
    required String email,
    required String username,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await signupUser(
        email,
        username,
        phone,
        password,
        confirmPassword,
      );
      _token = user.token;
      ApiClient().setToken(user.token);
      _status = AuthStatus.loggedIn;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _status = AuthStatus.error;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await repository.logout();
      _token = null;
      ApiClient().clearToken();
      _status = AuthStatus.loggedOut;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      notifyListeners();
    }
  }

  // Set token from local storage
  void setToken(String token) {
    _token = token;
    ApiClient().setToken(token);
    _status = AuthStatus.loggedIn;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
