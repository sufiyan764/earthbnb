import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
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
    print("tripKey------------------__> $tripKey");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trips'),
        leading: null,
      ),
      body: FutureBuilder<List<Trips>>(
        future: tripsProperties,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('You do not have any trips yet'));
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
                  margin: EdgeInsets.all(8.0),
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
                            return Image.asset(
                              'assets/images/properties/${trip.images[imgIndex]}',
                              fit: BoxFit.cover,
                              width: MediaQuery.of(context).size.width,
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
                            Text(trip.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  averageRating.toStringAsFixed(1), // Show average rating
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            Text(trip.location),
                            Text('Check-in: ${tripInfo?['checkInDate']} - Check-out: ${tripInfo?['checkOutDate']}'),
                            Text('Total Amount: \$${totalAmount}'),
                          ],
                        ),
                      ),
                      // Rating Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Row(
                          children: List.generate(5, (starIndex) {
                            final userRating = tripInfo?['rating'] ?? 0; // Default to 0 if no rating exists
                            return IconButton(
                              icon: Icon(
                                Icons.star,
                                color: userRating > starIndex ? Colors.amber : Colors.grey,
                              ),
                              onPressed: userRating > 0
                                  ? null // Disable button if a rating already exists
                                  : () => updateRating(trip.id, starIndex + 1, tripInfo?['key']),
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
