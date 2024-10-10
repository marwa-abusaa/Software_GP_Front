import 'package:flutter/material.dart';

class WelcomeButton extends StatelessWidget {
  const WelcomeButton({
    super.key,
    required this.buttonText,
    required this.onTap,
    required this.color,
    required this.textColor,
    this.borderRadius,
  });

  final String buttonText;
  final VoidCallback onTap; // Expecting a function instead of Widget
  final Color color;
  final Color textColor;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Trigger the onTap function on tap
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: 15.0), // Adjust padding for better proportions
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius ??
              BorderRadius.circular(
                  0), // Use provided borderRadius or default to 0
        ),
        child: Text(
          buttonText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18.0, // Adjust font size for better readability
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
