import 'package:earthbnb/profile.dart';
import 'package:earthbnb/properties.dart';
import 'package:earthbnb/propertydetails.dart';
import 'package:earthbnb/register.dart';
import 'package:earthbnb/trips.dart';
import 'package:earthbnb/wishlist.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'login.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final initialRoute = await getInitialRoute();
  print("Initial route: $initialRoute");
  runApp(MyApp(initialRoute: initialRoute));
}
Future<String> getInitialRoute() async {// Add a small delay
  final user = FirebaseAuth.instance.currentUser;
  return user != null ? '/properties' : '/';
}
class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({Key? key, required this.initialRoute}) : super(key: key);


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    print("initialRoute $initialRoute");
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: initialRoute,
      onGenerateInitialRoutes: (String initialRoute) {
        // Generate the initial route with no history
        return [
          MaterialPageRoute(
            builder: (context) {
              if (initialRoute == '/properties') {
                return const PropertyListScreen();
              } else {
                return LoginPage();
              }
            },
          ),
        ];
      },
      routes: {
        '/': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/properties': (context) => PropertyListScreen(),
        '/wishlist': (context) => WishlistScreen(),
        '/trips': (context) => TripsScreen(),
        '/profile': (context) => ProfilePage(),
        '/propertydetails': (context) => const PropertyDetailsScreen(),
      },
    );
  }
}



