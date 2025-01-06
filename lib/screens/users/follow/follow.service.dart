import 'dart:convert';
import 'package:flutter_application_1/config.dart';
import 'package:http/http.dart' as http;

Future<void> followUser(String userEmail, String followEmail) async {
  final url = Uri.parse(follow); // Replace with your backend URL
  final headers = {'Content-Type': 'application/json'};
  final body = jsonEncode({
    'userEmail': userEmail,
    'followEmail': followEmail,
  });

  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print('Follow successful: $responseData');
    } else {
      final errorData = jsonDecode(response.body);
      print('Failed to follow user: ${errorData['message']}');
    }
  } catch (error) {
    print('Error: $error');
  }
}

Future<void> unfollowUser(String userEmail, String followEmail) async {
  final url = Uri.parse(unfollow); // Replace with your backend URL
  final headers = {'Content-Type': 'application/json'};
  final body = jsonEncode({
    'userEmail': userEmail,
    'followEmail': followEmail,
  });

  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print('Unfollow successful: $responseData');
    } else {
      final errorData = jsonDecode(response.body);
      print('Failed to unfollow user: ${errorData['message']}');
    }
  } catch (error) {
    print('Error: $error');
  }
}

Future<List<Map<String, dynamic>>> getFollowersOrFollowing(
    String userEmail, String type) async {
  final url = Uri.parse(list).replace(queryParameters: {
    'userEmail': userEmail,
    'type': type
  }); // Replace with your actual endpoint
  final headers = {'Content-Type': 'application/json'};

  try {
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(responseData['list']);
    } else {
      throw Exception('Failed to fetch users: ${response.reasonPhrase}');
    }
  } catch (error) {
    throw Exception('Error: $error');
  }
}

Future<bool> isFollowing(String userEmail, String followEmail) async {
  final url = Uri.parse(following).replace(queryParameters: {
    'userEmail': userEmail,
    'followEmail': followEmail
  }); // Replace with your actual endpoint
  final headers = {'Content-Type': 'application/json'};

  try {
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['isFollowing'] ?? false;
    } else {
      throw Exception(
          'Failed to check following status: ${response.reasonPhrase}');
    }
  } catch (error) {
    throw Exception('Error: $error');
  }
}

Future<List<dynamic>> getFollowingBooks(String userEmail) async {
  final url = Uri.parse(followingBooks).replace(queryParameters: {
    'userEmail': userEmail
  }); // Replace with your actual endpoint
  final headers = {'Content-Type': 'application/json'};

  try {
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['books'] ?? []; // Return the books list
    } else {
      throw Exception('Failed to fetch books: ${response.reasonPhrase}');
    }
  } catch (error) {
    throw Exception('Error: $error');
  }
}

Future<List<dynamic>> searchFollowersOrFollowing({
  required String userEmail,
  required String searchQuery,
  required String type,
}) async {
  final url = Uri.parse(followingSearch).replace(queryParameters: {
    'userEmail': userEmail,
    'searchQuery': searchQuery,
    'type': type, // "followers" or "following"
  });

  try {
    final response =
        await http.get(url, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['results'] ?? []; // Return the list of results
    } else {
      throw Exception('Failed to search: ${response.reasonPhrase}');
    }
  } catch (error) {
    throw Exception('Error: $error');
  }
}

Future<List<Map<String, dynamic>>> fetchUsersWithRoleUser() async {
  try {
    final response = await http.get(Uri.parse(all_children));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      if (jsonData['status'] == true) {
        // Extract users list
        final List<Map<String, dynamic>> users =
            List<Map<String, dynamic>>.from(jsonData['users']);
        return users;
      } else {
        throw Exception(
            'Failed to fetch users: ${jsonData['error'] ?? 'Unknown error'}');
      }
    } else {
      throw Exception(
          'Failed to load data with status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching users: $e');
    rethrow;
  }
}

Future<List<Map<String, dynamic>>> searchUsersByName(String searchTerm) async {
  const String apiUrl =
      '$all_children/search'; // Replace with your actual API URL

  if (searchTerm.trim().isEmpty) {
    throw Exception('Search term cannot be empty.');
  }

  try {
    // Construct the URL with the searchTerm as a query parameter
    final Uri uri = Uri.parse('$apiUrl?searchTerm=$searchTerm');

    // Send the GET request
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      if (jsonData['status'] == true) {
        // Extract users list
        final List<Map<String, dynamic>> users =
            List<Map<String, dynamic>>.from(jsonData['users']);
        return users;
      } else {
        throw Exception('Error: ${jsonData['error'] ?? 'Unknown error'}');
      }
    } else if (response.statusCode == 400) {
      throw Exception('Bad request: Check your input.');
    } else {
      throw Exception(
          'Failed to load data with status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching users: $e');
    rethrow;
  }
}
