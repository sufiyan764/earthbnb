import 'package:flutter/material.dart';

import '../colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String appBarText;
  final IconButton? appBarLeading;

  // Constructor to receive the key and value as parameters
  const CustomAppBar({
    super.key,
    required this.appBarText,
    this.appBarLeading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: appBarLeading ?? Container(),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(
            child: Image.asset(
              'assets/earthbnb.png', // Path to your app icon
              height: 40.0, // Adjust the size
              width: 40.0,
              fit: BoxFit.cover, // Ensures the image fits properly in the circle
            ),
          ),
          const SizedBox(width: 8), // Spacing between icon and text
          Text(appBarText),
        ],
      ),
      centerTitle: true,
      backgroundColor: AppColors.accentTeal,
      foregroundColor: AppColors.backgroundWhite,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
