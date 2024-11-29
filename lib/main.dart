import 'package:earthbnb/PropertiesClass.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';


import 'firebase_options.dart';
import 'navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ApartmentListScreen(),
    );
  }
}

Future<List<Property>> loadProperties() async {
  // Load the JSON file from assets
  String jsonString = await rootBundle.loadString('assets/properties.json');
  // Decode the JSON string to a List
  List<dynamic> jsonList = json.decode(jsonString);
  // Convert the List to a List of Apartment objects
  return jsonList.map((json) => Property.fromJson(json)).toList();
}

class ApartmentListScreen extends StatefulWidget {
  @override
  _ApartmentListScreenState createState() => _ApartmentListScreenState();
}

class _ApartmentListScreenState extends State<ApartmentListScreen> {
  late Future<List<Property>> properties;

  @override
  void initState() {
    super.initState();
    properties = loadProperties();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Properties'),
      ),
      body: FutureBuilder<List<Property>>(
        future: properties,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading apartments'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No apartments available'));
          } else {
            List<Property> properties = snapshot.data!;
            return ListView.builder(
              itemCount: properties.length,
              itemBuilder: (context, index) {
                final property = properties[index];
                return ListTile(
                  title: Text(property.title),
                  subtitle: Text(property.location),
                  trailing: Text('\$${property.price}/night'),
                  leading: property.images.isNotEmpty
                      ? SizedBox(
                    width: 100, // Set the width for each image
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: property.images.length,
                      itemBuilder: (context, imgIndex) {
                        return Image.asset('assets/images/properties/${property.images[imgIndex]}');
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
        bottomNavigationBar: AppNavigation(selectedIndex: 0)
    );
  }
}
