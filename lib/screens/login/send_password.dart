import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/widgets/custom_scaffold.dart';
import 'package:flutter_application_1/screens/login/signin_screen.dart';
import 'dart:convert';  // Add this import
import 'package:flutter_application_1/config.dart';
import 'package:http/http.dart' as http;


class sendPassword extends StatefulWidget {
  const sendPassword({Key? key}) : super(key: key);

  @override
  State<sendPassword> createState() => _SendPasswordState();
}

class _SendPasswordState extends State<sendPassword> {

  TextEditingController emailController = TextEditingController();

void forgetPassword() async {
    if (emailController.text.isNotEmpty) {
      var regBody = {"email": emailController.text};
      try {
        var response = await http.post(
          Uri.parse(sendResetLink),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regBody),
        );

        if (response.statusCode == 200) {
          Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const sendPassword()),
        );
          var jsonResponse = jsonDecode(response.body);
          print(jsonResponse['status']);
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('email send successfully!')));
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const sendPassword()));
        } else if (response.statusCode == 400) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User does not exist .')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Something went wrong. Please try again later.')));
        }
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('An error occurred. Please try again.')));
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    // Password TextField
    
  // Submit Button
Widget _buildSubmitBtn() {
  return SizedBox(
    width: MediaQuery.of(context).size.width,
    height: 55,  // Set the height of the button here
    child: MaterialButton(
      elevation: 0.0,
      highlightElevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: Color(0xFF42AF3C),
      onPressed: () => {forgetPassword()},
      child: const Text(
        "Didn't get an email ! resend it.",
        style: TextStyle(
          fontSize: 14.0,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}


    return Scaffold(
       backgroundColor: offwhite,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        margin: const EdgeInsets.only(top: 30, left: 25.0, right: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20.0,
            ),
            Expanded(
              flex: 1,
              child: GestureDetector(
                // onTap: () => Navigator.pop(context),
                // child: const Icon(
                //   Icons.arrow_back,
                //   color: ourPink,
                // ),
              ),
            ),            
              const SizedBox(
              height: 40.0,
            ),
                  Expanded(
                flex: 8,                
                child: Container(                  
                  alignment: Alignment.center, // Change position, e.g., Alignment.center, Alignment.topLeft
                  child: Image.asset(
                    "assets/images/done.png",
                    height: 200,
                    //fit: BoxFit.contain, // You can use BoxFit.cover, BoxFit.fill, etc.
                  ),
                ),
            ),
      
            Expanded(
              flex: 16,
              child: Column(
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [  
                      SizedBox(height: 30.0),                  
                      Text(
                        "Please, check your email,      we sent you a new password.",
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 40.0),
                    ],
                  ),
                  
                  const SizedBox(height: 50.0),
                  _buildSubmitBtn(),
                  const SizedBox(height: 40.0),
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Sign in with new password! ',
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
                                color: Color(0xFF42AF3C),
                              ),
                            ),
                          ),
                        ],


                  ),
                  
                ],
              ),
            ),

         
          ],
        ),
      ),
    );
  }
}