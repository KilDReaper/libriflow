import '../core/network/api_client.dart';
import 'package:dio/dio.dart';
import '../shared/utils/image_url_resolver.dart';

class RemoteBookService {
  final ApiClient _client = ApiClient();
  final Dio _googleDio = Dio();
  static const String _googleBooksApiBase = 'https://www.googleapis.com/books/v1';

  Future<List<Map<String, dynamic>>> getBooks({
    String? search,
    String? category,
    bool includeGoogleBooks = false,
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
      'admin/books',
    ];

    final List<Map<String, dynamic>> merged = [];

    for (final endpoint in endpoints) {
      try {
        final response = await _client.get(
          endpoint,
          queryParameters: query.isEmpty ? null : query,
        ).timeout(const Duration(seconds: 8));
        final items = _extractList(response.data);
        if (items.isNotEmpty) {
          merged.addAll(items.map(_normalizeBook));
          break;
        }
      } catch (_) {}
    }

    if (includeGoogleBooks) {
      final googleBooks = await _getBooksFromGoogle(
        search: search,
        category: category,
      );
      merged.addAll(googleBooks);
    }

    if (merged.isEmpty) {
      return const [];
    }

    final seen = <String>{};
    final unique = <Map<String, dynamic>>[];
    for (final book in merged) {
      final key =
          '${book['title']?.toString().toLowerCase().trim()}::${book['author']?.toString().toLowerCase().trim()}';
      if (seen.add(key)) {
        unique.add(book);
      }
    }

    return unique;
  }

  Future<List<Map<String, dynamic>>> _getBooksFromGoogle({
    String? search,
    String? category,
  }) async {
    try {
      final hasSearch = search != null && search.trim().isNotEmpty;
      final hasCategory =
          category != null &&
          category.trim().isNotEmpty &&
          category.trim().toLowerCase() != 'all';

      String query;
      if (hasSearch && hasCategory) {
        query = '${search!.trim()} subject:${category!.trim()}';
      } else if (hasSearch) {
        query = search!.trim();
      } else if (hasCategory) {
        query = 'subject:${category!.trim()}';
      } else {
        query = 'subject:bestseller';
      }

      final response = await _googleDio.get(
        '$_googleBooksApiBase/volumes',
        queryParameters: {
          'q': query,
          'maxResults': 20,
          'printType': 'books',
          'orderBy': hasSearch ? 'relevance' : 'newest',
        },
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        return const [];
      }

      final items = data['items'];
      if (items is! List) {
        return const [];
      }

      final result = <Map<String, dynamic>>[];
      for (final item in items) {
        if (item is! Map<String, dynamic>) continue;
        final model = _normalizeGoogleBook(item);
        if (model != null) {
          result.add(model);
        }
      }
      return result;
    } catch (_) {
      return const [];
    }
  }

  Map<String, dynamic>? _normalizeGoogleBook(Map<String, dynamic> item) {
    final volumeInfo = item['volumeInfo'];
    if (volumeInfo is! Map<String, dynamic>) {
      return null;
    }

    final title = (volumeInfo['title'] ?? '').toString().trim();
    if (title.isEmpty) {
      return null;
    }

    final authors = volumeInfo['authors'];
    final String author = authors is List && authors.isNotEmpty
        ? authors.first.toString()
        : 'Unknown';

    final imageLinks = volumeInfo['imageLinks'];
    final rawImage = imageLinks is Map<String, dynamic>
        ? (imageLinks['thumbnail'] ?? imageLinks['smallThumbnail'] ?? '').toString()
        : '';
    final image = resolveBookImageUrl(rawImage);

    final categories = volumeInfo['categories'];
    final section = categories is List && categories.isNotEmpty
        ? categories.first.toString()
        : 'General';

    final rating = (volumeInfo['averageRating'] as num?)?.toDouble() ?? 0.0;

    return {
      'id': (item['id'] ?? '').toString(),
      'title': title,
      'author': author,
      'image': image,
      'section': section,
      'price': 0,
      'rating': rating,
      'course': '',
      'className': '',
      'source': 'google',
    };
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

    final rawImage =
        map['image'] ??
        map['coverUrl'] ??
      map['coverImageUrl'] ??
      map['cover_page_url'] ??
      map['coverPageUrl'] ??
      map['coverpageUrl'] ??
        map['cover_url'] ??
        map['cover'] ??
        map['imageUrl'] ??
        map['image_url'] ??
        map['coverImage'] ??
        map['thumbnail'] ??
        map['bookCover'] ??
        map['book_cover'] ??
        '';
    final image = resolveBookImageUrl(rawImage);

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