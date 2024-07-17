import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StayAPI {
  static const String baseUrl = 'http://10.0.2.2:8000/api/doctor';

  static Future<List<dynamic>> fetchStays() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    if (token == null) {
      print('Token is null, user not authenticated.');
      return [];
    }

    var userData = getUserDataFromToken(token);
    print('JWT Token: $token');
    print('Fetching stays for user ID: ${userData['id']} and email: ${userData['email']}');

    var fullUrl = '$baseUrl/${userData['id']}/stays';
    print('Full URL: $fullUrl');

    try {
      final response = await http.get(
        Uri.parse(fullUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      print('HTTP response code: ${response.statusCode}');
      print('HTTP response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Parsed JSON data: $data');
        return data;
      } else {
        print('Failed to fetch stays: ${response.reasonPhrase}');
        throw Exception('Failed to fetch stays: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Exception caught: $e');
      throw Exception('Failed to fetch stays');
    }
  }

  static Map<String, dynamic> getUserDataFromToken(String token) {
    try {
      var parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid token format');
      }
      var payload = json.decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      print('Decoded token payload: $payload');
      return {
        'id': payload['id'],
        'username': payload['email'],
      };
    } catch (e) {
      print('Error decoding token: $e');
      throw Exception('Failed to decode token');
    }
  }
}


class DoctorStay {
  final int id;
  final int specialtyId;
  final int doctorId;
  final int userId;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final int scheduleId;

  DoctorStay({
    required this.id,
    required this.specialtyId,
    required this.doctorId,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.scheduleId,
  });

  factory DoctorStay.fromJson(Map<String, dynamic> json) {
    return DoctorStay(
      id: json['id'],
      specialtyId: json['specialty_id'],
      doctorId: json['doctor_id'],
      userId: json['user_id'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      reason: json['reason'],
      scheduleId: json['schedule_id'],
    );
  }
}