import 'package:hive/hive.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/models/user_model.dart';

class AuthController {
  final AuthLocalDatasource datasource;

  AuthController(Box box) : datasource = AuthLocalDatasource(box);

  Future<bool> signup(String name, String email, String password) async {
    final user = UserModel(
      name: name,
      email: email,
      password: password,
    );
    return datasource.signup(user);
  }

  bool login(String email, String password) {
    return datasource.login(email, password);
  }
}
