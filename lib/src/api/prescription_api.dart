import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PrescriptionAPI {
  static const String baseUrl = 'https://soignemoiproject.online/api/prescription';

  static Future<void> addPrescription({
    required int stayId,
    required List<Map<String, dynamic>> medications,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    if (token == null) {
      throw Exception('User not authenticated');
    }

    var fullUrl = '$baseUrl';
    var response = await http.post(
      Uri.parse(fullUrl),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'stay_id': stayId,
        'medications': medications,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      }),
    );

    if (response.statusCode != 201) {
      print('HTTP status code: ${response.statusCode}');
      print('HTTP response body: ${response.body}');
      throw Exception('Failed to add prescription: ${response.reasonPhrase}');
    }
  }

  static Future<Map<String, dynamic>> checkPrescription(int stayId) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    if (token == null) {
      throw Exception('User not authenticated');
    }

    var fullUrl = '$baseUrl/check?stay_id=$stayId';
    var response = await http.get(
      Uri.parse(fullUrl),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      print('HTTP status code: ${response.statusCode}');
      print('HTTP response body: ${response.body}');
      throw Exception('Failed to check prescription: ${response.reasonPhrase}');
    }

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getPrescriptionDetails(int prescriptionId) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    if (token == null) {
      throw Exception('User not authenticated');
    }

    var fullUrl = '$baseUrl/$prescriptionId';
    var response = await http.get(
      Uri.parse(fullUrl),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      print('HTTP status code: ${response.statusCode}');
      print('HTTP response body: ${response.body}');
      throw Exception('Failed to fetch prescription details: ${response.reasonPhrase}');
    }

    return jsonDecode(response.body);
  }

  static Future<void> updateEndDate({
    required int prescriptionId,
    required DateTime endDate,
  }) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    if (token == null) {
      throw Exception('User not authenticated');
    }

    var fullUrl = '$baseUrl/$prescriptionId';
    var response = await http.put(
      Uri.parse(fullUrl),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'end_date': endDate.toIso8601String(),
      }),
    );

    if (response.statusCode != 200) {
      print('HTTP status code: ${response.statusCode}');
      print('HTTP response body: ${response.body}');
      throw Exception('Failed to update prescription: ${response.reasonPhrase}');
    }
  }
}
