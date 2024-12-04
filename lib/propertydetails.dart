import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:earthbnb/PropertiesClass.dart';
import 'checkout.dart'; // Import your CheckoutScreen

import 'navigation.dart';

class PropertyDetailsScreen extends StatefulWidget {
  const PropertyDetailsScreen() : super();

  @override
  _PropertyDetailsScreenState createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  bool isInWishlist = false;
  late Property property;
  int numberOfNights = 1; // Counter for the number of nights

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    property = ModalRoute.of(context)?.settings.arguments as Property;
    _checkWishlistStatus();
  }

  Future<void> _checkWishlistStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final wishlistRef =
    FirebaseDatabase.instance.ref('wishlist/${user.uid}/${property.title}');
    final snapshot = await wishlistRef.get();

    setState(() {
      isInWishlist = snapshot.exists;
    });
  }

  Future<void> _toggleWishlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final wishlistRef =
    FirebaseDatabase.instance.ref('wishlist/${user.uid}/${property.title}');

    if (isInWishlist) {
      // Remove from wishlist
      await wishlistRef.remove();
    } else {
      // Add to wishlist
      await wishlistRef.set(property.toJson());
    }

    setState(() {
      isInWishlist = !isInWishlist;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/properties');
          },
        ),
        title: Text(property.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                if (property.images.isNotEmpty)
                  SizedBox(
                    height: 200,
                    child: PageView.builder(
                      itemCount: property.images.length,
                      itemBuilder: (context, index) {
                        return Image.asset(
                          'assets/images/properties/${property.images[index]}',
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: Icon(
                      isInWishlist ? Icons.favorite : Icons.favorite_border,
                      color: isInWishlist ? Colors.red : Colors.white,
                    ),
                    onPressed: _toggleWishlist,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              property.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('Location: ${property.location}'),
            const SizedBox(height: 8),
            Text('Price: \$${property.price}/night'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Number of nights:'),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (numberOfNights > 1) {
                          setState(() {
                            numberOfNights--;
                          });
                        }
                      },
                      icon: const Icon(Icons.remove),
                    ),
                    Text(numberOfNights.toString()),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          numberOfNights++;
                        });
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckoutScreen(
                      property: property,
                      numberOfNights: numberOfNights,
                    ),
                  ),
                );
              },
              child: const Text('Book Now'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppNavigation(selectedIndex: 0),
    );
  }
}
