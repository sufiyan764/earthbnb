import 'package:flutter/material.dart';

import '../colors.dart';

class CustomInput extends StatelessWidget {
  final String inputText;
  final FormFieldValidator inputValidator;
  final TextEditingController inputController;
  final TextInputType textInputType;
  final int inputMaxLength;

  // Constructor to receive the key and value as parameters
  const CustomInput({
    super.key,
    required this.inputText,
    required this.inputController,
    required this.inputValidator,
    required this.textInputType,
    required this.inputMaxLength
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: inputController,
      decoration: InputDecoration(
        labelText: inputText,
        hintStyle: const TextStyle(color: Colors.black54),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.tealAccent, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        counterText: '',
      ),
      keyboardType: textInputType,
      maxLength: inputMaxLength,
      validator: inputValidator,
      obscureText: inputText == 'Password' || inputText == 'Confirm Password' ? true : false,
    );
  }
}
