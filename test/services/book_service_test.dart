import 'package:flutter_test/flutter_test.dart';
import 'package:libriflow/services/book_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BookService Tests', () {
    setUpAll(() async {
      // Initialize Hive with a test directory
      final testDirectory = Directory.systemTemp.createTempSync('hive_test_');
      Hive.init(testDirectory.path);
    });

    setUp(() async {
      await BookService.clearAllBooks();
    });

    tearDown(() async {
      await BookService.clearAllBooks();
      if (Hive.isBoxOpen('books')) {
        await Hive.box('books').close();
      }
    });

    test('rentBook should add a book to the rental database', () async {
      await BookService.rentBook(
        id: 'test-1',
        title: 'Test Book',
        author: 'Test Author',
        price: 10,
        image: 'test.jpg',
        section: 'Test',
        rating: 4.5,
        rentalDays: 30,
      );

      final rentedBooks = await BookService.getRentedBooks();
      expect(rentedBooks.length, 1);
      expect(rentedBooks[0].title, 'Test Book');
      expect(rentedBooks[0].transactionType, 'rented');
    });

    test('buyBook should add a book to the purchase database', () async {
      await BookService.buyBook(
        id: 'test-2',
        title: 'Purchase Book',
        author: 'Purchase Author',
        price: 15,
        image: 'purchase.jpg',
        section: 'Test',
        rating: 4.0,
      );

      final purchasedBooks = await BookService.getPurchasedBooks();
      expect(purchasedBooks.length, 1);
      expect(purchasedBooks[0].title, 'Purchase Book');
      expect(purchasedBooks[0].transactionType, 'purchased');
    });

    test('rentBook should prevent duplicate rentals', () async {
      await BookService.rentBook(
        id: 'test-3',
        title: 'Duplicate Test',
        author: 'Test Author',
        price: 12,
        image: 'test.jpg',
        section: 'Test',
        rating: 4.5,
      );

      expect(
        () => BookService.rentBook(
          id: 'test-3',
          title: 'Duplicate Test',
          author: 'Test Author',
          price: 12,
          image: 'test.jpg',
          section: 'Test',
          rating: 4.5,
        ),
        throwsException,
      );
    });
  });
}
