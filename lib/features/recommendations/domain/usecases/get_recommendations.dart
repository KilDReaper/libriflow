import '../entities/recommendation.dart';
import '../repositories/recommendation_repository.dart';

class GetRecommendations {
  final RecommendationRepository repository;
  GetRecommendations(this.repository);

  Future<List<Recommendation>> call({
    bool trending = false,
    String? genre,
    String? similarToBookId,
    String? bookType,
    String? course,
    String? className,
  }) {
    return repository.getRecommendations(
      trending: trending,
      genre: genre,
      similarToBookId: similarToBookId,
      bookType: bookType,
      course: course,
      className: className,
    );
  }
}
