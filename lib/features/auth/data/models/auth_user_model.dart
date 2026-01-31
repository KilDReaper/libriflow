import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.email,
    required super.username,
    required super.phone,
    required super.token,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] as Map<String, dynamic>?;

    return AuthUserModel(
      id: userData?['_id'] ?? '',
      email: userData?['email'] ?? '',
      username: userData?['username'] ?? '',
      phone: userData?['phoneNumber'] ?? userData?['phone'] ?? '',
      token: json['token'] ?? '',
    );
  }
}