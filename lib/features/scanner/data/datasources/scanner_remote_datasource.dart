import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';

abstract class ScannerRemoteDataSource {
  Future<Map<String, dynamic>> borrowByQRCode(String qrCode);
}

class ScannerRemoteDataSourceImpl implements ScannerRemoteDataSource {
  final ApiClient client = ApiClient();

  @override
  Future<Map<String, dynamic>> borrowByQRCode(String qrCode) async {
    try {
      final response = await client.post('borrow/scan', {
        'qrCode': qrCode,
      });
      return _extractMap(response.data);
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to process scan');
    }
  }

  Map<String, dynamic> _extractMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      final value = data['data'] ?? data['borrowing'];
      if (value is Map<String, dynamic>) {
        return value;
      }
      return data;
    }
    return {};
  }
}
