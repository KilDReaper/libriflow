import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';

class AuthLocalDatasource {
  final Box box;

  AuthLocalDatasource(this.box);

  Future<bool> signup(UserModel user) async {
    final key = user.email.trim().toLowerCase();
    if (box.containsKey(key)) return false;
    await box.put(key, user.toMap());
    return true;
  }

  bool login(String email, String password) {
    final key = email.trim().toLowerCase();
    if (!box.containsKey(key)) return false;
    final data = Map<String, dynamic>.from(box.get(key));
    final user = UserModel.fromMap(data);
    return user.password == password.trim();
  }
}
