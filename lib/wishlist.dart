import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'PropertiesClass.dart';
import 'WishlistClass.dart';
import 'navigation.dart';

class WishlistScreen extends StatefulWidget {
  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  late Future<List<Wishlist>> wishlistProperties;

  @override
  void initState() {
    super.initState();
    wishlistProperties = loadWishlistProperties();
  }

  Future<List<Wishlist>> loadWishlistProperties() async {
    // Load the JSON file from assets
    String jsonString = await rootBundle.loadString('assets/wishlist.json');
    // Decode the JSON string to a List
    List<dynamic> jsonList = json.decode(jsonString);
    // Convert the List to a List of Wishlist objects
    return jsonList.map((json) => Wishlist.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wishlist'),
      ),
      body: FutureBuilder<List<Wishlist>>(
        future: wishlistProperties,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading wishlist properties'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Your wishlist is empty'));
          } else {
            List<Wishlist> wishlist = snapshot.data!;
            return ListView.builder(
              itemCount: wishlist.length,
              itemBuilder: (context, index) {
                final wish = wishlist[index];
                return ListTile(
                  title: Text(wish.title),
                  subtitle: Text(wish.location),
                  trailing: Text('\$${wish.price}/night'),
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
