import 'package:cream_ventory/db/functions/user_db.dart';
import 'package:cream_ventory/screen/items/item_screen.dart';
import 'package:cream_ventory/screen/privacy_policy/privacy_policy.dart';
import 'package:cream_ventory/screen/listing/expense/expence_listing_screen.dart';
import 'package:cream_ventory/screen/listing/payment_in/payment_in_listing_screen.dart';
import 'package:cream_ventory/screen/listing/payment_out/payment_out_listing_screen.dart';
import 'package:cream_ventory/screen/listing/sale/sale_listing_screen.dart';
import 'package:cream_ventory/screen/sale_order/sale_order.dart';
import 'package:cream_ventory/user_profile/user_profile_screen.dart';
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;

    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(screenWidth, isSmallScreen),
            const SizedBox(height: 50),
            _buildUserInfo(screenWidth, isSmallScreen),
            const SizedBox(height: 20),
            _buildMenuItem(
              context: context,
              icon: Icons.group,
              title: 'Parties',
              onTap: () {},
              isSmallScreen: isSmallScreen,
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.list,
              title: 'Items',
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => ScreenItems())),
              isSmallScreen: isSmallScreen,
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.local_offer_outlined,
              title: 'Sale Orders',
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => SaleOrder())),
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
                MaterialPageRoute(
                  builder: (context) => const ProfileDisplayPage(),
                ),
              ),
              isSmallScreen: isSmallScreen,
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyPage(),
                ),
              ),
              isSmallScreen: isSmallScreen,
            ),
          ],
        ),
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
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 137, 191, 233), // Soft blue-gray
                Color.fromARGB(255, 89, 216, 228), // Subtle cyan
              ],
              stops: [0.0, 1.0],
            ),
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
                future: UserDB.getCurrentUser(), // Adjust method name as per your UserDB implementation
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
                    );
                  } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null || snapshot.data.profileImagePath == null) {
                    return const Icon(
                      Icons.person,
                      size: 50,
                      color: Color(0xFF4A90E2),
                    );
                  }

                  final user = snapshot.data;

                  debugPrint(user.profileImagePath);
                  return CircleAvatar(
                    radius: isSmallScreen ? 38 : 48,
                    backgroundImage: user.profileImagePath != null
                        ? FileImage(File(user.profileImagePath))
                        : const AssetImage('assets/default_avatar.png'),
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
                  fontFamily: 'holtwood'
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                user.distributionName ?? 'No Company',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  color: Colors.black54, 
                  fontFamily: 'BalooBhaina' 
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                user.phone ?? 'Eg: 8989765443',  
                style: TextStyle(
                  fontSize: isSmallScreen ? 14  : 16,
                  color: Colors.black54,
                  fontFamily: 'Audiowide' 
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
    required BuildContext context, // Added context parameter
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
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => SaleReportScreen())),
            isSmallScreen: isSmallScreen,
          ),
          _buildSubMenuItem(
            context: context,
            icon: Icons.arrow_downward,
            title: 'Payment In',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => PaymentInTransaction()),
            ),
            isSmallScreen: isSmallScreen,
          ),
          _buildSubMenuItem(
            context: context,
            icon: Icons.arrow_upward,
            title: 'Payment Out',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => PaymentOutTransaction()),
            ),
            isSmallScreen: isSmallScreen,
          ),
          _buildSubMenuItem(
            context: context,
            icon: Icons.account_balance_wallet,
            title: 'Expense',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ExpenseReportScreen()),
            ),
            isSmallScreen: isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildSubMenuItem({
    required BuildContext context, // Added context parameter
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
