// services/language_tool_service.dart
import 'dart:convert';
import 'package:flutter_application_1/api/api.dart';
import 'package:flutter_application_1/config.dart';
import 'package:http/http.dart' as http;

// دالة لإرسال النص إلى الخادم للحصول على نتائج التدقيق الإملائي
Future<Map<String, dynamic>> checkSpelling(String text) async {
  final response = await http.post(
    Uri.parse(checker),
    headers: {"Content-Type": "application/json"},
    body: json.encode({"text": text}),
  );

  if (response.statusCode == 200) {
    // إذا كانت الاستجابة ناجحة، إرجاع البيانات كـ Map
    return json.decode(response.body);
  } else {
    // في حالة الخطأ، إرجاع رسالة خطأ
    throw Exception('فشل في الاتصال بـ API');
  }
}

Future<void> addImage(
    String url, String email, String description, String category) async {
  // Create the request body
  final Map<String, dynamic> body = {
    'url': url,
    'email': email,
    'Description': description,
    'category': category,
  };

  try {
    // Send the POST request
    final response = await http.post(
      Uri.parse(storyImage),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    // Check the response
    if (response.statusCode == 201) {
      print('Image added successfully');
      // Handle the success response here
    } else {
      print('Failed to add image: ${response.body}');
      // Handle the error here
    }
  } catch (e) {
    print('Error occurred: $e');
    // Handle any errors here
  }
}

Future<List<dynamic>?> getImagesByEmail(String email) async {
  // API endpoint
  final String apiUrl = '$storyImage/$email'; // استبدلها بعنوان API الخاص بك

  try {
    // إرسال طلب GET
    final response = await http.get(Uri.parse(apiUrl));

    // التحقق من الاستجابة
    if (response.statusCode == 200) {
      // إذا كانت الاستجابة ناجحة، نقوم بتحليل بيانات JSON
      final data = json.decode(response.body);

      if (data['status'] == true) {
        // print('Images retrieved successfully: ${data['data']}');
        return data['data'];
      } else {
        print('Error: ${data['error']}');
        // في حال حدوث خطأ، يمكن إرجاع null أو رسالة خطأ
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

Future<List<dynamic>?> getImagesByCategory(String category) async {
  final String apiUrl =
      '$storyImageCategory/$category'; // استبدلها بعنوان API الخاص بك

  try {
    // إرسال طلب GET
    final response = await http.get(Uri.parse(apiUrl));

    // التحقق من حالة الاستجابة
    if (response.statusCode == 200) {
      // إذا كانت الاستجابة ناجحة، نقوم بتحليل بيانات JSON
      final data = json.decode(response.body);

      if (data['status'] == true) {
        //print('Images fetched successfully: ${data['images']}');
        // إرجاع قائمة الصور
        return data['images'];
      } else {
        print('Error: ${data['error']}');
        // في حال حدوث خطأ، يمكن إرجاع null أو رسالة خطأ
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

Future<void> deleteImage(String imageUrl) async {
  const String apiUrl = '$storyImage'; // Replace with your server URL

  try {
    final response = await http.delete(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'url': imageUrl}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == true) {
        print('Image deleted successfully!');
      } else {
        print('Failed to delete the image: ${responseData['error']}');
      }
    } else if (response.statusCode == 404) {
      print('Image not found!');
    } else {
      print('Unexpected error occurred: ${response.statusCode}');
    }
  } catch (error) {
    print('Error: $error');
  }
}

//////////////
///my story functions
Future<List<dynamic>?> getBooksByEmailAndStatus(
    String email, String status) async {
  final String apiUrl = "$booksByStatus"; // Replace with your API URL

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "email": email,
        "status": status,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      print("Success: ${data['data']}");
      return data['data'];
    } else {
      print("Error: ${response.statusCode} - ${response.body}");
      return null;
    }
  } catch (e) {
    print("Error: $e");
    return null;
  }
}

Future<void> deleteDeniedBook(String bookName) async {
  final String apiUrl = '$myBook'; // Replace with your API URL
  try {
    final response = await http.delete(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': bookName,
      }),
    );

    if (response.statusCode == 200) {
      // Book deleted successfully
      final responseBody = json.decode(response.body);
      if (responseBody['status'] == true) {
        print('Book deleted successfully');
        // Handle success (e.g., show a success message)
      } else {
        print('Failed to delete book: ${responseBody['error']}');
        // Handle failure (e.g., show error message)
      }
    } else {
      print('Failed to delete book. Status Code: ${response.statusCode}');
      // Handle error (e.g., show error message)
    }
  } catch (e) {
    print('Error: $e');
    // Handle exceptions (e.g., no internet, etc.)
  }
}

Future<void> registerBook(String name, String description, String image,
    String pdfLink, String draftId, String superEmail, String category) async {
  const String url = '$myBook'; // Replace with your API URL

  try {
    // Create the request body
    final Map<String, dynamic> requestBody = {
      'name': name,
      'email': APIS.currentEmail,
      'Description': description,
      'status': 'on request',
      'superComment': ' ',
      'image': image,
      'pdfLink': pdfLink,
      'draftId': draftId,
      'superEmail': superEmail,
      'category': category
    };

    // Send the POST request
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    // Handle the response
    if (response.statusCode == 201) {
      print('Book registered successfully!');
      final responseData = jsonDecode(response.body);
      print(responseData['success']); // Success message from the API
    } else {
      final responseData = jsonDecode(response.body);
      print('Failed to register book: ${responseData['error']}');
    }
  } catch (error) {
    print('An error occurred: $error');
  }
}
