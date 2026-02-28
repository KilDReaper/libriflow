import 'package:flutter/foundation.dart';
import '../../data/datasources/admin_book_service.dart';
import '../../data/models/admin_book_model.dart';

class AdminBooksProvider with ChangeNotifier {
  final AdminBookService _bookService = AdminBookService();

  // State
  List<AdminBookModel> _allBooks = [];
  List<AdminBookModel> _filteredBooks = [];
  InventoryStats? _inventoryStats;
  List<String> _availableGenres = [];
  
  bool _isLoading = false;
  bool _isLoadingStats = false;
  String? _error;

  // Filters
  String _searchQuery = '';
  String _selectedGenre = 'all';
  String _selectedStatus = 'all';
  double _minPrice = 0;
  double _maxPrice = 10000;
  
  // Sorting
  String _sortBy = 'title';
  bool _sortAscending = true;

  // Pagination
  int _currentPage = 1;
  int _itemsPerPage = 20;

  // Getters
  List<AdminBookModel> get books => _filteredBooks;
  List<AdminBookModel> get allBooks => _allBooks;
  InventoryStats? get inventoryStats => _inventoryStats;
  List<String> get availableGenres => _availableGenres;
  bool get isLoading => _isLoading;
  bool get isLoadingStats => _isLoadingStats;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedGenre => _selectedGenre;
  String get selectedStatus => _selectedStatus;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;
  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;
  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;
  
  int get totalBooks => _filteredBooks.length;
  int get totalPages => (_filteredBooks.length / _itemsPerPage).ceil();
  int get startIndex => (_currentPage - 1) * _itemsPerPage;
  int get endIndex => 
      (startIndex + _itemsPerPage > _filteredBooks.length)
          ? _filteredBooks.length
          : startIndex + _itemsPerPage;
  
  List<AdminBookModel> get paginatedBooks {
    if (_filteredBooks.isEmpty) return [];
    final start = startIndex;
    final end = endIndex;
    return _filteredBooks.sublist(start, end);
  }

  /// Load all books from the backend
  Future<void> loadBooks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allBooks = await _bookService.getBooks(limit: 1000);
      _applyFiltersAndSort();
      _error = null;
    } catch (e) {
      _error = 'Failed to load books: ${e.toString()}';
      _allBooks = [];
      _filteredBooks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load inventory statistics
  Future<void> loadInventoryStats() async {
    _isLoadingStats = true;
    notifyListeners();

    try {
      _inventoryStats = await _bookService.getInventoryStats();
    } catch (e) {
      print('ERROR: Failed to load inventory stats: $e');
      _inventoryStats = null;
    } finally {
      _isLoadingStats = false;
      notifyListeners();
    }
  }

  /// Load available genres
  Future<void> loadGenres() async {
    try {
      _availableGenres = await _bookService.getGenres();
      notifyListeners();
    } catch (e) {
      print('ERROR: Failed to load genres: $e');
      _availableGenres = [];
    }
  }

  /// Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    _currentPage = 1;
    _applyFiltersAndSort();
  }

  /// Set genre filter
  void setGenreFilter(String genre) {
    _selectedGenre = genre;
    _currentPage = 1;
    _applyFiltersAndSort();
  }

  /// Set status filter
  void setStatusFilter(String status) {
    _selectedStatus = status;
    _currentPage = 1;
    _applyFiltersAndSort();
  }

  /// Set price range filter
  void setPriceRange(double min, double max) {
    _minPrice = min;
    _maxPrice = max;
    _currentPage = 1;
    _applyFiltersAndSort();
  }

  /// Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedGenre = 'all';
    _selectedStatus = 'all';
    _minPrice = 0;
    _maxPrice = 10000;
    _currentPage = 1;
    _applyFiltersAndSort();
  }

  /// Set sorting
  void setSorting(String sortBy, {bool? ascending}) {
    _sortBy = sortBy;
    if (ascending != null) {
      _sortAscending = ascending;
    } else {
      // Toggle if same field
      _sortAscending = _sortBy == sortBy ? !_sortAscending : true;
    }
    _applyFiltersAndSort();
  }

  /// Set items per page
  void setItemsPerPage(int count) {
    _itemsPerPage = count;
    _currentPage = 1;
    notifyListeners();
  }

  /// Go to specific page
  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      _currentPage = page;
      notifyListeners();
    }
  }

  /// Go to next page
  void nextPage() {
    if (_currentPage < totalPages) {
      _currentPage++;
      notifyListeners();
    }
  }

  /// Go to previous page
  void previousPage() {
    if (_currentPage > 1) {
      _currentPage--;
      notifyListeners();
    }
  }

  /// Apply filters and sorting to the books list
  void _applyFiltersAndSort() {
    var filtered = List<AdminBookModel>.from(_allBooks);

    // Apply search filter
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((book) {
        return book.title.toLowerCase().contains(query) ||
            book.author.toLowerCase().contains(query) ||
            book.isbn.toLowerCase().contains(query);
      }).toList();
    }

    // Apply genre filter
    if (_selectedGenre != 'all' && _selectedGenre.isNotEmpty) {
      filtered = filtered.where((book) {
        return book.genres.any((genre) =>
            genre.toLowerCase() == _selectedGenre.toLowerCase());
      }).toList();
    }

    // Apply status filter
    if (_selectedStatus != 'all' && _selectedStatus.isNotEmpty) {
      filtered = filtered.where((book) {
        return book.status.toLowerCase() == _selectedStatus.toLowerCase();
      }).toList();
    }

    // Apply price filter
    filtered = filtered.where((book) {
      return book.price >= _minPrice && book.price <= _maxPrice;
    }).toList();

    // Apply sorting
    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'title':
          comparison = a.title.compareTo(b.title);
          break;
        case 'author':
          comparison = a.author.compareTo(b.author);
          break;
        case 'price':
          comparison = a.price.compareTo(b.price);
          break;
        case 'rating':
          comparison = a.rating.compareTo(b.rating);
          break;
        case 'stock':
          comparison = a.stockQuantity.compareTo(b.stockQuantity);
          break;
        case 'available':
          comparison = a.availableQuantity.compareTo(b.availableQuantity);
          break;
        case 'createdAt':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        default:
          comparison = a.title.compareTo(b.title);
      }
      return _sortAscending ? comparison : -comparison;
    });

    _filteredBooks = filtered;
    notifyListeners();
  }

  /// Delete a book
  Future<bool> deleteBook(String bookId) async {
    try {
      await _bookService.deleteBook(bookId);
      _allBooks.removeWhere((book) => book.id == bookId);
      _applyFiltersAndSort();
      await loadInventoryStats(); // Refresh stats
      return true;
    } catch (e) {
      _error = 'Failed to delete book: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Refresh all data
  Future<void> refresh() async {
    await Future.wait([
      loadBooks(),
      loadInventoryStats(),
      loadGenres(),
    ]);
  }
}
