import 'package:hive_flutter/hive_flutter.dart';
import '../features/home/data/models/book_model.dart';

class BookService {
  static const String _boxName = 'books';

  static Future<Box> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  // Add a rented book
  static Future<void> rentBook({
    required String id,
    required String title,
    required String author,
    required int price,
    required String image,
    required String section,
    required double rating,
    int rentalDays = 30,
  }) async {
    try {
      final box = await _getBox();
      
      // Check if book is already rented
      for (var value in box.values) {
        if (value is Map<dynamic, dynamic>) {
          if (value['id'] == id && value['transactionType'] == 'rented') {
            throw Exception('This book is already rented');
          }
        }
      }

      final book = BookModel(
        id: id,
        title: title,
        author: author,
        price: price,
        image: image,
        section: section,
        rating: rating,
        transactionType: 'rented',
        transactionDate: DateTime.now(),
        rentalDays: rentalDays,
      );

      await box.add(book.toMap());
      print('DEBUG: Book rented successfully - $title');
    } catch (e) {
      print('DEBUG: Error renting book - $e');
      rethrow;
    }
  }

  // Add a purchased book
  static Future<void> buyBook({
    required String id,
    required String title,
    required String author,
    required int price,
    required String image,
    required String section,
    required double rating,
  }) async {
    try {
      final box = await _getBox();
      
      // Check if book is already purchased
      for (var value in box.values) {
        if (value is Map<dynamic, dynamic>) {
          if (value['id'] == id && value['transactionType'] == 'purchased') {
            throw Exception('This book is already purchased');
          }
        }
      }

      final book = BookModel(
        id: id,
        title: title,
        author: author,
        price: price,
        image: image,
        section: section,
        rating: rating,
        transactionType: 'purchased',
        transactionDate: DateTime.now(),
      );

      await box.add(book.toMap());
      print('DEBUG: Book purchased successfully - $title');
    } catch (e) {
      print('DEBUG: Error purchasing book - $e');
      rethrow;
    }
  }

  // Get all rented books
  static Future<List<BookModel>> getRentedBooks() async {
    try {
      final box = await _getBox();
      final List<BookModel> rentedBooks = [];
      
      for (var value in box.values) {
        if (value is Map<dynamic, dynamic>) {
          try {
            // Convert dynamic keys to string keys for fromMap
            final bookMap = Map<String, dynamic>.from(
              value.map((k, v) => MapEntry(k.toString(), v))
            );
            if (bookMap['transactionType'] == 'rented') {
              rentedBooks.add(BookModel.fromMap(bookMap));
            }
          } catch (e) {
            print('DEBUG: Error parsing rented book - $e');
          }
        }
      }
      
      print('DEBUG: Found ${rentedBooks.length} rented books');
      return rentedBooks;
    } catch (e) {
      print('DEBUG: Error getting rented books - $e');
      return [];
    }
  }

  // Get all purchased books
  static Future<List<BookModel>> getPurchasedBooks() async {
    try {
      final box = await _getBox();
      final List<BookModel> purchasedBooks = [];
      
      for (var value in box.values) {
        if (value is Map<dynamic, dynamic>) {
          try {
            // Convert dynamic keys to string keys for fromMap
            final bookMap = Map<String, dynamic>.from(
              value.map((k, v) => MapEntry(k.toString(), v))
            );
            if (bookMap['transactionType'] == 'purchased') {
              purchasedBooks.add(BookModel.fromMap(bookMap));
            }
          } catch (e) {
            print('DEBUG: Error parsing purchased book - $e');
          }
        }
      }
      
      print('DEBUG: Found ${purchasedBooks.length} purchased books');
      return purchasedBooks;
    } catch (e) {
      print('DEBUG: Error getting purchased books - $e');
      return [];
    }
  }

  // Get all books (both rented and purchased)
  static Future<List<BookModel>> getAllBooks() async {
    try {
      final box = await _getBox();
      final List<BookModel> allBooks = [];
      
      for (var value in box.values) {
        if (value is Map<dynamic, dynamic>) {
          try {
            final bookMap = Map<String, dynamic>.from(
              value.map((k, v) => MapEntry(k.toString(), v))
            );
            allBooks.add(BookModel.fromMap(bookMap));
          } catch (e) {
            print('DEBUG: Error parsing book - $e');
          }
        }
      }
      
      return allBooks;
    } catch (e) {
      print('DEBUG: Error getting all books - $e');
      return [];
    }
  }

  // Remove a book by its key
  static Future<void> removeBook(int key) async {
    final box = await _getBox();
    await box.delete(key);
  }

  // Clear all books
  static Future<void> clearAllBooks() async {
    final box = await _getBox();
    await box.clear();
  }
}
