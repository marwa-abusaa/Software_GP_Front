import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/api.dart';
import 'package:flutter_application_1/screens/login/signin_screen.dart';
import 'package:flutter_application_1/widgets/custom_scaffold.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/config.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart'; // Add this import for file picker
import 'package:flutter_application_1/constants/app_colors.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _auth = FirebaseAuth.instance;
  final _formSignupKey = GlobalKey<FormState>();
  bool agreePersonalData = true;
  bool isSupervisor = false; // New variable to track supervisor state
  String? cvFilePath; // Variable to hold the CV file path
  bool isPasswordVisible = false; 

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController dobController = TextEditingController();

  String? selectedGender;
  bool _isNotValidate = false;

  void registerUser() async {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      try {
        // Upload CV to Firebase Storage if user is supervisor
        String? cvUrl;
        if (isSupervisor && cvFilePath != null) {
          cvUrl = await uploadCvFileToFirebase(cvFilePath!);
        }

        var regBody = {
          "email": emailController.text,
          "password": passwordController.text,
          "firstName": firstNameController.text,
          "lastName": lastNameController.text,
          "gender": selectedGender,
          "birthdate": dobController.text,
          "role": isSupervisor ? "supervisor" : "user",
          "cv": cvUrl, // Store the URL of the uploaded CV
        };

        var response = await http.post(
          Uri.parse(registration),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regBody),
        );

        if (response.statusCode == 201) {
          try {
            // Create the user in Firebase Authentication
            final newUser =
                await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: emailController.text,
              password: passwordController.text,
            );

            // Check if the user was successfully created
            if (newUser.user != null) {
              print("User created: ${newUser.user?.email}");

              // Set the current email globally
              APIS.initializeEmail(newUser.user!.email!);

              // Now, call createUser() to save user data to Firestore
              await APIS.createUser();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User creation failed.')));
            }
          } catch (e) {
            print("Error: $e");
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('An error occurred. Please try again.')));
          }

          var jsonResponse = jsonDecode(response.body);
          print(jsonResponse['status']);
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User registered successfully!')));
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const SignInScreen()));
        } else if (response.statusCode == 409) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Email is already registered.')));
        } else if (response.statusCode == 400) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Invalid request. Please check your input.')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Something went wrong. Please try again later.')));
        }
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('An error occurred. Please try again.')));
      }
    } else {
      setState(() {
        _isNotValidate = true;
      });
    }
  }

