import 'package:earthbnb/colors.dart';
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
  late int navigationIndex;

  DateTime? checkInDate;
  DateTime? checkOutDate;
  int numberOfNights = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    property = args['property'] as Property;
    type = args['type'];
    setState(() {
      navigationIndex = type == 'properties' ? 0 : 1;
    });

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

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return "${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}";
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Slider Section (moved outside padding)
            if (property.images.isNotEmpty)
              Stack(
                children: [
                  SizedBox(
                    height: 230,
                    child: PageView.builder(
                      itemCount: property.images.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8), // Shadow and spacing
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/images/properties/${property.images[index]}',
                              fit: BoxFit.cover,
                            ),
                          ),
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

            // Details Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property Title Section
                  Text(
                    property.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Location with Icon
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.black87),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.location,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Dynamic Price
                  Text(
                    "\$${property.price}/night",
                    style: const TextStyle(
                      color: AppColors.accentTeal,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Check-in and Check-out Section
                  ElevatedButton(
                    onPressed: _selectDateRange,
                    child: const Text("Select Check-In and Check-Out Dates"),
                  ),
                  const SizedBox(height: 8),

                  // Display Selected Dates
                  if (checkInDate != null)
                    Text.rich(
                      TextSpan(
                        text: 'Check-in: ',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        children: [
                          TextSpan(
                            text: _formatDate(checkInDate),
                            style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  if (checkOutDate != null)
                    Text.rich(
                      TextSpan(
                        text: 'Check-out: ',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        children: [
                          TextSpan(
                            text: _formatDate(checkOutDate),
                            style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                          ),
                        ],
                      ),
                    ),

                  // Number of Nights
                  if (numberOfNights > 0)
                    Text(
                      "Number of nights: $numberOfNights",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),

                  const SizedBox(height: 16),

                  // Book Now Button
                  ElevatedButton(
                    onPressed: () {
                      if (numberOfNights > 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutScreen(
                              property: property,
                              numberOfNights: numberOfNights,
                              checkInDate: checkInDate,
                              checkOutDate: checkOutDate,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please select check-in and check-out dates."),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentTeal,
                      foregroundColor: AppColors.backgroundWhite,
                    ),
                    child: const Text('Book Now'),
                  ),


                  // Rating Section (Moved to the bottom and listed from 5 to 1)
                  const SizedBox(height:20),
                  const Divider(
                    thickness: 1, // Thickness of the line
                    color: AppColors.cardShadow, // Color of the line
                    height: 10, // Space between content and the line
                  ),
                  const SizedBox(height:20),
                  const Text(
                    "Ratings",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(5, (index) {
                    final starCount = 5 - index; // Reverse the rating stars (5 to 1)
                    final userCount = property.rating.length > index ? property.rating[index] : 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Row(
                            children: List.generate(
                              starCount,
                                  (starIndex) => const Icon(Icons.star, color: AppColors.accentTeal, size: 16),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('$userCount Users'),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppNavigation(selectedIndex: navigationIndex),
    );
  }


}


