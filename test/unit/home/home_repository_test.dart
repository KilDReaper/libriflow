import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:libriflow/features/home/data/datasources/home_local_datasource.dart';
import 'package:libriflow/features/home/data/repositories/home_repository_impl.dart';

class MockHomeLocalDatasource extends Mock implements HomeLocalDatasource {}

void main() {
  late HomeRepositoryImpl repository;
  late MockHomeLocalDatasource mockLocalDatasource;

  setUp(() {
    mockLocalDatasource = MockHomeLocalDatasource();
    repository = HomeRepositoryImpl(mockLocalDatasource);
  });

  group('Home Repository Tests', () {
    test('getCurrentTab should return tab index from local datasource', () {
      // Arrange
      when(() => mockLocalDatasource.getCurrentTab()).thenReturn(2);

      // Act
      final result = repository.getCurrentTab();

      // Assert
      expect(result, 2);
      verify(() => mockLocalDatasource.getCurrentTab()).called(1);
    });

    test('getCurrentTab should return 0 as default tab', () {
      // Arrange
      when(() => mockLocalDatasource.getCurrentTab()).thenReturn(0);

      // Act
      final result = repository.getCurrentTab();

      // Assert
      expect(result, 0);
      verify(() => mockLocalDatasource.getCurrentTab()).called(1);
    });

    test('setCurrentTab should save tab index to local datasource', () {
      // Arrange
      when(() => mockLocalDatasource.setCurrentTab(any())).thenReturn(null);

      // Act
      repository.setCurrentTab(3);

      // Assert
      verify(() => mockLocalDatasource.setCurrentTab(3)).called(1);
    });

    test('setCurrentTab should handle tab index 0', () {
      // Arrange
      when(() => mockLocalDatasource.setCurrentTab(any())).thenReturn(null);

      // Act
      repository.setCurrentTab(0);

      // Assert
      verify(() => mockLocalDatasource.setCurrentTab(0)).called(1);
    });
  });
}
