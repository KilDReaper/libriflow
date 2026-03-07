import '../../domain/entities/borrowing.dart';
import '../../domain/repositories/borrowing_repository.dart';
import '../datasources/borrowing_remote_datasource.dart';

class BorrowingRepositoryImpl implements BorrowingRepository {
  final BorrowingRemoteDataSource remoteDataSource;

  BorrowingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Borrowing>> getMyBorrowings() async {
    return await remoteDataSource.getMyBorrowings();
  }

  @override
  Future<List<Borrowing>> getActiveBorrowings() async {
    return await remoteDataSource.getActiveBorrowings();
  }

  @override
  Future<Borrowing> getBorrowingDetails(String borrowingId) async {
    return await remoteDataSource.getBorrowingDetails(borrowingId);
  }

  @override
  Future<Borrowing> returnBorrowing(String borrowingId) async {
    return await remoteDataSource.returnBorrowing(borrowingId);
  }

  @override
  Future<BorrowingStats> getBorrowingStats() async {
    return await remoteDataSource.getBorrowingStats();
  }
}
