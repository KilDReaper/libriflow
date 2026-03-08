import 'package:flutter_test/flutter_test.dart';
import 'package:libriflow/features/borrowings/domain/entities/borrowing.dart';

void main() {
  const book = Book(
    id: 'b1',
    title: 'Domain-Driven Design',
    author: 'Eric Evans',
    isbn: '978-0321125217',
    coverImage: null,
  );

  const user = User(
    id: 'u1',
    username: 'reader',
    email: 'reader@example.com',
    profileImage: null,
  );

  test('Borrowing computed flags and overdue days', () {
    final borrowing = Borrowing(
      id: 'br1',
      book: book,
      user: user,
      borrowDate: DateTime.now().subtract(const Duration(days: 10)),
      dueDate: DateTime.now().subtract(const Duration(days: 3)),
      status: 'active',
      fineAmount: 10.0,
      finePaid: false,
    );

    expect(borrowing.isOverdue, isTrue);
    expect(borrowing.isReturned, isFalse);
    expect(borrowing.isLost, isFalse);
    expect(borrowing.daysOverdue, greaterThanOrEqualTo(3));
  });

  test('Borrowing returned/lost flags and non-overdue behavior', () {
    final returned = Borrowing(
      id: 'br2',
      book: book,
      user: user,
      borrowDate: DateTime.now().subtract(const Duration(days: 2)),
      dueDate: DateTime.now().add(const Duration(days: 5)),
      returnedDate: DateTime.now(),
      status: 'returned',
      fineAmount: 0,
      finePaid: true,
    );

    final lost = Borrowing(
      id: 'br3',
      book: book,
      user: user,
      borrowDate: DateTime.now().subtract(const Duration(days: 30)),
      dueDate: DateTime.now().subtract(const Duration(days: 20)),
      status: 'lost',
      fineAmount: 100,
      finePaid: false,
    );

    expect(returned.isReturned, isTrue);
    expect(returned.isOverdue, isFalse);
    expect(returned.daysOverdue, 0);
    expect(returned.daysUntilDue, greaterThanOrEqualTo(4));

    expect(lost.isLost, isTrue);
    expect(lost.isOverdue, isFalse);
    expect(lost.daysOverdue, 0);
  });

  test('BorrowingStats stores aggregate values', () {
    const stats = BorrowingStats(
      activeBorrowings: 3,
      returnedBorrowings: 7,
      overdueBorrowings: 1,
      totalFines: 45.5,
      paidFines: 20.0,
      unpaidFines: 25.5,
    );

    expect(stats.activeBorrowings, 3);
    expect(stats.returnedBorrowings, 7);
    expect(stats.overdueBorrowings, 1);
    expect(stats.totalFines, 45.5);
    expect(stats.paidFines, 20.0);
    expect(stats.unpaidFines, 25.5);
  });
}
