import 'package:flutter_application_1/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String?> fetchSuperEmail(String childEmail) async {
  const String apiUrl = '$superChild/child'; // Replace with your API URL

  // Prepare the request payload
  final Map<String, dynamic> requestBody = {
    'childEmail': childEmail,
  };

  try {
    // Make the POST request
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    // Check the response status code
    if (response.statusCode == 200) {
      // Parse the response and extract `superEmail`
      final responseData = jsonDecode(response.body);
      final String? superEmail = responseData['data']['superEmail'];
      return superEmail;
    } else if (response.statusCode == 404) {
      // Log error for child not found
      final errorData = jsonDecode(response.body);
      print("Error: ${errorData['error']}");
      return null;
    } else {
      // Handle other response errors
      print("Error: ${response.statusCode}, ${response.body}");
      return null;
    }
  } catch (e) {
    // Handle network or other errors
    print("An error occurred: $e");
    return null;
  }
}

Future<String> getUserFullName(String email) async {
  // Replace with your API URL

  try {
    // Send GET request to the API with the email as a query parameter
    final response = await http.get(
      Uri.parse('$myProfile?email=$email'),
      headers: {'Content-Type': 'application/json'},
    );
    // Check the response status
    if (response.statusCode == 200) {
      // Parse the response body
      final data = json.decode(response.body);

      if (data['status'] == true) {
        // Extract first and last name
        String firstName = data['data']['firstName'];
        String lastName = data['data']['lastName'];

        // Return the full name
        return '$firstName $lastName';
      } else {
        // If the status is false (error in response)
        print('Error: ${data['error']}');
        return 'Error: ${data['error']}';
      }
    } else {
      // Handle non-200 status codes (e.g., 400, 404)
      print('Error: ${response.statusCode}');
      return 'Error: Unable to fetch profile';
    }
  } catch (error) {
    // Handle any errors in making the request
    print('Error: $error');
    return 'Error: $error';
  }
}

Future<String> fetchUserImage(String email) async {
  try {
    // Make a GET request with the email as a query parameter
    final response = await http.get(Uri.parse('$myProfile?email=$email'));

    // Check if the request was successful
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Check if the response contains the user profile
      if (data['status'] == true && data['data'] != null) {
        return data['data']['image']; // Return the user's image URL
      } else {
        throw Exception('User profile not found or invalid response.');
      }
    } else {
      throw Exception(
          'Failed to fetch user profile. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching user image: $e');
    return ""; // Return null in case of an error
  }
}

Future<bool> updateUserImage(String email, String imageUrl) async {
  try {
    // Make a PATCH request with the email and new image URL
    final response = await http.patch(
      Uri.parse(myProfile),
      headers: {
        'Content-Type': 'application/json', // Set the content type to JSON
      },
      body: jsonEncode({
        'email': email, // Email of the user
        'image': imageUrl, // New image URL
      }),
    );

    // Check if the request was successful
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['status'] == true) {
        print('User image updated successfully');
        return true; // Return true if the update was successful
      } else {
        print('Failed to update image: ${data['error']}');
        return false; // Return false if the update failed
      }
    } else {
      print('Failed to update user image. Status code: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('Error updating user image: $e');
    return false; // Return false in case of an error
  }
}

Future<Map<String, dynamic>> getUserProgress(String email) async {
  final Map<String, String> headers = {
    "Content-Type": "application/json",
  };

  try {
    final response = await http.get(
      Uri.parse('$child?email=$email'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == true) {
        return responseData['data']; // Return the user profile data
      } else {
        throw Exception("Error: ${responseData['error']}");
      }
    } else if (response.statusCode == 404) {
      throw Exception("User does not exist.");
    } else {
      throw Exception(
          "Failed to fetch user profile. Status code: ${response.statusCode}");
    }
  } catch (e) {
    throw Exception("Error: $e");
  }
}
