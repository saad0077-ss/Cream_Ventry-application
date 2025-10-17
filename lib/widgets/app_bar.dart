import 'package:cream_ventory/themes/font_helper/font_helper.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title; // Title for the app bar
  final bool automaticallyImplyLeading; // Automatically show leading widget
  final List<Widget>? actions; // Action widgets like icons
  final VoidCallback? onNotificationPressed; // Callback for notification icon
  final Widget? notificationIcon; // Custom notification icon
  final Widget? route; // Custom route widget to navigate to on press
  final VoidCallback? onBackPressed; // Custom callback for back button
  final double fontSize;
  final bool center;

  const CustomAppBar({
    super.key,
    required this.title,
    this.automaticallyImplyLeading = true,
    this.actions,
    this.onNotificationPressed,
    this.notificationIcon,
    this.route,
    this.onBackPressed,
    this.fontSize = 30,
    this.center = true,
  }); 

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      elevation: 0,
      title: Text(
        title,
        style: AppTextStyles.appBarHoltwood(fontSize: fontSize), 
      ),
      centerTitle: center,
      leading: automaticallyImplyLeading
          ? IconButton(
              onPressed: onBackPressed ??
                  () {
                    Navigator.of(context).pop();
                  },
              icon: const Icon(
                Icons.arrow_back_ios_new_outlined,
                size: 30,
                color: Colors.black87, // Ensure icon contrasts with gradient
              ),
            )
          : null,
      actions: [
        if (notificationIcon != null)
          IconButton(
            icon: notificationIcon!,
            onPressed: onNotificationPressed ??
                () {
                  if (route != null) {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) => route!));
                  }
                },
          ),
        ...?actions,
      ],
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFD6E6F2), // Soft blue-gray (matches ScreenHome)
              Color(0xFF7BE7F0), // Subtle cyan (matches ScreenHome)
            ],
            stops: [0.0, 1.0], // Smooth transition for app bar
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}