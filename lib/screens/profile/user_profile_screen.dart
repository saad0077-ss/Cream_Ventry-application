import 'package:cream_ventory/core/theme/theme.dart';
import 'package:cream_ventory/database/functions/user_db.dart';
import 'package:cream_ventory/models/user_model.dart';
import 'package:cream_ventory/core/utils/profile/profile_display_logics.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

class ProfileDisplayPage extends StatelessWidget {
  const ProfileDisplayPage({super.key}); 

  @override
  Widget build(BuildContext context) {
    final logic = ProfileDisplayLogic(context);

    return Scaffold(
      body: FutureBuilder<bool>(
        future: UserDB.isUserLoggedIn(),
        builder: (context, loginSnapshot) {
          if (loginSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF667EEA)),
            );
          } 
          if (loginSnapshot.hasData && loginSnapshot.data == true) {
            return FutureBuilder<UserModel>(
              future: UserDB.getCurrentUser(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF667EEA)),
                  );
                }
                if (userSnapshot.hasData) {
                  final user = userSnapshot.data!;
                  return ValueListenableBuilder<Box<UserModel>>(
                    valueListenable: UserDB.getUserProfileListenable(user.id),
                    builder: (context, box, _) {
                      final currentUser = box.get(user.id);
                      if (currentUser == null) {
                        return const Center(child: Text('User data not found'));
                      }
                      return Container(
                        decoration: BoxDecoration(
                          gradient: AppTheme.appGradient
                        ),
                        child: _ProfileContent(
                          profile: currentUser,
                          logic: logic,
                        ),
                      );
                    },
                  );
                }
                return const Center(child: Text('Error loading user data'));
              },
            );
          }
          return const Center(
            child: Text('Please log in to view your profile'),
          );
        },
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final UserModel profile;
  final ProfileDisplayLogic logic;

  const _ProfileContent({required this.profile, required this.logic});

  ImageProvider? _getImageProvider() {
    if (profile.profileImagePath == null || profile.profileImagePath!.isEmpty) {
      return null;
    }

    if (kIsWeb) {
      try {
        final bytes = base64Decode(profile.profileImagePath!);
        return MemoryImage(bytes);
      } catch (e) {
        debugPrint('Error decoding base64 image: $e');
        return null;
      }
    } else {
      return FileImage(File(profile.profileImagePath!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = _getImageProvider();

    return CustomScrollView(
      slivers: [
        // Custom App Bar with Profile Header
        SliverAppBar(
          expandedHeight:300,
          pinned: true,
          backgroundColor:  const Color.fromARGB(151, 0, 0, 0),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: logic.navigateToEditProfile,
                icon: Container( 
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF7B68EE), // Medium slate blue
                    Color(0xFF9B7FDB), // Soft purple
                    Color(0xFFB794D6), // Light purple-pink
                    Color(0xFFD4A5C8), // Pale purple-pink
                  ],
                  stops: [0.0, 0.35, 0.65, 1.0], 
                ),
              ),
              child: Stack(
                children: [
                  // Decorative elements
                  Positioned(
                    top: -60,
                    right: -60, 
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: -40,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  // Profile Section
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        // Profile Image
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.white,
                            child: imageProvider != null
                                ? CircleAvatar(
                                    radius: 52,
                                    backgroundImage: imageProvider,
                                  )
                                : const Icon(
                                    Icons.person_rounded,
                                    size: 60,
                                    color: Color(0xFF667EEA),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Username
                        Text(
                          profile.name?.isNotEmpty == true
                              ? profile.name!
                              : profile.username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'ABeeZee',
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Company Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Symbols.store_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                profile.distributionName?.isNotEmpty == true
                                    ? profile.distributionName!
                                    : 'No Distribution',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'ABeeZee',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Financial Summary Section
                _buildSectionCard(
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: const Color(0xFF10B981),
                  title: 'Financial Summary',
                  child: Column(
                    children: [
                      ValueListenableBuilder<double>(
                        valueListenable: logic.totalIncomeNotifier,
                        builder: (_, income, __) =>
                            ValueListenableBuilder<double>(
                              valueListenable: logic.totalExpenseNotifier,
                              builder: (_, expense, __) => Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      icon: Icons.trending_up_rounded,
                                      value: '₹${income.toStringAsFixed(2)}',
                                      label: 'Total Income',
                                      color: const Color(0xFF10B981),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatCard(
                                      icon: Icons.trending_down_rounded,
                                      value: '₹${expense.toStringAsFixed(2)}',
                                      label: 'Total Expense',
                                      color: const Color(0xFFEF4444),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      ),
                      const SizedBox(height: 12),
                      ValueListenableBuilder<double>(
                        valueListenable: logic.totalYouWillGetNotifier,
                        builder: (_, get, __) => ValueListenableBuilder<double>(
                          valueListenable: logic.totalYouWillGiveNotifier,
                          builder: (_, give, __) => Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.account_balance_wallet_rounded,
                                  value: '₹${get.toStringAsFixed(2)}',
                                  label: 'You Will Get',
                                  color: const Color(0xFF3B82F6),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.payments_rounded,
                                  value: '₹${give.toStringAsFixed(2)}',
                                  label: 'You Will Give',
                                  color: const Color(0xFFF59E0B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Contact Information Section
                _buildSectionCard(
                  icon: Icons.contact_phone_outlined,
                  iconColor: const Color(0xFF667EEA),
                  title: 'Contact Information',
                  child: Column(
                    children: [
                      _buildDetailField(
                        icon: Icons.email_outlined,
                        label: 'Email Address',
                        value: profile.email.isNotEmpty
                            ? profile.email
                            : 'Not provided',
                        isEmpty: profile.email.isEmpty,
                      ),
                      _buildDetailField(
                        icon: Icons.phone_outlined,
                        label: 'Phone Number',
                        value: profile.phone?.isNotEmpty == true
                            ? profile.phone!
                            : 'Not provided',
                        isEmpty: profile.phone?.isEmpty ?? true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                _buildSectionCard(
                  icon: Icons.analytics_outlined,
                  iconColor: const Color(0xFF8B5CF6),
                  title: 'Account Statistics',
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.inventory_2_outlined,
                          value: '0', // Replace with actual data
                          label: 'Products',
                          color: const Color(0xFF3B82F6),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.receipt_long_outlined,
                          value: '0', // Replace with actual data
                          label: 'Sales',
                          color: const Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.groups_outlined,
                          value: '0', // Replace with actual data
                          label: 'Parties',
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Address Section
                _buildSectionCard(
                  icon: Icons.location_on_outlined,
                  iconColor: const Color(0xFFF59E0B),
                  title: 'Address',
                  child: _buildDetailField(
                    icon: Icons.home_outlined,
                    label: 'Full Address',
                    value: profile.address?.isNotEmpty == true
                        ? profile.address!
                        : 'Not provided',
                    isEmpty: profile.address?.isEmpty ?? true,
                    maxLines: 3,
                  ),
                ),

                const SizedBox(height: 24),

                // Danger Zone
                _buildSectionCard(
                  icon: Icons.warning_amber_rounded,
                  iconColor: const Color(0xFFEF4444),
                  title: 'Account Actions',
                  child: _buildDangerButton(
                    icon: Icons.logout_rounded,
                    label: 'Logout',
                    subtitle: 'Sign out from your account',
                    onTap: () => _showLogoutDialog(context, logic),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black54 , 
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  fontFamily: 'ABeeZee',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'ABeeZee',
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontFamily: 'ABeeZee',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailField({
    required IconData icon,
    required String label,
    required String value,
    required bool isEmpty,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
              fontFamily: 'ABeeZee',
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isEmpty
                      ? Colors.grey.shade400
                      : const Color(0xFF667EEA), 
                  size: 22,
                ),
                const SizedBox(width: 12), 
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      color: isEmpty
                          ? Colors.grey.shade500
                          : const Color(0xFF334155),
                      fontWeight: FontWeight.w500,
                      fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                      fontFamily: 'ABeeZee',
                    ),
                    maxLines: maxLines,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.grey.shade700, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                        fontFamily: 'ABeeZee',
                      ), 
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500, 
                        fontFamily: 'ABeeZee',
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, ProfileDisplayLogic logic) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(25),
            constraints: const BoxConstraints(maxWidth: 345),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ), 
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ABeeZee',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to log out of your account?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.4,
                    fontFamily: 'ABeeZee',
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                            fontFamily: 'ABeeZee',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          logic.logout();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 2,
                          shadowColor: Colors.redAccent.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontFamily: 'ABeeZee',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
