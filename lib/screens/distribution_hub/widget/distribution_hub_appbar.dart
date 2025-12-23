import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DistributionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final VoidCallback? onHomePressed; // Optional custom callback
  final double fontSize;
  final bool center;
  final bool isSmallScreen;

  const DistributionAppBar({
    super.key,
    this.actions,
    this.onHomePressed,
    this.fontSize = 23,
    this.center = true,
    required this.isSmallScreen
  });

  @override
  Widget build(BuildContext context) {

    final double effectiveFontSize = (ScreenUtil().screenWidth < 360) ? 18   : fontSize; 
    return AppBar(   
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white, 
      elevation: 0, 
      title: Text( 
        'DISTRIBUTION HUB',
        style: TextStyle(
          fontSize: effectiveFontSize,
          color: Colors.black,
          fontFamily: 'Audiowide',
        ),
      ),
      centerTitle: center,
      leading: isSmallScreen
          ? IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer(); 
              },
              icon: const Icon(Icons.menu, size: 30),
            )
          : null,
      actions: [
        // Home Button
       
        ...?actions,
      ], 
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight, 
            colors: [
              Color(0xFFD6E6F2),
              Color(0xFF7BE7F0),
            ],
            stops: [0.0, 1.0],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}