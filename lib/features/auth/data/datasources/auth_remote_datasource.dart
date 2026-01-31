// lib/features/auth/data/datasources/auth_remote_datasource.dart
import '../models/auth_user_model.dart';
import '../../../../core/network/api_client.dart';

abstract class AuthRemoteDatasource {
  Future<AuthUserModel> login(String email, String password);
  Future<AuthUserModel> signup(
    String email,
    String username,
    String phone,
    String password,
    String confirmPassword,
  );
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final ApiClient client;

  AuthRemoteDatasourceImpl([ApiClient? client]) : client = client ?? ApiClient();

  @override
  Future<AuthUserModel> login(String email, String password) async {
    final response = await client.post('/auth/login', {
      'email': email,
      'password': password,
    });
    return AuthUserModel.fromJson(response.data['data']);
  }

  @override
  Future<AuthUserModel> signup(
    String email,
    String username,
    String phone,
    String password,
    String confirmPassword,
  ) async {
    final response = await client.post('/auth/register', {
      'email': email,
      'username': username,
      'phone': phone,
      'password': password,
      'confirmPassword': confirmPassword,
    });
    return AuthUserModel.fromJson(response.data['data']);
  }
}
