import 'package:hive/hive.dart';

abstract class HomeLocalDatasource {
  int getCurrentTab();
  void setCurrentTab(int index);
}

class HomeLocalDatasourceImpl implements HomeLocalDatasource {
  final Box _box;

  HomeLocalDatasourceImpl(this._box);

  @override
  int getCurrentTab() {
    return _box.get('currentTab', defaultValue: 0) as int;
  }

  @override
  void setCurrentTab(int index) {
    _box.put('currentTab', index);
  }
}