// Function to upload CV to Firebase Storage
  Future<String?> uploadCvFileToFirebase(String filePath) async {
    try {
      // Create a reference to Firebase Storage

      final cvRef = APIS.storage
          .ref()
          .child('cv_files/${DateTime.now().millisecondsSinceEpoch}.pdf');

      // Upload the file
      final uploadTask = await cvRef.putFile(File(filePath));
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('CV upload failed: $e');
      return null;
    }
  }

  // Function to pick a file
  Future<void> _pickCvFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'], // Allowed file types
    );

    if (result != null) {
      setState(() {
        cvFilePath = result.files.single.path; // Set the file path
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: CustomScaffold(
        child: Column(
          children: [
            const Expanded(
              flex: 1,
              child: SizedBox(
                height: 10,
              ),
            ),
            Expanded(
              flex: 7,
              child: Container(
                padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
                decoration: const BoxDecoration(
                  color: offwhite,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.0),
                    topRight: Radius.circular(40.0),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formSignupKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.w600,
                            color: ourPink,
                          ),
                        ),
                        const SizedBox(height: 30.0),

                        // Create Account as Supervisor Switch
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(Icons.supervisor_account,
                                color: Colors.black54),
                            const SizedBox(width: 10),
                            const Text(
                              'Sign as Supervisor ',
                              style: TextStyle(fontSize: 16),
                            ),
                            Switch(
                              value: isSupervisor,
                              onChanged: (value) {
                                setState(() {
                                  isSupervisor = value;
                                });
                              },
                              activeColor: ourBlue,
                              inactiveThumbColor:
                                  const Color.fromARGB(255, 198, 64, 64),
                            ),
                          ],
                        ),

                        //space
                        const SizedBox(height: 20.0),
                        // First Name
                        TextFormField(
                          controller: firstNameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter First Name';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            label: const Text('First Name'),
                            hintText: 'Enter First Name',
                            hintStyle: const TextStyle(color: Colors.black26),
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25.0),

                        // Last Name
                        TextFormField(
                          controller: lastNameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Last Name';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            label: const Text('Last Name'),
                            hintText: 'Enter Last Name',
                            hintStyle: const TextStyle(color: Colors.black26),
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25.0),

                        // Gender
                        DropdownButtonFormField<String>(
                          value: selectedGender,
                          onChanged: (newValue) {
                            setState(() {
                              selectedGender = newValue;
                            });
                          },
                          validator: (value) =>
                              value == null ? 'Please select a gender' : null,
                          items: const [
                            DropdownMenuItem(
                              value: 'Male',
                              child: Text(
                                'Male',
                                style: TextStyle(
                                  //color: ourPink,
                                  fontSize: 14,
                                ), // Custom text color
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Female',
                              child: Text(
                                'Female',
                                style: TextStyle(
                                  //color: ourPink,
                                  fontSize: 14,
                                ), // Custom text color
                              ),
                            ),
                          ],
                          decoration: InputDecoration(
                            label: const Text('Gender'),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),

                          dropdownColor:
                              offwhite, // Background color of dropdown menu
                          borderRadius: BorderRadius.circular(25),
                        ),
                        const SizedBox(height: 25.0),

                        // Date of Birth
                        TextFormField(
                          controller: dobController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: "Date of Birth",
                            hintText: "Select Date of Birth",
                            prefixIcon: const Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onTap: () async {
                            // Get the current year
                            int currentYear = DateTime.now().year;

                            // Calculate the appropriate lastDate based on whether the user is a supervisor or not
                            DateTime lastDate;
                            if (isSupervisor) {
                              lastDate = DateTime(currentYear -
                                  20); // Supervisor should be at least 20 years old
                            } else {
                              lastDate = DateTime(currentYear -
                                  5); // Non-supervisor should be at least 5 years old
                            }

                            // Show date picker with the adjusted lastDate
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              firstDate: DateTime(1900),
                              lastDate: lastDate, // Set the calculated lastDate
                            );
                            if (pickedDate != null) {
                              setState(() {
                                dobController.text =
                                    "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 25.0),

                        // Email
                        TextFormField(
                          controller: emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Email';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            errorText:
                                _isNotValidate ? "Enter Proper Info" : null,
                            label: const Text('Email'),
                            hintText: 'Enter Email',
                            hintStyle: const TextStyle(
                              color: Colors.black26,
                            ),
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25.0),

                        // Password
                        TextFormField(
                          controller: passwordController,
                          obscureText: !isPasswordVisible,
                          obscuringCharacter: '•',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Password';
                            } else if (value.length < 8) {
                              return 'Password must be at least 8 characters long';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            errorText:
                                _isNotValidate ? "Enter Proper Info" : null,
                            label: const Text('Password'),
                            hintText: 'Enter Password',
                            hintStyle: const TextStyle(color: Colors.black26),
                            prefixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                              suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: ourPink,
                              ),
                              onPressed: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 25.0),

                        // Conditional CV Upload Field
                        if (isSupervisor)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 25.0),
                              const Text(
                                'Upload CV',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 10.0),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      cvFilePath != null
                                          ? cvFilePath!.split('/').last
                                          : 'No file selected',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.upload_file),
                                    onPressed: _pickCvFile,
                                  ),
                                ],
                              ),
                            ],
                          ),

                        const SizedBox(height: 50.0),

                        // Register Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ourPink,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              // shape: RoundedRectangleBorder(
                              //   borderRadius: BorderRadius.circular(10),
                              // ),
                            ),
                            onPressed: () async {
                              if (_formSignupKey.currentState!.validate()) {
                                registerUser();
                              }
                            },
                            child: const Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30.0),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account? ',
                              style: TextStyle(
                                color: Colors.black45,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (e) => const SignInScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Sign in',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: ourBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // const Expanded(
            //   flex: 1,
            //   child: SizedBox(
            //     height: 10,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
