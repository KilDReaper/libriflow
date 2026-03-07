import 'package:flutter/material.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/signup_user.dart';
import '../../domain/usecases/biometric_usecases.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/network/api_client.dart';

enum AuthStatus { initial, loading, loggedIn, loggedOut, error }

class AuthProvider extends ChangeNotifier {
  final LoginUser loginUser;
  final SignupUser signupUser;
  final AuthRepository repository;
  final AuthenticateWithBiometric authenticateWithBiometric;
  final CheckBiometricAvailability checkBiometricAvailability;
  final GetSavedBiometricEmail getSavedBiometricEmail;
  final SaveBiometricEmail saveBiometricEmail;
  final ClearBiometricEmail clearBiometricEmail;

  AuthStatus _status = AuthStatus.initial;
  String? _token;
  String? _errorMessage;
  bool _isBiometricAvailable = false;

  AuthProvider({
    required this.loginUser,
    required this.signupUser,
    required this.repository,
    required this.authenticateWithBiometric,
    required this.checkBiometricAvailability,
    required this.getSavedBiometricEmail,
    required this.saveBiometricEmail,
    required this.clearBiometricEmail,
  });

  // Getters
  AuthStatus get status => _status;
  String? get token => _token;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isLoggedIn => _status == AuthStatus.loggedIn;
  bool get isBiometricAvailable => _isBiometricAvailable;

  // Check if biometric is available
  Future<void> checkBiometricStatus() async {
    try {
      _isBiometricAvailable = await checkBiometricAvailability();
      notifyListeners();
    } catch (e) {
      _isBiometricAvailable = false;
      notifyListeners();
    }
  }

  // Login
  Future<void> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await loginUser(email, password);
      _token = user.token;
      ApiClient().setToken(user.token);
      
      // Automatically enable biometric for this email
      if (_isBiometricAvailable) {
        await saveBiometricEmail(email);
      }
      
      _status = AuthStatus.loggedIn;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _status = AuthStatus.error;
      notifyListeners();
    }
  }

  // Biometric login
  Future<void> loginWithBiometric() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Authenticate using biometric
      final isAuthenticated = await authenticateWithBiometric();
      if (!isAuthenticated) {
        _errorMessage = 'Biometric authentication failed';
        _status = AuthStatus.error;
        notifyListeners();
        return;
      }

      // Get saved email
      final savedEmail = await getSavedBiometricEmail();
      if (savedEmail == null) {
        _errorMessage = 'No saved biometric login found. Please login with your email and password first.';
        _status = AuthStatus.error;
        notifyListeners();
        return;
      }

      // Check if we have a saved token for this email
      final isLoggedInPreviously = await repository.isLoggedIn();
      if (isLoggedInPreviously) {
        // Use saved token
        final token = await repository.getToken();
        if (token != null && token.isNotEmpty) {
          _token = token;
          ApiClient().setToken(token);
          _status = AuthStatus.loggedIn;
          notifyListeners();
          return;
        }
      }

      _errorMessage = 'Session expired. Please login with your email and password.';
      _status = AuthStatus.error;
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
      await clearBiometricEmail();
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

  // Enable biometric for an email
  Future<void> enableBiometricForEmail(String email) async {
    try {
      await saveBiometricEmail(email);
    } catch (e) {
      _errorMessage = 'Failed to enable biometric login';
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
