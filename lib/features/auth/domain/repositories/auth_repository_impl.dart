import 'package:libriflow/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:libriflow/features/auth/data/datasources/auth_remote_datasource.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remote;
  final AuthLocalDatasource local;

  AuthRepositoryImpl({
    required this.remote,
    required this.local,
  });

  @override
  Future<void> login(String email, String password) async {
    final token = await remote.login(email, password);
    local.saveToken(token);
  }

  @override
  Future<void> signup(String email, String password) async {
    await remote.signup(email, password);
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
