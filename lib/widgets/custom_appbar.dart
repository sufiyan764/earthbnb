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
      title: Text(appBarText),
      centerTitle: true,
      backgroundColor: AppColors.accentTeal,
      foregroundColor: AppColors.backgroundWhite,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
