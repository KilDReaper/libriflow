import '../entities/recommendation.dart';

abstract class RecommendationRepository {
  Future<List<Recommendation>> getRecommendations({
    bool trending = false,
    String? genre,
    String? similarToBookId,
    String? bookType,
    String? course,
    String? className,
  });
}
