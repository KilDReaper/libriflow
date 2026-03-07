import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:libriflow/features/admin/data/models/admin_book_model.dart';

class BookDetailsDrawer extends StatelessWidget {
  final AdminBookModel book;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BookDetailsDrawer({
    super.key,
    required this.book,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width > 600 ? 500 : double.infinity,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF1A73E8),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Book Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (onEdit != null)
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: onEdit,
                      tooltip: 'Edit',
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: onDelete,
                      tooltip: 'Delete',
                    ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cover Image
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          book.image,
                          width: 200,
                          height: 280,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 200,
                            height: 280,
                            color: Colors.grey[300],
                            child: const Icon(Icons.book, size: 80),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Author
                    Row(
                      children: [
                        const Icon(Icons.person, size: 18, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            book.author,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Rating
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < book.rating.floor()
                                ? Icons.star
                                : index < book.rating
                                    ? Icons.star_half
                                    : Icons.star_border,
                            color: Colors.amber,
                            size: 24,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          '${book.rating.toStringAsFixed(1)} (${book.totalReviews} reviews)',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Status Badge
                    _StatusBadge(status: book.status),
                    const SizedBox(height: 24),

                    // Details Section
                    const Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _DetailRow(label: 'ISBN', value: book.isbn),
                    _DetailRow(
                      label: 'Genres',
                      value: book.genres.join(', '),
                    ),
                    if (book.publisher != null)
                      _DetailRow(label: 'Publisher', value: book.publisher!),
                    if (book.publishedDate != null)
                      _DetailRow(
                        label: 'Published',
                        value: book.publishedDate!,
                      ),
                    if (book.language != null)
                      _DetailRow(label: 'Language', value: book.language!),
                    if (book.pages != null)
                      _DetailRow(label: 'Pages', value: '${book.pages}'),
                    _DetailRow(label: 'Price', value: '₹${book.price}'),

                    const SizedBox(height: 24),

                    // Inventory Section
                    const Text(
                      'Inventory',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _InventoryCard(
                            label: 'Total Stock',
                            value: '${book.stockQuantity}',
                            icon: Icons.inventory,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InventoryCard(
                            label: 'Available',
                            value: '${book.availableQuantity}',
                            icon: Icons.check_circle,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _InventoryCard(
                            label: 'Borrowed',
                            value: '${book.borrowedQuantity}',
                            icon: Icons.people,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InventoryCard(
                            label: 'Utilization',
                            value: book.stockQuantity > 0
                                ? '${((book.borrowedQuantity / book.stockQuantity) * 100).toStringAsFixed(0)}%'
                                : '0%',
                            icon: Icons.trending_up,
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),

                    if (book.description != null) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        book.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Timestamps
                    const Text(
                      'System Info',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      label: 'Added',
                      value: DateFormat('MMM dd, yyyy HH:mm')
                          .format(book.createdAt),
                    ),
                    _DetailRow(
                      label: 'Updated',
                      value: DateFormat('MMM dd, yyyy HH:mm')
                          .format(book.updatedAt),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _InventoryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _InventoryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
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
    IconData icon;

    switch (status.toLowerCase()) {
      case 'available':
        color = Colors.green;
        label = 'Available';
        icon = Icons.check_circle;
        break;
      case 'out_of_stock':
        color = Colors.orange;
        label = 'Out of Stock';
        icon = Icons.warning;
        break;
      case 'discontinued':
        color = Colors.red;
        label = 'Discontinued';
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        label = status;
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
