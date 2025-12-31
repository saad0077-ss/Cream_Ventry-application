import 'package:cream_ventory/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.appGradient
        ),
        child: CustomScrollView(
          slivers: [ 
            // Custom App Bar with gradient
            SliverAppBar(
              expandedHeight: 280,
              pinned: true, 
              backgroundColor: Colors.blueGrey ,
              leading: IconButton(
                color: Colors.black  ,
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
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Decorative circles
                      Positioned(
                        top: -50,
                        right: -50,
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
                        bottom: -30,
                        left: -30,
                        child: Container(
                          width: 120,
                          height: 120, 
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      // App Logo and Name
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 50 ),
                            Image.asset( 
                              'assets/icon/Designer.png', 
                              width: 80,   
                              height: 80, 
                              fit: BoxFit.fill,
                              alignment: Alignment.center,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'CreamVentory',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1, 
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Version 1.2.0',
                                style: TextStyle(
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
                    // About Section
                    _buildSectionCard(
                      icon: Icons.info_outline_rounded,
                      iconColor: const Color(0xFF667EEA),
                      title: 'About CreamVentory',
                      child: const Text(
                        'CreamVentory is a powerful yet simple inventory management application designed specifically for individual business owners and small distributors.\n\n'
                        'Manage your products, track sales, handle payments, and monitor expenses — all in one place. Built with simplicity in mind, CreamVentory helps you focus on growing your business without the complexity of enterprise software.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF64748B),
                          height: 1.6,
                        ),
                      ),
                    ),
        
                    const SizedBox(height: 16),
        
                    // Features Section
                    _buildSectionCard(
                      icon: Icons.star_outline_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      title: 'Key Features',
                      child: Column(
                        children: [
                          _buildFeatureItem(
                            Icons.inventory_2_outlined,
                            'Product Management',
                            'Add, edit, and organize your inventory items',
                          ),
                          _buildFeatureItem(
                            Icons.receipt_long_outlined,
                            'Sales Tracking',
                            'Create and manage sale orders effortlessly',
                          ),
                          _buildFeatureItem(
                            Icons.payments_outlined,
                            'Payment Records',
                            'Track incoming and outgoing payments',
                          ),
                          _buildFeatureItem(
                            Icons.account_balance_wallet_outlined,
                            'Expense Management',
                            'Monitor and categorize your business expenses',
                          ),
                          _buildFeatureItem(
                            Icons.person_outline_rounded,
                            'Single User Focus',
                            'Designed for individual business owners',
                          ),
                          _buildFeatureItem(
                            Icons.offline_bolt_outlined,
                            'Offline Ready',
                            'Works without internet connection',
                          ),
                        ],
                      ),
                    ),
        
                    const SizedBox(height: 16),
        
                    // Developer Section
                    _buildSectionCard(
                      icon: Icons.code_rounded,
                      iconColor: const Color(0xFF10B981),
                      title: 'Developer',
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF667EEA).withOpacity(0.1),
                                  const Color(0xFF764BA2).withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF667EEA),
                                        Color(0xFF764BA2),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.person_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Muhammed Saad C', // Replace with your name
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Flutter Developer',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildContactButton(
                                  context: context,
                                  icon: Icons.email_outlined,
                                  label: 'Email',
                                  value: 'muhammedsaadc@gmail.com',
                                  color: const Color(0xFFEF4444),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildContactButton(
                                  context: context,
                                  icon: Icons.phone_outlined,
                                  label: 'Phone',
                                  value: '+91 8921873547',
                                  color: const Color(0xFF3B82F6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
        
                    const SizedBox(height: 16),
        
                    // App Info Section
                    _buildSectionCard(
                      icon: Icons.smartphone_rounded,
                      iconColor: const Color(0xFF8B5CF6),
                      title: 'App Information',
                      child: Column(
                        children: [
                          _buildInfoRow('Version', '1.2.0'), 
                          _buildInfoRow('Build Number', '10'),
                          _buildInfoRow('Platform', 'Android & Web'),
                          _buildInfoRow('Framework', 'Flutter'), 
                          _buildInfoRow('Last Updated', 'December 2025'),
                        ], 
                      ),
                    ),
        
                    const SizedBox(height: 24),
        
                    // Footer
                    Center(
                      child: Column(
                        children: [ 
                          Text(
                            'Made with ❤️ in Flutter',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '© 2025 CreamVentory. All rights reserved.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
        
                    const SizedBox(height: 30),
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
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF667EEA).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF667EEA), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Copy to clipboard and show snackbar
          Clipboard.setData(ClipboardData(text: value));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text('$label copied to clipboard!'),
                ],
              ),
              backgroundColor: color,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
