class Book {
  final String id;
  final String title;
  final String author;
  final String isbn;
  final String? coverImage;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    this.coverImage,
  });
}

class User {
  final String id;
  final String username;
  final String email;
  final String? profileImage;

  const User({
    required this.id,
    required this.username,
    required this.email,
    this.profileImage,
  });
}

class Borrowing {
  final String id;
  final Book book;
  final User user;
  final DateTime borrowDate;
  final DateTime dueDate;
  final DateTime? returnedDate;
  final String status; // active, returned, overdue, lost
  final double fineAmount;
  final bool finePaid;

  const Borrowing({
    required this.id,
    required this.book,
    required this.user,
    required this.borrowDate,
    required this.dueDate,
    this.returnedDate,
    required this.status,
    required this.fineAmount,
    required this.finePaid,
  });

  bool get isOverdue =>
      status == 'active' && DateTime.now().isAfter(dueDate);

  bool get isReturned => status == 'returned';

  bool get isLost => status == 'lost';

  int get daysUntilDue =>
      dueDate.difference(DateTime.now()).inDays;

  int get daysOverdue {
    if (status == 'active' && DateTime.now().isAfter(dueDate)) {
      return DateTime.now().difference(dueDate).inDays;
    }
    return 0;
  }
}

class BorrowingStats {
  final int activeBorrowings;
  final int returnedBorrowings;
  final int overdueBorrowings;
  final double totalFines;
  final double paidFines;
  final double unpaidFines;

  const BorrowingStats({
    required this.activeBorrowings,
    required this.returnedBorrowings,
    required this.overdueBorrowings,
    required this.totalFines,
    required this.paidFines,
    required this.unpaidFines,
  });
}
