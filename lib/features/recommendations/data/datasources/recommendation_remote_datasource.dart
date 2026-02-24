import '../../../../core/network/api_client.dart';
import '../models/recommendation_model.dart';

abstract class RecommendationRemoteDataSource {
  Future<List<RecommendationModel>> getRecommendations();
}

class RecommendationRemoteDataSourceImpl
    implements RecommendationRemoteDataSource {
  final ApiClient client = ApiClient();

  @override
  Future<List<RecommendationModel>> getRecommendations() async {
    final response = await client.get('books/recommendations');
    final data = response.data;
    final List<dynamic> items = _extractList(data);
    return items
        .map((json) => RecommendationModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is Map<String, dynamic>) {
      final value = data['data'] ?? data['items'] ?? data['recommendations'];
      if (value is List) {
        return value;
      }
    }
    if (data is List) {
      return data;
    }
    return const [];
  }
}
