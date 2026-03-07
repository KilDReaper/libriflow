import '../entities/payment.dart';
import '../repositories/payment_repository.dart';

class GetMyPaymentsUseCase {
  final PaymentRepository repository;

  GetMyPaymentsUseCase({required this.repository});

  Future<List<Payment>> call() async {
    return await repository.getMyPayments();
  }
}

class GetUnpaidFinesUseCase {
  final PaymentRepository repository;

  GetUnpaidFinesUseCase({required this.repository});

  Future<List<UnpaidFine>> call() async {
    return await repository.getUnpaidFines();
  }
}

class CreatePaymentUseCase {
  final PaymentRepository repository;

  CreatePaymentUseCase({required this.repository});

  Future<Payment> call({
    required String borrowingId,
    required double amount,
    required String paymentMethod,
  }) async {
    return await repository.createPayment(
      borrowingId: borrowingId,
      amount: amount,
      paymentMethod: paymentMethod,
    );
  }
}

class VerifyPaymentUseCase {
  final PaymentRepository repository;

  VerifyPaymentUseCase({required this.repository});

  Future<Payment> call({
    required String paymentId,
    required String transactionId,
  }) async {
    return await repository.verifyPayment(
      paymentId: paymentId,
      transactionId: transactionId,
    );
  }
}

class GetPaymentDetailsUseCase {
  final PaymentRepository repository;

  GetPaymentDetailsUseCase({required this.repository});

  Future<Payment> call(String paymentId) async {
    return await repository.getPaymentDetails(paymentId);
  }
}
