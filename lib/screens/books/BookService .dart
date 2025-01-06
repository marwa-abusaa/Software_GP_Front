import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/config.dart';

class BookService {
  // Replace with your backend URL

  // Function to search for books with a minimum rating
  static Future<List<dynamic>> searchBooksRating(double minRating) async {
    final uri = Uri.parse(searchBooksAPI);
    final body = jsonEncode({
      'minRating': minRating,
    });
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      final data = json.decode(response.body);
      if (data['status'] == true) {
        log("Inside the top rate search ");
        log(data['data'].toString());
        return data['data']; // Assuming your response has a 'books' field
      } else {
        print(data['error']);
        return [];
      }
    } else {
      // If the server returns an error response
      print('Failed to load books: ${response.body}');
      return [];
    }
  }

  /// categories search
  ///

  static Future<List<dynamic>> searchCategory(String category) async {
    final uri = Uri.parse(searchBooksAPI);
    final body = jsonEncode({
      'category': category,
    });

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      final data = json.decode(response.body);
      if (data['status'] == true) {
        log("Inside the top rate search ");
        log(data['data'].toString());
        return data['data']; // Assuming your response has a 'books' field
      } else {
        print(data['error']);
        return [];
      }
    } else {
      // If the server returns an error response
      print('Failed to load books: ${response.body}');
      return [];
    }
  }

  static Future<List<dynamic>> getAllBooks() async {
    final response = await http.get(Uri.parse(getAllBooksAPI));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == true) {
        log("Inside the getAllBooks function");
        log(data['data'].toString());

        // Ensure that 'data' is a list of books
        if (data['data'] is List) {
          return data['data'];
        } else {
          print("Error: Expected a list of books, but got ${data['data']}");
          return [];
        }
      } else {
        print("Error from server: ${data['error']}");
        return [];
      }
    } else {
      print('Failed to load books: ${response.body}');
      return [];
    }
  }

  static Future<List<dynamic>> searchBooks({
    String? name,
    String? author,
    String? category,
    double? minRating,
  }) async {
    final uri = Uri.parse(searchBooksAPI);
    final body = jsonEncode({
      'name': name,
      'author': author,
      'category': category,
      'minRating': minRating,
    });

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == true) {
        log("Inside the search filter function");
        log(data['data'].toString());

        // Ensure that 'data' is a list of books
        if (data['data'] is List) {
          return data['data'];
        } else {
          print("Error: Expected a list of books, but got ${data['data']}");
          return [];
        }
      } else {
        print("Error from server: ${data['error']}");
        return [];
      }
    } else {
      print('Failed to load books: ${response.body}');
      return [];
    }
  }

  static Future<List<dynamic>?> getMyPublishedBooks(String email) async {
    // API endpoint
    final String apiUrl = '$getBook/$email'; // استبدلها بعنوان API الخاص بك

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == true) {
          return data['data'];
        } else {
          print('Error: ${data['error']}');
          return null;
        }
      } else {
        print('Failed to load images: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error occurred: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> fetchBookByName(String bookName) async {
    try {
      // Send a GET request with the book name as a query parameter
      final response = await http.get(Uri.parse('$getBook?name=$bookName'));

      // Check if the response is successful
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == true) {
          return {
            'success': true,
            'data': responseData['data'], // Contains the book details
          };
        } else {
          return {
            'success': false,
            'message': responseData['error'] ?? 'Unknown error occurred',
          };
        }
      } else {
        return {
          'success': false,
          'message':
              'Failed to fetch book. Status code: ${response.statusCode}',
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'An error occurred: $error',
      };
    }
  }

  /////////////////FAVV
  static Future<void> addBookToFavorites(String email, String bookId) async {
    try {
      // Construct the request payload
      final Map<String, String> payload = {
        'email': email,
        'bookId': bookId,
      };

      // Make the POST request
      final response = await http.post(
        Uri.parse(fav),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      // Handle the response
      if (response.statusCode == 200) {
        print('Book added to favorites: ${response.body}');
      } else {
        print('Failed to add book to favorites: ${response.body}');
      }
    } catch (e) {
      print('Error adding book to favorites: $e');
    }
  }

  static Future<void> removeBookFromFavorites(
      String email, String bookId) async {
    try {
      // Construct the request payload
      final Map<String, String> payload = {
        'email': email,
        'bookId': bookId,
      };

      // Make the POST request
      final response = await http.delete(
        Uri.parse(fav),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      // Handle the response
      if (response.statusCode == 200) {
        print('Book removed from favorites: ${response.body}');
      } else {
        print('Failed to remove book from favorites: ${response.body}');
      }
    } catch (e) {
      print('Error removing book from favorites: $e');
    }
  }

  static Future<List<dynamic>> getFavoriteBooks(String email) async {
    try {
      // Make the GET request with query parameters
      final response = await http.get(
        Uri.parse('$fav?email=$email'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Decode and return the list of books
        final List<dynamic> books = jsonDecode(response.body);
        return books;
      } else {
        // Throw an error if the server returned a non-200 status code
        throw Exception('Failed to fetch favorite books: ${response.body}');
      }
    } catch (e) {
      // Handle errors gracefully
      throw Exception('Error fetching favorite books: $e');
    }
  }

  static Future<bool> isBookInFavorites(String email, String bookId) async {
    const String apiUrl = '$fav/check'; // Replace with your API endpoint

    try {
      // Make the GET request with query parameters
      final response = await http.get(
        Uri.parse('$apiUrl?email=$email&bookId=$bookId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Decode the response and return the "isFavorite" value
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData.containsKey('isFavorite') &&
            responseData['isFavorite'] is bool) {
          return responseData['isFavorite'];
        } else {
          throw Exception("Invalid response structure: ${response.body}");
        }
      } else {
        // Throw an error if the server returned a non-200 status code
        throw Exception('Failed to check favorite status: ${response.body}');
      }
    } catch (e) {
      // Handle errors gracefully
      throw Exception('Error checking favorite status: $e');
    }
  }
}
