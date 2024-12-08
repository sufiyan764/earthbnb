import 'package:earthbnb/PropertiesClass.dart';
import 'package:earthbnb/colors.dart';
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
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'Explore Properties',
          style: TextStyle(
            color: AppColors.textDarkGray,
            fontSize:  20,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AppColors.backgroundWhite,
        elevation: 1,
      ),
      body: FutureBuilder<List<Property>>(
        future: properties,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No properties available',
                style: TextStyle(color: AppColors.textDarkGray),
              ),
            );
          }

          List<Property> propertiesList = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 properties per row
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 3 / 4, // Aspect ratio for property cards
            ),
            itemCount: propertiesList.length,
            itemBuilder: (context, index) {
              final property = propertiesList[index];
              final averageRating = calculateAverageRating(property.rating);

              return _buildPropertyCard(
                context,
                property,
                averageRating,
              );
            },
          );
        },
      ),
      bottomNavigationBar: const AppNavigation(selectedIndex: 0),
    );
  }

  Widget _buildPropertyCard(BuildContext context, Property property, double averageRating) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacementNamed(
          context,
          '/propertydetails',
          arguments: {
            'property': property,
            'type': 'properties',
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: property.images.isNotEmpty
                    ? Image.asset(
                  'assets/images/properties/${property.images[0]}',
                  fit: BoxFit.cover,
                )
                    : Image.asset(
                  'assets/images/properties/default.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Property Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                property.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDarkGray,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            // Location
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                property.location,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textDarkGray,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Spacer(),
            // Price & Rating Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: AppColors.accentTeal,
                        size: 18,
                      ),
                      const SizedBox(width: 3.5),
                      Text(
                        averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '\$${property.price}/night',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentTeal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}