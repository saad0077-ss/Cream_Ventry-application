import 'package:cream_ventory/db/functions/user_db.dart';
import 'package:cream_ventory/screen/items/item_screen.dart';
import 'package:cream_ventory/screen/privacy_policy/privacy_policy.dart';
import 'package:cream_ventory/screen/listing/expense/expence_listing_screen.dart';
import 'package:cream_ventory/screen/listing/payment_in/payment_in_listing_screen.dart';
import 'package:cream_ventory/screen/listing/payment_out/payment_out_listing_screen.dart';
import 'package:cream_ventory/screen/listing/sale/sale_listing_screen.dart';
import 'package:cream_ventory/screen/listing/sale/sale_oreder_listing_screen.dart';
import 'package:cream_ventory/profile/user_profile_screen.dart';
import 'package:cream_ventory/themes/app_theme/theme.dart';
import 'package:flutter/material.dart';
import 'dart:io';

// Placeholder page for unimplemented routes (replace with actual pages as needed)
class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title Page - Not Implemented')),
    );
  }
}  



class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // -------------------------------------------------------------- 
    // 1. Detect screen size – same thresholds you already use
    // --------------------------------------------------------------
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;
    final bool isDesktop = screenWidth >= 800;   // <-- your desktop rule

    // --------------------------------------------------------------
    // 2. The *content* of the drawer (header + list) is shared
    // --------------------------------------------------------------
    final Widget drawerContent = ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildHeader(screenWidth, isSmallScreen),   
        const SizedBox(height: 50),
        _buildUserInfo(screenWidth, isSmallScreen), 
        const SizedBox(height: 20),

        // ----- Menu items ------------------------------------------------
        // _buildMenuItem(
        //   context: context,
        //   icon: Icons.group,
        //   title: 'Parties',
        //   onTap: () {},                     // keep your original placeholder
        //   isSmallScreen: isSmallScreen,
        // ),
        _buildMenuItem(
          context: context,
          icon: Icons.list,
          title: 'Items',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ScreenItems()),
          ),
          isSmallScreen: isSmallScreen,
        ),
        _buildMenuItem(
          context: context,
          icon: Icons.local_offer_outlined,
          title: 'Sale Orders',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SaleOrder()),
          ),
          isSmallScreen: isSmallScreen,
        ),
        _buildTransactionMenu(context, screenWidth, isSmallScreen),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Divider(color: Colors.grey),
        ),

        _buildMenuItem(
          context: context,
          icon: Icons.person,
          title: 'Profile',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProfileDisplayPage()),
          ),
          isSmallScreen: isSmallScreen,
        ),
        _buildMenuItem(
          context: context,
          icon: Icons.privacy_tip,
          title: 'Privacy Policy',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
          ),
          isSmallScreen: isSmallScreen,
        ),
      ],
    );

    // --------------------------------------------------------------
    // 3. Return either a Drawer (mobile) or a plain Container (desktop)
    // --------------------------------------------------------------
    if (isDesktop) {
      return Container(
        width: 250,                         // you can tweak this
        color: Colors.white,
        child: drawerContent,
      );
    }

    // Mobile – classic Drawer
    return Drawer(
      child: Container(
        color: Colors.white,
        child: drawerContent,
      ),
    );
  }

 
  Widget _buildHeader(double screenWidth, bool isSmallScreen) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          height: 120,
          decoration: const BoxDecoration(
            gradient:AppTheme.appGradient,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),
        Positioned( 
          bottom: -40,
          child: CircleAvatar(
            radius: isSmallScreen ? 40 : 50,
            backgroundColor: const Color.fromARGB(255, 209, 111, 111),
            child: CircleAvatar(
              radius: isSmallScreen ? 38 : 48,
              child: FutureBuilder(
                future: UserDB.getCurrentUser(),   
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
                    );
                  } else if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data == null ||
                      snapshot.data.profileImagePath == null) {
                    return const Icon(
                      Icons.person,
                      size: 50,
                      color: Color(0xFF4A90E2),
                    );
                  }

                  final user = snapshot.data;
                  return CircleAvatar(
                    radius: isSmallScreen ? 38 : 48,
                    backgroundImage: user.profileImagePath != null
                        ? FileImage(File(user.profileImagePath))
                        : const AssetImage('assets/default_avatar.png')
                            as ImageProvider,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo(double screenWidth, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: FutureBuilder(
        future: UserDB.getCurrentUser(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Text(
              'Error loading user data',
              style: TextStyle(color: Colors.red, fontSize: 14),
              textAlign: TextAlign.center,
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Text(
              'No user data available',
              style: TextStyle(color: Colors.black54, fontSize: 14),
              textAlign: TextAlign.center,
            );
          }
          final user = snapshot.data;
          return Column(
            children: [
              Text(
                user.username ?? 'Unknown User',
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 24,
                  color: Colors.black87,
                  fontFamily: 'holtwood',
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                user.distributionName ?? 'No Company',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  color: Colors.black54,
                  fontFamily: 'BalooBhaina',
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                user.phone ?? 'Eg: 8989765443',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  color: Colors.black54,
                  fontFamily: 'Audiowide',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isSmallScreen,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color.fromARGB(255, 60, 64, 68),
            child: Icon(icon, color: Colors.white),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: isSmallScreen ? 14 : 16,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildTransactionMenu(
    BuildContext context,
    double screenWidth,
    bool isSmallScreen,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ExpansionTile(
        leading: const CircleAvatar(
          backgroundColor: Color.fromARGB(255, 35, 39, 43),
          child: Icon(Icons.store, color: Colors.white),
        ),
        title: Text(
          'Transactions',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isSmallScreen ? 14 : 16,
          ),
        ),
        children: [
          _buildSubMenuItem(
            context: context,
            icon: Icons.local_offer,
            title: 'Sales',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SaleReportScreen()),
            ),
            isSmallScreen: isSmallScreen,
          ),
          _buildSubMenuItem(
            context: context,
            icon: Icons.arrow_downward,
            title: 'Payment In',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PaymentInTransaction()),
            ),
            isSmallScreen: isSmallScreen,
          ),
          _buildSubMenuItem(
            context: context,
            icon: Icons.arrow_upward,
            title: 'Payment Out',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PaymentOutTransaction()),
            ),
            isSmallScreen: isSmallScreen,
          ),
          _buildSubMenuItem(
            context: context,
            icon: Icons.account_balance_wallet,
            title: 'Expense',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ExpenseReportScreen()),
            ),
            isSmallScreen: isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildSubMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isSmallScreen, 
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 40.0),
      child: ListTile(
        leading: Icon(icon, color: const Color.fromARGB(255, 61, 64, 67)),
        title: Text(title, style: TextStyle(fontSize: isSmallScreen ? 14 : 16)),
        onTap: onTap,
      ),
    );
  }
}