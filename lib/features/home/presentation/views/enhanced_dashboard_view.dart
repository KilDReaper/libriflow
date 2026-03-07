import 'package:flutter/material.dart';
import '../../../../services/remote_book_service.dart';
import '../../../../shared/utils/mysnackbar.dart';
import '../widgets/featured_books_carousel.dart';
import '../widgets/book_card_widget.dart';
import '../widgets/search_and_filter_bar.dart';
import '../pages/enhanced_book_details_page.dart';
import '../../../recommendations/presentation/pages/recommended_books_page.dart';
import '../../../scanner/presentation/pages/qr_scanner_page.dart';
import '../../../admin/presentation/pages/admin_dashboard_page.dart';

class EnhancedDashboardView extends StatefulWidget {
  const EnhancedDashboardView({super.key});

  @override
  State<EnhancedDashboardView> createState() => _EnhancedDashboardViewState();
}

class _EnhancedDashboardViewState extends State<EnhancedDashboardView>
    with AutomaticKeepAliveClientMixin {
  final RemoteBookService _bookService = RemoteBookService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _allBooks = [];
  List<Map<String, dynamic>> _filteredBooks = [];
  List<Map<String, dynamic>> _newArrivals = [];
  List<Map<String, dynamic>> _trending = [];
  List<Map<String, dynamic>> _available = [];

  List<String> _genres = ['All'];
  String _selectedGenre = 'All';
  String _sortBy = 'title';
  String _searchQuery = '';

  bool _isLoading = true;
  bool _showBackToTop = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 500 && !_showBackToTop) {
      setState(() => _showBackToTop = true);
    } else if (_scrollController.offset <= 500 && _showBackToTop) {
      setState(() => _showBackToTop = false);
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _loadBooks() async {
    setState(() => _isLoading = true);

    try {
      final books = await _bookService.getBooks();
      
      // Extract genres
      final genresSet = books
          .map((book) => book['section']?.toString() ?? 'General')
          .where((section) => section.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

      // Sort for featured sections
      final sortedByRating = List<Map<String, dynamic>>.from(books)
        ..sort((a, b) {
          final ratingA = (a['rating'] as num?)?.toDouble() ?? 0.0;
          final ratingB = (b['rating'] as num?)?.toDouble() ?? 0.0;
          return ratingB.compareTo(ratingA);
        });

      if (!mounted) return;
      setState(() {
        _allBooks = books;
        _genres = ['All', ...genresSet];
        _newArrivals = books.take(10).toList(); // First 10 as new
        _trending = sortedByRating.take(10).toList(); // Top rated
        _available = books.where((b) => true).take(10).toList(); // Available
        _isLoading = false;
      });
      _applyFiltersAndSort();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _allBooks = [];
        _isLoading = false;
      });
      MySnackBar.show(
        context,
        message: 'Failed to load books',
        background: Colors.red,
      );
    }
  }

  void _applyFiltersAndSort() {
    var filtered = List<Map<String, dynamic>>.from(_allBooks);

    // Apply search
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((book) {
        final title = book['title']?.toString().toLowerCase() ?? '';
        final author = book['author']?.toString().toLowerCase() ?? '';
        return title.contains(query) || author.contains(query);
      }).toList();
    }

    // Apply genre filter
    if (_selectedGenre != 'All') {
      filtered = filtered.where((book) {
        final section = book['section']?.toString() ?? '';
        return section == _selectedGenre;
      }).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'title':
        filtered.sort((a, b) {
          final titleA = a['title']?.toString() ?? '';
          final titleB = b['title']?.toString() ?? '';
          return titleA.compareTo(titleB);
        });
        break;
      case 'author':
        filtered.sort((a, b) {
          final authorA = a['author']?.toString() ?? '';
          final authorB = b['author']?.toString() ?? '';
          return authorA.compareTo(authorB);
        });
        break;
      case 'rating':
        filtered.sort((a, b) {
          final ratingA = (a['rating'] as num?)?.toDouble() ?? 0.0;
          final ratingB = (b['rating'] as num?)?.toDouble() ?? 0.0;
          return ratingB.compareTo(ratingA);
        });
        break;
      case 'price':
        filtered.sort((a, b) {
          final priceA = (a['price'] as num?)?.toInt() ?? 0;
          final priceB = (b['price'] as num?)?.toInt() ?? 0;
          return priceA.compareTo(priceB);
        });
        break;
      case 'newest':
        // Keep original order for newest
        break;
    }

    setState(() => _filteredBooks = filtered);
  }

  void _openBookDetails(Map<String, dynamic> book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnhancedBookDetailsPage(book: book),
      ),
    );
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _selectedGenre = 'All';
      _sortBy = 'title';
    });
    _applyFiltersAndSort();
  }

  bool get _hasActiveFilters =>
      _searchQuery.isNotEmpty || _selectedGenre != 'All' || _sortBy != 'title';

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LibriFlow'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF1A73E8),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminDashboardPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecommendedBooksPage(
                    bookType: '',
                    course: '',
                    className: '',
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QRScannerPage(),
                ),
              );
              if (result != null && mounted) {
                MySnackBar.show(
                  context,
                  message: 'Scanned: ${result['code']}',
                  background: Colors.green,
                );
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadBooks,
        child: _isLoading
            ? _buildLoadingSkeleton()
            : CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // Search and Filters
                  SliverToBoxAdapter(
                    child: SearchAndFilterBar(
                      searchController: _searchController,
                      onSearchChanged: (value) {
                        setState(() => _searchQuery = value);
                        _applyFiltersAndSort();
                      },
                      genres: _genres,
                      selectedGenre: _selectedGenre,
                      onGenreChanged: (value) {
                        setState(() => _selectedGenre = value);
                        _applyFiltersAndSort();
                      },
                      sortBy: _sortBy,
                      onSortChanged: (value) {
                        setState(() => _sortBy = value);
                        _applyFiltersAndSort();
                      },
                      onClearFilters: _clearFilters,
                      hasActiveFilters: _hasActiveFilters,
                    ),
                  ),

                  // Featured Sections (only show when no filters active)
                  if (!_hasActiveFilters) ...[
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    
                    // New Arrivals
                    SliverToBoxAdapter(
                      child: FeaturedBooksCarousel(
                        title: '📚 New Arrivals',
                        books: _newArrivals,
                        onBookTap: _openBookDetails,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),

                    // Trending Now
                    SliverToBoxAdapter(
                      child: FeaturedBooksCarousel(
                        title: '🔥 Trending Now',
                        books: _trending,
                        onBookTap: _openBookDetails,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),

                    // Available Now
                    SliverToBoxAdapter(
                      child: FeaturedBooksCarousel(
                        title: '✨ Available Now',
                        books: _available,
                        onBookTap: _openBookDetails,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ],

                  // All Books Section Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _hasActiveFilters ? 'Search Results' : 'All Books',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_filteredBooks.length} books',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Books Grid
                  _filteredBooks.isEmpty
                      ? SliverFillRemaining(
                          child: _buildEmptyState(),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 170,
                              // Taller cards avoid RenderFlex overflows in tight heights.
                              childAspectRatio: 0.52,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final book = _filteredBooks[index];
                                return BookCardWidget(
                                  id: book['id']?.toString() ?? '',
                                  title: book['title']?.toString() ?? 'Untitled',
                                  author:
                                      book['author']?.toString() ?? 'Unknown',
                                  image: book['image']?.toString() ?? '',
                                  genre:
                                      book['section']?.toString() ?? 'General',
                                  price: (book['price'] as num?)?.toInt() ?? 0,
                                  rating:
                                      (book['rating'] as num?)?.toDouble() ??
                                          0.0,
                                  availableQuantity: 5, // Default
                                  onTap: () => _openBookDetails(book),
                                  onReserve: () {
                                    MySnackBar.show(
                                      context,
                                      message: 'Reserved ${book['title']}',
                                      background: Colors.green,
                                    );
                                  },
                                );
                              },
                              childCount: _filteredBooks.length,
                            ),
                          ),
                        ),

                  // Bottom padding
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
      ),
      floatingActionButton: _showBackToTop
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              backgroundColor: const Color(0xFF1A73E8),
              child: const Icon(Icons.arrow_upward),
            )
          : null,
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 80),
        const Text(
          'Loading books...',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 170,
            childAspectRatio: 0.52,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: 6,
          itemBuilder: (context, index) => const BookCardSkeleton(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No books found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _clearFilters,
            icon: const Icon(Icons.refresh),
            label: const Text('Clear Filters'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A73E8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
