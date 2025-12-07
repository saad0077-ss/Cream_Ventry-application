import 'package:cream_ventory/screens/auth/sign_in_screen.dart';
import 'package:cream_ventory/widgets/background_image.dart';
import 'package:cream_ventory/widgets/button.dart';
import 'package:flutter/material.dart';

class ScreenIntro2Desktop extends StatelessWidget {
  const ScreenIntro2Desktop({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final isSmallScreen = screenWidth < 1110; 
    final isMediumScreen = screenWidth < 1410;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFFF5F7),
              const Color(0xFFFFF9E6),
              Colors.white, 
            ],
          ),
        ),
        child: Row(
          children: [
            // Left side - Text content
            Expanded(
              flex: 5,
              child: Container(
                padding:  EdgeInsets.symmetric(horizontal:isMediumScreen?60: 80, vertical:isMediumScreen?50: 60),
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
                            color: const Color(0xFFFF6B9D).withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Title
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFFFF6B9D),
                          Color(0xFFFE8B9C),
                          Color(0xFFFEC163),
                        ],
                      ).createShader(bounds),
                      child: const Text(
                        'READY TO\nSCOOP INTO\nSUCCESS?',
                        style: TextStyle(
                          fontSize: 68,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          color: Colors.white,
                          letterSpacing: -1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Description
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
                            'Your journey to effortless\ninventory management\nstarts here.',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              height: 1.5,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Track flavors, manage stock levels,\nand keep your ice cream business\nrunning smoothly.',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              height: 1.6,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 56),

                    // Button with enhanced styling
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6B9D).withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: CustomButton(
                        label: "LET'S GET STARTED",
                        fontSize: isSmallScreen ? 15 : 20,
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const ScreenSignIn(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Feature list
                    Wrap(
                      spacing:isMediumScreen?10: 20,
                      runSpacing:isMediumScreen?12: 16,
                      children: [
                        _buildFeatureBadge('📊 Real-time Analytics',isMediumScreen),
                        _buildFeatureBadge('📱 Cross-platform',isMediumScreen),
                        _buildFeatureBadge('🚀 Lightning Fast',isMediumScreen),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Right side - Animation 
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.all(60),
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: 600,
                      maxHeight: screenHeight * 0.6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B9D).withOpacity(0.1),
                          blurRadius: 40,
                          spreadRadius: 3 ,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: IntroBackground(
                        imagePath: 'assets/animation/intro2.json',
                        fit: BoxFit.contain,
                        loopAnimation: true,
                        reverseAnimation: false,
                        animationSpeed: 1.0,
                        animateChild: true,
                        animationScale: 0.9,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ), 
      ),
    ); 
  }

  Widget _buildFeatureBadge(String label,bool isMediumScreen) {
    return Container(
      padding:  EdgeInsets.symmetric(horizontal:isMediumScreen ?12: 16, vertical:isMediumScreen? 8: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF6B9D).withOpacity(0.1),
            const Color(0xFFFEC163).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFF6B9D).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label, 
        style: TextStyle(
          fontSize:isMediumScreen?10: 15,
          fontWeight: FontWeight.w600,
          color: Colors.grey[800],
        ),
      ),
    );
  }
}