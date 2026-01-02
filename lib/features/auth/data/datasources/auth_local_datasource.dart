import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';

class AuthLocalDatasource {
  final Box box;

  AuthLocalDatasource(this.box);

  Future<bool> signup(UserModel user) async {
    if (box.containsKey(user.email)) {
      return false; // user already exists
    }
    await box.put(user.email, user.toMap());
    return true;
  }

  bool login(String email, String password) {
    if (!box.containsKey(email)) return false;

    final userMap = box.get(email);
    final user = UserModel.fromMap(Map<String, dynamic>.from(userMap));

    return user.password == password;
  }
}
