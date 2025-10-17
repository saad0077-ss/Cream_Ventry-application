import 'package:cream_ventory/screen/home/screen/app_notification.dart';
import 'package:cream_ventory/screen/home/screen/tap_view_button.dart';
import 'package:cream_ventory/screen/home/screen/transaction_notification.dart';
import 'package:cream_ventory/themes/app_theme/theme.dart';
import 'package:cream_ventory/widgets/app_bar.dart';
import 'package:flutter/material.dart';

class NotificationCenter extends StatefulWidget {
  const NotificationCenter({super.key});

  @override
  NotificationCenterState createState() => NotificationCenterState();
}

class NotificationCenterState extends State<NotificationCenter>
    with SingleTickerProviderStateMixin {
  bool isAppNotificationsSelected = true;
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Notification',
        fontSize: 25,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.appGradient), 
        child: Column(
          children: [
            TabButtons(
            
              isTabOneSelected: isAppNotificationsSelected,
              onTapOne: () {
                setState(() {
                  isAppNotificationsSelected = true;
                  tabController.index = 0;
                });
              },
              onTapTwo: () {
                setState(() {
                  isAppNotificationsSelected = false;
                  tabController.index = 1;
                });
              },
              title1: 'App Notifications',
              title2: 'All Transactions',
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [TabAppNotification(), TabTransactionNotification()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
