import 'package:flutter/material.dart';

class CustomSnackbar {
  static void show({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    Color backgroundColor = Colors.red,
    Color textColor = Colors.white,
    IconData? icon,
    Color iconColor = Colors.white,
    String? actionLabel,
    VoidCallback? onAction,
    EdgeInsets margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    EdgeInsets padding = const EdgeInsets.all(16),
    double borderRadius = 8.0,
    double elevation = 6.0,
  }) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(
                icon,
                color: iconColor,
              ),
            ),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: textColor),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      margin: margin,
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      elevation: elevation,
      duration: duration,
      action: actionLabel != null
          ? SnackBarAction(
              label: actionLabel,
              onPressed: onAction ?? () {},
              textColor: textColor,
            )
          : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
