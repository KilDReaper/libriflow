import '../entities/recommendation.dart';
import '../repositories/recommendation_repository.dart';

class GetRecommendations {
  final RecommendationRepository repository;
  GetRecommendations(this.repository);

  Future<List<Recommendation>> call() {
    return repository.getRecommendations();
  }
}
