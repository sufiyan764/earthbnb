import 'package:earthbnb/properties.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'wishlist.dart';

class AppNavigation extends StatelessWidget {
  final int selectedIndex;

  const AppNavigation({super.key, required this.selectedIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index == selectedIndex) return; // Prevent reload of the same page
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/properties');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/wishlist');
        break;
        case 2:
      Navigator.pushReplacementNamed(context, '/trips');
      break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) => _onItemTapped(context, index),
      selectedItemColor: Colors.blue, // Set your selected color here
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true, // Make sure the label for the selected item is always visible
      showUnselectedLabels: true,
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
