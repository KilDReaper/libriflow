import 'package:flutter/material.dart';
import '../../../reservations/presentation/pages/my_reservations_page.dart';

class LibraryView extends StatefulWidget {
  const LibraryView({super.key});

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  final List<Map<String, dynamic>> rentedBooks = [
    {
      "title": "The Art of War",
      "image": "https://picsum.photos/200?random=1",
      "author": "Sun Tzu",
      "daysLeft": 12,
      "totalDays": 30
    },
    {
      "title": "Atomic Habits",
      "image": "https://picsum.photos/200?random=2",
      "author": "James Clear",
      "daysLeft": 5,
      "totalDays": 21
    },
    {
      "title": "Deep Work",
      "image": "https://picsum.photos/200?random=3",
      "author": "Cal Newport",
      "daysLeft": 20,
      "totalDays": 30
    },
  ];

  final List<Map<String, dynamic>> purchasedBooks = [
    {
      "title": "Harry Potter",
      "image": "https://picsum.photos/200?random=4",
      "author": "J.K. Rowling",
      "purchaseDate": "Jan 15, 2024"
    },
    {
      "title": "Rich Dad Poor Dad",
      "image": "https://picsum.photos/200?random=5",
      "author": "Robert Kiyosaki",
      "purchaseDate": "Feb 3, 2024"
    },
    {
      "title": "The Hobbit",
      "image": "https://picsum.photos/200?random=6",
      "author": "J.R.R. Tolkien",
      "purchaseDate": "Dec 20, 2023"
    },
  ];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  Widget buildBookGrid(List<Map<String, dynamic>> books, BuildContext context, {bool isRented = true}) {
    final width = MediaQuery.of(context).size.width;

    final crossCount = width > 1000
        ? 5
        : width > 800
            ? 4
            : width > 600
                ? 3
                : 2;

    if (books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isRented ? Icons.library_books : Icons.shopping_bag_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              isRented ? 'No rented books' : 'No purchased books',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isRented ? 'Start renting books from the dashboard' : 'Start purchasing books from the dashboard',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

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
        return _buildLibraryBookCard(book, isRented);
      },
    );
  }

  Widget _buildLibraryBookCard(Map<String, dynamic> book, bool isRented) {
    final daysLeft = isRented ? (book["daysLeft"] as int?) ?? 0 : 0;
    final totalDays = isRented ? (book["totalDays"] as int?) ?? 30 : 30;
    
    return Material(
      child: InkWell(
        onTap: () {},
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
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    child: Image.network(
                      book["image"] ?? "https://picsum.photos/200",
                      fit: BoxFit.cover,
                      height: 150,
                    ),
                  ),
                  if (isRented && daysLeft > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: daysLeft <= 5
                              ? Colors.red.shade500
                              : Colors.green.shade500,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$daysLeft days',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
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
                        book["title"] ?? "Unknown Book",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
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
                      const Spacer(),
                      if (isRented && daysLeft > 0 && totalDays > 0)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: daysLeft / totalDays,
                                minHeight: 6,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  daysLeft <= 5 ? Colors.red.shade500 : Colors.blue.shade400,
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          'Purchased: ${book["purchaseDate"] ?? "N/A"}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Library"),
        elevation: 2,
        backgroundColor: const Color(0xFF1A73E8),
        actions: [
          IconButton(
            icon: const Icon(Icons.event_note),
            tooltip: 'My Reservations',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MyReservationsPage(),
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: tabController,
              labelColor: const Color(0xFF1A73E8),
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: const Color(0xFF1A73E8),
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.library_books, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        "Rented (${rentedBooks.length})",
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        "Purchased (${purchasedBooks.length})",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          buildBookGrid(rentedBooks, context, isRented: true),
          buildBookGrid(purchasedBooks, context, isRented: false),
        ],
      ),
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }
}
