import 'dart:convert';
import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/config.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/screens/all_users/profileScreens/mainProfile.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class EditPasswordScreen extends StatefulWidget {
  late String emaill;
  EditPasswordScreen({required this.emaill, Key? key}) : super(key: key);

  @override
  _EditPasswordScreenState createState() => _EditPasswordScreenState();
}

class _EditPasswordScreenState extends State<EditPasswordScreen> {
  late String passwordFromAPI = "";
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Validation logic
  bool isNewPasswordValid = true;
  bool isNewPasswordLengthValid = true;
  bool isSaveAttempted = false; // New flag to check if save was attempted

  // Eye icon visibility state
  bool isOldPasswordVisible = false;
  bool isNewPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    // getPasswordDecoded();
  }

  void getPasswordDecoded() async {
    if (widget.emaill.isNotEmpty) {
      var response = await http.get(
        Uri.parse('$myProfile?email=${widget.emaill}'),
        headers: {"Content-Type": "application/json"},
      );

      print("Response Code: " + response.statusCode.toString());

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        setState(() {
          String encodedPassword = jsonResponse['data']['password'] ?? '';
          passwordFromAPI = utf8.decode(base64.decode(encodedPassword));
        });
      } else if (response.statusCode == 404) {
        var jsonResponse = jsonDecode(response.body);
        showErrorSnackbar(jsonResponse['error'] ?? 'User does not exist');
      } else {
        showErrorSnackbar('Something went wrong. Please try again later.');
      }
    }
  }

  void showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _validatePassword() {
    setState(() {
      isNewPasswordValid =
          newPasswordController.text == confirmPasswordController.text;
      isNewPasswordLengthValid = newPasswordController.text.length >= 8;
    });
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
                'Password updated successfully!',
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
                  //     builder: (context) => ProfileScreen(
                  //       emaill: widget.emaill,
                  //     ),
                  //   ), // Navigates to the Profile screen
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

  void updatePass() async {
    if (widget.emaill.isNotEmpty) {
      // Check if the old password matches the hashed password
      //if (BCrypt.checkpw(oldPasswordController.text, passwordFromAPI)) {
        var reqBody = {
          "email": widget.emaill,
          "newPass": newPasswordController.text,
        };

        var response = await http.patch(
          Uri.parse(newPass),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(reqBody),
        );
        print("Updated code: " + response.statusCode.toString());

        if (response.statusCode == 200) {
          print("Updated successfully");
          showSuccessDialog();
        } else {
          showErrorSnackbar('Something went wrong. Please try again later.');
        }
      //} 
      // else {
      //   showErrorSnackbar('Old password is not correct.');
      // }
    } else {
      showErrorSnackbar('Old password is not correct or not retrieved yet.');
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
          toolbarHeight: 105,
          title: const Text(
            'Edit Password',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: offwhite,
          elevation: 0,
          iconTheme: const IconThemeData(color: ourPink),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        // Old Password Field
                        _buildPasswordField(
                          label: 'Old Password',
                          controller: oldPasswordController,
                          isVisible: isOldPasswordVisible,
                          onToggleVisibility: () {
                            setState(() {
                              isOldPasswordVisible = !isOldPasswordVisible;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        // New Password Field
                        _buildPasswordField(
                          label: 'New Password',
                          controller: newPasswordController,
                          isVisible: isNewPasswordVisible,
                          onToggleVisibility: () {
                            setState(() {
                              isNewPasswordVisible = !isNewPasswordVisible;
                            });
                          },
                        ),
                        if (!isNewPasswordLengthValid && isSaveAttempted)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              'New password must be at least 8 characters!',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        const SizedBox(height: 16),
                        // Confirm New Password Field
                        _buildPasswordField(
                          label: 'Confirm New Password',
                          controller: confirmPasswordController,
                          isVisible: isConfirmPasswordVisible,
                          onToggleVisibility: () {
                            setState(() {
                              isConfirmPasswordVisible =
                                  !isConfirmPasswordVisible;
                            });
                          },
                        ),
                        if (!isNewPasswordValid &&
                            isNewPasswordLengthValid &&
                            isSaveAttempted)
                          const Text(
                            'Passwords do not match!',
                            style: TextStyle(color: Colors.red),
                          ),
                        const SizedBox(height: 16),
                        // Save Button
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isSaveAttempted = true; // Set flag to true
                                _validatePassword(); // Validate only when Save is pressed
                              });

                              if (isNewPasswordValid &&
                                  isNewPasswordLengthValid) {
                                updatePass();
                                print(widget.emaill);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC96868),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              'Save',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
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

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: !isVisible,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: ourPink, // Change this to your desired color
              ),
              onPressed: onToggleVisibility,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.grey,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            hintText: 'Enter your $label',
            hintStyle: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
