import '../../domain/entities/recommendation.dart';
import '../../domain/repositories/recommendation_repository.dart';
import '../datasources/recommendation_local_datasource.dart';
import '../datasources/recommendation_remote_datasource.dart';

class RecommendationRepositoryImpl implements RecommendationRepository {
  final RecommendationRemoteDataSource remote;
  final RecommendationLocalDataSource local;

  RecommendationRepositoryImpl({
    required this.remote,
    required this.local,
  });

  @override
  Future<List<Recommendation>> getRecommendations() async {
    try {
      final models = await remote.getRecommendations();
      await local.cacheRecommendations(models);
      return models;
    } catch (e) {
      final cached = await local.getCachedRecommendations();
      if (cached.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }
}
