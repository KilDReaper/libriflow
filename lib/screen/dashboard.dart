import 'package:flutter/material.dart';
import '/common/mysnackbar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> books = [
    {"title": "Clean Code", "author": "Robert C. Martin", "price": 15},
    {"title": "Atomic Habits", "author": "James Clear", "price": 10},
    {"title": "Flutter Basics", "author": "Google", "price": 12},
    {"title": "AI for Beginners", "author": "Andrew Ng", "price": 20},
  ];

  List<Map<String, dynamic>> filteredBooks = [];

  @override
  void initState() {
    filteredBooks = books;
    super.initState();
  }

  void searchBook(String query) {
    setState(() {
      filteredBooks = books
          .where((book) =>
              book["title"].toLowerCase().contains(query.toLowerCase()) ||
              book["author"].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("LibriFlow Dashboard"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              onChanged: searchBook,
              decoration: InputDecoration(
                hintText: "Search books",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: filteredBooks.length,
              itemBuilder: (context, index) {
                final book = filteredBooks[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Center(
                            child: Icon(
                              Icons.book,
                              size: 60,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        Text(
                          book["title"],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          book["author"],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "\$${book["price"]}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  MySnackBar.show(
                                    context,
                                    message:
                                        "${book["title"]} rented successfully",
                                    // background: Colors.green,
                                  );
                                },
                                child: const Text("Rent"),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  MySnackBar.show(
                                    context,
                                    message:
                                        "${book["title"]} purchased successfully",
                                  );
                                },
                                child: const Text("Buy"),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
