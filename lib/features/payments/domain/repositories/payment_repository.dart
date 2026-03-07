import '../../domain/entities/payment.dart';

abstract class PaymentRepository {
  Future<List<Payment>> getMyPayments();
  Future<List<UnpaidFine>> getUnpaidFines();
  Future<Payment> createPayment({
    required String borrowingId,
    required double amount,
    required String paymentMethod,
  });
  Future<Payment> verifyPayment({
    required String paymentId,
    required String transactionId,
  });
  Future<Payment> getPaymentDetails(String paymentId);
}
