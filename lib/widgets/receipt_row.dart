import 'package:flutter/material.dart';

class ReceiptRow extends StatelessWidget {
  final String keyText;
  final String valueText;

  // Constructor to receive the key and value as parameters
  const ReceiptRow({Key? key, required this.keyText, required this.valueText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30), // Adjust horizontal padding to control row width
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between key and value
        children: [
          Expanded(
            child: Text(
              keyText,
              style: TextStyle(
                fontWeight: keyText == "Total Amount:" ? FontWeight.bold : FontWeight.normal,
                fontSize: keyText == "Total Amount:" ? 22 : 18,
              ),
            ),
          ),
          Text(
            valueText,
            style: TextStyle(
              fontWeight: keyText == "Total Amount:" ? FontWeight.bold : FontWeight.normal,
              fontSize: keyText == "Total Amount:" ? 22 : 18,
            ),
          ),
        ],
      ),
    );
  }
}
