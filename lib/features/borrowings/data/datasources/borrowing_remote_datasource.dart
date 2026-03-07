import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/borrowing_model.dart';

abstract class BorrowingRemoteDataSource {
  Future<List<BorrowingModel>> getMyBorrowings();
  Future<List<BorrowingModel>> getActiveBorrowings();
  Future<BorrowingModel> getBorrowingDetails(String borrowingId);
  Future<BorrowingModel> returnBorrowing(String borrowingId);
  Future<BorrowingStatsModel> getBorrowingStats();
}

class BorrowingRemoteDataSourceImpl implements BorrowingRemoteDataSource {
  final ApiClient client = ApiClient();

  @override
  Future<List<BorrowingModel>> getMyBorrowings() async {
    try {
      final response = await client.get('borrowings/my');
      final data = response.data;
      final List<dynamic> items = _extractList(data, 'borrowings');
      return items
          .map((json) => BorrowingModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to fetch borrowings');
    }
  }

  @override
  Future<List<BorrowingModel>> getActiveBorrowings() async {
    try {
      final response = await client.get('borrowings/my/active');
      final data = response.data;
      final List<dynamic> items = _extractList(data, 'borrowings');
      return items
          .map((json) => BorrowingModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to fetch active borrowings');
    }
  }

  @override
  Future<BorrowingModel> getBorrowingDetails(String borrowingId) async {
    try {
      final response = await client.get('borrowings/$borrowingId');
      final data = _extractMap(response.data, 'borrowing');
      return BorrowingModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to fetch borrowing details');
    }
  }

  @override
  Future<BorrowingModel> returnBorrowing(String borrowingId) async {
    try {
      final response = await client.post('borrowings/$borrowingId/return', {});
      final data = _extractMap(response.data, 'borrowing');
      return BorrowingModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to return book');
    }
  }

  @override
  Future<BorrowingStatsModel> getBorrowingStats() async {
    try {
      final response = await client.get('borrowings/my/stats');
      final data = _extractMap(response.data, 'stats');
      return BorrowingStatsModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to fetch borrowing stats');
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
