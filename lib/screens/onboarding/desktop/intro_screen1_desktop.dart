import 'package:cream_ventory/screens/onboarding/intro_screen2.dart';
import 'package:cream_ventory/screens/onboarding/widgets/intro_screen_skip_button.dart';
import 'package:cream_ventory/widgets/background_image.dart';
import 'package:cream_ventory/widgets/button.dart';
import 'package:flutter/material.dart';

class ScreenIntro1Desktop extends StatelessWidget {
  const ScreenIntro1Desktop({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background with animation
          IntroBackground(
            imagePath: 'assets/animation/united.json',
            fit: BoxFit.cover,
            loopAnimation: false,
            animationSpeed: 0.5,
            gradientOverlay: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.black.withOpacity(0.5),
                Colors.black.withOpacity(0.7),
              ],
            ),
            animateChild: true,
          ),

          // Skip button
          const IntroSkipButton(),

          // Main content - positioned on the left
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: screenWidth * 0.55, // Takes 55% of screen width
              padding: const EdgeInsets.only(left: 80, right: 60),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withOpacity(0.75),
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Decorative element
                  Container(
                    width: 80,
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFF6B9D),
                          Color(0xFFFEC163),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B9D).withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title with gradient
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFFFFFFFF),
                        Color(0xFFFEC163),
                      ],
                    ).createShader(bounds),
                    child: const Text(
                      'WELCOME TO\nCREAMVENTORY! 🍦',
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Description with better contrast
                  Container(
                    padding: const EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: const Color(0xFFFF6B9D).withOpacity(0.6),
                          width: 3,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Keep your flavors fresh,\nyour stock full, and your\ncustomers happy.',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 15,
                                color: Colors.black.withOpacity(0.8),
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Let\'s manage your ice cream\ninventory with a cherry on top!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            height: 1.6,
                            color: Colors.white.withOpacity(0.95),
                            shadows: [
                              Shadow(
                                blurRadius: 15,
                                color: Colors.black.withOpacity(0.8),
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 56),

                  // Enhanced button with glow effect
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B9D).withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CustomButton(
                      label: 'EXPLORE NOW',
                      fontSize: 20,
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const ScreenIntro2(),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Feature indicators
                  Row(
                    children: [
                      _buildFeatureIndicator('Easy Setup', Icons.check_circle_outline),
                      const SizedBox(width: 24),
                      _buildFeatureIndicator('Real-time Updates', Icons.flash_on_outlined),
                      const SizedBox(width: 24),
                      _buildFeatureIndicator('Smart Alerts', Icons.notifications_outlined),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureIndicator(String label, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFFFEC163),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.9),
            shadows: [
              Shadow(
                blurRadius: 10,
                color: Colors.black.withOpacity(0.8),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 