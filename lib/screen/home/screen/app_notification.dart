
import 'package:flutter/material.dart';

class TabAppNotification extends StatefulWidget {
  const TabAppNotification({
    super.key,
  });

  @override
  State<TabAppNotification> createState() => _TabAppNotificationState();
}

class _TabAppNotificationState extends State<TabAppNotification> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      
      child: const Center(
        child: Text(
          "App Notifications Content",
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }
}
