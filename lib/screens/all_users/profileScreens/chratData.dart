import 'package:flutter_application_1/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> incrementProgress(String email, String type) async {
  // Get the current month (you can adjust this format as needed)
  DateTime now = DateTime.now();
  String month =
      now.month.toString(); // Get the numeric month (e.g., "1" for January)

  // API URL (Replace with your actual URL)
  final url = Uri.parse(progress);

  // Prepare the request body
  final body = json.encode({
    'email': email,
    'type': type,
    'month': month,
  });

  // Send the POST request
  try {
    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    // Handle response
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Progress count incremented: ${data['message']}');
    } else if (response.statusCode == 201) {
      final data = json.decode(response.body);
      print('Progress data created: ${data['message']}');
    } else {
      print('Failed to increment progress: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

Future<void> addProgressData(
    String email, String type, String month, int count) async {
  final response = await http.post(
    Uri.parse(progress),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'type': type,
      'month': month,
      'count': count,
    }),
  );

  if (response.statusCode != 201) {
    throw Exception('Failed to add progress data');
  }
}
