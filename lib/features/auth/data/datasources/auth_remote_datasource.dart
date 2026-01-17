import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthRemoteDatasource {
  final String baseUrl = "http://10.0.2.2:5000/api";

  Future<void> signup(String email, String password, String confirmPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'), 
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": email,
        "password": password,
        "confirmPassword": confirmPassword,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 201) {
      throw Exception(data['message'] ?? 'Signup failed');
    }
  }

  Future<String> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'), // Corrected: /api/auth/login
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Updated to match your backend: { "success": true, "token": { "token": "..." } }
        return data['token']['token']; 
      } else {
        final errorMessage = data['message'] ?? 'Login failed';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception("Server Error: ${e.toString()}");
    }
  }
}