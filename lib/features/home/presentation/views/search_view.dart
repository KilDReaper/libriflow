import 'package:flutter/material.dart';
import '../../../recommendations/presentation/pages/recommended_books_page.dart';
import 'book_details_page.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController searchController = TextEditingController();
  String searchText = "";

  final List<String> categories = [
    "Fiction",
    "Sci-Fi",
    "Romance",
    "Programming",
    "History",
    "Horror",
  ];

  final List<Map<String, dynamic>> books = [
    {
      "id": "flutter-for-beginners",
      "title": "Flutter for Beginners",
      "author": "John Adams",
      "image":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ855e1EnC0jUgGQbFetgA1Kvwog6HQf2lfkA&s"
    },
    {
      "id": "data-structures-python",
      "title": "Data Structures in Python",
      "author": "Emily Clark",
      "image": "https://picsum.photos/200"
    },
    {
      "id": "silent-patient",
      "title": "The Silent Patient",
      "author": "Alex Michaelides",
      "image":
          "https://static.wixstatic.com/media/b077d4_c764f44d42d840a29ae3ea49155d50de~mv2.jpg"
    },
  ];

  List<Map<String, dynamic>> get filteredBooks {
    return books
        .where((b) =>
            b["title"].toLowerCase().contains(searchText.toLowerCase()))
        .toList();
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
                  builder: (context) => const RecommendedBooksPage(),
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
                onChanged: (v) {
                  setState(() {
                    searchText = v;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search books...",
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      searchController.clear();
                      setState(() {
                        searchText = "";
                      });
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
                        child: Chip(
                          label: Text(c),
                          backgroundColor: Colors.blue.shade50,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Books Grid
            Expanded(
              child: searchText.isEmpty
                  ? const Center(
                      child: Text(
                        "Search any book to begin",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : GridView.builder(
                      itemCount: filteredBooks.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemBuilder: (context, index) {
                        final book = filteredBooks[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookDetailsPage(
                                  bookId: book["id"].toString(),
                                  title: book["title"].toString(),
                                  author: book["author"].toString(),
                                  image: book["image"].toString(),
                                  section: "General",
                                  price: 0,
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
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    book["image"],
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  book["title"],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  book["author"],
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
