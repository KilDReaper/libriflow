import '../core/network/api_client.dart';

class RemoteBookService {
  final ApiClient _client = ApiClient();

  Future<List<Map<String, dynamic>>> getBooks({
    String? search,
    String? category,
  }) async {
    final query = <String, dynamic>{};
    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
      query['q'] = search.trim();
    }
    if (category != null &&
        category.trim().isNotEmpty &&
        category.trim().toLowerCase() != 'all') {
      query['category'] = category.trim();
      query['section'] = category.trim();
    }

    final endpoints = <String>[
      'books',
      'books/all',
      'books/list',
      'library/books',
    ];

    for (final endpoint in endpoints) {
      try {
        final response = await _client.get(
          endpoint,
          queryParameters: query.isEmpty ? null : query,
        );
        final items = _extractList(response.data);
        if (items.isNotEmpty) {
          return items.map(_normalizeBook).toList();
        }
      } catch (_) {}
    }

    return const [];
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) {
      return data;
    }
    if (data is Map<String, dynamic>) {
      final directValue =
          data['books'] ?? data['items'] ?? data['results'] ?? data['rows'];
      if (directValue is List) {
        return directValue;
      }

      final nestedData = data['data'];
      if (nestedData is List) {
        return nestedData;
      }
      if (nestedData is Map<String, dynamic>) {
        final nestedValue =
            nestedData['books'] ?? nestedData['items'] ?? nestedData['results'];
        if (nestedValue is List) {
          return nestedValue;
        }
      }
    }
    return const [];
  }

  Map<String, dynamic> _normalizeBook(dynamic item) {
    final map = item is Map<String, dynamic>
        ? item
        : Map<String, dynamic>.from(item as Map);

    final dynamic authorValue = map['author'] ?? map['authors'] ?? map['writer'];
    final String author = authorValue is List
        ? (authorValue.isNotEmpty ? authorValue.first.toString() : 'Unknown')
        : (authorValue ?? 'Unknown').toString();

    final image = (map['image'] ??
            map['coverUrl'] ??
            map['cover'] ??
            map['imageUrl'] ??
          map['coverImage'] ??
            map['thumbnail'] ??
            '')
        .toString();

    final priceNum = (map['price'] ?? map['rentalPrice'] ?? map['amount'] ?? 0)
        as num?;
    final ratingNum = (map['rating'] ?? map['averageRating'] ?? 0) as num?;

    return {
      'id': (map['id'] ?? map['_id'] ?? '').toString(),
      'title': (map['title'] ?? map['bookTitle'] ?? map['name'] ?? 'Untitled')
          .toString(),
      'author': author,
      'image': image,
      'section':
          (map['section'] ?? map['category'] ?? map['genre'] ?? 'General')
              .toString(),
      'price': priceNum?.toInt() ?? 0,
      'rating': ratingNum?.toDouble() ?? 0.0,
      'course': (map['course'] ?? map['program'] ?? '').toString(),
      'className': (map['class'] ?? map['className'] ?? '').toString(),
    };
  }
}