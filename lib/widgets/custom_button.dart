import 'package:flutter/material.dart';

import '../colors.dart';

class CustomButton extends StatelessWidget {
  final String buttonText;
  final String isColored;
  final VoidCallback onPressed;
  final Color buttonColor;

  // Constructor to receive the key and value as parameters
  const CustomButton({
    super.key,
    required this.buttonText,
    required this.isColored,
    required this.onPressed,
    required this.buttonColor
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: isColored == "true" ? buttonColor : null,
          foregroundColor: isColored == "true" ? AppColors.backgroundWhite : null,
        ),
        child: Text(
          buttonText,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    )
    ;
  }
}
