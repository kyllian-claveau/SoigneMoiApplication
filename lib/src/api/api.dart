import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  static const String baseUrl = 'https://soignemoiproject.online/api';

  Future<http.Response> login(Map<String, String> data) async {
    print(json.encode(data));
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    return response;
  }

  Future<String?> authenticate(String email, String password) async {
    final response = await login({'username': email, 'password': password});
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return body['token'];
    }
    return null;
  }

  static Future<void> storeToken(String token) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    localStorage.setString('token', token);
  }

  static bool hasRoleDoctor(String token) {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    List<dynamic> roles = decodedToken['roles'];
    return roles.contains('ROLE_DOCTOR');
  }
}
