import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String userBox = 'userBox';

  static Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isBoxOpen(userBox)) {
      await Hive.openBox(userBox);
    }
  }

  static Box getUserBox() {
    return Hive.box(userBox);
  }
}
