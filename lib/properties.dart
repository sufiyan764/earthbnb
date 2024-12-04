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
                  return ListTile(
                    title: Text(property.title),
                    subtitle: Text(property.location),
                    trailing: Text('\$${property.price}/night'),
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
                        arguments: property,
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