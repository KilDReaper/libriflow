import 'package:flutter/material.dart';
import '../../../../shared/utils/image_url_resolver.dart';
import '../../../../shared/utils/mysnackbar.dart';
import '../../../../services/book_service.dart';

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

  Future<void> _borrowBook(BuildContext context) async {
    try {
      await BookService.rentBook(
        id: bookId,
        title: title,
        author: author,
        price: price,
        image: image,
        section: section,
        rating: 0.0,
        rentalDays: 30,
      );
      if (context.mounted) {
        MySnackBar.show(
          context,
          message: '$title rented successfully. Go to Library and tap refresh to see it.',
          background: Colors.green,
        );
      }
    } catch (e) {
      if (context.mounted) {
        MySnackBar.show(
          context,
          message: e.toString().replaceAll('Exception: ', ''),
          background: Colors.red,
        );
      }
    }
  }

  Future<void> _buyBook(BuildContext context) async {
    try {
      await BookService.buyBook(
        id: bookId,
        title: title,
        author: author,
        price: price,
        image: image,
        section: section,
        rating: 0.0,
      );
      if (context.mounted) {
        MySnackBar.show(
          context,
          message: '$title purchased successfully. Go to Library and tap refresh to see it.',
          background: Colors.green,
        );
      }
    } catch (e) {
      if (context.mounted) {
        MySnackBar.show(
          context,
          message: e.toString().replaceAll('Exception: ', ''),
          background: Colors.red,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
      ),
      body: SingleChildScrollView(
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
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _borrowBook(context),
                    icon: const Icon(Icons.calendar_month),
                    label: const Text('Rent'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _buyBook(context),
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Buy'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    final safeImage = resolveBookImageUrl(image);
    if (isNetworkImageUrl(safeImage)) {
      return Image.network(
        safeImage,
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
      );
    }

    return Image.asset(
      safeImage,
      width: double.infinity,
      height: 220,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: double.infinity,
          height: 220,
          color: Colors.grey.shade200,
          child: const Icon(Icons.book, size: 80),
        );
      },
    );
  }
}
