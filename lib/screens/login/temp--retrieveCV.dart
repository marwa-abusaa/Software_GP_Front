import 'package:flutter/material.dart';
import 'package:flutter_application_1/config.dart';
import 'package:flutter_application_1/screens/pdfView.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserProfilePage extends StatefulWidget {
  final String email;

  UserProfilePage({required this.email});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late String cvUrl;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Fetch user profile on page load
    fetchUserProfile();
  }

  // Fetch user profile based on email
  Future<void> fetchUserProfile() async {
    try {
      final response =
          await http.get(Uri.parse('$myProfile?email=${widget.email}'));

      if (response.statusCode == 200) {
        // Parse the response data
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          isLoading = false;
          cvUrl = data['data']['cv'];
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load user profile.';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: $e';
      });
    }
  }

  // Extract the username from the email (before '@')
  String getUsernameFromEmail(String email) {
    return email.split('@')[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Profile')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('User Profile for ${widget.email}'),
                      SizedBox(height: 20),
                      Text('CV:'),
                      TextButton(
                        onPressed: () {
                          // Navigate to PdfViewerScreen to view the CV
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PdfViewerScreen(
                                pdfUrl: cvUrl,
                                title:
                                    getUsernameFromEmail(widget.email) + "Cv ",
                                    author:getUsernameFromEmail(widget.email) ,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          '${getUsernameFromEmail(widget.email)}\'s CV',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Text(errorMessage),
                ),
    );
  }
}
