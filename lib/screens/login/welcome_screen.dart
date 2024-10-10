import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/login/signin_screen.dart';
import 'package:flutter_application_1/screens/login/signup_screen.dart';
import 'package:flutter_application_1/widgets/welcome_button.dart';
import 'package:flutter_application_1/constants/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/1.png'),
                fit: BoxFit.cover, // Makes sure the image covers the entire background
              ),
            ),
          ),

          // The content on top of the background image
          Column(
            children: [
              Flexible(
                flex: 6,
                child: Container(), // Spacer to push buttons down
              ),
              Flexible(
                flex: 1,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: WelcomeButton(
                          buttonText: 'Sign in',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignInScreen(),
                              ),
                            );
                          },
                          color: orangee,
                          textColor: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(50),
                          ),
                        ),
                      ),
                      Expanded(
                        child: WelcomeButton(
                          buttonText: 'Sign up',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpScreen(),
                              ),
                            );
                          },
                          color: ourPink,
                          textColor: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(50),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
