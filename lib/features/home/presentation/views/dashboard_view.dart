import 'package:flutter/material.dart';
import '../../../../shared/utils/mysnackbar.dart';
import '../../../scanner/presentation/pages/qr_scanner_page.dart';
import '../../../recommendations/presentation/pages/recommended_books_page.dart';
import 'book_details_page.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> books = [
    {
      "id": "507f1f77bcf86cd799439011",
      "title": "Clean Code",
      "author": "Robert C. Martin",
      "price": 15,
      "image": "assets/images/clean_code.png",
      "section": "Programming",
      "rating": 4.8
    },
    {
      "id": "507f1f77bcf86cd799439012",
      "title": "Atomic Habits",
      "author": "James Clear",
      "price": 10,
      "image": "assets/images/atomic_habits.png",
      "section": "Self-help",
      "rating": 4.9
    },
    {
      "id": "507f1f77bcf86cd799439013",
      "title": "Flutter Basics",
      "author": "Google",
      "price": 12,
      "image": "assets/images/flutter_basics.png",
      "section": "Technology",
      "rating": 4.6
    },
    {
      "id": "507f1f77bcf86cd799439014",
      "title": "AI for Beginners",
      "author": "Andrew Ng",
      "price": 20,
      "image": "assets/images/ai_for_beginners.png",
      "section": "Artificial Intelligence",
      "rating": 4.7
    },
  ];

  late List<Map<String, dynamic>> filteredBooks;

  final List<String> categories = [
    "All",
    "Programming",
    "Self-help",
    "AI",
    "Technology",
  ];

  String selectedCategory = "All";

  @override
  void initState() {
    super.initState();
    filteredBooks = List.from(books);
  }

  void searchBook(String query) {
    setState(() {
      filteredBooks = books.where((book) {
        final matchQuery = book["title"]
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            book["author"]
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase());
        final matchCategory = selectedCategory == "All"
            ? true
            : book["section"] == selectedCategory;
        return matchQuery && matchCategory;
      }).toList();
    });
  }

  void selectCategory(String category) {
    setState(() {
      selectedCategory = category;
      searchBook(searchController.text);
    });
  }

  Widget _categoryChip(String text) {
    final isSelected = text == selectedCategory;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          text,
          style: TextStyle(
            fontFamily: "OpenSans",
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => selectCategory(text),
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
        message: "Scanned: ${result['code']} - Action: ${result['action']}",
        background: Colors.green,
      );
    }
  }

  void _openRecommendations() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RecommendedBooksPage(),
      ),
    );
  }

  void _openBookDetails(Map<String, dynamic> book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailsPage(
          bookId: book["id"].toString(),
          title: book["title"].toString(),
          author: book["author"].toString(),
          image: book["image"].toString(),
          section: book["section"].toString(),
          price: book["price"] as int,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final crossCount = screenWidth > 1000
        ? 5
        : screenWidth > 800
            ? 4
            : screenWidth > 600
                ? 3
                : 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text("LibriFlow Dashboard"),
        centerTitle: true,
        elevation: 2,
        backgroundColor: const Color(0xFF1A73E8),
        actions: [
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
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Quick Scan Banner
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
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 32),
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
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {});
                          searchBook(value);
                        },
                        decoration: InputDecoration(
                          hintText: "Search books, authors...",
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF1A73E8)),
                          suffixIcon: searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    searchController.clear();
                                    setState(() {});
                                    searchBook('');
                                  },
                                )
                              : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 2),
                      ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      );
                    },
                  ),
                ),
                // Category Filter
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const SizedBox(width: 4),
                        ...categories.map(_categoryChip).toList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.62,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final book = filteredBooks[index];
                  return _buildBookCard(book);
                },
                childCount: filteredBooks.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: filteredBooks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.book_outlined, size: 80, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'No books found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your search or filters',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
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
              // Category Badge
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    child: Image.asset(
                      book["image"] ?? "assets/images/placeholder.png",
                      height: 130,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade500,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        book["section"] ?? "General",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book["title"] ?? "Unknown Title",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book["author"] ?? "Unknown Author",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '${book["rating"] ?? 0.0}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "\$${book["price"] ?? 0}",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.favorite_border,
                              size: 16,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                MySnackBar.show(
                                  context,
                                  message: "${book["title"] ?? "Book"} rented successfully",
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade500,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                "Rent",
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                MySnackBar.show(
                                  context,
                                  message: "${book["title"] ?? "Book"} purchased successfully",
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue.shade500,
                                side: BorderSide(color: Colors.blue.shade200),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                "Buy",
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
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
}
