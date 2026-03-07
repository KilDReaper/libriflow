import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeLocalDatasource local;

  HomeRepositoryImpl(this.local);

  @override
  int getCurrentTab() {
    return local.getCurrentTab();
  }

  @override
  void setCurrentTab(int index) {
    local.setCurrentTab(index);
  }
}
