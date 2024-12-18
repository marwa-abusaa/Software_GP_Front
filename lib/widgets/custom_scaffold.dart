import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/app_colors.dart';

class CustomScaffold extends StatelessWidget {
  const CustomScaffold({super.key, this.child});
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: ourPink,
          size: 25,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Red background container
          Container(
            color: offwhite, // Set the background color to red
            width: double.infinity,
            height: double.infinity,
          ),
          Positioned(
            top: -58,
            left: MediaQuery.of(context).size.width / 2 - 190,
            child: Image.asset(
              'assets/images/logo2.png',
              width: 360,
              height: 360,
            ),
          ),
          SafeArea(
            child: child!,
          ),
        ],
      ),
    );
  }
}
