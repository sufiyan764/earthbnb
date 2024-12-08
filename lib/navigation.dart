import 'package:earthbnb/colors.dart';
import 'package:earthbnb/profile.dart';
import 'package:earthbnb/properties.dart';
import 'package:earthbnb/trips.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'wishlist.dart';

class AppNavigation extends StatelessWidget {
  final int selectedIndex;

  const AppNavigation({super.key, required this.selectedIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index == selectedIndex) return; // Prevent reload of the same page

    Widget targetPage;
    switch (index) {
      case 0:
        targetPage = PropertyListScreen(); // Replace with your actual widget
        break;
      case 1:
        targetPage = WishlistScreen(); // Replace with your actual widget
        break;
      case 2:
        targetPage = TripsScreen(); // Replace with your actual widget
        break;
      case 3:
        targetPage = ProfilePage(); // Replace with your actual widget
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetPage,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) => _onItemTapped(context, index),
      selectedItemColor: AppColors.backgroundWhite, // Set your selected color here
      unselectedItemColor: AppColors.unselectedNavIcon,
      showSelectedLabels: true, // Make sure the label for the selected item is always visible
      showUnselectedLabels: true,
      backgroundColor: AppColors.accentTeal,
      iconSize: 30.0, // Set a fixed icon size for consistency
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.explore),
          label: 'Explore',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Wishlist',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.luggage),
          label: 'Trips',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

}
