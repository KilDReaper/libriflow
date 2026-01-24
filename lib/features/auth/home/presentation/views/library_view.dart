import 'package:flutter/material.dart';

class LibraryView extends StatefulWidget {
  const LibraryView({super.key});

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  final List<Map<String, dynamic>> rentedBooks = [
    {"title": "The Art of War", "image": "https://picsum.photos/200?random=1"},
    {"title": "Atomic Habits", "image": "https://picsum.photos/200?random=2"},
    {"title": "Deep Work", "image": "https://picsum.photos/200?random=3"},
  ];

  final List<Map<String, dynamic>> purchasedBooks = [
    {"title": "Harry Potter", "image": "https://picsum.photos/200?random=4"},
    {"title": "Rich Dad Poor Dad", "image": "https://picsum.photos/200?random=5"},
    {"title": "The Hobbit", "image": "https://picsum.photos/200?random=6"},
  ];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  Widget buildBookGrid(List<Map<String, dynamic>> books, BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final crossCount = width > 1000
        ? 5
        : width > 800
            ? 4
            : width > 600
                ? 3
                : 2;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: books.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.65,
      ),
      itemBuilder: (context, index) {
        final book = books[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                spreadRadius: 2,
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  child: Image.network(
                    book["image"],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  book["title"],
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Library"),
        bottom: TabBar(
          controller: tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "Rented"),
            Tab(text: "Purchased"),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          buildBookGrid(rentedBooks, context),
          buildBookGrid(purchasedBooks, context),
        ],
      ),
    );
  }
}
