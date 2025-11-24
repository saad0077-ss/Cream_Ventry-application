import 'package:cream_ventory/screens/auth/desktop/screen_sign_in_desktop.dart';
import 'package:cream_ventory/screens/auth/widgets/auth_screen_center_text.dart';
import 'package:cream_ventory/screens/auth/widgets/sign_in_screen_form_feild_container.dart';
import 'package:cream_ventory/widgets/container.dart';
import 'package:cream_ventory/widgets/positioned.dart';
import 'package:flutter/material.dart';

class ScreenSignIn extends StatefulWidget {
  const ScreenSignIn({super.key});

  @override
  State<ScreenSignIn> createState() => _ScreenSignInState();
}

class _ScreenSignInState extends State<ScreenSignIn> 
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

    // Use desktop layout for screens >= 1000px
    if (screenWidth >= 1000) {
      return ScreenSignInDesktop(
        animationController: _animationController,
        breatheAnimation: _breatheAnimation,
        gradientAnimation1: _gradientAnimation1, 
        gradientAnimation2: _gradientAnimation2,
      );
    }

    // Mobile/Tablet layout
    final double bottomPadding = 24.3;
    final double horizontalPadding = 22.5;
    final double containerHeight = 365.4;
    final double containerPaddingHorizontal = 17.75;
    final double containerPaddingVertical = 10.6;

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
          Container(
            color: const Color.fromARGB(49, 0, 0, 0),
          ),
          // Welcome text
          WelcomeText(),
          // Center text for sign-in
          CenterTextSignIn(),
          // Positioned container for form fields with breathing animation
          CustomPositioned(
            type: PositionedType.basic,
            bottom: bottomPadding,
            left: horizontalPadding,
            right: horizontalPadding,
            child: AnimatedBuilder(
              animation: _breatheAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _breatheAnimation.value,
                  child: ReusableContainer(
                    padding: EdgeInsets.symmetric(
                      horizontal: containerPaddingHorizontal,
                      vertical: containerPaddingVertical,
                    ),
                    height: containerHeight,
                    width: MediaQuery.of(context).size.width -
                        (2 * horizontalPadding),
                    color: Colors.black26,
                    child: FormFeildContainer(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  } 
}