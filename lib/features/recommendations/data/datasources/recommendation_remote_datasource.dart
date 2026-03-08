import 'package:dio/dio.dart';
import '../models/recommendation_model.dart';

abstract class RecommendationRemoteDataSource {
  Future<List<RecommendationModel>> getRecommendations({
    bool trending = false,
    String? genre,
    String? similarToBookId,
    String? bookType,
    String? course,
    String? className,
    String? preferredAuthor,
    String? keywords,
  });
}

class RecommendationRemoteDataSourceImpl
    implements RecommendationRemoteDataSource {
  final Dio _dio = Dio();
  static const String _googleBooksApiBase = 'https://www.googleapis.com/books/v1';

  @override
  Future<List<RecommendationModel>> getRecommendations({
    bool trending = false,
    String? genre,
    String? similarToBookId,
    String? bookType,
    String? course,
    String? className,
    String? preferredAuthor,
    String? keywords,
  }) async {
    // Build search query for Google Books
    String searchQuery = '';

    if (bookType == 'course' && course != null && course.trim().isNotEmpty) {
      // Academic books - search by course and class
      searchQuery = course.trim();
      if (className != null && className.trim().isNotEmpty) {
        searchQuery += ' ${className.trim()}';
      }
      searchQuery += ' textbook';
    } else if (trending) {
      // Trending/popular books
      searchQuery = 'subject:bestseller';
    } else {
      // Non-academic books with richer user context
      final queryParts = <String>[];
      if (genre != null && genre.trim().isNotEmpty) {
        queryParts.add('subject:${genre.trim()}');
      }
      if (preferredAuthor != null && preferredAuthor.trim().isNotEmpty) {
        queryParts.add('inauthor:${preferredAuthor.trim()}');
      }
      if (keywords != null && keywords.trim().isNotEmpty) {
        queryParts.add(keywords.trim());
      }

      searchQuery =
          queryParts.isEmpty
              ? 'subject:fiction OR subject:non-fiction'
              : queryParts.join(' ');
    }

    try {
      final response = await _dio.get(
        '$_googleBooksApiBase/volumes',
        queryParameters: {
          'q': searchQuery,
          'maxResults': 20,
          'orderBy': 'relevance',
          'printType': 'books',
        },
      );

      if (response.data == null || response.data['items'] == null) {
        return [];
      }

      final items = response.data['items'] as List<dynamic>;
      
      return items
          .map((item) => _convertGoogleBookToModel(item as Map<String, dynamic>))
          .where((model) => model != null)
          .cast<RecommendationModel>()
          .toList();
    } catch (e) {
      print('Error fetching from Google Books: $e');
      return [];
    }
  }

  RecommendationModel? _convertGoogleBookToModel(Map<String, dynamic> googleBook) {
    try {
      final volumeInfo = googleBook['volumeInfo'] as Map<String, dynamic>?;
      if (volumeInfo == null) return null;

      final id = googleBook['id'] as String? ?? '';
      final title = volumeInfo['title'] as String? ?? 'Unknown Title';
      
      final authors = volumeInfo['authors'] as List<dynamic>?;
      final author = authors != null && authors.isNotEmpty 
          ? authors.first.toString() 
          : 'Unknown Author';
      
      final imageLinks = volumeInfo['imageLinks'] as Map<String, dynamic>?;
      final coverUrl = imageLinks?['thumbnail'] as String? ?? 
                       imageLinks?['smallThumbnail'] as String? ?? '';
      
      final rating = (volumeInfo['averageRating'] as num?)?.toDouble() ?? 0.0;

      return RecommendationModel(
        id: id,
        title: title,
        author: author,
        coverUrl: coverUrl,
        rating: rating,
      );
    } catch (e) {
      print('Error converting Google Book item: $e');
      return null;
    }
  }
}
