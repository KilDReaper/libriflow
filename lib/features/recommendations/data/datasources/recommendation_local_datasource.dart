import 'package:hive/hive.dart';
import '../models/recommendation_model.dart';

abstract class RecommendationLocalDataSource {
  Future<List<RecommendationModel>> getCachedRecommendations();
  Future<void> cacheRecommendations(List<RecommendationModel> items);
}

class RecommendationLocalDataSourceImpl
    implements RecommendationLocalDataSource {
  final Box box;

  RecommendationLocalDataSourceImpl(this.box);

  @override
  Future<List<RecommendationModel>> getCachedRecommendations() async {
    final cached = box.get('items');
    if (cached is List) {
      return cached
          .whereType<Map>()
          .map((json) => RecommendationModel.fromJson(
              Map<String, dynamic>.from(json)))
          .toList();
    }
    return const [];
  }

  @override
  Future<void> cacheRecommendations(List<RecommendationModel> items) async {
    final payload = items.map((item) => item.toJson()).toList();
    await box.put('items', payload);
  }
}
