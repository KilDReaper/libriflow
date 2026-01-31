import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;

  ApiClient._internal()
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'http://10.0.2.2:5000/api/',
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            headers: {
              'Accept': 'application/json',
            },
          ),
        ) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('REQUEST[${options.method}] => PATH: ${options.path}');
        print('BODY: ${options.data}');
        print('HEADERS: ${options.headers}');
        return handler.next(options);
      },

      onResponse: (response, handler) {
        print('RESPONSE[${response.statusCode}] => DATA: ${response.data}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        // More detailed error logging to assist diagnosis when response is null
        print('DIO ERROR type: ${e.type}');
        print('MESSAGE: ${e.message}');
        try {
          print('REQUEST PATH: ${e.requestOptions.path}');
          print('REQUEST DATA: ${e.requestOptions.data}');
          print('REQUEST HEADERS: ${e.requestOptions.headers}');
        } catch (_) {}
        print('RESPONSE STATUS: ${e.response?.statusCode}');
        print('RESPONSE DATA: ${e.response?.data}');
        return handler.next(e);
      },

    ));
  }

  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() => _instance;

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> post(String path, dynamic body, {void Function(int, int)? onSendProgress}) async {
    try {
      if (body is FormData) {
        return await _dio.post(path, data: body, onSendProgress: onSendProgress);
      } else {
        return await _dio.post(path, data: body);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> put(String path, Map<String, dynamic> body) async {
    try {
      return await _dio.put(path, data: body);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearToken() {
    _dio.options.headers.remove('Authorization');
  }

  Exception _handleDioError(DioException error) {
    // Provide extra context for easier debugging when there's no response
    final path = error.requestOptions.path;
    final type = error.type;
    if (error.response != null) {
      return Exception('Request failed [${error.response!.statusCode}] at $path: ${error.response!.data}');
    } else {
      return Exception('Request error at $path (type: $type): ${error.message}');
    }
  }
}