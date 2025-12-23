import 'package:cream_ventory/core/constants/font_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool automaticallyImplyLeading;
  final List<Widget>? actions;
  final VoidCallback? onNotificationPressed;
  final Widget? notificationIcon;
  final Widget? route;
  final VoidCallback? onBackPressed;
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
    final double effectiveFontSize =
        (ScreenUtil().screenWidth < 360) ? 25 : fontSize;

    return AppBar(
      automaticallyImplyLeading: false, // We handle leading manually for custom design
      elevation: 0,
      title: Text(
        title,
        style: AppTextStyles.appBarHoltwood(fontSize: effectiveFontSize),
      ),
      centerTitle: center,
      leading: automaticallyImplyLeading
          ? Padding(
              padding: EdgeInsets.only(left: 13 , top: 6, bottom: 6),  
              child: Material(
                color: Colors.transparent,
                child: InkWell( 
                  borderRadius: BorderRadius.circular(12.r),
                  onTap: onBackPressed ??
                      () {
                        Navigator.of(context).pop();
                      },
                  child: Container(
                    width: 80,
                    height: 80 , 
                    decoration: BoxDecoration( 
                      color: Colors.black.withOpacity(0.1), 
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ), 
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 24,
                      color: const Color(0xFF2C3E50), // Deep elegant color
                    ),
                  ),
                ),
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
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => route!),
                    );
                  }
                },
          ),
        ...?actions,
        SizedBox(width: 12.w), // Nice padding on the right
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
          ), 
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}