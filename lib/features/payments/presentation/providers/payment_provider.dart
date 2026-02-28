import 'package:flutter/material.dart';
import '../../domain/entities/payment.dart';
import '../../domain/usecases/payment_usecases.dart';

class PaymentProvider extends ChangeNotifier {
  final GetMyPaymentsUseCase getMyPaymentsUseCase;
  final GetUnpaidFinesUseCase getUnpaidFinesUseCase;
  final CreatePaymentUseCase createPaymentUseCase;
  final VerifyPaymentUseCase verifyPaymentUseCase;
  final GetPaymentDetailsUseCase getPaymentDetailsUseCase;

  PaymentProvider({
    required this.getMyPaymentsUseCase,
    required this.getUnpaidFinesUseCase,
    required this.createPaymentUseCase,
    required this.verifyPaymentUseCase,
    required this.getPaymentDetailsUseCase,
  });

  List<Payment> _payments = [];
  List<UnpaidFine> _unpaidFines = [];
  bool _isLoading = false;
  String? _error;

  List<Payment> get payments => _payments;
  List<UnpaidFine> get unpaidFines => _unpaidFines;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalUnpaidFines =>
      _unpaidFines.fold(0.0, (sum, fine) => sum + fine.fineAmount);

  Future<void> getMyPayments() async {
    _setLoading(true);
    _error = null;
    try {
      _payments = await getMyPaymentsUseCase.call();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getUnpaidFines() async {
    _setLoading(true);
    _error = null;
    try {
      _unpaidFines = await getUnpaidFinesUseCase.call();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<Payment?> createPayment({
    required String borrowingId,
    required double amount,
    required String paymentMethod,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      final payment = await createPaymentUseCase.call(
        borrowingId: borrowingId,
        amount: amount,
        paymentMethod: paymentMethod,
      );
      _payments.add(payment);
      notifyListeners();
      return payment;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<Payment?> verifyPayment({
    required String paymentId,
    required String transactionId,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      final payment = await verifyPaymentUseCase.call(
        paymentId: paymentId,
        transactionId: transactionId,
      );
      final index = _payments.indexWhere((p) => p.id == paymentId);
      if (index != -1) {
        _payments[index] = payment;
      }
      notifyListeners();
      return payment;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<Payment?> getPaymentDetails(String paymentId) async {
    _setLoading(true);
    _error = null;
    try {
      final payment = await getPaymentDetailsUseCase.call(paymentId);
      notifyListeners();
      return payment;
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
