import 'dart:convert';
import 'package:flutter_application_1/config.dart';
import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>> fetchBooksBySuperEmail(
    String superEmail) async {
  // Construct the URL to call the API
  final url =
      Uri.parse('$superReq/$superEmail'); // Update with your backend URL

  try {
    // Make the GET request
    final response = await http.get(url);

    // Check the status code of the response
    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the response body
      final data = jsonDecode(response.body);
      if (data['status']) {
        // Return the list of books from the 'data' field
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        // If the status is false, handle the error by returning an empty list
        print('Error: ${data['error']}');
        return [];
      }
    } else {
      // Handle the error when the status code is not 200
      print('Failed to fetch books. Status code: ${response.statusCode}');
      return [];
    }
  } catch (error) {
    // Handle any errors that occur during the HTTP request
    print('An error occurred: $error');
    return [];
  }
}

Future<void> updateBookStatus(
    String bookName, String bookEmail, String status, String comment) async {
  // Prepare the request data
  final Map<String, dynamic> data = {
    'name': bookName,
    'email': bookEmail,
    'status': status, // New status for the book
    'superComment': comment
    // You can add other fields like description, image, etc. if needed
  };

  final response = await http.patch(
    Uri.parse(myBook), // Replace with your API URL
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode(data),
  );

  if (response.statusCode == 200) {
    final responseData = json.decode(response.body);
    if (responseData['status'] == true) {
      // Book updated successfully
      print('Book updated successfully!');
    } else {
      // Error in response
      print('Error: ${responseData['error']}');
    }
  } else {
    // If the request failed
    print('Failed to update the book!');
  }
}

Future<void> registerBookToPublish(
  String name,
  String author,
  String description,
  String category,
  double rate,
  String image,
  String pdfLink,
  String email,
) async {
  // Replace with your API URL
  print('<><><><><><><><><><><><><<><><>><><><,><><>><><<><>');

  print('Book Name: $name');
  print('Author: $author');
  print('Description: $description');
  print('Category: $category');
  print('Rate: $rate');
  print('Image: $image');
  print('pdf: $pdfLink');
  print('email: $email');
  // Create the data to be sent in the request body
  Map<String, dynamic> requestData = {
    'name': name,
    'author': author,
    'Description': description,
    'category': category,
    'rate': rate,
    'image': image, // Ensure this is a valid image URL or base64 string
    'pdfLink': pdfLink,
    'email': email,
  };

  try {
    // Send the POST request
    final response = await http.post(
      Uri.parse(getBook),
      headers: {
        'Content-Type': 'application/json', // Ensure the server expects JSON
      },
      body: json.encode(requestData),
    );

    // Handle the response from the server
    if (response.statusCode == 201) {
      // Book added successfully
      print('Book has been added successfully!');
    } else if (response.statusCode == 400) {
      // Bad request - one or more fields are missing
      final responseData = json.decode(response.body);
      print('Error: ${responseData['error']}');
    } else if (response.statusCode == 409) {
      // Conflict - book already exists
      final responseData = json.decode(response.body);
      print('Error: ${responseData['error']}');
    } else {
      // Unexpected error
      print('Unexpected error occurred: ${response.statusCode}');
    }
  } catch (error) {
    print('Error sending request: $error');
  }
}

Future<List<dynamic>> getAllMyChildren(String superEmail) async {
  final Map<String, String> headers = {
    "Content-Type": "application/json",
  };

  final Map<String, dynamic> body = {
    "superEmail": superEmail,
  };

  try {
    final response = await http.post(
      Uri.parse('$superChild/children'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == true) {
        return responseData['data']; // Return the children data
      } else {
        throw Exception("Error: ${responseData['error']}");
      }
    } else if (response.statusCode == 404) {
      throw Exception("Children do not exist.");
    } else {
      throw Exception(
          "Failed to fetch children. Status code: ${response.statusCode}");
    }
  } catch (e) {
    throw Exception("Error: $e");
  }
}

Future<List<dynamic>> searchUsers(String searchTerm, String superEmail) async {
  // Replace with your API base URL

  try {
    // Construct the URL with query parameters
    final Uri url = Uri.parse(
        '$searchChildren?searchTerm=$searchTerm&superEmail=$superEmail');

    // Send the GET request
    final http.Response response = await http.get(url);

    // Check if the response is successful
    if (response.statusCode == 200) {
      // Parse the JSON response
      final data = json.decode(response.body);

      // Extract users from the response and return
      return data['users'] as List<dynamic>;
    } else if (response.statusCode == 400) {
      throw Exception(json.decode(response.body)['message']);
    } else {
      throw Exception('Error: ${response.statusCode} ${response.body}');
    }
  } catch (e) {
    // Handle exceptions
    throw Exception('An error occurred: $e');
  }
}

Future<void> incrementCreatedStory(String email) async {
  final Uri apiUrl =
      Uri.parse('$child/story'); // Replace with your API endpoint

  try {
    // Send POST request
    final response = await http.post(
      apiUrl,
      headers: {
        'Content-Type': 'application/json', // Set the content type to JSON
      },
      body: json.encode({
        'email': email, // Pass the email in the request body
      }),
    );

    if (response.statusCode == 200) {
      // Successfully incremented the story number
      final responseData = json.decode(response.body);
      print('Response: ${responseData['data']}');
    } else {
      // Handle error based on status code
      final responseData = json.decode(response.body);
      print('Error: ${responseData['error']}');
    }
  } catch (error) {
    print('Error: $error');
  }
}

Future<void> incrementContest(String email) async {
  final Uri apiUrl =
      Uri.parse('$child/contest'); // Replace with your API endpoint

  try {
    // Send POST request
    final response = await http.post(
      apiUrl,
      headers: {
        'Content-Type': 'application/json', // Set the content type to JSON
      },
      body: json.encode({
        'email': email, // Pass the email in the request body
      }),
    );

    if (response.statusCode == 200) {
      // Successfully incremented the story number
      final responseData = json.decode(response.body);
      print('Response: ${responseData['data']}');
    } else {
      // Handle error based on status code
      final responseData = json.decode(response.body);
      print('Error: ${responseData['error']}');
    }
  } catch (error) {
    print('Error: $error');
  }
}

Future<void> incrementCourse(String email) async {
  final Uri apiUrl =
      Uri.parse('$child/story'); // Replace with your API endpoint

  try {
    // Send POST request
    final response = await http.post(
      apiUrl,
      headers: {
        'Content-Type': 'application/json', // Set the content type to JSON
      },
      body: json.encode({
        'email': email, // Pass the email in the request body
      }),
    );

    if (response.statusCode == 200) {
      // Successfully incremented the story number
      final responseData = json.decode(response.body);
      print('Response: ${responseData['data']}');
    } else {
      // Handle error based on status code
      final responseData = json.decode(response.body);
      print('Error: ${responseData['error']}');
    }
  } catch (error) {
    print('Error: $error');
  }
}
