import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:libriflow/features/home/domain/repositories/home_repository.dart';
import 'package:libriflow/features/home/domain/usecases/change_tab_usecase.dart';
import 'package:libriflow/features/home/domain/usecases/get_current_tab_usecase.dart';

class MockHomeRepository extends Mock implements HomeRepository {}

void main() {
  late MockHomeRepository mockRepository;

  setUp(() {
    mockRepository = MockHomeRepository();
  });

  group('Home tab usecases', () {
    test('ChangeTabUseCase delegates selected index', () {
      final useCase = ChangeTabUseCase(mockRepository);

      useCase.call(2);

      verify(() => mockRepository.setCurrentTab(2)).called(1);
    });

    test('GetCurrentTabUseCase returns current tab index', () {
      final useCase = GetCurrentTabUseCase(mockRepository);
      when(() => mockRepository.getCurrentTab()).thenReturn(1);

      final result = useCase.call();

      expect(result, 1);
      verify(() => mockRepository.getCurrentTab()).called(1);
    });
  });
}
