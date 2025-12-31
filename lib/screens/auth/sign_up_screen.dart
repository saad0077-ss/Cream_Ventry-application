import 'package:cream_ventory/screens/auth/desktop/screen_sign_up_desktop.dart';
import 'package:cream_ventory/screens/auth/widgets/sign_up_screen_form_feild.dart';
import 'package:flutter/material.dart';

class ScreenSignUp extends StatefulWidget {
  const ScreenSignUp({super.key});

  @override
  State<ScreenSignUp> createState() => _ScreenSignUpState();
}

class _ScreenSignUpState extends State<ScreenSignUp>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _breatheAnimation;
  late Animation<Color?> _gradientAnimation1;
  late Animation<Color?> _gradientAnimation2;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller for breathing effect and gradient
    _animationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    // Breathing animation for subtle scale effect
    _breatheAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Gradient color animation
    _gradientAnimation1 = ColorTween(
      begin: Colors.blue.shade300,
      end: Colors.purple.shade300,
    ).animate(_animationController);

    _gradientAnimation2 = ColorTween(
      begin: Colors.purple.shade700,
      end: Colors.blue.shade700,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Use desktop layout for screens >= 1000px
    if (screenWidth >= 1000) {
      return ScreenSignUpDesktop(
        animationController: _animationController,
        breatheAnimation: _breatheAnimation,
        gradientAnimation1: _gradientAnimation1,
        gradientAnimation2: _gradientAnimation2,
      );
    }

    // Mobile/Tablet layout with responsive height
    final bool isSmallScreen = screenWidth < 420;

    final bool isNHeightSmall =screenHeight >=645 && screenHeight <= 1000; 
    final bool isSmallHeight = screenHeight <= 644;
    final bool isVsmallHeight =screenHeight>=540 && screenHeight < 600;

    final double horizontalPadding = isSmallScreen ? 16.0 : 17.0;

    // Fixed pixel-based container height
    final double containerHeight = isNHeightSmall ? 580.0 : isSmallHeight ? 520.0 : 600.0 ;
    ();


    // Calculate container width based on screen width
    final double containerWidth;
    if (screenWidth >= 506) {
      // Between 506 and 1000: fixed width of 500px (546 - 2*17 padding)
      containerWidth = 450.0;
    } else {
      // Below 546: responsive (full width minus padding)
      containerWidth = screenWidth - (2 * horizontalPadding);
    }

    // Adjust padding based on screen size
    final double containerPaddingHorizontal =
        screenWidth < 420 ? 17.75 * 0.7 : 16.75 * 0.9;
    final double containerPaddingVertical =
        screenWidth < 420 ? 10.6 * 0.7 :isVsmallHeight ? 25 * 2  :  10.9 * 0.9; 

    return Scaffold(
      body: Stack(
        children: [
          // Animated colored container replacing the background image
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _gradientAnimation1.value ?? Colors.blue.shade300,
                      _gradientAnimation2.value ?? Colors.purple.shade700,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: const [0.0, 1.0],
                  ),
                ),
              );
            },
          ),
          // Semi-transparent overlay for better contrast
          Container(color: const Color.fromARGB(49, 0, 0, 0)),

          // Centered container for form fields with breathing animation
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: AnimatedBuilder(
                animation: _breatheAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _breatheAnimation.value,
                    child: Container(
                      height: containerHeight,
                      width: containerWidth,
                      decoration: BoxDecoration(
                        // Glassmorphism effect
                        color: Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 1.5,
                        ),
                        // Multi-layered shadow for depth
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: -5,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: containerPaddingHorizontal,
                            vertical: containerPaddingVertical,
                          ),
                          decoration: BoxDecoration(
                            // Subtle inner glow
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.15),
                                Colors.white.withOpacity(0.05),
                              ],
                            ),
                          ),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: FormFeild(),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
