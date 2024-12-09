import 'package:earthbnb/widgets/custom_appbar.dart';
import 'package:earthbnb/widgets/custom_button.dart';
import 'package:earthbnb/widgets/format_date.dart';
import 'package:flutter/material.dart';
import 'package:earthbnb/PropertiesClass.dart';

import 'colors.dart';

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
      appBar: const CustomAppBar(appBarText: 'Thank You', appBarLeading: null),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.teal,
                size: 120,
              ),
              const SizedBox(height: 16),
              Text(
                'Booking Confirmed!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        property.location,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const Divider(height: 24, thickness: 1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Check-In:'),
                          FormattedDateWidget(
                            date: checkInDate,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Check-Out:'),
                          FormattedDateWidget(
                            date: checkOutDate,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Thank you for booking with EarthBnB. We hope you have a wonderful stay!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 32),
              CustomButton(buttonText: 'Back to Explore', isColored: "true", onPressed: () {
                Navigator.pushNamed(context, '/properties');
              }, buttonColor: AppColors.accentTeal),
            ],
          ),
        ),
      ),
    );
  }
}
