import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String userBoxName = 'users';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(userBoxName);
  }

  static Box get userBox => Hive.box(userBoxName);
}
