import '../repositories/home_repository.dart';

class ChangeTabUseCase {
  final HomeRepository repository;

  ChangeTabUseCase(this.repository);

  void call(int index) {
    repository.setCurrentTab(index);
  }
}
