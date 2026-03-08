import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remote;
  final AuthLocalDatasource local;

  AuthRepositoryImpl({
    required this.remote,
    required this.local,
  });

  @override
  Future<AuthUser> login(String email, String password) async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('No internet connection. Please connect and login again.');
    }

    try {
      final userModel = await remote.login(email, password);
      await local.saveToken(userModel.token);
      return userModel;
    } on SocketException {
      throw Exception('Network error. Please check your connection and try again.');
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 401) {
        throw Exception('Invalid email or password.');
      }
      throw Exception('Login failed. Please try again.');
    }
  }

  @override
  Future<AuthUser> signup(
    String email,
    String username,
    String phone,
    String password,
    String confirmPassword,
  ) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('Cannot create account while offline.');
    }

    if (password != confirmPassword) {
      throw Exception('Passwords do not match.');
    }

    // Call signup API
    await remote.signup(email, username, phone, password, confirmPassword);

    // Immediately login to get token
    final userModel = await login(email, password);
    return userModel;
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await local.getToken();
    return token != null;
  }

  @override
  Future<String?> getToken() async {
    return await local.getToken();
  }

  @override
  Future<void> logout() async {
    await local.clearToken();
  }
}
