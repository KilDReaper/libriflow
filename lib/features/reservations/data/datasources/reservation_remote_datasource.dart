import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/reservation_model.dart';

abstract class ReservationRemoteDataSource {
  Future<List<ReservationModel>> getMyReservations();
  Future<ReservationModel> createReservation({
    required String bookId,
    required String bookTitle,
  });
  Future<void> cancelReservation(String reservationId);
}

class ReservationRemoteDataSourceImpl implements ReservationRemoteDataSource {
  final ApiClient client = ApiClient();

  @override
  Future<List<ReservationModel>> getMyReservations() async {
    final response = await client.get('reservations/me');
    final data = response.data;
    final List<dynamic> items = _extractList(data, 'reservations');
    return items
        .map((json) => ReservationModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ReservationModel> createReservation({
    required String bookId,
    required String bookTitle,
  }) async {
    final response = await client.post('reservations', {
      'bookId': bookId,
      'bookTitle': bookTitle,
    });
    return ReservationModel.fromJson(
      _extractMap(response.data, 'reservation'),
    );
  }

  @override
  Future<void> cancelReservation(String reservationId) async {
    try {
      await client.delete('reservations/$reservationId');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Cancel failed');
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
