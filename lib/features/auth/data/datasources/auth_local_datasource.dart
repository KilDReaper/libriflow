import 'package:hive_flutter/hive_flutter.dart';

class AuthLocalDatasource {
  final Box box;

  AuthLocalDatasource(this.box);

  Future<void> saveToken(String token) async {
    await box.put('token', token);
  }
  String? getToken() {
    return box.get('token');
  }
  Future<void> clearToken() async {
    await box.delete('token');
  }
}
