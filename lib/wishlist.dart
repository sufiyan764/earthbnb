import 'package:earthbnb/PropertiesClass.dart';
import 'package:earthbnb/colors.dart';
import 'package:earthbnb/widgets/custom_appbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'WishlistClass.dart';
import 'navigation.dart';

class WishlistScreen extends StatefulWidget {
  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final _auth = FirebaseAuth.instance;
  late Future<List<Wishlist>> wishlistProperties;

  @override
  void initState() {
    super.initState();
    wishlistProperties = loadWishlistProperties();
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

  Future<List<Wishlist>> loadWishlistProperties() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final DatabaseReference ref = FirebaseDatabase.instance.ref('wishlist/${user.uid}');
    DataSnapshot snapshot = await ref.get();

    if (!snapshot.exists) {
      print("No data available");
      throw Exception('No data available');
    }

    if (snapshot.value is List) {
      List<Wishlist> wishlist = [];
      List<dynamic> wishlistData = List<dynamic>.from(snapshot.value as List);

      for (var item in wishlistData) {
        try {
          if (item is Map && item.containsKey('property')) {
            final propertyId = item['property'] - 1;
            final propertyRef = FirebaseDatabase.instance.ref('properties/$propertyId');
            DataSnapshot propertySnapshot = await propertyRef.get();

            if (propertySnapshot.exists) {
              final propertyData = Map<String, dynamic>.from(propertySnapshot.value as Map);
              wishlist.add(Wishlist.fromJson(propertyData));
            } else {
              print("Property with ID $propertyId not found in properties collection");
            }
          } else {
            print("Skipping item: $item as it doesn't contain a valid property reference");
          }
        } catch (e) {
          print("Error processing item: $item. Error: $e");
        }
      }

      return wishlist;
    } else {
      print("Unexpected data format: Expected a List");
      throw Exception('Unexpected data format: Expected a List');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: const CustomAppBar(appBarText: 'Wishlist'),
      body: FutureBuilder<List<Wishlist>>(
        future: wishlistProperties,

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Your wishlist is empty'));
          } else {
            List<Wishlist> wishlist = snapshot.data!;
            return ListView.builder(
              itemCount: wishlist.length,
              itemBuilder: (context, index) {
                final wish = wishlist[index];
                final averageRating = calculateAverageRating(wish.rating);
                return ListTile(
                  title: Text(wish.title),
                  subtitle: Text(wish.location),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: AppColors.accentTeal, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            averageRating.toStringAsFixed(1), // Show average rating
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      Text(
                        '\$${wish.price}/night',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  leading: wish.images.isNotEmpty
                      ? SizedBox(
                    width: 100, // Set the width for each image
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: wish.images.length,
                      itemBuilder: (context, imgIndex) {
                        return Image.asset(
                            'assets/images/properties/${wish.images[imgIndex]}');
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
                        'property': wish.toProperty(),
                        'type': 'wishlist'
                      },
                    );
                  },
                );
              },
            );
          }
        },
      ),
        bottomNavigationBar: AppNavigation(selectedIndex: 1)
    );
  }
}
