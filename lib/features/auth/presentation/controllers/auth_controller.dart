import 'package:flutter/material.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository repository;

  AuthController(this.repository);

  bool isLoading = false;

  Future<String?> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      await repository.login(email, password);
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> signup(String email, String password, String confirmPassword) async {
    isLoading = true;
    notifyListeners();

    try {
      await repository.signup(email, password, confirmPassword);
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
