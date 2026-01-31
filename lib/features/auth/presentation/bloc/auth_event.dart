abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested({
    required this.email,
    required this.password,
  });
}

class SignupRequested extends AuthEvent {
  final String email;
  final String username;
  final String phone;
  final String password;
  final String confirmPassword;

  SignupRequested({
    required this.email,
    required this.username,
    required this.phone,
    required this.password,
    required this.confirmPassword,
  });
}

class LogoutRequested extends AuthEvent {}
