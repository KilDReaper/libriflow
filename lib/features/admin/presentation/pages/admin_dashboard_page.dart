import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_books_provider.dart';
import '../widgets/inventory_stats_widget.dart';
import '../widgets/search_and_filter_widget.dart';
import '../widgets/books_list_widget.dart';
import '../widgets/book_details_drawer.dart';
import '../../data/models/admin_book_model.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = context.read<AdminBooksProvider>();
    await provider.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Dashboard'),
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Add book feature coming soon'),
                ),
              );
            },
            tooltip: 'Add Book',
          ),
        ],
      ),
      body: Consumer<AdminBooksProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: _loadData,
            child: CustomScrollView(
              slivers: [
                // Stats Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Inventory Overview',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const InventoryStatsWidget(),
                      ],
                    ),
                  ),
                ),

                // Divider
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 32),
                  ),
                ),

                // Books Section Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Books Catalog',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const SearchAndFilterWidget(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Books List
                SliverFillRemaining(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: BooksListWidget(
                      onBookTap: (book) => _showBookDetails(context, book),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showBookDetails(BuildContext context, AdminBookModel book) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Book Details',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return BookDetailsDrawer(
          book: book,
          onEdit: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Edit book feature coming soon'),
              ),
            );
          },
          onDelete: () async {
            Navigator.pop(context);
            final provider = context.read<AdminBooksProvider>();
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Book'),
                content: Text('Are you sure you want to delete "${book.title}"?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );

            if (confirm == true && context.mounted) {
              final success = await provider.deleteBook(book.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Book deleted successfully'
                          : 'Failed to delete book',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            }
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );
      },
    );
  }
}
