import 'package:flutter_application_1/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<dynamic>> getNotActivatedSupervisors() async {
  try {
    final response = await http.get(Uri.parse(notActive));

    if (response.statusCode == 200) {
      // Decode the JSON response
      List<dynamic> supervisors = json.decode(response.body);
      return supervisors;
    } else {
      throw Exception(
          'Failed to load supervisors. Status code: ${response.statusCode}');
    }
  } catch (error) {
    print('Error fetching supervisors: $error');
    rethrow;
  }
}

Future<void> updateActivation({
  required String email,
  required String note,
  required String activated,
}) async {
  try {
    // Prepare the payload
    final Map<String, dynamic> payload = {
      'email': email,
      'note': note,
      'activated': activated,
    };

    // Send the POST request
    final response = await http.post(
      Uri.parse(activate),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(payload),
    );

    // Handle the response
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print('Success: ${responseData['message']}');
    } else {
      final errorData = json.decode(response.body);
      throw Exception('Error: ${errorData['error']}');
    }
  } catch (error) {
    print('Error: $error');
    rethrow;
  }
}
