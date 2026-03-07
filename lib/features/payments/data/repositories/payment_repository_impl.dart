import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_datasource.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;

  PaymentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Payment>> getMyPayments() async {
    return await remoteDataSource.getMyPayments();
  }

  @override
  Future<List<UnpaidFine>> getUnpaidFines() async {
    return await remoteDataSource.getUnpaidFines();
  }

  @override
  Future<Payment> createPayment({
    required String borrowingId,
    required double amount,
    required String paymentMethod,
  }) async {
    return await remoteDataSource.createPayment(
      borrowingId: borrowingId,
      amount: amount,
      paymentMethod: paymentMethod,
    );
  }

  @override
  Future<Payment> verifyPayment({
    required String paymentId,
    required String transactionId,
  }) async {
    return await remoteDataSource.verifyPayment(
      paymentId: paymentId,
      transactionId: transactionId,
    );
  }

  @override
  Future<Payment> getPaymentDetails(String paymentId) async {
    return await remoteDataSource.getPaymentDetails(paymentId);
  }
}
