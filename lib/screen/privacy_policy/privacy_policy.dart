import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: SafeArea(
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_outlined,
              size: 28.sp,
              color: Colors.black,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 24.sp,
            fontFamily: 'holtwood',
            shadows: const [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 4,
                color: Colors.blueGrey,
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // ───── Animated Gradient Background ─────
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration( 
                    gradient: LinearGradient(
                      begin: Alignment.topLeft, 
                      end: Alignment.bottomRight,
                      colors: const [
                       Color(0xFF87CEEB), // Sky Blue
                        Color(0xFFB3E5FC), // Lighter Sky
                        Color(0xFFE3F2FD), // Very Light Blue
                        Color(0xFFFFFFFF), // Pure White
                      ],
                      stops: const [0.0, 0.4, 0.7, 1.0],
                      transform: GradientRotation(
                        _animation.value * 2 * 3.14159,
                      ), // Full rotation
                    ),
                  ),
                );
              },
            ),
          ),

          // ───── Subtle Frosted Glass Blur Effect ─────
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: Colors.transparent),
            ),
          ),

          // ───── Dark Overlay for Text Contrast ─────
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.35)),
          ),

          // ───── Scrollable Content ─────
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  _buildTitle('INFORMATION WE COLLECT:'),
                  _buildBody(
                    'We collect personal information (name, email, address) to enhance user experience, process transactions, and send relevant updates.',
                  ),

                  _buildTitle('HOW WE USE YOUR INFORMATION:'),
                  _buildBody(
                    'We use collected information to improve our app, personalize user experience, and communicate essential updates or services.',
                  ),

                  _buildTitle('DATA SECURITY:'),
                  _buildBody(
                    'We employ security measures to protect against unauthorized access, disclosure, or destruction of user data.',
                  ),

                  _buildTitle('NO SHARING OF PERSONAL INFORMATION:'),
                  _buildBody(
                    'We do not sell, trade, or rent user information to third parties.',
                  ),

                  _buildTitle('CHANGES TO POLICY:'),
                  _buildBody(
                    'We may update this policy; users are encouraged to review it periodically.',
                  ),

                  _buildTitle('ACCEPTANCE OF TERMS:'),
                  _buildBody(
                    'By using our app, you agree to the terms outlined in this policy.',
                  ),

                  _buildTitle('CONTACT US:'),
                  _buildBody(
                    'For questions or concerns, contact Muhammed Saad C at muhammedsaad@gmail.com.',
                  ),

                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───── Helper Widgets ─────
  Widget _buildTitle(String text) => Padding(
    padding: EdgeInsets.only(top: 20.h, bottom: 10.h),
    child: Text(
      text,
      style: TextStyle( 
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    ),
  );

  Widget _buildBody(String text) => Text(
    text,
    style: TextStyle(fontSize: 14.sp, color: Colors.black, height: 1.6),
  );

}
