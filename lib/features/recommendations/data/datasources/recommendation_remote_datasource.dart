import '../../../../core/network/api_client.dart';
import '../models/recommendation_model.dart';

abstract class RecommendationRemoteDataSource {
  Future<List<RecommendationModel>> getRecommendations({
    bool trending = false,
    String? genre,
    String? similarToBookId,
    String? bookType,
    String? course,
    String? className,
  });
}

class RecommendationRemoteDataSourceImpl
    implements RecommendationRemoteDataSource {
  final ApiClient client = ApiClient();

  @override
  Future<List<RecommendationModel>> getRecommendations({
    bool trending = false,
    String? genre,
    String? similarToBookId,
    String? bookType,
    String? course,
    String? className,
  }) async {
    String path = 'books/recommendations';
    if (similarToBookId != null && similarToBookId.isNotEmpty) {
      path = 'books/recommendations/similar/$similarToBookId';
    } else if (genre != null && genre.isNotEmpty) {
      path = 'books/recommendations/genre/$genre';
    } else if (trending) {
      path = 'books/recommendations/trending';
    }

    final query = <String, dynamic>{};
    if (bookType != null && bookType.trim().isNotEmpty) {
      query['bookType'] = bookType.trim();
    }
    if (course != null && course.trim().isNotEmpty) {
      query['course'] = course.trim();
    }
    if (className != null && className.trim().isNotEmpty) {
      query['className'] = className.trim();
      query['class'] = className.trim();
    }

    final response = await client.get(
      path,
      queryParameters: query.isEmpty ? null : query,
    );

    final items = _extractList(response.data);

    return items
        .map((json) => RecommendationModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is Map<String, dynamic>) {
      final direct =
          data['recommendations'] ??
          data['results'] ??
          data['books'] ??
          data['similar'] ??
          data['items'];
      if (direct is List) {
        return direct;
      }

      final nested = data['data'];
      if (nested is List) {
        return nested;
      }
      if (nested is Map<String, dynamic>) {
        final nestedList =
            nested['recommendations'] ??
            nested['results'] ??
            nested['books'] ??
            nested['similar'] ??
            nested['items'] ??
            nested['data'];
        if (nestedList is List) {
          return nestedList;
        }

        // Some APIs wrap twice: { data: { data: { recommendations: [] } } }
        final nestedData = nested['data'];
        if (nestedData is Map<String, dynamic>) {
          final nestedDataList =
              nestedData['recommendations'] ??
              nestedData['results'] ??
              nestedData['books'] ??
              nestedData['similar'] ??
              nestedData['items'];
          if (nestedDataList is List) {
            return nestedDataList;
          }
        }
      }
    }
    if (data is List) {
      return data;
    }
    return const [];
  }
}
