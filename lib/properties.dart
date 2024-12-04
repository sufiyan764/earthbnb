import 'package:earthbnb/PropertiesClass.dart';
import 'package:earthbnb/propertydetails.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'navigation.dart';

Future<List<Property>> loadProperties() async {
  final DatabaseReference ref = FirebaseDatabase.instance.ref('properties');
  DataSnapshot snapshot = await ref.get();
  if (snapshot.exists) {
    if (snapshot.value is List) {
      List<dynamic> propertiesList = snapshot.value as List<dynamic>;
      List<Property> properties = [];

      for (var propertyData in propertiesList) {
        properties.add(Property.fromJson(Map<String, dynamic>.from(propertyData)));
      }

      return properties;
    } else {
      throw Exception('Unexpected data format: Expected a List');
    }
  } else {
    throw Exception('No data available');
  }
}

class PropertyListScreen extends StatefulWidget {
  const PropertyListScreen({super.key});

  @override
  _PropertyListScreenState createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  late Future<List<Property>> properties;

  @override
  void initState() {
    super.initState();
    properties = loadProperties();
  }

  double calculateAverageRating(List<int> ratings) {
    if (ratings.isEmpty) return 0.0;
    int totalRatings = 0;
    int totalUsers = 0;

    for (int i = 0; i < ratings.length; i++) {
      totalRatings += (i + 1) * ratings[i]; // Rating value (1-5) * count of users
      totalUsers += ratings[i];
    }

    return totalUsers > 0 ? totalRatings / totalUsers : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Properties'),
          leading: null,
        ),
        body: FutureBuilder<List<Property>>(
          future: properties,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No properties available'));
            } else {
              List<Property> properties = snapshot.data!;
              return ListView.builder(
                itemCount: properties.length,
                itemBuilder: (context, index) {
                  final property = properties[index];
                  final averageRating = calculateAverageRating(property.rating);
                  return ListTile(
                    title: Text(property.title),
                    subtitle: Text(property.location),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              averageRating.toStringAsFixed(1), // Show average rating
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        Text(
                          '\$${property.price}/night',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    leading: property.images.isNotEmpty
                        ? SizedBox(
                      width: 100, // Set the width for each image
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: property.images.length,
                        itemBuilder: (context, imgIndex) {
                          return Image.asset('assets/images/properties/${property.images[imgIndex]}');
                        },
                      ),
                    )
                        : null,
                    onTap: () {
                      // Navigate to the PropertyDetailsScreen and pass the selected property
                      Navigator.pushReplacementNamed(
                        context,
                        '/propertydetails',
                        arguments: {
                          'property': property,
                          'type': 'properties'
                        },
                      );
                    },
                  );
                },
              );
            }
          },
        ),
        bottomNavigationBar: const AppNavigation(selectedIndex: 0)
    );
  }
}