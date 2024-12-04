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

  Future<List<Wishlist>> loadWishlistProperties() async {
    final user = _auth.currentUser;
    final DatabaseReference ref = FirebaseDatabase.instance.ref('wishlist/${user?.uid}');
    DataSnapshot snapshot = await ref.get();
    print("snapshot----------------_> " + snapshot.toString());
    if (snapshot.exists) {
      print("snapshot.value----------------_> " + snapshot.value.toString());
      if (snapshot.value is Map) {
        List<Wishlist> wishlist = [];
        Map<Object?, Object?> wishlistMap = snapshot.value as Map<Object?, Object?>;
        print("wishlistMap -----------------> ${wishlistMap}");

        wishlistMap.forEach((key, value) {
          try {
            print("Processing item with key: $key and value: $value");
            if (value is Map<Object?, Object?>) {
              wishlist.add(Wishlist.fromJson(Map<String, dynamic>.from(value)));
            } else {
              print("Skipping item with key: $key because value is not a Map");
            }
          } catch (e) {
            print("Error processing item with key: $key. Error: $e");
          }
        });

        print("wishlist -----------------> $wishlist");
        return wishlist;
      } else {
        print("not list");
        throw Exception('Unexpected data format: Expected a List');
      }
    } else {
      print("no data");
      throw Exception('No data available');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wishlist'),
        leading: null,
      ),
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
