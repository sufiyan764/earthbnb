import 'package:earthbnb/colors.dart';
import 'package:earthbnb/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:earthbnb/PropertiesClass.dart';
import 'checkout.dart'; // Import your CheckoutScreen
import 'widgets/receipt_row.dart';
import 'widgets/custom_button.dart';

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

  void bookNow() {
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
    int amount = property.price * numberOfNights;
    double gst = amount * 0.13;
    double totalAmount = amount + gst;
    return Scaffold(
        appBar: CustomAppBar(appBarText: property.title, appBarLeading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/$type');
          },
        )) ,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      Text(
                        "\$${property.price}/night",
                        style: const TextStyle(
                          color: AppColors.accentTeal,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Divider(
                    thickness: 1,
                    color: AppColors.cardShadow,
                    height: 10,
                  ),

                  const SizedBox(height: 16),
                  Text(
                    property.description,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  const Divider(
                    thickness: 1,
                    color: AppColors.cardShadow,
                    height: 10,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: 'Rooms: ',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          children: [
                            TextSpan(
                              text: property.rooms.toString(),
                              style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text.rich(
                        TextSpan(
                          text: 'Accommodation: ',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          children: [
                            TextSpan(
                              text: property.guests.toString(),
                              style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text.rich(
                        TextSpan(
                          text: 'Bathrooms: ',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          children: [
                            TextSpan(
                              text: property.bathrooms.toString(),
                              style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(
                    thickness: 1,
                    color: AppColors.cardShadow,
                    height: 10,
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      "What we offer",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate((property.amenities.length / 2).ceil(), (index) {
                    final start = index * 2;
                    final end = (start + 2 <= property.amenities.length) ? start + 2 : property.amenities.length;
                    final chunk = property.amenities.sublist(start, end);

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: chunk.map((amenity) {
                        return Text(
                          amenity,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        );
                      }).toList(),
                    );
                  }),
                  const SizedBox(height: 16),
                  const Divider(
                    thickness: 1,
                    color: AppColors.cardShadow,
                    height: 10,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.supervised_user_circle_sharp, color: Colors.teal, size: 90,),
                        const SizedBox(width: 4),
                        Column(
                          children: [
                            Text(
                              "Hosted by ${property.hostName}",
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                            ),
                            const Text(
                              "Superhost",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                              textAlign: TextAlign.start,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(
                    thickness: 1,
                    color: AppColors.cardShadow,
                    height: 10,
                  ),
                  const SizedBox(height: 16),

                  const Center(
                    child: Text(
                      "Ratings",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(5, (index) {
                    final starCount = 5 - index;
                    final userCount = property.rating[starCount - 1];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            children: [
                              ...List.generate(
                                starCount,
                                    (starIndex) => const Icon(Icons.star, color: AppColors.accentTeal, size: 25),
                              ),
                              if (starCount < 5)
                                ...List.generate(
                                  5 - starCount,
                                      (starIndex) => const Icon(Icons.star_border, color: AppColors.accentTeal, size: 25),
                                ),
                            ],
                          ),
                          const Text(
                            '-',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            '$userCount Users',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  const Divider(
                    thickness: 1,
                    color: AppColors.cardShadow,
                    height: 10,
                  ),
                  const SizedBox(height:20),

                  Center(
                    child: CustomButton(buttonText: numberOfNights > 0 ? "Edit Dates" : "Reserve Dates", isColored: numberOfNights > 0 ? "false" : "true", onPressed: _selectDateRange, buttonColor: AppColors.accentTeal)
                  ),
                  const SizedBox(height: 16),
                  if(checkInDate != null && checkOutDate != null && numberOfNights > 0)
                    Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ReceiptRow(keyText: 'Check-in:', valueText: _formatDate(checkInDate)),
                            const SizedBox(height: 8),
                            ReceiptRow(keyText: 'Check-out:', valueText: _formatDate(checkOutDate)),
                            const SizedBox(height: 8),
                            ReceiptRow(keyText: 'Price for $numberOfNights nights:', valueText: '\$${amount.toStringAsFixed(2)}'),
                            const SizedBox(height: 8),
                            ReceiptRow(keyText: 'GST (13%):', valueText: '\$${gst.toStringAsFixed(2)}'),
                            const SizedBox(height: 8),
                            ReceiptRow(keyText: 'Total Amount:', valueText: '\$${totalAmount.toStringAsFixed(2)}'),
                            const SizedBox(height: 16),
                            CustomButton(buttonText: 'Book Now', isColored: "true", onPressed: bookNow, buttonColor: AppColors.accentTeal)
                          ],
                        )
                    ),
                  const SizedBox(height: 25),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppNavigation(selectedIndex: navigationIndex),
    );
  }

  Widget _buildReceiptRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30), // Adjust horizontal padding to control row width
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between key and value
        children: [
          Expanded(
            child: Text(
              key,
              style: TextStyle(
                fontWeight: key == "Total Amount:" ? FontWeight.bold : FontWeight.normal,
                fontSize: key == "Total Amount:" ? 22 : 18,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: key == "Total Amount:" ? FontWeight.bold : FontWeight.normal,
              fontSize: key == "Total Amount:" ? 22 : 18,
            ),
          ),
        ],
      ),
    );
  }
}


