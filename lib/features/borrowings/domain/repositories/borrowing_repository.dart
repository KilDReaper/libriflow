import '../../domain/entities/borrowing.dart';

abstract class BorrowingRepository {
  Future<List<Borrowing>> getMyBorrowings();
  Future<List<Borrowing>> getActiveBorrowings();
  Future<Borrowing> getBorrowingDetails(String borrowingId);
  Future<Borrowing> returnBorrowing(String borrowingId);
  Future<BorrowingStats> getBorrowingStats();
}
