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

Future<List<dynamic>> searchNonActivatedUsers(String query) async {
  try {
    final response = await http.get(
      Uri.parse('$searchActive?query=$query'),
      headers: {
        'Content-Type': 'application/json', // Ensure proper headers
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['users']; // Return the list of users
    } else {
      throw Exception(
          'Failed to fetch users: ${response.statusCode} ${response.reasonPhrase}');
    }
  } catch (error) {
    print('Error fetching non-activated users: $error');
    throw error; // Rethrow the error for handling by the caller
  }
}

Future<List<String>> fetchCategories() async {
  final response = await http.get(Uri.parse(categories));
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((category) => category['name'].toString()).toList();
  } else {
    throw Exception('Failed to load categories');
  }
}

Future<void> addCategory(String name) async {
  final url = Uri.parse(categories); // Replace with your actual API URL
  try {
    // Prepare the request
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name}),
    );

    // Check the response status
    if (response.statusCode == 201) {
      print('Category added successfully');
      final category =
          jsonDecode(response.body); // Response data of the new category
      print('New Category: $category');
    } else {
      // Handle error response
      final error = jsonDecode(response.body)['error'];
      throw Exception('Failed to add category: $error');
    }
  } catch (e) {
    print('Error adding category: $e');
    throw Exception('Could not connect to the server');
  }
}

Future<void> deleteCategory(String id) async {
  final url =
      Uri.parse('$categories/$id'); // Assuming the endpoint is /categories/:id

  try {
    print('Deleting category with URL: $url');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        // Add Authorization header if required
        // 'Authorization': 'Bearer YOUR_TOKEN',
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      print('Category deleted successfully');
    } else if (response.statusCode == 400) {
      print('Bad Request: ${jsonDecode(response.body)['error']}');
    } else if (response.statusCode == 404) {
      print('Category not found: ${jsonDecode(response.body)['error']}');
    } else {
      print('Failed to delete category: ${response.body}');
    }
  } catch (e) {
    print('Error occurred while deleting category: $e');
  }
}

Future<List<dynamic>> fetchProgressDataByType(String type) async {
  try {
    // Construct the URL with the type query parameter
    final Uri uri = Uri.parse('$progressAdmin?type=$type');

    // Make the GET request
    final response = await http.get(uri);

    // Check if the response is successful
    if (response.statusCode == 200) {
      // Parse the response body
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      // Return only the 'data' field
      return responseData['data'] ??
          []; // Return an empty list if 'data' is null
    } else {
      // Handle errors
      return []; // Return an empty list in case of failure
    }
  } catch (error) {
    // Handle exceptions
    return []; // Return an empty list in case of exceptions
  }
}

Future<Map<String, dynamic>> fetchGenderStatistics() async {
  try {
    // Send GET request
    final response = await http.get(
      Uri.parse(gender_statistics),
    );

    // Check for success
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return {
        'success': true,
        'data': responseData['data'], // Contains the gender statistics
      };
    } else {
      // Handle error response
      final errorData = json.decode(response.body);
      return {
        'success': false,
        'message': errorData['message'] ?? 'Unknown error occurred',
      };
    }
  } catch (error) {
    // Handle connection errors
    return {
      'success': false,
      'message': 'Failed to connect to the server: $error',
    };
  }
}

Future<List<Map<String, dynamic>>?> fetchAgeStatistics(String role) async {
  // Define the API endpoint
  final url = Uri.parse(age_statistics); // Replace with actual URL

  try {
    // Send GET request with role as query parameter
    final response = await http.get(
      url.replace(queryParameters: {'role': role}),
    );

    // Check if the response is successful (status code 200)
    if (response.statusCode == 200) {
      // Parse the response body
      final data = json.decode(response.body);

      // Return the list of age statistics data
      return List<Map<String, dynamic>>.from(data['data']);
    } else {
      // Handle failure if the status code is not 200
      final data = json.decode(response.body);
      print("Error: ${data['message']}");
      return null; // Return null if there's an error
    }
  } catch (error) {
    print("Failed to fetch data: $error");
    return null; // Return null if an exception occurs
  }
}
