import '../../domain/entities/borrowing.dart';

class BookModel extends Book {
  const BookModel({
    required super.id,
    required super.title,
    required super.author,
    required super.isbn,
    super.coverImage,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      author: (json['author'] ?? '').toString(),
      isbn: (json['isbn'] ?? '').toString(),
      coverImage: json['coverImage']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'isbn': isbn,
      'coverImage': coverImage,
    };
  }
}

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    super.profileImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      profileImage: json['profileImage']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'profileImage': profileImage,
    };
  }
}

class BorrowingModel extends Borrowing {
  const BorrowingModel({
    required super.id,
    required super.book,
    required super.user,
    required super.borrowDate,
    required super.dueDate,
    super.returnedDate,
    required super.status,
    required super.fineAmount,
    required super.finePaid,
  });

  factory BorrowingModel.fromJson(Map<String, dynamic> json) {
    final borrowDate = json['borrowDate'] ?? json['createdAt'];
    final dueDate = json['dueDate'] ?? json['returnDate'];
    final returnedDate = json['returnedDate'] ?? json['actualReturnDate'];

    return BorrowingModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      book: json['book'] is Map<String, dynamic>
          ? BookModel.fromJson(json['book'])
          : BookModel(
              id: (json['bookId'] ?? '').toString(),
              title: (json['bookTitle'] ?? '').toString(),
              author: '',
              isbn: '',
            ),
      user: json['user'] is Map<String, dynamic>
          ? UserModel.fromJson(json['user'])
          : UserModel(
              id: (json['userId'] ?? '').toString(),
              username: (json['userName'] ?? '').toString(),
              email: '',
            ),
      borrowDate: borrowDate is String
          ? DateTime.tryParse(borrowDate) ?? DateTime.now()
          : borrowDate is DateTime
              ? borrowDate
              : DateTime.now(),
      dueDate: dueDate is String
          ? DateTime.tryParse(dueDate) ?? DateTime.now()
          : dueDate is DateTime
              ? dueDate
              : DateTime.now(),
      returnedDate: returnedDate is String
          ? DateTime.tryParse(returnedDate)
          : returnedDate is DateTime
              ? returnedDate
              : null,
      status: (json['status'] ?? 'active').toString(),
      fineAmount: (json['fineAmount'] as num?)?.toDouble() ?? 0.0,
      finePaid: (json['finePaid'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book': book is BookModel ? (book as BookModel).toJson() : null,
      'user': user is UserModel ? (user as UserModel).toJson() : null,
      'borrowDate': borrowDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'returnedDate': returnedDate?.toIso8601String(),
      'status': status,
      'fineAmount': fineAmount,
      'finePaid': finePaid,
    };
  }
}

class BorrowingStatsModel extends BorrowingStats {
  const BorrowingStatsModel({
    required super.activeBorrowings,
    required super.returnedBorrowings,
    required super.overdueBorrowings,
    required super.totalFines,
    required super.paidFines,
    required super.unpaidFines,
  });

  factory BorrowingStatsModel.fromJson(Map<String, dynamic> json) {
    return BorrowingStatsModel(
      activeBorrowings: (json['activeBorrowings'] as num?)?.toInt() ?? 0,
      returnedBorrowings: (json['returnedBorrowings'] as num?)?.toInt() ?? 0,
      overdueBorrowings: (json['overdueBorrowings'] as num?)?.toInt() ?? 0,
      totalFines: (json['totalFines'] as num?)?.toDouble() ?? 0.0,
      paidFines: (json['paidFines'] as num?)?.toDouble() ?? 0.0,
      unpaidFines: (json['unpaidFines'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activeBorrowings': activeBorrowings,
      'returnedBorrowings': returnedBorrowings,
      'overdueBorrowings': overdueBorrowings,
      'totalFines': totalFines,
      'paidFines': paidFines,
      'unpaidFines': unpaidFines,
    };
  }
}
