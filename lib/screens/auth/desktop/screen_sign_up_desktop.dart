import 'package:cream_ventory/screens/auth/widgets/sign_up_screen_form_feild.dart';
import 'package:cream_ventory/widgets/container.dart';
import 'package:flutter/material.dart';

class ScreenSignUpDesktop extends StatelessWidget {
  final AnimationController animationController;
  final Animation<double> breatheAnimation;
  final Animation<Color?> gradientAnimation1;
  final Animation<Color?> gradientAnimation2;

  const ScreenSignUpDesktop({
    super.key,
    required this.animationController,
    required this.breatheAnimation,
    required this.gradientAnimation1,
    required this.gradientAnimation2,
  });

  @override
  Widget build(BuildContext context) {
    // Desktop-specific responsive values
    final double maxContentWidth = 1200.0;
    final double formWidth = 520.0; // Slightly wider for sign-up form
    final double formHeight = 600.0; // Taller for more fields
    final double horizontalSpacing = 80.0;

    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      gradientAnimation1.value ?? Colors.blue.shade300,
                      gradientAnimation2.value ?? Colors.purple.shade700,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: const [0.0, 1.0],
                  ),
                ),
              );
            },
          ),
          // Semi-transparent overlay
          Container(color: const Color.fromARGB(49, 0, 0, 0)),
          // Desktop layout with centered content
          Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left side - Welcome text and branding
                  Expanded(
                    flex: 5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Large welcome text for desktop
                        Text(
                          'Join CreamVentory',
                          style: TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Create your account and start managing your inventory today',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 32),
                        // Benefits list
                        _buildFeatureItem(
                          icon: Icons.rocket_launch_outlined,
                          text: 'Get started in minutes',
                        ),
                        SizedBox(height: 16),
                        _buildFeatureItem(
                          icon: Icons.analytics_outlined,
                          text:
                              'Get clear insights on sales, profit, and party balances',
                        ),

                        SizedBox(height: 16),
                        _buildFeatureItem(
                          icon: Icons.cloud_off_outlined,
                          text: 'Fully offline — works without internet',
                        ),

                        SizedBox(height: 16),
                        _buildFeatureItem(
                          icon: Icons.edit_note_outlined,
                          text:
                              'Quickly edit stock, prices, and product details anytime',
                        ),
                      ], 
                    ),
                  ),
                  SizedBox(width: horizontalSpacing),
                  // Right side - Form container with breathing animation
                  Expanded(
                    flex: 4,
                    child: AnimatedBuilder(
                      animation: breatheAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: breatheAnimation.value,
                          child: ReusableContainer(
                            padding: EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 40,
                            ),
                            height: formHeight,
                            width: formWidth,
                            color: Colors.black26,
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Sign up title
                                  Text(
                                    'Create Account',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Fill in the details below to get started',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 32),
                                  // Form fields
                                  FormFeild(),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({required IconData icon, required String text}) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
