import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/config.dart';
import 'package:http/http.dart' as http;

Future<void> joinContest(
    BuildContext context, // Pass BuildContext to show UI elements like SnackBar
    String contestName,
    String email,
    String bookName,
    String note) async {
  // API endpoint (replace with your actual API URL)

  // Prepare the request body
  Map<String, String> requestBody = {
    'contestName': contestName,
    'email': email,
    'bookName': bookName,
    'note': note,
  };

  try {
    // Send a POST request to the API
    final response = await http.post(
      Uri.parse(cnotestJoin),
      headers: {
        'Content-Type': 'application/json', // Set content type to JSON
      },
      body: json.encode(requestBody), // Encode request body as JSON
    );

    // Check if the request was successful

    final responseData = json.decode(response.body);
    if (responseData['status'] == true) {
      // Successfully joined the contest
      print('Contest joined successfully: ${responseData['success']}');
      // You can also show a success SnackBar if needed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contest joined successfully!')),
      );
    } else {
      // Show the error message based on API response
      String errorMessage =
          responseData['error'] ?? 'An unknown error occurred.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $errorMessage')),
      );
    }
  } catch (error) {
    // Catch any errors (e.g., network issues) and show an error SnackBar
    print('Error occurred: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text('Error occurred: $error. Please check your connection.')),
    );
  }
}

Future<List<dynamic>> getContestParticipants(
  String contestName,
) async {
  // API endpoint (replace with your actual API URL)
  const String apiUrl = cnotestJoin;

  try {
    // Send a GET request to the API with the contestName as a query parameter
    final response = await http.get(
      Uri.parse('$apiUrl?contestName=$contestName'),
      headers: {
        'Content-Type': 'application/json', // Set content type to JSON
      },
    );

    // Check if the request was successful
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['status'] == true) {
        // Return the list of participants as List<dynamic>
        return responseData['data'];
      } else {
        // Handle API errors
        throw Exception(
            responseData['error'] ?? 'Failed to fetch participants');
      }
    } else {
      // Handle HTTP errors
      throw Exception(
          'Failed to fetch participants. Status code: ${response.statusCode}');
    }
  } catch (error) {
    // Catch any errors (e.g., network issues) and throw them
    throw Exception('Error occurred: $error');
  }
}

Future<void> addContestVote({
  required String contestName,
  required String email,
  String? book1,
  String? book2,
  String? book3,
}) async {
  try {
    // Request body
    final Map<String, dynamic> requestBody = {
      'contestName': contestName,
      'email': email,
      'book1': book1,
      'book2': book2,
      'book3': book3,
    };

    // HTTP POST request
    final response = await http.post(
      Uri.parse(cnotestVote),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['status'] == true) {
        print('Vote submitted successfully!');
        print('Response: ${responseData['success']}');
      } else {
        print('Error: ${responseData['error']}');
      }
    } else {
      print('Failed to submit vote. Status Code: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  } catch (error) {
    print('Error occurred while submitting vote: $error');
  }
}

Future<bool> checkVote({
  required String contestName,
  required String email,
}) async {
  final String apiUrl = "$cnotestVote/check";

  try {
    final Map<String, String> requestBody = {
      'contestName': contestName,
      'email': email,
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print("User can vote >>> from API");
      return true;
    } else {
      print('Failed to check vote. Status code: ${response.statusCode}');
      print("User can not vote >>> from API");

      print('Response body: ${response.body}');
      return false;
    }
  } catch (e) {
    print('Exception occurred while checking vote: $e');
    return false;
  }
}
