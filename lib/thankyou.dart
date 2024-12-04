import 'package:flutter/material.dart';
import 'package:earthbnb/PropertiesClass.dart';

class ThankYouScreen extends StatelessWidget {
  final Property property;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;

  const ThankYouScreen({
    Key? key,
    required this.property,
    required this.checkInDate,
    required this.checkOutDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thank You'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('Property: ${property.title}'),
            Text('Location: ${property.location}'),
            Text('Check-In: ${checkInDate?.toLocal()}'),
            Text('Check-Out: ${checkOutDate?.toLocal()}'),
            const SizedBox(height: 16),
            const Text(
              'Thank you for your booking!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/properties'); // Replace with your explore route
              },
              child: const Text('Back to Explore'),
            ),
          ],
        ),
      ),
    );
  }
}
