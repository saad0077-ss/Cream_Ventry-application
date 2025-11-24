import 'package:cream_ventory/screens/auth/widgets/sign_in_screen_form_feild_container.dart';
import 'package:cream_ventory/widgets/container.dart';
import 'package:flutter/material.dart';

class ScreenSignInDesktop extends StatelessWidget {
  final AnimationController animationController;
  final Animation<double> breatheAnimation;
  final Animation<Color?> gradientAnimation1;
  final Animation<Color?> gradientAnimation2;

  const ScreenSignInDesktop({
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
    final double formWidth = 480.0;
    final double formHeight = 520.0;
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
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Sign in to continue to CreamVentory',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 32),
                        // Additional branding or features list
                        _buildFeatureItem(
                          icon: Icons.inventory_2_outlined,
                          text: 'Manage your inventory seamlessly',
                        ),
                        SizedBox(height: 16),
                        _buildFeatureItem(
                          icon: Icons.analytics_outlined,
                          text: 'Track and analyze your business',
                        ),
                        SizedBox(height: 16),
                        _buildFeatureItem(
                          icon: Icons.inventory_2_outlined,
                          text:
                              'Manage daily ice cream sales and stock updates',
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
                                  // Sign in title
                                  Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Enter your credentials to access your account',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 32),
                                  // Form fields
                                  FormFeildContainer(),
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
