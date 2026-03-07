import 'package:libriflow/core/network/api_client.dart';
import 'package:libriflow/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:libriflow/features/auth/data/models/auth_user_model.dart';

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final ApiClient _apiClient = ApiClient();

  @override
  Future<AuthUserModel> signup(
    String email,
    String username,
    String phone,
    String password,
    String confirmPassword,
  ) async {
    try {
      final response = await _apiClient.post('auth/register', {
        'username': username,
        'email': email,
        'phoneNumber': phone, 
        'password': password,
        'confirmPassword': confirmPassword,
      });
      return AuthUserModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthUserModel> login(String email, String password) async {
    try {
      final response = await _apiClient.post('auth/login', {
        'email': email,
        'password': password,
      });

      return AuthUserModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}