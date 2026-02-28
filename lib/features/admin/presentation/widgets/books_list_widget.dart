import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_books_provider.dart';
import '../../data/models/admin_book_model.dart';

class BooksListWidget extends StatelessWidget {
  final Function(AdminBookModel) onBookTap;

  const BooksListWidget({
    super.key,
    required this.onBookTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminBooksProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading books...'),
              ],
            ),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  provider.error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => provider.loadBooks(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.paginatedBooks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.book_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No books found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try adjusting your filters',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Books Grid/Table
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 900) {
                    // Table view for larger screens
                    return _BooksTable(
                      books: provider.paginatedBooks,
                      onBookTap: onBookTap,
                      onDelete: (book) => _confirmDelete(context, provider, book),
                    );
                  } else {
                    // Card grid for smaller screens
                    return _BooksGrid(
                      books: provider.paginatedBooks,
                      onBookTap: onBookTap,
                      onDelete: (book) => _confirmDelete(context, provider, book),
                    );
                  }
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Pagination
            _PaginationControls(),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AdminBooksProvider provider,
    AdminBookModel book,
  ) async {
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
  }
}

// Books Table for Desktop
class _BooksTable extends StatelessWidget {
  final List<AdminBookModel> books;
  final Function(AdminBookModel) onBookTap;
  final Function(AdminBookModel) onDelete;

  const _BooksTable({
    required this.books,
    required this.onBookTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          showCheckboxColumn: false,
          columns: const [
            DataColumn(label: Text('Cover')),
            DataColumn(label: Text('Title')),
            DataColumn(label: Text('Author')),
            DataColumn(label: Text('Genre')),
            DataColumn(label: Text('Price')),
            DataColumn(label: Text('Stock')),
            DataColumn(label: Text('Available')),
            DataColumn(label: Text('Rating')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: books.map((book) {
            return DataRow(
              onSelectChanged: (_) => onBookTap(book),
              cells: [
                DataCell(
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      book.image,
                      width: 40,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 40,
                        height: 56,
                        color: Colors.grey[300],
                        child: const Icon(Icons.book, size: 24),
                      ),
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 200,
                    child: Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(Text(book.author)),
                DataCell(
                  Wrap(
                    spacing: 4,
                    children: book.genres.take(2).map((genre) {
                      return Chip(
                        label: Text(
                          genre,
                          style: const TextStyle(fontSize: 11),
                        ),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                ),
                DataCell(Text('₹${book.price}')),
                DataCell(Text('${book.stockQuantity}')),
                DataCell(Text('${book.availableQuantity}')),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(book.rating.toStringAsFixed(1)),
                    ],
                  ),
                ),
                DataCell(_StatusBadge(status: book.status)),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, size: 20),
                        tooltip: 'View',
                        onPressed: () => onBookTap(book),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        tooltip: 'Delete',
                        color: Colors.red,
                        onPressed: () => onDelete(book),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// Books Grid for Mobile/Tablet
class _BooksGrid extends StatelessWidget {
  final List<AdminBookModel> books;
  final Function(AdminBookModel) onBookTap;
  final Function(AdminBookModel) onDelete;

  const _BooksGrid({
    required this.books,
    required this.onBookTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return _BookCard(
          book: book,
          onTap: () => onBookTap(book),
          onDelete: () => onDelete(book),
        );
      },
    );
  }
}

class _BookCard extends StatelessWidget {
  final AdminBookModel book;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _BookCard({
    required this.book,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  book.image,
                  width: 60,
                  height: 84,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 60,
                    height: 84,
                    color: Colors.grey[300],
                    child: const Icon(Icons.book, size: 32),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Book Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          book.author,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            ...book.genres.take(2).map((genre) => Chip(
                              label: Text(
                                genre,
                                style: const TextStyle(fontSize: 10),
                              ),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            )),
                            _StatusBadge(status: book.status),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${book.price}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF1A73E8),
                              ),
                            ),
                            Text(
                              'Stock: ${book.availableQuantity}/${book.stockQuantity}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.star, size: 16, color: Colors.amber),
                                const SizedBox(width: 2),
                                Text(book.rating.toStringAsFixed(1)),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20),
                              color: Colors.red,
                              onPressed: onDelete,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    
    switch (status.toLowerCase()) {
      case 'available':
        color = Colors.green;
        label = 'Available';
        break;
      case 'out_of_stock':
        color = Colors.orange;
        label = 'Out of Stock';
        break;
      case 'discontinued':
        color = Colors.red;
        label = 'Discontinued';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PaginationControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AdminBooksProvider>(
      builder: (context, provider, child) {
        if (provider.totalPages <= 1) {
          return const SizedBox.shrink();
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.first_page),
              onPressed: provider.currentPage > 1
                  ? () => provider.goToPage(1)
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: provider.currentPage > 1
                  ? provider.previousPage
                  : null,
            ),
            ...List.generate(
              provider.totalPages > 5 ? 5 : provider.totalPages,
              (index) {
                int pageNumber;
                if (provider.totalPages <= 5) {
                  pageNumber = index + 1;
                } else if (provider.currentPage <= 3) {
                  pageNumber = index + 1;
                } else if (provider.currentPage >= provider.totalPages - 2) {
                  pageNumber = provider.totalPages - 4 + index;
                } else {
                  pageNumber = provider.currentPage - 2 + index;
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () => provider.goToPage(pageNumber),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: provider.currentPage == pageNumber
                            ? const Color(0xFF1A73E8)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$pageNumber',
                        style: TextStyle(
                          color: provider.currentPage == pageNumber
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: provider.currentPage == pageNumber
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: provider.currentPage < provider.totalPages
                  ? provider.nextPage
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.last_page),
              onPressed: provider.currentPage < provider.totalPages
                  ? () => provider.goToPage(provider.totalPages)
                  : null,
            ),
          ],
        );
      },
    );
  }
}
