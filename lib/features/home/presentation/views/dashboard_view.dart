import 'package:flutter/material.dart';
import '../../../../services/book_service.dart';
import '../../../../services/remote_book_service.dart';
import '../../../../shared/utils/mysnackbar.dart';
import '../../../recommendations/presentation/pages/recommended_books_page.dart';
import '../../../scanner/presentation/pages/qr_scanner_page.dart';
import '../../../admin/presentation/pages/admin_dashboard_page.dart';
import 'book_details_page.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final RemoteBookService _remoteBookService = RemoteBookService();
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> books = [];
  List<Map<String, dynamic>> filteredBooks = [];
  List<String> categories = ['All'];

  bool isLoading = true;
  String? errorMessage;
  String selectedCategory = 'All';

  int _gridCount({
    required double width,
    required Orientation orientation,
  }) {
    int count;
    if (width < 380) {
      count = 2; // small phones
    } else if (width < 700) {
      count = 3; // phones
    } else if (width < 1024) {
      count = 4; // tablets
    } else {
      count = 5; // large screens
    }

    if (orientation == Orientation.landscape) count += 1;
    return count;
  }

  double _gridAspectRatio({
    required double width,
    required int crossAxisCount,
    required Orientation orientation,
    double spacing = 12,
  }) {
    // Calculate item width
    final itemWidth = (width - ((crossAxisCount - 1) * spacing)) / crossAxisCount;
    
    // Image takes up ~60% of card height
    final imageHeight = itemWidth / 1.35;
    
    // Content height that adapts - use a more flexible formula
    // This ensures the ratio works for any screen size
    final contentHeight = itemWidth * 1.3;
    
    final itemHeight = imageHeight + contentHeight;
    return itemWidth / itemHeight;
  }

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final fetchedBooks = await _remoteBookService.getBooks();
      final fetchedCategories = fetchedBooks
          .map((book) => (book['section'] ?? 'General').toString())
          .where((section) => section.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

      if (!mounted) return;
      setState(() {
        books = fetchedBooks;
        categories = ['All', ...fetchedCategories];
        isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        books = [];
        filteredBooks = [];
        categories = ['All'];
        isLoading = false;
        errorMessage = null;
      });
    }
  }

  void _applyFilters() {
    final query = searchController.text.trim().toLowerCase();
    setState(() {
      filteredBooks = books.where((book) {
        final title = (book['title'] ?? '').toString().toLowerCase();
        final author = (book['author'] ?? '').toString().toLowerCase();
        final section = (book['section'] ?? '').toString();

        final matchesText =
            query.isEmpty || title.contains(query) || author.contains(query);
        final matchesCategory =
            selectedCategory == 'All' || section == selectedCategory;

        return matchesText && matchesCategory;
      }).toList();
    });
  }

  void _selectCategory(String category) {
    selectedCategory = category;
    _applyFilters();
  }

  Widget _categoryChip(String text) {
    final isSelected = text == selectedCategory;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => _selectCategory(text),
        backgroundColor: Colors.grey.shade100,
        selectedColor: Colors.blue.shade500,
        side: BorderSide(
          color: isSelected ? Colors.blue.shade500 : Colors.transparent,
          width: 2,
        ),
      ),
    );
  }

  void _openScanner() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerPage()),
    );

    if (result != null && mounted) {
      MySnackBar.show(
        context,
        message: 'Scanned: ${result['code']} - Action: ${result['action']}',
        background: Colors.green,
      );
    }
  }

  void _openRecommendations() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RecommendedBooksPage(
          bookType: '',
          course: '',
          className: '',
        ),
      ),
    );
  }

  void _openBookDetails(Map<String, dynamic> book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailsPage(
          bookId: book['id'].toString(),
          title: book['title'].toString(),
          author: book['author'].toString(),
          image: book['image'].toString(),
          section: book['section'].toString(),
          price: (book['price'] as num?)?.toInt() ?? 0,
        ),
      ),
    );
  }

  Future<void> _rentBook(Map<String, dynamic> book) async {
    try {
      await BookService.rentBook(
        id: book['id'].toString(),
        title: book['title'].toString(),
        author: book['author'].toString(),
        price: (book['price'] as num?)?.toInt() ?? 0,
        image: book['image'].toString(),
        section: book['section'].toString(),
        rating: (book['rating'] as num?)?.toDouble() ?? 0.0,
        rentalDays: 30,
      );
      if (mounted) {
        MySnackBar.show(
          context,
          message: '${book['title']} rented successfully',
          background: Colors.green,
        );
      }
    } catch (e) {
      if (mounted) {
        MySnackBar.show(
          context,
          message: e.toString().replaceAll('Exception: ', ''),
          background: Colors.red,
        );
      }
    }
  }

  Future<void> _buyBook(Map<String, dynamic> book) async {
    try {
      await BookService.buyBook(
        id: book['id'].toString(),
        title: book['title'].toString(),
        author: book['author'].toString(),
        price: (book['price'] as num?)?.toInt() ?? 0,
        image: book['image'].toString(),
        section: book['section'].toString(),
        rating: (book['rating'] as num?)?.toDouble() ?? 0.0,
      );
      if (mounted) {
        MySnackBar.show(
          context,
          message: '${book['title']} purchased successfully',
          background: Colors.green,
        );
      }
    } catch (e) {
      if (mounted) {
        MySnackBar.show(
          context,
          message: e.toString().replaceAll('Exception: ', ''),
          background: Colors.red,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LibriFlow Dashboard'),
        centerTitle: true,
        elevation: 2,
        backgroundColor: const Color(0xFF1A73E8),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'Admin Dashboard',
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
            tooltip: 'AI Recommendations',
            onPressed: _openRecommendations,
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan Book',
            onPressed: _openScanner,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadBooks,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade600, Colors.blue.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade200,
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isCompact = constraints.maxWidth < 460;

                        if (isCompact) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.qr_code_scanner,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Quick Book Scan',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Scan QR or barcode to borrow/return',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.95),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _openScanner,
                                  icon: const Icon(Icons.arrow_forward, size: 18),
                                  label: const Text('Scan'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.blue.shade600,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.qr_code_scanner,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Quick Book Scan',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Scan QR or barcode to borrow/return',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.95),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _openScanner,
                              icon: const Icon(Icons.arrow_forward, size: 18),
                              label: const Text('Scan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.blue.shade600,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (_) => _applyFilters(),
                      decoration: InputDecoration(
                        hintText: 'Search books, authors...',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        prefixIcon:
                            const Icon(Icons.search, color: Color(0xFF1A73E8)),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  searchController.clear();
                                  _applyFilters();
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF1A73E8),
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          const SizedBox(width: 4),
                          ...categories.map(_categoryChip),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (errorMessage != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              )
            else if (filteredBooks.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    books.isEmpty
                        ? 'No books available in your database yet'
                        : 'No books found for current filter',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              )
            else
              SliverLayoutBuilder(
                builder: (context, constraints) {
                  const spacing = 12.0;
                  final orientation = MediaQuery.of(context).orientation;
                  final width = constraints.crossAxisExtent;
                  final crossCount = _gridCount(
                    width: width,
                    orientation: orientation,
                  );
                  final ratio = _gridAspectRatio(
                    width: width,
                    crossAxisCount: crossCount,
                    orientation: orientation,
                    spacing: spacing,
                  );

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossCount,
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                        childAspectRatio: ratio,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildBookCard(filteredBooks[index]),
                        childCount: filteredBooks.length,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookCard(Map<String, dynamic> book) {
    return Material(
      child: InkWell(
        onTap: () => _openBookDetails(book),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(14)),
                    child: AspectRatio(
                      aspectRatio: 1.35,
                      child: _buildImage(book['image'].toString()),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade500,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        (book['section'] ?? 'General').toString(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        (book['title'] ?? 'Unknown Title').toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        (book['author'] ?? 'Unknown Author').toString(),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 13, color: Colors.amber),
                          const SizedBox(width: 3),
                          Text(
                            ((book['rating'] as num?)?.toDouble() ?? 0.0)
                                .toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '\$${(book['price'] as num?)?.toInt() ?? 0}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _rentBook(book),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade500,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: const Text(
                                'Rent',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _buyBook(book),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue.shade500,
                                side: BorderSide(color: Colors.blue.shade200),
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: const Text(
                                'Buy',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String image) {
    Widget fallback() => Container(
          color: Colors.grey.shade200,
          alignment: Alignment.center,
          child: const Icon(Icons.menu_book, size: 40, color: Colors.grey),
        );

    if (image.isEmpty) return fallback();

    if (image.startsWith('http')) {
      return Image.network(
        image,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    }

    return Image.asset(
      image,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback(),
    );
  }
}