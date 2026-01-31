import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../model/user_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile({
    required String name,
    required String email,
    String? password,
    String? confirmPassword,
  });
  Future<UserModel> uploadImage(String imagePath);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient client = ApiClient();

  @override
  Future<UserModel> getProfile() async {
    final response = await client.get('auth/profile');
    return UserModel.fromJson(response.data['user'] ?? response.data['data']);
  }

  @override
  Future<UserModel> updateProfile({
    required String name,
    required String email,
    String? password,
    String? confirmPassword,
  }) async {
    final response = await client.put(
      'auth/profile',
      {
        'username': name,
        'email': email,
        if (password != null) 'password': password,
        if (confirmPassword != null) 'confirmPassword': confirmPassword,
      },
    );
    return UserModel.fromJson(response.data['user'] ?? response.data['data']);
  }

  @override
  Future<UserModel> uploadImage(String imagePath) async {
    final fileName = imagePath.split('/').last;
    
    final formData = FormData.fromMap({
      "image": await MultipartFile.fromFile(
        imagePath,
        filename: fileName,
      ),
    });

    try {
      final response = await client.post(
        'auth/upload-profile-image',
        formData,
      );

      return UserModel.fromJson(response.data['user'] ?? response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Upload failed');
    }
  }
}