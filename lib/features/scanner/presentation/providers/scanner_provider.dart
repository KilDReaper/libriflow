import 'package:flutter/material.dart';
import '../../domain/usecases/borrow_by_qr_code.dart';

class ScannerProvider extends ChangeNotifier {
  final BorrowByQRCodeUseCase borrowByQRCodeUseCase;

  ScannerProvider({required this.borrowByQRCodeUseCase});

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _lastScanResult;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get lastScanResult => _lastScanResult;

  Future<Map<String, dynamic>?> borrowByQRCode(String qrCode) async {
    _setLoading(true);
    _error = null;
    _lastScanResult = null;
    try {
      _lastScanResult = await borrowByQRCodeUseCase.call(qrCode);
      notifyListeners();
      return _lastScanResult;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
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
