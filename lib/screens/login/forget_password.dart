import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/widgets/custom_scaffold.dart';
import 'send_password.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/config.dart';
import 'dart:convert';  // Add this import

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {

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
    Widget _buildPasswordTextField() {
      return Container(
        margin: const EdgeInsets.only(right: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8.0),
              child: const Icon(
                Icons.alternate_email_sharp,
                color: ourPink,
              ),
            ),
            const SizedBox(
              width: 10.0,
            ),
            Expanded(
              child: TextField(
                controller: emailController,
                style: const TextStyle(
                  fontSize: 15.0,
                  //fontWeight: FontWeight.w600,
                ),
                decoration: const InputDecoration(
                  hintText: "Email",
                  // hintStyle: TextStyle(
                  //   fontSize: 15.0,
                  //   //fontWeight: FontWeight.w500,
                  // ),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: ourBlue,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

  // Submit Button
Widget _buildSubmitBtn() {
  return SizedBox(
    width: MediaQuery.of(context).size.width,
    height: 60,  // Set the height of the button here
    child: MaterialButton(
      elevation: 0.0,
      highlightElevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: ourBlue,
       onPressed: () {
        // Navigate to PasswordSentPage when button is pressed
        forgetPassword();
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => const sendPassword()),
        // );
      },
      child: const Text(
        "Submit",
        style: TextStyle(
          fontSize: 18.0,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}


    return Scaffold(
       backgroundColor:offwhite,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
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
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back,
                    color: ourPink,
                  ),
                ),
              ),
                    Expanded(
                  flex: 8,
                  child: Container(                  
                    alignment: Alignment.center, // Change position, e.g., Alignment.center, Alignment.topLeft
                    child: Image.asset(
                      "assets/images/forgot3.png",
                      height: 250,
                      //fit: BoxFit.contain, // You can use BoxFit.cover, BoxFit.fill, etc.
                    ),
                  ),
              ),

              Expanded(
                flex: 16,
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Forgot\nPassword?",
                          style: TextStyle(
                            color: ourPink,
                            fontSize: 29.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        Text(
                          "Don't worry, Please enter your email address, we will send you a new password.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 40.0),
                      ],
                    ),
                    _buildPasswordTextField(),
                    const SizedBox(height: 50.0),
                    _buildSubmitBtn()
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}