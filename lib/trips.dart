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

  Future<List<Trips>> loadTripsProperties() async {
    final user = _auth.currentUser;
    final DatabaseReference ref = FirebaseDatabase.instance.ref('trips/${user?.uid}');
    DataSnapshot snapshot = await ref.get();
    if (snapshot.exists) {
      if (snapshot.value is List) {
        List<dynamic> tripsArray = snapshot.value as List<dynamic>;
        List<Trips> trips = [];

        for (var tripsData in tripsArray) {
          trips.add(Trips.fromJson(Map<String, dynamic>.from(tripsData)));
        }

        return trips;
      } else {
        throw Exception('Unexpected data format: Expected a List');
      }
    } else {
      throw Exception('No data available');
    }
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
                  final wish = trips[index];
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
        bottomNavigationBar: AppNavigation(selectedIndex: 2)
    );
  }
}
