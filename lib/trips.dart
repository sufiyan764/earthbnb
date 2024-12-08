import 'package:flutter/material.dart';
import 'package:earthbnb/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'TripsClass.dart';
import 'navigation.dart';

class TripsScreen extends StatefulWidget {
  @override
  _TripsScreenState createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  final _auth = FirebaseAuth.instance;
  late Future<List<Trips>> tripsProperties;

  @override
  void initState() {
    super.initState();
    tripsProperties = loadTripsProperties();
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

  Future<List<Trips>> loadTripsProperties() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final DatabaseReference ref = FirebaseDatabase.instance.ref('trips/${user.uid}');
    DataSnapshot snapshot = await ref.get();

    if (!snapshot.exists) {
      print("No data available");
      throw Exception('No data available');
    }

    if (snapshot.value is List) {
      List<Trips> trips = [];
      List<dynamic> tripsData = List<dynamic>.from(snapshot.value as List);

      for (var item in tripsData) {
        try {
          if (item is Map && item.containsKey('property')) {
            final propertyId = item['property'];
            final propertyRef = FirebaseDatabase.instance.ref('properties/$propertyId');
            DataSnapshot propertySnapshot = await propertyRef.get();

            if (propertySnapshot.exists) {
              final propertyData = Map<String, dynamic>.from(propertySnapshot.value as Map);
              propertyData['tripInfo'] = item; // Attach trip-specific info
              trips.add(Trips.fromJson(propertyData));
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

      return trips;
    } else {
      throw Exception('Unexpected data format: Expected a List');
    }
  }

  Future<void> updateRating(int propertyId, int rating, String tripKey) async {
    propertyId = propertyId - 1;
    final DatabaseReference propertyRef = FirebaseDatabase.instance.ref('properties/$propertyId');
    final DatabaseReference tripRef = FirebaseDatabase.instance.ref('trips/${_auth.currentUser!.uid}/$tripKey');

    final DataSnapshot propertySnapshot = await propertyRef.get();

    if (!propertySnapshot.exists) {
      print("Property not found");
      return;
    }

    // Update properties collection
    final propertyData = Map<String, dynamic>.from(propertySnapshot.value as Map);
    List<int> ratings = List<int>.from(propertyData['rating']);
    ratings[rating - 1] += 1;

    await propertyRef.update({'rating': ratings});

    // Update trips collection
    await tripRef.update({'rating': rating});

    setState(() {
      tripsProperties = loadTripsProperties(); // Refresh data
    });
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';

    // Format date manually
    final months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'Trips',
          style: TextStyle(
            color: AppColors.textDarkGray,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AppColors.backgroundWhite,
        leading: null,
      ),
      body: FutureBuilder<List<Trips>>(
        future: tripsProperties,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('You do not have any trips yet'));
          } else {
            List<Trips> trips = snapshot.data!;
            return ListView.builder(
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];
                final averageRating = calculateAverageRating(trip.rating);
                final tripInfo = trip.tripInfo;
                final amount = tripInfo?['amount'] ?? 0; // Default to 0 if null
                final numberOfNights = tripInfo?['numberOfNights'] ?? 0;
                final totalAmount = (amount * numberOfNights * 1.13).toStringAsFixed(2);

                return Card(
                  color: AppColors.backgroundWhite,
                  margin: const EdgeInsets.only(left: 16, top:8, bottom:8, right:16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Slider
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: trip.images.length,
                          itemBuilder: (context, imgIndex) {
                            return ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(16)),
                              child: Image.asset(
                                'assets/images/properties/${trip.images[imgIndex]}',
                                fit: BoxFit.cover,

                                width: MediaQuery.of(context).size.width,
                              ),
                            );
                          },
                        ),
                      ),

                      // Property Details
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trip.title,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              trip.location,
                              style: const TextStyle(
                                color: AppColors.textDarkGray,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Highlight Check-in and Check-out
                            Text.rich(
                              TextSpan(
                                text: 'Check-in: ',
                                style: const TextStyle(fontWeight: FontWeight.bold), // Bold Check-in label
                                children: [
                                  TextSpan(
                                    text: _formatDate(tripInfo?['checkInDate']),
                                    style: const TextStyle(fontWeight: FontWeight.normal), // Normal for the date
                                  ),
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: 'Check-out: ',
                                style: const TextStyle(fontWeight: FontWeight.bold), // Bold Check-out label
                                children: [
                                  TextSpan(
                                    text: _formatDate(tripInfo?['checkOutDate']),
                                    style: const TextStyle(fontWeight: FontWeight.normal), // Normal for the date
                                  ),
                                ],
                              ),
                            ),

                            Text.rich(
                              TextSpan(
                                text: 'Total Ammount: ',
                                style: const TextStyle(fontWeight: FontWeight.bold), // Bold Check-out label
                                children: [
                                  TextSpan(
                                    text: totalAmount,
                                    style: const TextStyle(fontWeight: FontWeight.normal), // Normal for the date
                                  ),
                                ],
                              ),
                            ),

                          ],
                        ),
                      ),
                      // Rating Section
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0), // Reduce vertical padding
                        child: Row(
                          children: List.generate(5, (starIndex) {
                            final userRating = tripInfo?['rating'] ?? 0; // Default to 0 if no rating exists
                            return IconButton(
                              icon: Icon(
                                Icons.star,
                                size: 30, // Adjust the size of the star if needed
                                color: userRating > starIndex ? AppColors.accentTeal : Colors.grey,
                              ),
                              padding: const EdgeInsets.all(0.0), // Reduce padding around each star
                              onPressed: userRating > 0
                                  ? null // Disable button if a rating already exists
                                  : () => updateRating(trip.id, starIndex + 1, index.toString()),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: AppNavigation(selectedIndex: 2),
    );
  }
}
