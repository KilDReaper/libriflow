import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phoneNumber,
    super.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
  return UserModel(
    id: (json['_id'] ?? json['id'] ?? '').toString(),
    name: (json['username'] ?? json['name'] ?? '').toString(),
    email: (json['email'] ?? '').toString(),
    phoneNumber: (json['phoneNumber'] ?? '').toString(),
    avatarUrl: (json['profileImage'] ?? json['avatarUrl'])?.toString(),
  );
}

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImage': avatarUrl,
    };
  }
}