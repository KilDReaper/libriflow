import '../repositories/home_repository.dart';

class GetCurrentTabUseCase {
  final HomeRepository repository;

  GetCurrentTabUseCase(this.repository);

  int call() {
    return repository.getCurrentTab();
  }
}
