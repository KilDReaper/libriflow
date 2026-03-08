import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../services/remote_book_service.dart';
import '../../../../shared/utils/image_url_resolver.dart';
import '../../../recommendations/presentation/pages/recommended_books_page.dart';
import 'book_details_page.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final RemoteBookService _bookService = RemoteBookService();
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;
  String searchText = "";
  String selectedCategory = 'All';
  bool isLoading = false;
  String? errorMessage;
  List<Map<String, dynamic>> books = [];

  List<String> categories = ['All'];

  @override
  void initState() {
    super.initState();
    _searchBooks();
  }

  Future<void> _searchBooks() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final fetchedBooks = await _bookService.getBooks(
        search: searchText.trim().isEmpty ? null : searchText,
        category: selectedCategory,
        includeGoogleBooks: true,
      );

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
    } catch (e) {
      if (!mounted) return;
      setState(() {
        books = [];
        categories = ['All'];
        isLoading = false;
        errorMessage = null;
      });
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchText = value;
    });

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      _searchBooks();
    });
  }

  void _searchByCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
    _searchBooks();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Books"),
        elevation: 2,
        backgroundColor: const Color(0xFF1A73E8),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            tooltip: 'AI Recommendations',
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
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade200,
              ),
              child: TextField(
                controller: searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: "Search books...",
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _debounce?.cancel();
                      searchController.clear();
                      setState(() {
                        searchText = "";
                      });
                      _searchBooks();
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Categories
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: categories
                    .map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: Text(
                            c,
                            style: TextStyle(
                              color: selectedCategory == c ? Colors.white : Colors.blue.shade900,
                              fontWeight: selectedCategory == c ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          backgroundColor: selectedCategory == c 
                              ? const Color(0xFF1A73E8) 
                              : Colors.blue.shade50,
                          onPressed: () => _searchByCategory(c),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Books Grid
            Expanded(
              child: _buildBodyContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Text(
          errorMessage!,
          style: const TextStyle(fontSize: 14),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (books.isEmpty) {
      return Center(
        child: Text(
          searchText.trim().isEmpty
              ? 'No books available in your database yet'
              : 'No books found',
          style: const TextStyle(fontSize: 16),
        ),
      );
    }

    return GridView.builder(
      itemCount: books.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 170,
        childAspectRatio: 0.52,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final book = books[index];
        return InkWell(
          onTap: () {
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
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 5,
                  spreadRadius: 1,
                  color: Colors.black.withOpacity(0.05),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildBookImage(book['image'].toString()),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  book['title'].toString(),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  book['author'].toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookImage(String imageUrl) {
    final safeImageUrl = resolveBookImageUrl(imageUrl);

    if (safeImageUrl.isEmpty) {
      return Container(
        height: 180,
        width: double.infinity,
        color: Colors.grey.shade200,
        child: const Icon(Icons.menu_book, size: 40),
      );
    }

    if (!isNetworkImageUrl(safeImageUrl)) {
      return Image.asset(
        safeImageUrl,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 180,
            width: double.infinity,
            color: Colors.grey.shade200,
            child: const Icon(Icons.menu_book, size: 40),
          );
        },
      );
    }

    return Image.network(
      safeImageUrl,
      height: 180,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 180,
          width: double.infinity,
          color: Colors.grey.shade200,
          child: const Icon(Icons.menu_book, size: 40),
        );
      },
    );
  }
}
