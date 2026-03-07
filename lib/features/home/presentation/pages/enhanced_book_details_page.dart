import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/utils/mysnackbar.dart';
import '../../../../shared/utils/image_url_resolver.dart';
import '../../../../services/book_service.dart';
import '../../../reservations/presentation/providers/reservation_provider.dart';

class EnhancedBookDetailsPage extends StatefulWidget {
  final Map<String, dynamic> book;

  const EnhancedBookDetailsPage({
    super.key,
    required this.book,
  });

  @override
  State<EnhancedBookDetailsPage> createState() => _EnhancedBookDetailsPageState();
}

class _EnhancedBookDetailsPageState extends State<EnhancedBookDetailsPage> {
  bool _isProcessing = false;

  Future<void> _rentBook() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    
    try {
      await BookService.rentBook(
        id: widget.book['id'].toString(),
        title: widget.book['title'].toString(),
        author: widget.book['author'].toString(),
        price: (widget.book['price'] as num?)?.toInt() ?? 0,
        image: widget.book['image'].toString(),
        section: widget.book['section'].toString(),
        rating: (widget.book['rating'] as num?)?.toDouble() ?? 0.0,
        rentalDays: 30,
      );
      if (mounted) {
        MySnackBar.show(
          context,
          message: '${widget.book['title']} rented successfully for 30 days',
          background: Colors.green,
        );
      }
    } catch (e) {
      if (mounted) {
        MySnackBar.show(
          context,
          message: e.toString().replaceAll('Exception: ', ''),
          background: Colors.red,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _buyBook() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    
    try {
      await BookService.buyBook(
        id: widget.book['id'].toString(),
        title: widget.book['title'].toString(),
        author: widget.book['author'].toString(),
        price: (widget.book['price'] as num?)?.toInt() ?? 0,
        image: widget.book['image'].toString(),
        section: widget.book['section'].toString(),
        rating: (widget.book['rating'] as num?)?.toDouble() ?? 0.0,
      );
      if (mounted) {
        MySnackBar.show(
          context,
          message: '${widget.book['title']} purchased successfully',
          background: Colors.green,
        );
      }
    } catch (e) {
      if (mounted) {
        MySnackBar.show(
          context,
          message: e.toString().replaceAll('Exception: ', ''),
          background: Colors.red,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.book['title']?.toString() ?? 'Untitled';
    final author = widget.book['author']?.toString() ?? 'Unknown';
    final image = resolveBookImageUrl(widget.book['image']);
    final section = widget.book['section']?.toString() ?? 'General';
    final price = (widget.book['price'] as num?)?.toInt() ?? 0;
    final rating = (widget.book['rating'] as num?)?.toDouble() ?? 0.0;
    final bookId = widget.book['id']?.toString() ?? '';

    return Scaffold(
      body: Consumer<ReservationProvider>(
        builder: (context, provider, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (provider.successMessage != null) {
              MySnackBar.show(context, message: provider.successMessage!);
              provider.clearMessages();
            }
            if (provider.errorMessage != null) {
              MySnackBar.show(
                context,
                message: provider.errorMessage!,
                background: Colors.red,
              );
              provider.clearMessages();
            }
          });

          return CustomScrollView(
            slivers: [
              // App Bar with Image
              SliverAppBar(
                expandedHeight: 400,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      isNetworkImageUrl(image)
                          ? Image.network(
                              image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.book, size: 100),
                              ),
                            )
                          : Image.asset(
                              image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.book, size: 100),
                              ),
                            ),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Genre Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          section,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Author
                      Row(
                        children: [
                          const Icon(Icons.person, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            author,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Rating and Price Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Rating
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Rating',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Price
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹$price',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A73E8),
                                  ),
                                ),
                                Text(
                                  'Rental Price',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Additional Info
                      _InfoRow(
                        icon: Icons.inventory_2,
                        label: 'Availability',
                        value: 'In Stock',
                        valueColor: Colors.green,
                      ),
                      const Divider(height: 24),
                      _InfoRow(
                        icon: Icons.category,
                        label: 'Category',
                        value: section,
                      ),
                      const Divider(height: 24),
                      _InfoRow(
                        icon: Icons.confirmation_number,
                        label: 'Book ID',
                        value: bookId,
                      ),

                      const SizedBox(height: 32),

                      // Description (if available)
                      if (widget.book['description'] != null) ...[
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.book['description'].toString(),
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],

                      // Rent and Buy Buttons
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 56,
                              child: ElevatedButton.icon(
                                onPressed: _isProcessing ? null : _rentBook,
                                icon: _isProcessing
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.calendar_month),
                                label: Text(
                                  _isProcessing ? 'Processing...' : 'Rent (30 days)',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1A73E8),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 56,
                              child: OutlinedButton.icon(
                                onPressed: _isProcessing ? null : _buyBook,
                                icon: const Icon(Icons.shopping_cart),
                                label: const Text(
                                  'Buy',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF1A73E8),
                                  side: const BorderSide(
                                    color: Color(0xFF1A73E8),
                                    width: 2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Reserve Button (as secondary action)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: (provider.isLoading || _isProcessing)
                              ? null
                              : () {
                                  provider.createReservation(
                                    bookId: bookId,
                                    bookTitle: title,
                                  );
                                },
                          icon: provider.isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.bookmark_add_outlined),
                          label: Text(
                            provider.isLoading
                                ? 'Reserving...'
                                : 'Reserve for Later',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                            side: BorderSide(
                              color: Colors.grey[400]!,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
