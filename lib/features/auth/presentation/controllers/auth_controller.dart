import 'package:flutter/material.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository repository;

  AuthController(this.repository);

  bool isLoading = false;

  Future<void> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      await repository.login(email, password);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signup(String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      await repository.signup(email, password);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
