import 'package:cream_ventory/database/functions/user_db.dart';
import 'package:cream_ventory/screens/settings/about_app_screen.dart';
import 'package:cream_ventory/screens/payments/payment_in_listing_screen.dart';
import 'package:cream_ventory/screens/payments/payment_out_listing_screen.dart';
import 'package:cream_ventory/screens/product/item_screen.dart';
import 'package:cream_ventory/screens/settings/account_detail.dart';
import 'package:cream_ventory/screens/settings/privacy_policy_screen.dart';
import 'package:cream_ventory/screens/expense/expence_listing_screen.dart';
import 'package:cream_ventory/screens/sale/sale_listing_screen.dart';
import 'package:cream_ventory/screens/sale/sale_oreder_listing_screen.dart';
import 'package:cream_ventory/screens/profile/user_profile_screen.dart';
import 'package:cream_ventory/screens/settings/user_password_change.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class DashboardPage extends StatelessWidget { 
  const DashboardPage({super.key}); 

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;
    final bool isDesktop = screenWidth >= 800;

    final Widget drawerContent = Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8FAFC), Color(0xFFEEF2F6)],
        ),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(screenWidth, isSmallScreen),
          const SizedBox(height: 60),
          _buildUserInfo(screenWidth, isSmallScreen),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'MAIN MENU',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildMenuItem(
            context: context,
            icon: Icons.inventory_2_outlined,
            title: 'Items',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ScreenItems()),
            ),
            isSmallScreen: isSmallScreen,
          ),
          _buildMenuItem(
            context: context,
            icon: Icons.receipt_long_outlined,
            title: 'Sale Orders',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SaleOrder()),
            ),
            isSmallScreen: isSmallScreen,
          ),
          _buildTransactionMenu(context, screenWidth, isSmallScreen),
          _buildMenuItem(
            context: context,
            icon: Icons.person_outline_rounded,
            title: 'Profile',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileDisplayPage()),
            ),
            isSmallScreen: isSmallScreen,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'PREFERENCES',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildSettingsMenu(context, screenWidth, isSmallScreen),
          const SizedBox(height: 24),
        ],
      ),
    );

    if (isDesktop) {
      return Container(
        width: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(2, 0),
            ),
          ],
        ),
        child: drawerContent,
      );
    }

    return Drawer(
      backgroundColor: Colors.transparent,
      child: drawerContent,
    );
  }

  Widget _buildHeader(double screenWidth, bool isSmallScreen) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          height: 140,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667EEA).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 40, left: 20),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'CreamVentory',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -45,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: isSmallScreen ? 42 : 50,
              backgroundColor: Colors.white,
              child: FutureBuilder(
                future: UserDB.getCurrentUser(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
                    );
                  } else if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data == null ||
                      snapshot.data.profileImagePath == null) {
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF0F4FF),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 50,
                        color: Color(0xFF667EEA),
                      ),
                    );
                  }
                  final user = snapshot.data;
                  return CircleAvatar(
                    radius: isSmallScreen ? 40 : 48,
                    backgroundImage: user.profileImagePath != null
                        ? FileImage(File(user.profileImagePath))
                        : const AssetImage('assets/default_avatar.png') as ImageProvider,
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
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          } else if (snapshot.hasError) {
            return _buildUserInfoError();
          } else if (!snapshot.hasData || snapshot.data == null) {
            return _buildUserInfoEmpty();
          }
          final user = snapshot.data;
          return Column(
            children: [
              Text(
                user.username ?? 'Unknown User',
                style: TextStyle(
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user.distributionName ?? 'No Company',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF667EEA),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone_outlined, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    user.phone ?? 'No phone',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 13 : 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserInfoError() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Error loading user data',
        style: TextStyle(color: Colors.red.shade700, fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildUserInfoEmpty() {
    return Text(
      'No user data available',
      style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
      textAlign: TextAlign.center,
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
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667EEA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: const Color(0xFF667EEA), size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: isSmallScreen ? 14 : 15,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionMenu(BuildContext context, double screenWidth, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.only(bottom: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.swap_horiz_rounded, color: Color(0xFF10B981), size: 22),
          ),
          title: Text(
            'Transactions',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: isSmallScreen ? 14 : 15,
              color: const Color(0xFF334155),
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade500, size: 20),
          ),
          children: [
            _buildSubMenuItem(context: context, icon: Icons.point_of_sale_rounded, title: 'Sales', color: const Color(0xFF3B82F6),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SaleReportScreen())), isSmallScreen: isSmallScreen),
            _buildSubMenuItem(context: context, icon: Icons.south_west_rounded, title: 'Payment In', color: const Color(0xFF10B981),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaymentInTransaction())), isSmallScreen: isSmallScreen),
            _buildSubMenuItem(context: context, icon: Icons.north_east_rounded, title: 'Payment Out', color: const Color(0xFFF59E0B),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaymentOutTransaction())), isSmallScreen: isSmallScreen),
            _buildSubMenuItem(context: context, icon: Icons.account_balance_wallet_outlined, title: 'Expense', color: const Color(0xFFEF4444),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ExpenseReportScreen())), isSmallScreen: isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsMenu(BuildContext context, double screenWidth, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.only(bottom: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.settings_outlined, color: Color(0xFF6366F1), size: 22),
          ),
          title: Text(
            'Settings',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: isSmallScreen ? 14 : 15,
              color: const Color(0xFF334155),
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6), 
            ), 
            child: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade500, size: 20),
          ),
          children: [
            _buildSubMenuItem(context: context, icon: Icons.person_outline_rounded, title: 'Account Details', color: const Color(0xFF8B5CF6),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AccountDetailsScreen())), isSmallScreen: isSmallScreen),
            _buildSubMenuItem(context: context, icon: Icons.lock_outline_rounded, title: 'Change Password', color: const Color(0xFFEC4899),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChangePassword())), isSmallScreen: isSmallScreen),
            _buildSubMenuItem(context: context, icon: Icons.privacy_tip_outlined, title: 'Privacy Policy', color: const Color(0xFF14B8A6),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PrivacyPolicyPage())), isSmallScreen: isSmallScreen),
            _buildSubMenuItem(context: context, icon: Icons.info_outline_rounded, title: 'About App', color: const Color(0xFF64748B),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AboutAppScreen())), isSmallScreen: isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildSubMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    required bool isSmallScreen,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 12, top: 2, bottom: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}