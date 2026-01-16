import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthRemoteDatasource {
  final String baseUrl = "https://your-api-url.com";

  Future<String> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'];
    } else {
      throw Exception("Login failed");
    }
  }

  Future<void> signup(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception("Signup failed");
    }
  }
}
