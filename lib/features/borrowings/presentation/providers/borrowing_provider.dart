import 'package:flutter/material.dart';
import '../../domain/entities/borrowing.dart';
import '../../domain/usecases/borrowing_usecases.dart';

class BorrowingProvider extends ChangeNotifier {
  final GetMyBorrowingsUseCase getMyBorrowingsUseCase;
  final GetActiveBorrowingsUseCase getActiveBorrowingsUseCase;
  final GetBorrowingDetailsUseCase getBorrowingDetailsUseCase;
  final ReturnBorrowingUseCase returnBorrowingUseCase;
  final GetBorrowingStatsUseCase getBorrowingStatsUseCase;

  BorrowingProvider({
    required this.getMyBorrowingsUseCase,
    required this.getActiveBorrowingsUseCase,
    required this.getBorrowingDetailsUseCase,
    required this.returnBorrowingUseCase,
    required this.getBorrowingStatsUseCase,
  });

  List<Borrowing> _borrowings = [];
  List<Borrowing> _activeBorrowings = [];
  BorrowingStats? _stats;
  bool _isLoading = false;
  String? _error;

  List<Borrowing> get borrowings => _borrowings;
  List<Borrowing> get activeBorrowings => _activeBorrowings;
  BorrowingStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> getMyBorrowings() async {
    _setLoading(true);
    _error = null;
    try {
      _borrowings = await getMyBorrowingsUseCase.call();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getActiveBorrowings() async {
    _setLoading(true);
    _error = null;
    try {
      _activeBorrowings = await getActiveBorrowingsUseCase.call();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<Borrowing?> getBorrowingDetails(String borrowingId) async {
    _setLoading(true);
    _error = null;
    try {
      final borrowing = await getBorrowingDetailsUseCase.call(borrowingId);
      notifyListeners();
      return borrowing;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> returnBorrowing(String borrowingId) async {
    _setLoading(true);
    _error = null;
    try {
      final returned = await returnBorrowingUseCase.call(borrowingId);
      // Update the borrowing in the list
      final index = _borrowings.indexWhere((b) => b.id == borrowingId);
      if (index != -1) {
        _borrowings[index] = returned;
      }
      final activeIndex = _activeBorrowings.indexWhere((b) => b.id == borrowingId);
      if (activeIndex != -1) {
        _activeBorrowings.removeAt(activeIndex);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getBorrowingStats() async {
    _setLoading(true);
    _error = null;
    try {
      _stats = await getBorrowingStatsUseCase.call();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
