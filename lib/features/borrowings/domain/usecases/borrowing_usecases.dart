import '../entities/borrowing.dart';
import '../repositories/borrowing_repository.dart';

class GetMyBorrowingsUseCase {
  final BorrowingRepository repository;

  GetMyBorrowingsUseCase({required this.repository});

  Future<List<Borrowing>> call() async {
    return await repository.getMyBorrowings();
  }
}

class GetActiveBorrowingsUseCase {
  final BorrowingRepository repository;

  GetActiveBorrowingsUseCase({required this.repository});

  Future<List<Borrowing>> call() async {
    return await repository.getActiveBorrowings();
  }
}

class GetBorrowingDetailsUseCase {
  final BorrowingRepository repository;

  GetBorrowingDetailsUseCase({required this.repository});

  Future<Borrowing> call(String borrowingId) async {
    return await repository.getBorrowingDetails(borrowingId);
  }
}

class ReturnBorrowingUseCase {
  final BorrowingRepository repository;

  ReturnBorrowingUseCase({required this.repository});

  Future<Borrowing> call(String borrowingId) async {
    return await repository.returnBorrowing(borrowingId);
  }
}

class GetBorrowingStatsUseCase {
  final BorrowingRepository repository;

  GetBorrowingStatsUseCase({required this.repository});

  Future<BorrowingStats> call() async {
    return await repository.getBorrowingStats();
  }
}
