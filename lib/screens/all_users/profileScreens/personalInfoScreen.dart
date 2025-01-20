import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/config.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class PersonalInfoScreen extends StatefulWidget {
  late String emaill;
  late String profileImage;
  PersonalInfoScreen({required this.emaill, required this.profileImage,Key? key}) : super(key: key);
  @override
  _PersonalInfoScreenState createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();

  bool isEditing = false;
  bool isSaved = false;

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  void showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                color: ourPink,
                size: 80, // Increase the size of the tick icon
              ),
              SizedBox(height: 20),
              Text(
                'Data updated successfully!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center, // Center the text
              ),
            ],
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => ProfileScreen(
                  //             emaill: widget.emaill,
                  //           )), // Navigates to the ForgotPassword page
                  // );
                },
                child: const Text(
                  'OK',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void getProfile() async {
    if (widget.emaill.isNotEmpty) {
      try {
        var response = await http.get(
          Uri.parse('$myProfile?email=${widget.emaill}'),
          headers: {"Content-Type": "application/json"},
        );

        print("Response Code: " + response.statusCode.toString());

        if (response.statusCode == 200) {
          var jsonResponse = jsonDecode(response.body);

          setState(() {
            firstNameController.text = jsonResponse['data']['firstName'] ?? '';
            lastNameController.text = jsonResponse['data']['lastName'] ?? '';
            emailController.text = jsonResponse['data']['email'] ?? '';
            birthdateController.text = jsonResponse['data']['birthdate'] ?? '';

            // Parse and format birthdate
            String birthdate = jsonResponse['data']['birthdate'] ?? '';
            if (birthdate.isNotEmpty) {
              DateTime date = DateTime.parse(birthdate);
              birthdateController.text = DateFormat('MM-yyyy').format(date);
            }
          });
        } else if (response.statusCode == 404) {
          var jsonResponse = jsonDecode(response.body);
          showErrorSnackbar(jsonResponse['error'] ?? 'User does not exist');
        } else {
          showErrorSnackbar('Something went wrong. Please try again later.');
        }
      } catch (e) {
        print("Error: $e");
        showErrorSnackbar(
            'An error occurred. Please check your connection and try again.');
      }
    }
  }

  void updateProfile() async {
    if (widget.emaill.isNotEmpty) {
      var reqBody = {
        "email": widget.emaill,
        "firstName": firstNameController.text,
        "lastName": lastNameController.text,
        "birthdate": birthdateController.text
      };

      var response = await http.patch(
        Uri.parse(myProfile),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody),
      );
      print("Updated code: " + response.statusCode.toString());

      if (response.statusCode == 200) {
        print("Updated successfully");
        showSuccessDialog(); // Show success popup
        initState();
      } else {
        showErrorSnackbar('Something went wrong. Please try again later.');
      }
    }
  }

  void toggleEdit() {
    setState(() {
      if (isEditing) {
        isSaved = true; // Set saved indicator to true
        updateProfile();
      }
      isEditing = !isEditing;
    });

    // Reset saved indicator after 2 seconds
    if (isSaved) {
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          isSaved = false; // Reset saved indicator
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: offwhite,
        appBar: AppBar(
          toolbarHeight: 120,
          title: const Text(
            'Personal Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          backgroundColor: offwhite,
          elevation: 0,
          iconTheme: const IconThemeData(color: ourPink),
          actions: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    isEditing ? Icons.save : Icons.edit,
                    color: const Color(0xFFC96868),
                    size: 35,
                  ),
                  onPressed: toggleEdit,
                ),
                if (isEditing)
                  const Text(
                    "save",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color.fromARGB(255, 59, 167, 169),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xFFC96868),
                    backgroundImage: NetworkImage(widget.profileImage),
                                            
                    //  child: Icon(
                    //   Icons.person,
                    //   size: 50,
                    //   color: Colors.white,
                    // ),
                  ),
                ),
                const SizedBox(height: 20),

                // Personal Information Card
                Card(
                  color: logoBar,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'First Name',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: firstNameController,
                          readOnly: !isEditing,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Enter your first name',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Last Name',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: lastNameController,
                          readOnly: !isEditing,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Enter your last name',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Email',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: emailController,
                          readOnly: true, // Email should always be read-only
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Birthdate',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: birthdateController,
                          readOnly: !isEditing,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Enter your birthdate',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
