import 'package:cream_ventory/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:cream_ventory/database/functions/user_db.dart';
import 'dart:io';

class AccountDetailsScreen extends StatefulWidget {
  const AccountDetailsScreen({super.key});

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  bool _isLoading = true;

  // Controllers
  final _usernameController = TextEditingController();
  final _distributionNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  dynamic currentUser;
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await UserDB.getCurrentUser();
      setState(() {
        currentUser = user;
        _usernameController.text = user.username;
        _distributionNameController.text = user.distributionName ?? '';
        _phoneController.text = user.phone ?? '';
        _emailController.text = user.email;
        _addressController.text = user.address ?? '';
        _profileImagePath = user.profileImagePath;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _distributionNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF667EEA)),
            )
          : Container(
            decoration: BoxDecoration(
              gradient: AppTheme.appGradient 
            ),
            child: CustomScrollView(
                slivers: [
                  // Custom App Bar
                  SliverAppBar(
                    expandedHeight: 300,
                    pinned: true,
                    backgroundColor: const Color.fromARGB(151, 0, 0, 0),
                    leading: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
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
                                  color: Colors.white30 ,
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
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
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
                                      child: _profileImagePath != null
                                          ? CircleAvatar(
                                              radius: 52,
                                              backgroundImage: FileImage(
                                                File(_profileImagePath!),
                                              ),
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
                                    _usernameController.text.isNotEmpty
                                        ? _usernameController.text
                                        : 'Your Name',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
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
                                    child: Text(
                                      _distributionNameController.text.isNotEmpty
                                          ? _distributionNameController.text
                                          : 'Your Company',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
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
                          // Personal Information Section
                          _buildSectionCard(
                            icon: Icons.person_outline_rounded,
                            iconColor: const Color(0xFF667EEA),
                            title: 'Personal Information',
                            child: Column(
                              children: [
                                _buildDetailField(
                                  icon: Icons.badge_outlined,
                                  label: 'Full Name',
                                  controller: _usernameController,
                                  enabled: false,
                                ),
                                _buildDetailField(
                                  icon: Icons.business_rounded,
                                  label: 'Distribution / Company Name',
                                  controller: _distributionNameController,
                                  enabled: false,
                                ),
                              ],
                            ),
                          ),
            
                          const SizedBox(height: 16),
            
                          // Contact Information Section
                          _buildSectionCard(
                            icon: Icons.contact_phone_outlined,
                            iconColor: const Color(0xFF10B981),
                            title: 'Contact Information',
                            child: Column(
                              children: [
                                _buildDetailField(
                                  icon: Icons.phone_outlined,
                                  label: 'Phone Number',
                                  controller: _phoneController,
                                  enabled: false,
                                  keyboardType: TextInputType.phone,
                                ),
                                _buildDetailField(
                                  icon: Icons.email_outlined,
                                  label: 'Email Address',
                                  controller: _emailController,
                                  enabled: false,
                                  keyboardType: TextInputType.emailAddress,
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
                              controller: _addressController,
                              enabled: false,
                              maxLines: 3,
                            ),
                          ),
            
                          const SizedBox(height: 16),
            
                          // Account Stats Section
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
            
                          const SizedBox(height: 24),
            
  
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ),
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
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
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

  Widget _buildDetailField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required bool enabled,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: TextField(
              controller: controller,
              enabled: enabled,
              keyboardType: keyboardType,
              maxLines: maxLines,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF334155),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 22),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                hintText: 'Enter $label',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
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
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

}
