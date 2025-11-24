import 'package:cream_ventory/core/theme/theme.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  double _scrollProgress = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      if (maxScroll > 0) {
        setState(() => _scrollProgress = _scrollController.offset / maxScroll);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.appGradient),
        child: Stack(
          children: [
            // Background gradient circles
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFE879F9).withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient:AppTheme.appGradient
                ),
              ),
            ),

            CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Custom App Bar
                SliverAppBar(
                  expandedHeight: 180,
                  floating: false,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: Colors.blueGrey ,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.shield_outlined,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Privacy Policy',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Last updated: October 31, 2025',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  leading: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                // Content
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _animationController,
                    child: SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, 0.1),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: Curves.easeOut,
                            ),
                          ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Hero Card
                            _buildHeroCard(),
                            const SizedBox(height: 24),

                            // Policy Sections
                            _buildSection(
                              icon: Icons.block,
                              iconColor: const Color(0xFFEF4444),
                              title: 'Information We Do NOT Collect',
                              content:
                                  '''Creamventory is a 100% offline, local-first app. We do not:

• Collect any personal information (name, email, phone, etc.)
• Access or store your location
• Track usage or analytics
• Use cookies, ads, or third-party tracking
• Transmit any data over the internet''',
                            ),

                            _buildSection(
                              icon: Icons.storage_rounded,
                              iconColor: const Color(0xFF3B82F6),
                              title: 'Data Storage (Local Only)',
                              content:
                                  '''All data is stored locally on your device using Hive (a lightweight, secure local database).

This includes:
• Ice cream stock records
• Party order details
• Customer names (for orders)
• Payment records
• Photos of ice creams, events, or receipts

We have no access to this data. It never leaves your phone.''',
                            ),

                            _buildSection(
                              icon: Icons.camera_alt_rounded,
                              iconColor: const Color(0xFF8B5CF6),
                              title: 'Camera & Gallery Access',
                              content: '''The app may request permission to:
• Take photos (e.g., of ice cream flavors, party setups)
• Select images from gallery

These images are saved locally and used only within the app. You can revoke permissions anytime in your device settings.''',
                            ),

                            _buildSection(
                              icon: Icons.cloud_off_rounded,
                              iconColor: const Color(0xFFF59E0B),
                              title: 'No Cloud Sync or Backups',
                              content:
                                  '''Creamventory does not sync data to any cloud.

You are responsible for backing up your data (e.g., via device backup or manual export).

⚠️ If you uninstall the app or clear app data, all information will be lost.''',
                            ),

                            _buildSection(
                              icon: Icons.code_rounded,
                              iconColor: const Color(0xFF10B981),
                              title: 'Third-Party Libraries',
                              content:
                                  '''The app uses open-source Flutter packages:
• flutter
• hive
• image_picker
• path_provider
• provider

These are used only for local functionality. We are not responsible for their updates or security.''',
                            ),

                            _buildSection(
                              icon: Icons.person_outline_rounded,
                              iconColor: const Color(0xFF6366F1),
                              title: 'Your Responsibilities',
                              content: '''You are solely responsible for:
• The accuracy of stock, orders, and customer data
• Securing your device
• Backing up important business data
• Using customer photos or information lawfully''',
                            ),

                            _buildSection(
                              icon: Icons.child_care_rounded,
                              iconColor: const Color(0xFFEC4899),
                              title: "Children's Privacy",
                              content:
                                  '''Creamventory is a business tool and not intended for children under 13. We do not knowingly collect data from children.''',
                            ),

                            _buildSection(
                              icon: Icons.handshake_outlined,
                              iconColor: const Color(0xFF14B8A6),
                              title: 'No Data Sharing or Selling',
                              content:
                                  '''Since no data leaves your device, we do not:
• Share data with third parties
• Sell data
• Use data for advertising''',
                            ),

                            _buildSection(
                              icon: Icons.lock_outline_rounded,
                              iconColor: const Color(0xFF0EA5E9),
                              title: 'Security',
                              content:
                                  '''Data is stored securely using encrypted Hive boxes (where supported).

However, no app is 100% secure. Protect your device with a passcode or biometric lock.''',
                            ),

                            _buildSection(
                              icon: Icons.update_rounded,
                              iconColor: const Color(0xFFF97316),
                              title: 'Changes to This Policy',
                              content:
                                  '''We may update this Privacy Policy. Changes will be reflected in the app with a new "Last Updated" date.

Continued use means you accept the changes.''',
                            ),

                            // Contact Card
                            _buildContactCard(),

                            const SizedBox(height: 24),

                            // Agreement Footer
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7C3AED).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(
                                    0xFF7C3AED,
                                  ).withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.verified_user_rounded,
                                    color: Color(0xFF7C3AED),
                                    size: 32,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      'By using Creamventory, you acknowledge that you have read and agree to this Privacy Policy.',
                                      style: TextStyle(
                                        color: Colors.grey[800],
                                        fontSize: 14,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Progress Indicator
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: LinearProgressIndicator(
                  value: _scrollProgress,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.5),
                  ),
                  minHeight: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white60,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Image.asset(
            'assets/icon/Designer.png',
            width: 50,
            height: 50,
            fit: BoxFit.fill,
            alignment: Alignment.center,
          ),

          const SizedBox(height: 16),
          const Text(
            'Welcome to Creamventory',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'A mobile application designed to help you manage your ice cream business. Track stock, manage orders, generate invoices, and capture photos — all in one place.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.15),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Color(0xFF10B981), size: 20),
                SizedBox(width: 8),
                Text(
                  '100% Offline • Your Data Stays Local',
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          children: [
            Text(
              content,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.support_agent_rounded,
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(height: 16),
          const Text(
            'Contact Us',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'For support or privacy concerns',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 20),
          _buildContactItem(Icons.person, 'Muhammed Saad C'),
          _buildContactItem(Icons.email_outlined, 'muhammedsaad@gmail.com'),
          _buildContactItem(Icons.phone_outlined, '+91 8921873547'),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 15)),
        ],
      ),
    );
  }
}
