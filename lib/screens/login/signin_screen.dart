import 'dart:convert';
import 'package:flutter_application_1/api/notification_services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/api.dart';
import 'package:flutter_application_1/config.dart';
import 'package:flutter_application_1/screens/supervisors/supervisor_home_screen.dart';
import 'package:flutter_application_1/screens/users/home_screen.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:flutter_application_1/screens/login/signup_screen.dart';
import 'package:flutter_application_1/widgets/custom_scaffold.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/screens/login/forget_password.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _auth = FirebaseAuth.instance;
  final _formSignInKey = GlobalKey<FormState>();
  bool rememberPassword = true;
  bool isPasswordVisible = false; // Track password visibility
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initSharedPref();
    print(APIS.user?.email);
    _clearFirebaseAuth(); // Ensure no old user is signed in
    print(APIS.user?.email);
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  void loginUser() async {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      var reqBody = {
        "email": emailController.text,
        "password": passwordController.text,
      };

      try {
        var response = await http.post(
          Uri.parse(login),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(reqBody),
        );
        // Handle response based on status code
        if (response.statusCode == 200) {
          try {
            final user = await _auth.signInWithEmailAndPassword(
                email: emailController.text, password: passwordController.text);

            APIS.initializeEmail(emailController.text);
          } catch (e) {
            print(e);
          }
          // Successful login
          var jsonResponse = jsonDecode(response.body);
          var myToken = jsonResponse['token'];
          TOKEN = myToken;
          var role = jsonResponse['role'];
          ROLE = role;
          prefs.setString('token', myToken);
          if (role == "user") {
            await NotificationService.subscribeToTopic();

            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HomeScreen(
                        token: myToken,
                      )),
            );
            // CompetitionsScreen();
            // HomeScreen();
          } else if (role == "supervisor") {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SupervisorHomeScreen(
                        token: myToken,
                      )),
            );
          }
          // add another else for the admin ...
        } else if (response.statusCode == 400) {
          // Bad Request
          var jsonResponse = jsonDecode(response.body);
          showErrorSnackbar(
              jsonResponse['error'] ?? 'Email and password are required');
        } else if (response.statusCode == 401) {
          // Unauthorized
          var jsonResponse = jsonDecode(response.body);
          showErrorSnackbar(
              jsonResponse['error'] ?? 'Invalid email or password');
        } else if (response.statusCode == 403) {
          // Forbidden - Special message for supervisors whose request hasn't been accepted
          var jsonResponse = jsonDecode(response.body);
          showErrorSnackbar(jsonResponse['error'] ??
              'The admin still has not accepted your request for being a supervisor in TinyTales');
        } else if (response.statusCode == 404) {
          // Not Found
          var jsonResponse = jsonDecode(response.body);
          showErrorSnackbar(jsonResponse['error'] ?? 'User does not exist');
        } else {
          // Other unexpected responses
          showErrorSnackbar('Something went wrong. Please try again later.');
        }
      } catch (e) {
        // Handle any exceptions that occur during the request
        print("Error: $e");
        showErrorSnackbar(
            'An error occurred. Please check your connection and try again.');
      }
    } else {
      showErrorSnackbar('Please fill in all fields.');
    }
  }

// Function to display an error message using a SnackBar
  void showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
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
              flex: 8,
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
                    key: _formSignInKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Welcome back',
                          style: TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.w600,
                            color: ourPink,
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        TextFormField(
                          controller: emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Email';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            label: const Text('Email'),
                            hintText: 'Enter Email',
                            hintStyle: const TextStyle(
                              color: Colors.black26,
                            ),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black12, // Default border color
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black12, // Default border color
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15.0,
                        ),
                        TextFormField(
                          controller: passwordController,
                          obscureText: !isPasswordVisible, // Control visibility
                          obscuringCharacter: '•',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Password';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            label: const Text('Password'),
                            hintText: 'Enter Password',
                            hintStyle: const TextStyle(
                              color: Colors.black26,
                            ),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black12, // Default border color
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black12, // Default border color
                              ),
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
                        const SizedBox(
                          height: 25.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: rememberPassword,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      rememberPassword = value!;
                                    });
                                  },
                                  activeColor: ourBlue,
                                ),
                                const Text(
                                  'Remember me',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black45,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgotPassword()), // Navigates to the ForgotPassword page
                                );
                              },
                              child: const Text(
                                'Forget password?',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: ourBlue,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 25.0,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: ourPink),
                            onPressed: () {
                              if (_formSignInKey.currentState!.validate() &&
                                  rememberPassword) {
                                loginUser();
                                // ScaffoldMessenger.of(context).showSnackBar(
                                //   const SnackBar(
                                //     content: Text('Processing Data'),
                                //   ),
                                // );
                              } else if (!rememberPassword) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Please agree to the processing of personal data')),
                                );
                              }
                            },
                            child: const Text('Sign in'),
                          ),
                        ),
                        const SizedBox(
                          height: 25.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Divider(
                                thickness: 0.7,
                                color: Colors.grey.withOpacity(0.5),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 0,
                                horizontal: 10,
                              ),
                              child: Text(
                                'Sign up with',
                                style: TextStyle(
                                  color: Colors.black45,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                thickness: 0.7,
                                color: Colors.grey.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 25.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Logo(Logos.facebook_f),
                            Logo(Logos.twitter),
                            Logo(Logos.google),
                            Logo(Logos.apple),
                          ],
                        ),
                        const SizedBox(
                          height: 25.0,
                        ),
                        // don't have an account
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Don\'t have an account? ',
                              style: TextStyle(
                                color: Colors.black45,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (e) => const SignUpScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Sign up',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: ourBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _clearFirebaseAuth() async {
  try {
    await APIS.auth.signOut(); // Sign out any previously signed-in user
    print("Successfully signed out from Firebase Authentication.");
  } catch (e) {
    print("Error signing out: $e");
  }
}
