import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../services/book_service.dart';
import '../../../../shared/utils/image_url_resolver.dart';
import '../../data/models/book_model.dart';
import '../../../reservations/presentation/pages/my_reservations_page.dart';

class LibraryView extends StatefulWidget {
  const LibraryView({super.key});

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  List<BookModel> rentedBooks = [];
  List<BookModel> purchasedBooks = [];
  bool isLoading = true;

  double _libraryGridRatio(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = MediaQuery.textScalerOf(context).scale(1.0);

    if (size.width < 360 || scale >= 1.2) {
      return 0.48;
    }
    if (size.width < 430) {
      return 0.5;
    }
    return 0.52;
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() => isLoading = true);
    try {
      final rented = await BookService.getRentedBooks();
      final purchased = await BookService.getPurchasedBooks();
      setState(() {
        rentedBooks = rented;
        purchasedBooks = purchased;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading books: $e')),
        );
      }
    }
  }

  Widget buildBookGrid(List<BookModel> books, BuildContext context, {bool isRented = true}) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 170,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        // Dynamic tile height improves resilience across device sizes/text scales.
        childAspectRatio: _libraryGridRatio(context),
      ),
      itemBuilder: (context, index) {
        final book = books[index];
        return _buildLibraryBookCard(book, isRented);
      },
    );
  }

  Widget _buildLibraryBookCard(BookModel book, bool isRented) {
    final daysLeft = isRented ? book.daysLeft : 0;
    final totalDays = isRented ? (book.rentalDays ?? 30) : 30;
    final purchaseDate = !isRented ? DateFormat('MMM dd, yyyy').format(book.transactionDate) : '';
    final safeImage = resolveBookImageUrl(book.image);
    final useNetworkImage = isNetworkImageUrl(safeImage);
    
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
                    child: useNetworkImage
                        ? Image.network(
                            safeImage,
                            fit: BoxFit.cover,
                            height: 138,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 138,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.book, size: 50),
                              );
                            },
                          )
                        : Image.asset(
                          safeImage,
                            fit: BoxFit.cover,
                            height: 138,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 138,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.book, size: 50),
                              );
                            },
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
                  padding: const EdgeInsets.all(10),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final scale = MediaQuery.textScalerOf(context).scale(1.0);
                      final compact = constraints.maxHeight < 130 || scale > 1.15;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            book.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: compact ? 12 : 13,
                              height: 1.2,
                            ),
                            maxLines: compact ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            book.author,
                            style: TextStyle(
                              fontSize: compact ? 10 : 11,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          if (isRented && daysLeft > 0 && totalDays > 0)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: daysLeft / totalDays,
                                minHeight: compact ? 4 : 5,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  daysLeft <= 5
                                      ? Colors.red.shade500
                                      : Colors.blue.shade400,
                                ),
                              ),
                            )
                          else
                            Text(
                              'Purchased: $purchaseDate',
                              style: TextStyle(
                                fontSize: compact ? 9 : 10,
                                color: Colors.grey.shade500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      );
                    },
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
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadBooks,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear All Books',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear All Books'),
                  content: const Text('Are you sure you want to clear all books from your library?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await BookService.clearAllBooks();
                        _loadBooks();
                        if (mounted) Navigator.pop(context);
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
            },
          ),
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
          RefreshIndicator(
            onRefresh: _loadBooks,
            child: buildBookGrid(rentedBooks, context, isRented: true),
          ),
          RefreshIndicator(
            onRefresh: _loadBooks,
            child: buildBookGrid(purchasedBooks, context, isRented: false),
          ),
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
