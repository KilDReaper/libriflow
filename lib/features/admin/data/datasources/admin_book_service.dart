import '../../../../core/network/api_client.dart';
import '../models/admin_book_model.dart';

class AdminBookService {
  final ApiClient _client = ApiClient();

  /// Get all books with optional filters
  Future<List<AdminBookModel>> getBooks({
    String? search,
    String? genre,
    String? status,
    double? minPrice,
    double? maxPrice,
    int page = 1,
    int limit = 20,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      };

      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }
      if (genre != null && genre.trim().isNotEmpty && genre != 'all') {
        queryParams['genre'] = genre.trim();
      }
      if (status != null && status.trim().isNotEmpty && status != 'all') {
        queryParams['status'] = status.trim();
      }
      if (minPrice != null) {
        queryParams['minPrice'] = minPrice;
      }
      if (maxPrice != null) {
        queryParams['maxPrice'] = maxPrice;
      }

      // Try multiple endpoints
      final endpoints = ['books', 'books/all', 'admin/books'];
      
      for (final endpoint in endpoints) {
        try {
          final response = await _client.get(endpoint, queryParameters: queryParams);
          final data = response.data;
          
          // Extract books list from various response structures
          List<dynamic> booksJson = [];
          if (data is List) {
            booksJson = data;
          } else if (data is Map<String, dynamic>) {
            booksJson = _extractList(data);
          }

          if (booksJson.isNotEmpty) {
            return booksJson
                .map((json) => AdminBookModel.fromJson(
                    json is Map<String, dynamic> ? json : Map<String, dynamic>.from(json as Map)))
                .toList();
          }
        } catch (e) {
          print('DEBUG: Endpoint $endpoint failed: $e');
          continue;
        }
      }

      return [];
    } catch (e) {
      print('ERROR: Failed to fetch books: $e');
      rethrow;
    }
  }

  List<dynamic> _extractList(Map<String, dynamic> data) {
    // Direct fields
    final directValue = data['books'] ?? data['items'] ?? data['results'] ?? data['rows'];
    if (directValue is List) return directValue;

    // Nested data field
    final nestedData = data['data'];
    if (nestedData is List) return nestedData;
    if (nestedData is Map<String, dynamic>) {
      final nestedValue =
          nestedData['books'] ?? nestedData['items'] ?? nestedData['results'];
      if (nestedValue is List) return nestedValue;
    }

    return [];
  }

  /// Get a single book by ID
  Future<AdminBookModel> getBookById(String bookId) async {
    try {
      final response = await _client.get('books/$bookId');
      final data = response.data;
      
      Map<String, dynamic> bookJson;
      if (data is Map<String, dynamic>) {
        bookJson = data['book'] ?? data['data'] ?? data;
      } else {
        throw Exception('Invalid response format');
      }

      return AdminBookModel.fromJson(bookJson);
    } catch (e) {
      print('ERROR: Failed to fetch book: $e');
      rethrow;
    }
  }

  /// Get inventory statistics
  Future<InventoryStats> getInventoryStats() async {
    try {
      final books = await getBooks(limit: 1000); // Get all books
      return InventoryStats.fromBooks(books);
    } catch (e) {
      print('ERROR: Failed to fetch inventory stats: $e');
      rethrow;
    }
  }

  /// Get unique genres from all books
  Future<List<String>> getGenres() async {
    try {
      // Try to get from dedicated endpoint first
      try {
        final response = await _client.get('books/genres');
        final data = response.data;
        if (data is List) {
          return data.map((e) => e.toString()).toList();
        } else if (data is Map<String, dynamic>) {
          final genres = data['genres'] ?? data['data'];
          if (genres is List) {
            return genres.map((e) => e.toString()).toList();
          }
        }
      } catch (_) {}

      // Fallback: extract from all books
      final books = await getBooks(limit: 1000);
      final genresSet = <String>{};
      for (var book in books) {
        genresSet.addAll(book.genres);
      }
      final genresList = genresSet.toList()..sort();
      return genresList;
    } catch (e) {
      print('ERROR: Failed to fetch genres: $e');
      return [];
    }
  }

  /// Delete a book (if backend supports it)
  Future<void> deleteBook(String bookId) async {
    try {
      await _client.delete('books/$bookId');
    } catch (e) {
      print('ERROR: Failed to delete book: $e');
      rethrow;
    }
  }

  /// Update book details (if backend supports it)
  Future<AdminBookModel> updateBook(String bookId, Map<String, dynamic> updates) async {
    try {
      final response = await _client.put('books/$bookId', updates);
      final data = response.data;
      
      Map<String, dynamic> bookJson;
      if (data is Map<String, dynamic>) {
        bookJson = data['book'] ?? data['data'] ?? data;
      } else {
        throw Exception('Invalid response format');
      }

      return AdminBookModel.fromJson(bookJson);
    } catch (e) {
      print('ERROR: Failed to update book: $e');
      rethrow;
    }
  }

  /// Create a new book (if backend supports it)
  Future<AdminBookModel> createBook(Map<String, dynamic> bookData) async {
    try {
      final response = await _client.post('books', bookData);
      final data = response.data;
      
      Map<String, dynamic> bookJson;
      if (data is Map<String, dynamic>) {
        bookJson = data['book'] ?? data['data'] ?? data;
      } else {
        throw Exception('Invalid response format');
      }

      return AdminBookModel.fromJson(bookJson);
    } catch (e) {
      print('ERROR: Failed to create book: $e');
      rethrow;
    }
  }
}
