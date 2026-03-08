import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:libriflow/features/recommendations/data/datasources/recommendation_local_datasource.dart';
import 'package:libriflow/features/recommendations/data/datasources/recommendation_remote_datasource.dart';
import 'package:libriflow/features/recommendations/data/models/recommendation_model.dart';
import 'package:libriflow/features/recommendations/data/repositories/recommendation_repository_impl.dart';

class MockRecommendationRemoteDataSource extends Mock
    implements RecommendationRemoteDataSource {}

class MockRecommendationLocalDataSource extends Mock
    implements RecommendationLocalDataSource {}

void main() {
  late RecommendationRepositoryImpl repository;
  late MockRecommendationRemoteDataSource mockRemoteDatasource;
  late MockRecommendationLocalDataSource mockLocalDatasource;

  setUp(() {
    mockRemoteDatasource = MockRecommendationRemoteDataSource();
    mockLocalDatasource = MockRecommendationLocalDataSource();
    repository = RecommendationRepositoryImpl(
      remote: mockRemoteDatasource,
      local: mockLocalDatasource,
    );
  });

  group('Recommendation Repository Tests', () {
    final testRecommendations = <RecommendationModel>[
      const RecommendationModel(
        id: '1',
        title: 'Recommended Book 1',
        author: 'Author 1',
        coverUrl: 'https://example.com/cover1.jpg',
        rating: 4.5,
      ),
      const RecommendationModel(
        id: '2',
        title: 'Recommended Book 2',
        author: 'Author 2',
        coverUrl: 'https://example.com/cover2.jpg',
        rating: 4.2,
      ),
    ];

    test('getRecommendations should return trending books', () async {
      // Arrange
      when(() => mockRemoteDatasource.getRecommendations(
            trending: any(named: 'trending'),
            genre: any(named: 'genre'),
            similarToBookId: any(named: 'similarToBookId'),
            bookType: any(named: 'bookType'),
            course: any(named: 'course'),
            className: any(named: 'className'),
          )).thenAnswer((_) async => testRecommendations);

      when(() => mockLocalDatasource.cacheRecommendations(any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await repository.getRecommendations(trending: true);

      // Assert
      expect(result, testRecommendations);
      expect(result.length, 2);
      verify(() => mockRemoteDatasource.getRecommendations(
            trending: true,
            genre: null,
            similarToBookId: null,
            bookType: null,
            course: null,
            className: null,
          )).called(1);
      verify(() => mockLocalDatasource.cacheRecommendations(testRecommendations))
          .called(1);
    });

    test('getRecommendations should filter by genre', () async {
      // Arrange
      when(() => mockRemoteDatasource.getRecommendations(
            trending: any(named: 'trending'),
            genre: any(named: 'genre'),
            similarToBookId: any(named: 'similarToBookId'),
            bookType: any(named: 'bookType'),
            course: any(named: 'course'),
            className: any(named: 'className'),
          )).thenAnswer((_) async => testRecommendations);

      when(() => mockLocalDatasource.cacheRecommendations(any()))
          .thenAnswer((_) async => {});

      // Act
      final result =
          await repository.getRecommendations(genre: 'Science Fiction');

      // Assert
      expect(result, testRecommendations);
      verify(() => mockRemoteDatasource.getRecommendations(
            trending: false,
            genre: 'Science Fiction',
            similarToBookId: null,
            bookType: null,
            course: null,
            className: null,
          )).called(1);
    });

    test('getRecommendations should return cached data on network error',
        () async {
      // Arrange
      when(() => mockRemoteDatasource.getRecommendations(
            trending: any(named: 'trending'),
            genre: any(named: 'genre'),
            similarToBookId: any(named: 'similarToBookId'),
            bookType: any(named: 'bookType'),
            course: any(named: 'course'),
            className: any(named: 'className'),
          )).thenThrow(Exception('Network error'));

      when(() => mockLocalDatasource.getCachedRecommendations())
          .thenAnswer((_) async => testRecommendations);

      // Act
      final result = await repository.getRecommendations();

      // Assert
      expect(result, testRecommendations);
      verify(() => mockLocalDatasource.getCachedRecommendations()).called(1);
    });

    test('getRecommendations should throw when no cache available', () async {
      // Arrange
      when(() => mockRemoteDatasource.getRecommendations(
            trending: any(named: 'trending'),
            genre: any(named: 'genre'),
            similarToBookId: any(named: 'similarToBookId'),
            bookType: any(named: 'bookType'),
            course: any(named: 'course'),
            className: any(named: 'className'),
          )).thenThrow(Exception('Network error'));

      when(() => mockLocalDatasource.getCachedRecommendations())
          .thenAnswer((_) async => []);

      // Act & Assert
      expect(
        () => repository.getRecommendations(),
        throwsException,
      );
    });

    test('getRecommendations should cache successfully fetched data',
        () async {
      // Arrange
      when(() => mockRemoteDatasource.getRecommendations(
            trending: any(named: 'trending'),
            genre: any(named: 'genre'),
            similarToBookId: any(named: 'similarToBookId'),
            bookType: any(named: 'bookType'),
            course: any(named: 'course'),
            className: any(named: 'className'),
          )).thenAnswer((_) async => testRecommendations);

      when(() => mockLocalDatasource.cacheRecommendations(any()))
          .thenAnswer((_) async => {});

      // Act
      await repository.getRecommendations();

      // Assert
      verify(() => mockLocalDatasource.cacheRecommendations(testRecommendations))
          .called(1);
    });
  });
}
