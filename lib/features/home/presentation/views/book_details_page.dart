import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/utils/mysnackbar.dart';
import '../../../reservations/presentation/providers/reservation_provider.dart';

class BookDetailsPage extends StatelessWidget {
  final String bookId;
  final String title;
  final String author;
  final String image;
  final String section;
  final int price;

  const BookDetailsPage({
    super.key,
    required this.bookId,
    required this.title,
    required this.author,
    required this.image,
    required this.section,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
      ),
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildImage(),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  author,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 6),
                Text(
                  section,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blueGrey.shade600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Price: \$$price',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: provider.isReserving
                        ? null
                        : () {
                            provider.reserveBook(
                              bookId: bookId,
                              bookTitle: title,
                            );
                          },
                    icon: provider.isReserving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.bookmark_add),
                    label: Text(
                      provider.isReserving ? 'Reserving...' : 'Reserve Book',
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

  Widget _buildImage() {
    if (image.startsWith('http')) {
      return Image.network(
        image,
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
      );
    }

    return Image.asset(
      image,
      width: double.infinity,
      height: 220,
      fit: BoxFit.cover,
    );
  }
}
