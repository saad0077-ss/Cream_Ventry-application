import 'package:cream_ventory/screens/distribution_hub/distribution_hub_screen.dart';
import 'package:cream_ventory/screens/home/widgets/navigation.dart';
import 'package:cream_ventory/screens/product/item_screen.dart';
import 'package:cream_ventory/screens/reports/main_report_screen.dart';
import 'package:cream_ventory/screens/sale/sale_oreder_listing_screen.dart';
import 'package:cream_ventory/screens/profile/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// A class that provides a list of HomeMenuItem objects
class HomeMenuProvider {
  /// Returns the list of menu items
  static List<HomeMenuItem> getMenuItems(BuildContext context) {
  return [
    HomeMenuItem(
      title: 'DISTRIBUTION HUB',
      subtitle: 'Manage your Clients', 
      icon: const FaIcon(FontAwesomeIcons.truck, size: 24, color: Colors.white),
      onTap: () => NavigationHelper.navigateTo(context,  DistributionHub()),
      gradient: const LinearGradient(
        colors: [Colors.orange, Colors.deepOrangeAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),   
    HomeMenuItem(
      title: 'SALE ORDER',
      subtitle: 'Make Sale Orders Here', 
      icon: const FaIcon(FontAwesomeIcons.fileInvoice, size: 24, color: Colors.white),
      onTap: () => NavigationHelper.navigateTo(context,  SaleOrder()),
      gradient: const LinearGradient(
        colors: [Colors.purple, Colors.purpleAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    HomeMenuItem(
      title: 'REPORTS',
      subtitle: 'All reports related to sales, stock and expenses',
      icon: const FaIcon(FontAwesomeIcons.chartLine, size: 24, color: Colors.white),
      onTap: () => NavigationHelper.navigateTo(context,  ScreenReport(reportTitle: 'REPORTS',)),
      gradient: const LinearGradient(
        colors: [Colors.blue, Colors.lightBlueAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),   
    ),
    HomeMenuItem(
      title: 'ITEMS',
      subtitle: 'Manage Categories & Products',
      icon: const FaIcon(FontAwesomeIcons.boxesStacked, size: 24, color: Colors.white),
      onTap: () => NavigationHelper.navigateTo(context,  ScreenItems()),
      gradient: const LinearGradient(
        colors: [Colors.teal, Colors.greenAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    HomeMenuItem(
      title: 'PROFILE',
      subtitle: 'View and update info',
      icon: const FaIcon(FontAwesomeIcons.user, size: 24, color: Colors.white),
      onTap: () => NavigationHelper.navigateTo(context, const ProfileDisplayPage()),
      gradient: const LinearGradient(
        colors: [Colors.pinkAccent, Colors.redAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ];
}

}


/// Represents a single menu item
class HomeMenuItem {
  final String title;
  final FaIcon icon;
  final VoidCallback onTap;
  final LinearGradient gradient;
  final String? subtitle; 



  const HomeMenuItem({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.gradient,
    this.subtitle,
  });
}