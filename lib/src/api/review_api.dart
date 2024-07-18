import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReviewAPI {
  static const String baseUrl = 'http://10.0.2.2:8000/api/review';

  static Future<void> addReview({
    required int stayId,
    required String title,
    required String description,
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
        'title': title,
        'description': description,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add review: ${response.reasonPhrase}');
    }
  }

  static Future<Map<String, dynamic>> checkTodayReview(int stayId) async {
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
      throw Exception('Failed to check today review: ${response.reasonPhrase}');
    }

    var responseBody = jsonDecode(response.body);
    if (responseBody['exists'] && responseBody['review'] is int) {
      // Retrieve the full review details
      var reviewResponse = await http.get(
        Uri.parse('$baseUrl/${responseBody['review']}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (reviewResponse.statusCode != 200) {
        throw Exception('Failed to fetch review: ${reviewResponse.reasonPhrase}');
      }

      responseBody['review'] = jsonDecode(reviewResponse.body);
    }

    return responseBody;
  }
}
