import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/scanner_remote_datasource.dart';
import '../../data/repositories/scanner_repository_impl.dart';
import '../../domain/usecases/borrow_by_qr_code.dart';

// State class to hold scanner state
class ScannerState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? lastScanResult;

  ScannerState({
    this.isLoading = false,
    this.error,
    this.lastScanResult,
  });

  ScannerState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? lastScanResult,
  }) {
    return ScannerState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastScanResult: lastScanResult,
    );
  }
}

// Provider for remote data source
final scannerRemoteDataSourceProvider = Provider<ScannerRemoteDataSource>((ref) {
  return ScannerRemoteDataSourceImpl();
});

// Provider for repository
final scannerRepositoryProvider = Provider((ref) {
  return ScannerRepositoryImpl(
    remoteDataSource: ref.watch(scannerRemoteDataSourceProvider),
  );
});

// Provider for use case
final borrowByQRCodeUseCaseProvider = Provider((ref) {
  return BorrowByQRCodeUseCase(
    repository: ref.watch(scannerRepositoryProvider),
  );
});

// StateNotifier to manage scanner state
class ScannerNotifier extends StateNotifier<ScannerState> {
  final BorrowByQRCodeUseCase borrowByQRCodeUseCase;

  ScannerNotifier({required this.borrowByQRCodeUseCase}) : super(ScannerState());

  Future<Map<String, dynamic>?> borrowByQRCode(String qrCode) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      lastScanResult: null,
    );

    try {
      final result = await borrowByQRCodeUseCase.call(qrCode);
      state = state.copyWith(
        isLoading: false,
        lastScanResult: result,
      );
      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Main provider for ScannerNotifier
final scannerProvider = StateNotifierProvider<ScannerNotifier, ScannerState>((ref) {
  return ScannerNotifier(
    borrowByQRCodeUseCase: ref.watch(borrowByQRCodeUseCaseProvider),
  );
});
