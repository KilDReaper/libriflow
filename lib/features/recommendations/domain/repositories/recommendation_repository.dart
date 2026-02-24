import '../entities/recommendation.dart';

abstract class RecommendationRepository {
  Future<List<Recommendation>> getRecommendations();
}
