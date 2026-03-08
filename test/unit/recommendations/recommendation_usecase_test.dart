import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:libriflow/features/recommendations/domain/entities/recommendation.dart';
import 'package:libriflow/features/recommendations/domain/repositories/recommendation_repository.dart';
import 'package:libriflow/features/recommendations/domain/usecases/get_recommendations.dart';

class MockRecommendationRepository extends Mock
    implements RecommendationRepository {}

void main() {
  late GetRecommendations useCase;
  late MockRecommendationRepository mockRepository;

  setUp(() {
    mockRepository = MockRecommendationRepository();
    useCase = GetRecommendations(mockRepository);
  });

  group('GetRecommendations UseCase Tests', () {
    final testRecommendations = <Recommendation>[
      const Recommendation(
        id: '1',
        title: 'Recommended Book 1',
        author: 'Author 1',
        coverUrl: 'https://example.com/cover1.jpg',
        rating: 4.5,
      ),
      const Recommendation(
        id: '2',
        title: 'Recommended Book 2',
        author: 'Author 2',
        coverUrl: 'https://example.com/cover2.jpg',
        rating: 4.2,
      ),
    ];

    test('should get trending recommendations', () async {
      // Arrange
      when(() => mockRepository.getRecommendations(
            trending: any(named: 'trending'),
            genre: any(named: 'genre'),
            similarToBookId: any(named: 'similarToBookId'),
            bookType: any(named: 'bookType'),
            course: any(named: 'course'),
            className: any(named: 'className'),
          )).thenAnswer((_) async => testRecommendations);

      // Act
      final result = await useCase.call(trending: true);

      // Assert
      expect(result, testRecommendations);
      expect(result.length, 2);
      verify(() => mockRepository.getRecommendations(
            trending: true,
            genre: null,
            similarToBookId: null,
            bookType: null,
            course: null,
            className: null,
          )).called(1);
    });

    test('should get recommendations by genre', () async {
      // Arrange
      when(() => mockRepository.getRecommendations(
            trending: any(named: 'trending'),
            genre: any(named: 'genre'),
            similarToBookId: any(named: 'similarToBookId'),
            bookType: any(named: 'bookType'),
            course: any(named: 'course'),
            className: any(named: 'className'),
          )).thenAnswer((_) async => testRecommendations);

      // Act
      final result = await useCase.call(genre: 'Science Fiction');

      // Assert
      expect(result, testRecommendations);
      verify(() => mockRepository.getRecommendations(
            trending: false,
            genre: 'Science Fiction',
            similarToBookId: null,
            bookType: null,
            course: null,
            className: null,
          )).called(1);
    });

    test('should get similar book recommendations', () async {
      // Arrange
      when(() => mockRepository.getRecommendations(
            trending: any(named: 'trending'),
            genre: any(named: 'genre'),
            similarToBookId: any(named: 'similarToBookId'),
            bookType: any(named: 'bookType'),
            course: any(named: 'course'),
            className: any(named: 'className'),
          )).thenAnswer((_) async => testRecommendations);

      // Act
      final result = await useCase.call(similarToBookId: 'book123');

      // Assert
      expect(result, testRecommendations);
      verify(() => mockRepository.getRecommendations(
            trending: false,
            genre: null,
            similarToBookId: 'book123',
            bookType: null,
            course: null,
            className: null,
          )).called(1);
    });

    test('should handle empty recommendations', () async {
      // Arrange
      when(() => mockRepository.getRecommendations(
            trending: any(named: 'trending'),
            genre: any(named: 'genre'),
            similarToBookId: any(named: 'similarToBookId'),
            bookType: any(named: 'bookType'),
            course: any(named: 'course'),
            className: any(named: 'className'),
          )).thenAnswer((_) async => []);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, isEmpty);
    });

    test('should handle API errors', () async {
      // Arrange
      when(() => mockRepository.getRecommendations(
            trending: any(named: 'trending'),
            genre: any(named: 'genre'),
            similarToBookId: any(named: 'similarToBookId'),
            bookType: any(named: 'bookType'),
            course: any(named: 'course'),
            className: any(named: 'className'),
          )).thenThrow(Exception('Failed to fetch recommendations'));

      // Act & Assert
      expect(() => useCase.call(), throwsException);
    });
  });
}
