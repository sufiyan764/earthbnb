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
  late String type;

  DateTime? checkInDate;
  DateTime? checkOutDate;
  int numberOfNights = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    property = args['property'] as Property;
    type = args['type'];

    _checkWishlistStatus();
  }

  Future<void> _checkWishlistStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final wishlistRef = FirebaseDatabase.instance.ref('wishlist/${user.uid}');
    final snapshot = await wishlistRef.get();

    if (!snapshot.exists) {
      setState(() {
        isInWishlist = false;
      });
      return;
    }

    // Convert the snapshot to a list and check if the property exists
    final wishlist = List<dynamic>.from(snapshot.value as List);
    final exists = wishlist.any((item) => item['property'] == property.id);

    setState(() {
      isInWishlist = exists;
    });
  }

  Future<void> _toggleWishlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final wishlistRef = FirebaseDatabase.instance.ref('wishlist/${user.uid}');

    // Fetch the current wishlist
    final snapshot = await wishlistRef.get();
    List<dynamic> wishlist = [];
    if (snapshot.exists) {
      wishlist = List<dynamic>.from(snapshot.value as List);
    }

    if (isInWishlist) {
      // Remove the property object from wishlist
      wishlist.removeWhere((item) => item['property'] == property.id);
    } else {
      // Add the property object to wishlist
      wishlist.add({'property': property.id});
    }

    // Update the wishlist in the database
    await wishlistRef.set(wishlist);

    setState(() {
      isInWishlist = !isInWishlist;
    });
  }

  Future<void> _selectDateRange() async {
    final today = DateTime.now();
    final nextYear = DateTime(today.year + 1, 12, 31);

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: checkInDate != null && checkOutDate != null
          ? DateTimeRange(start: checkInDate!, end: checkOutDate!)
          : null,
      firstDate: today,
      lastDate: nextYear,
    );

    if (picked != null) {
      final rangeInDays = picked.end.difference(picked.start).inDays;
      if (rangeInDays > 7) {
        // Show error if the range is more than 7 nights
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("You can only book up to 7 nights."),
          ),
        );
        return;
      }

      setState(() {
        checkInDate = picked.start;
        checkOutDate = picked.end;
        numberOfNights = rangeInDays;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/$type');
          },
        ),
        title: Text(property.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
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
              // Ratings Section
              const SizedBox(height: 16),
              const Text(
                "Ratings",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...List.generate(5, (index) {
                final starCount = index + 1;
                final userCount = property.rating.length > index ? property.rating[index] : 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Row(
                        children: List.generate(
                          starCount,
                              (starIndex) => const Icon(Icons.star, color: Colors.amber, size: 16),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('$userCount Users'),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _selectDateRange,
                child: const Text("Select Check-In and Check-Out Dates"),
              ),
              const SizedBox(height: 8),
              if (checkInDate != null && checkOutDate != null)
                Text(
                  "Selected dates: ${checkInDate!.toLocal()} to ${checkOutDate!.toLocal()}",
                ),
              if (numberOfNights > 0)
                Text(
                  "Number of nights: $numberOfNights",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if(numberOfNights > 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutScreen(
                            property: property,
                            numberOfNights: numberOfNights,
                            checkInDate: checkInDate,
                            checkOutDate: checkOutDate
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please select checkin and checkout dates."),
                      ),
                    );
                  }
                },
                child: const Text('Book Now'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppNavigation(selectedIndex: 0),
    );
  }
}
