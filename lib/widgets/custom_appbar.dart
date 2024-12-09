import 'package:flutter/material.dart';

import '../colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String appBarText;
  final IconButton? appBarLeading;

  const CustomAppBar({
    super.key,
    required this.appBarText,
    this.appBarLeading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120.0,
      color: AppColors.accentTeal,
      child: Stack(
        children: [
          // Leading IconButton
          if (appBarLeading != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: appBarLeading,
              ),
            ),
          // Centered Title and Logo
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/earthbnb.png',
                    height: 50.0,
                    width: 50.0,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  appBarText,
                  style: const TextStyle(
                    fontSize: 20,
                    color: AppColors.backgroundWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(120.0);
}
