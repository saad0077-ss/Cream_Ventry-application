import 'package:cream_ventory/screens/auth/widgets/auth_screen_center_text.dart';
import 'package:cream_ventory/screens/auth/widgets/sign_in_screen_text_container.dart';
import 'package:cream_ventory/screens/auth/widgets/sign_up_screen_form_feild.dart';
import 'package:cream_ventory/widgets/container.dart';
import 'package:cream_ventory/widgets/positioned.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    // Define responsive sizes using ScreenUtil
    final double bottomPadding = 21.3.h; // ~3% of 812px design height
    final double horizontalPadding = 22.w; // ~6% of 375px design width
    // Adjust container height for web/desktop to avoid overflow
    final double containerHeight = kIsWeb
        ? MediaQuery.of(context).size.height * 0.48  // Larger height for web
        : 395.h; // ~49% of 812px design height
    final double containerPaddingHorizontal = 22.5.w; // ~6% of 375px design width
    final double containerPaddingVertical = 20.h; // ~3% of 812px design height

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
          // Text container, assumed to handle its own responsiveness
          TextContainer(),
          // Center text for sign-up, assumed to handle its own responsiveness
          CenterTextSignUp(),
          // Positioned container for form fields with breathing animation
          CustomPositioned(
            type: PositionedType.fill,
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
                    width: MediaQuery.of(context).size.width - (2 * horizontalPadding),
                    color: Colors.black26,
                    child: SingleChildScrollView(child: FormFeild()),
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