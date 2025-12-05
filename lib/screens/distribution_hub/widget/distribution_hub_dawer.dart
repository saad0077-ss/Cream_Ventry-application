// dashboard_page.dart - FIXED IMAGE DISPLAY VERSION
import 'dart:io';
import 'dart:convert';
import 'package:cream_ventory/database/functions/user_db.dart';
import 'package:cream_ventory/models/user_model.dart';
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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  final bool isCollapsed;
  final VoidCallback onCollapseToggle;
  final bool isSmallScreen;

  const DashboardPage({
    super.key,
    required this.isCollapsed,
    required this.onCollapseToggle,
    required this.isSmallScreen,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
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
          _buildHeader(isDesktop),
          const SizedBox(height: 60),
          if (!widget.isCollapsed) _buildUserInfo(),
          if (!widget.isCollapsed) const SizedBox(height: 24),
          if (!widget.isCollapsed)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('MAIN MENU',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey, letterSpacing: 1.2)),
            ),
          if (!widget.isCollapsed) const SizedBox(height: 8),

          _buildMenuItem(icon: Icons.inventory_2_outlined, title: 'Items', onTap: () => _navigateTo(const ScreenItems())),
          _buildMenuItem(icon: Icons.receipt_long_outlined, title: 'Sale Orders', onTap: () => _navigateTo(const SaleOrder())),
          _buildTransactionMenu(),
          _buildMenuItem(icon: Icons.person_outline_rounded, title: 'Profile', onTap: () => _navigateTo(const ProfileDisplayPage())),

          if (!widget.isCollapsed) const SizedBox(height: 16),
          if (!widget.isCollapsed)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('PREFERENCES',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey, letterSpacing: 1.2)),
            ),
          if (!widget.isCollapsed) const SizedBox(height: 8),

          _buildSettingsMenu(),
          const SizedBox(height: 24),
        ],
      ),
    );

    if (isDesktop) {
      return Container(
        width: widget.isCollapsed ? 80 : 280,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(2, 0))],
        ),
        child: drawerContent,
      );
    }

    return Drawer(backgroundColor: Colors.transparent, child: drawerContent);
  }

  void _navigateTo(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  Widget _buildHeader(bool isDesktop) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          height: 140,
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40, left: 20),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    widget.isCollapsed ? '' : 'CreamVentory',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              if (isDesktop)
                Positioned(
                  top: 40,
                  right: 16,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: widget.onCollapseToggle,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                      child: Icon(widget.isCollapsed ? Icons.menu_open_rounded : Icons.menu_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Positioned(
          bottom: -45,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
            ),
            child: CircleAvatar(
              radius: widget.isCollapsed ? 30 : (widget.isSmallScreen ? 42 : 50),
              backgroundColor: Colors.white,
              child: FutureBuilder<UserModel?>(
                future: UserDB.getCurrentUser(),
                builder: (context, snapshot) {
                  // Debug: Print the snapshot data
                  print('=== DASHBOARD IMAGE DEBUG ===');
                  print('Connection state: ${snapshot.connectionState}');
                  
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(strokeWidth: 2);
                  }
                  
                  if (snapshot.hasError) {
                    print('ERROR: ${snapshot.error}');
                    return Icon(Icons.error_outline, 
                      size: widget.isCollapsed ? 30 : 50, 
                      color: Colors.red);
                  }
                  
                  if (!snapshot.hasData || snapshot.data == null) {
                    print('No user data');
                    return Icon(Icons.person_rounded, 
                      size: widget.isCollapsed ? 30 : 50, 
                      color: const Color(0xFF667EEA));
                  }
                  
                  final user = snapshot.data!;
                  final path = user.profileImagePath;
                  
                  print('User: ${user.username}');
                  print('Profile path: "$path"');
                  print('Path type: ${path.runtimeType}');
                  print('Path length: ${path?.length ?? 0}');
                  print('Is web: $kIsWeb');
                  
                  if (path == null || path.isEmpty) {
                    print('Path is null or empty - showing default icon');
                    return Icon(Icons.person_rounded, 
                      size: widget.isCollapsed ? 30 : 50, 
                      color: const Color(0xFF667EEA));
                  }
                  
                  // Handle different path formats
                  try {
                    ImageProvider imageProvider;
                    
                    if (kIsWeb) {
                      // Web: Use base64 data directly
                      if (path.startsWith('data:')) {
                        imageProvider = MemoryImage(UriData.parse(path).contentAsBytes());
                      } else if (path.startsWith('/9j/') || path.length > 500) {
                        // This is base64 without data: prefix
                        final bytes = base64Decode(path);
                        imageProvider = MemoryImage(bytes);
                      } else {
                        imageProvider = NetworkImage(path);
                      }
                    } else {
                      // Desktop/Mobile: Check if it's a base64 string or file path
                      if (path.startsWith('/9j/') || path.length > 500) {
                        // This is base64 data, not a file path
                        print('Detected base64 data instead of file path');
                        try {
                          final bytes = base64Decode(path);
                          imageProvider = MemoryImage(bytes);
                        } catch (e) {
                          print('Failed to decode base64: $e');
                          return Icon(Icons.broken_image, 
                            size: widget.isCollapsed ? 30 : 50, 
                            color: Colors.orange);
                        }
                      } else {
                        // This should be a file path
                        print('Using desktop/mobile file handler');
                        final file = File(path);
                        print('File path: ${file.path}');
                        print('File exists: ${file.existsSync()}');
                        
                        if (!file.existsSync()) {
                          print('FILE NOT FOUND at: $path');
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.broken_image, 
                                size: widget.isCollapsed ? 30 : 50, 
                                color: Colors.orange),
                              if (!widget.isCollapsed)
                                const Text('File not found', 
                                  style: TextStyle(fontSize: 8, color: Colors.orange)),
                            ],
                          );
                        }
                        
                        print('File found! Loading image...');
                        imageProvider = FileImage(file);
                      }
                    }
                    
                    print('Creating CircleAvatar with image');
                    return CircleAvatar(
                      radius: widget.isCollapsed ? 28 : (widget.isSmallScreen ? 40 : 48),
                      backgroundImage: imageProvider,
                      onBackgroundImageError: (exception, stackTrace) {
                        print('IMAGE LOAD ERROR: $exception');
                        print('Stack trace: $stackTrace');
                      },
                      child: null, // This ensures image shows if loaded
                    );
                  } catch (e, stackTrace) {
                    print('EXCEPTION: $e');
                    print('Stack: $stackTrace');
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error, 
                          size: widget.isCollapsed ? 30 : 50, 
                          color: Colors.red),
                        if (!widget.isCollapsed)
                          const Text('Error', 
                            style: TextStyle(fontSize: 8, color: Colors.red)),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: FutureBuilder<UserModel?>(
        future: UserDB.getCurrentUser(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox();
          final user = snapshot.data!;
          return Column(
            children: [
              Text(user.username, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF667EEA).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(user.distributionName ?? 'No Company', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF667EEA))),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMenuItem({required IconData icon, required String title, required VoidCallback onTap}) {
    final bool collapsed = widget.isCollapsed;

    Widget child = Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(  
            padding: EdgeInsets.symmetric(
              horizontal: collapsed ? 7 : 16,
              vertical: 14,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFF667EEA).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: const Color(0xFF667EEA), size: 22),
                ),
                if (!collapsed) ...[
                  const SizedBox(width: 14),
                  Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: Color(0xFF334155)))),
                  const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    return collapsed ? Tooltip(message: title, preferBelow: false, child: child) : child;
  }

  Widget _buildTransactionMenu() {
    return _buildExpandableMenu(
      title: 'Transactions',
      icon: Icons.swap_horiz_rounded,
      color: const Color(0xFF10B981),
      items: [
        _SubMenuData(Icons.point_of_sale_rounded, 'Sales', const Color(0xFF3B82F6), () => _navigateTo(const SaleReportScreen())),
        _SubMenuData(Icons.south_west_rounded, 'Payment In', const Color(0xFF10B981), () => _navigateTo(const PaymentInTransaction())),
        _SubMenuData(Icons.north_east_rounded, 'Payment Out', const Color(0xFFF59E0B), () => _navigateTo(const PaymentOutTransaction())),
        _SubMenuData(Icons.account_balance_wallet_outlined, 'Expense', const Color(0xFFEF4444), () => _navigateTo(const ExpenseReportScreen())),
      ],
    );
  }

  Widget _buildSettingsMenu() {
    return _buildExpandableMenu(
      title: 'Settings',
      icon: Icons.settings_outlined,
      color: const Color(0xFF6366F1),
      items: [
        _SubMenuData(Icons.person_outline_rounded, 'Account Details', const Color(0xFF8B5CF6), () => _navigateTo(const AccountDetailsScreen())),
        _SubMenuData(Icons.lock_outline_rounded, 'Change Password', const Color(0xFFEC4899), () => _navigateTo(const ChangePassword())),
        _SubMenuData(Icons.privacy_tip_outlined, 'Privacy Policy', const Color(0xFF14B8A6), () => _navigateTo(const PrivacyPolicyPage())),
        _SubMenuData(Icons.info_outline_rounded, 'About App', const Color(0xFF64748B), () => _navigateTo(const AboutAppScreen())),
      ],
    );
  }

  Widget _buildExpandableMenu({
    required String title,
    required IconData icon,
    required Color color,
    required List<_SubMenuData> items,
  }) {
    final bool collapsed = widget.isCollapsed;
   
    Widget tile = ExpansionTile(
      initiallyExpanded: false,
      maintainState: true,
      tilePadding: EdgeInsets.symmetric(horizontal: collapsed ? 14 : 16, vertical: 4),
      childrenPadding: EdgeInsets.only(left: collapsed ? 0 : 12, bottom: 8), 
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 22),
      ),
      title: collapsed ? const SizedBox.shrink() : Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: Color(0xFF334155))),
      trailing: collapsed ? const SizedBox.shrink() : const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey, size: 20),
      children: items.map(_buildSubMenuItem).toList(),
    );

    if (collapsed) {
      tile = Tooltip(message: title, preferBelow: false, child: tile);
    }

    return Theme(data: Theme.of(context).copyWith(dividerColor: Colors.transparent), child: tile);
  }

  Widget _buildSubMenuItem(_SubMenuData item) {
    final bool collapsed = widget.isCollapsed;

    Widget child = Container(
      margin: EdgeInsets.symmetric(horizontal: collapsed ? 18 : 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: item.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: item.color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(item.icon, color: item.color, size: 18),
                ),
                if (!collapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(item.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF475569)), overflow: TextOverflow.ellipsis),
                  ),
                ],
              ],
            ),
          ),
        ),
      ), 
    );

    return collapsed ? Tooltip(message: item.title, preferBelow: false, child: child) : child; 
  }
}
 
class _SubMenuData {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  _SubMenuData(this.icon, this.title, this.color, this.onTap);
}