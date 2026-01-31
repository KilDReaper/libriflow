import 'package:hive/hive.dart';

abstract class AuthLocalDatasource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
}

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  final Box _box;

  AuthLocalDatasourceImpl(this._box);

  @override
  Future<void> saveToken(String token) async {
    await _box.put('token', token);
  }

  @override
  Future<String?> getToken() async {
    return _box.get('token') as String?;
  }

  @override
  Future<void> clearToken() async {
    await _box.delete('token');
  }
}
