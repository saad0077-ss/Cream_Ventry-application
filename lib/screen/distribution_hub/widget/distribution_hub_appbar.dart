import 'package:flutter/material.dart';

class DistributionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool automaticallyImplyLeading; // Automatically show leading widget
  final List<Widget>? actions; // Action widgets like icons
  final VoidCallback? onNotificationPressed; // Callback for notification icon
  final Widget? notificationIcon; // Custom notification icon
  final Widget? route; // Custom route widget to navigate to on press
  final double fontSize;
  final bool center;

  const DistributionAppBar({
    super.key,
    this.automaticallyImplyLeading = true,
    this.actions,
    this.onNotificationPressed,
    this.notificationIcon,
    this.route,
    this.fontSize = 23 ,
    this.center = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'DISTRIBUTION HUB',
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.black,
          fontFamily: 'Audiowide',
        ), 
      ),
      centerTitle: center ? true : false,
      leading:
          automaticallyImplyLeading
              ? IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();       
                },
                icon: const Icon(Icons.menu, size: 30),
              )
              : null,
      actions: [
        if (notificationIcon != null)
          IconButton(
            icon: notificationIcon!,
            onPressed:
                onNotificationPressed ??
                () {
                  if (route != null) {
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (context) => route!));
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
