import 'package:flutter/material.dart';
import 'package:earthbnb/PropertiesClass.dart';

class CheckoutScreen extends StatelessWidget {
  final Property property;
  final int numberOfNights;

  const CheckoutScreen({
    Key? key,
    required this.property,
    required this.numberOfNights,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int amount = property.price * numberOfNights;
    double gst = amount * 0.13;
    double totalAmount = amount + gst;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'Email Address'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Address',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(labelText: 'Street'),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'Unit'),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'City'),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'Province'),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'Country'),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'Postal Code'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Card Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(labelText: 'Name on Card'),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'Card Number'),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'CVV'),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'Expiry MMYY'),
            ),
            const SizedBox(height: 16),
            Text(
              'Amount: \$${amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'GST (13%): \$${gst.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Total Amount: \$${totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Implement payment or confirmation logic
              },
              child: const Text('Confirm Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
