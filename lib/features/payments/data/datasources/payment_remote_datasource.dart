import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/payment_model.dart';

abstract class PaymentRemoteDataSource {
  Future<List<PaymentModel>> getMyPayments();
  Future<List<UnpaidFineModel>> getUnpaidFines();
  Future<PaymentModel> createPayment({
    required String borrowingId,
    required double amount,
    required String paymentMethod,
  });
  Future<PaymentModel> verifyPayment({
    required String paymentId,
    required String transactionId,
  });
  Future<PaymentModel> getPaymentDetails(String paymentId);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final ApiClient client = ApiClient();

  @override
  Future<List<PaymentModel>> getMyPayments() async {
    try {
      final response = await client.get('payments/my');
      final data = response.data;
      final List<dynamic> items = _extractList(data, 'payments');
      return items
          .map((json) => PaymentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to fetch payments');
    }
  }

  @override
  Future<List<UnpaidFineModel>> getUnpaidFines() async {
    try {
      final response = await client.get('borrowings/my/unpaid-fines');
      final data = response.data;
      final List<dynamic> items = _extractList(data, 'fines');
      return items
          .map((json) => UnpaidFineModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to fetch unpaid fines');
    }
  }

  @override
  Future<PaymentModel> createPayment({
    required String borrowingId,
    required double amount,
    required String paymentMethod,
  }) async {
    try {
      final response = await client.post('payments', {
        'borrowingId': borrowingId,
        'amount': amount,
        'paymentMethod': paymentMethod,
      });
      final data = _extractMap(response.data, 'payment');
      return PaymentModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to create payment');
    }
  }

  @override
  Future<PaymentModel> verifyPayment({
    required String paymentId,
    required String transactionId,
  }) async {
    try {
      final response = await client.patch('payments/$paymentId/verify', {
        'transactionId': transactionId,
      });
      final data = _extractMap(response.data, 'payment');
      return PaymentModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to verify payment');
    }
  }

  @override
  Future<PaymentModel> getPaymentDetails(String paymentId) async {
    try {
      final response = await client.get('payments/$paymentId');
      final data = _extractMap(response.data, 'payment');
      return PaymentModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to fetch payment details');
    }
  }

  List<dynamic> _extractList(dynamic data, String key) {
    if (data is Map<String, dynamic>) {
      final value = data[key] ?? data['data'] ?? data['items'];
      if (value is List) {
        return value;
      }
    }
    return const [];
  }

  Map<String, dynamic> _extractMap(dynamic data, String key) {
    if (data is Map<String, dynamic>) {
      final value = data[key] ?? data['data'];
      if (value is Map<String, dynamic>) {
        return value;
      }
      return data;
    }
    return {};
  }
}
