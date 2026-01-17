import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:libriflow/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:libriflow/features/auth/data/datasources/auth_remote_datasource.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remote;
  final AuthLocalDatasource local;

  AuthRepositoryImpl({required this.remote, required this.local});

  @override
  Future<void> login(String email, String password) async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult != ConnectivityResult.none) {
      try {
        final token = await remote.login(email, password);

        await local.saveToken(token);
      } on SocketException {
        return _offlineFallback();
      } catch (e) {

        rethrow;
      }
    } 

    else {
      return _offlineFallback();
    }
  }

  Future<void> _offlineFallback() async {
    final cachedToken = local.getToken();
    if (cachedToken != null) {

      return; 
    } else {
      throw Exception("No internet connection and no saved session found.");
    }
  }

  @override
  Future<void> signup(String email, String password, String confirmPassword) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception("Cannot create account while offline.");
    }
    
    await remote.signup(email, password, confirmPassword);
  }

  @override
  bool isLoggedIn() {
    return local.getToken() != null;
  }

  @override
  void logout() {
    local.clearToken();
  }
}