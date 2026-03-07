class AuthUser {
  final String id;
  final String email;
  final String username;
  final String phone;
  final String token;

  const AuthUser({
    required this.id,
    required this.email,
    required this.username,
    required this.phone,
    required this.token,
  });
}
