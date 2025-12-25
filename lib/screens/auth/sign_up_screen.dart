// import 'package:cream_ventory/screens/auth/desktop/screen_sign_up_desktop.dart';
// import 'package:cream_ventory/screens/auth/widgets/auth_screen_center_text.dart';
// import 'package:cream_ventory/screens/auth/widgets/sign_in_screen_text_container.dart';
// import 'package:cream_ventory/screens/auth/widgets/sign_up_screen_form_feild.dart';
// import 'package:cream_ventory/widgets/container.dart';
// import 'package:cream_ventory/widgets/positioned.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
 
// class ScreenSignUp extends StatefulWidget {
//   const ScreenSignUp({super.key});

//   @override
//   State<ScreenSignUp> createState() => _ScreenSignUpState();
// } 

// class _ScreenSignUpState extends State<ScreenSignUp>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _breatheAnimation;
//   late Animation<Color?> _gradientAnimation1;
//   late Animation<Color?> _gradientAnimation2;

//   @override
//   void initState() {
//     super.initState();
//     // Initialize animation controller for breathing effect and gradient
//     _animationController = AnimationController(
//       duration: const Duration(seconds: 4),
//       vsync: this,
//     )..repeat(reverse: true);

//     // Breathing animation for subtle scale effect
//     _breatheAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: Curves.easeInOut,
//       ),
//     );

//     // Gradient color animation
//     _gradientAnimation1 = ColorTween(
//       begin: Colors.blue.shade300,
//       end: Colors.purple.shade300,
//     ).animate(_animationController);

//     _gradientAnimation2 = ColorTween(
//       begin: Colors.purple.shade700,
//       end: Colors.blue.shade700,
//     ).animate(_animationController);
//   }

//   @override 
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     // Use desktop layout for screens >= 1000px
//     if (screenWidth >= 1000) {
//       return ScreenSignUpDesktop(
//         animationController: _animationController,
//         breatheAnimation: _breatheAnimation,
//         gradientAnimation1: _gradientAnimation1,
//         gradientAnimation2: _gradientAnimation2,
//       );
//     }

//     // Mobile/Tablet layout with responsive height
//     final bool isSmallScreen = screenWidth < 420;
//     final bool isSplitScreen = screenHeight < 600;
    
//     final double bottomPadding = isSmallScreen ? 18.0 : 21.3;
//     final double horizontalPadding = isSmallScreen ? 16.0 : 22.0;
    
//     // Responsive container height (48-52% of screen, with min/max constraints)
//     final double containerHeight = () {
//       if (kIsWeb) {
//         return (screenHeight * 0.48).clamp(350.0, 480.0);
//       } else if (isSplitScreen) {
//         // Split screen mode - use more vertical space
//         return (screenHeight * 0.55).clamp(300.0, 400.0);
//       } else if (isSmallScreen) {
//         // Small screens
//         return (screenHeight * 0.46).clamp(340.0, 390.0);
//       } else {
//         // Regular screens
//         return (screenHeight * 0.48).clamp(360.0, 450.0);
//       }
//     }();
    
//     final double containerPaddingHorizontal = isSmallScreen ? 16.0 : 22.5;
//     final double containerPaddingVertical = isSmallScreen ? 14.0 : 20.0;

//     return Scaffold( 
//       body: Stack(
//         children: [
//           // Animated colored container replacing the background image
//           AnimatedBuilder( 
//             animation: _animationController, 
//             builder: (context, child) {
//               return Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       _gradientAnimation1.value ?? Colors.blue.shade300,
//                       _gradientAnimation2.value ?? Colors.purple.shade700,
//                     ],
//                     begin: Alignment.topLeft,  
//                     end: Alignment.bottomRight,
//                     stops: const [0.0, 1.0],
//                   ),
//                 ),
//               );
//             },
//           ),
//           // Semi-transparent overlay for better contrast
//           Container(color: const Color.fromARGB(49, 0, 0, 0)),
//           // Text container
//           TextContainer(),
//           // Center text for sign-up
//           CenterTextSignUp(),
//           // Positioned container for form fields with breathing animation
//           CustomPositioned(
//             type: PositionedType.fill,
//             bottom: bottomPadding,
//             left: horizontalPadding,
//             right: horizontalPadding,
//             child: AnimatedBuilder(
//               animation: _breatheAnimation,
//               builder: (context, child) {
//                 return Transform.scale(
//                   scale: _breatheAnimation.value,
//                   child: ReusableContainer(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: containerPaddingHorizontal,
//                       vertical: containerPaddingVertical,
//                     ),
//                     height: containerHeight,
//                     width: screenWidth - (2 * horizontalPadding),
//                     color: Colors.black26,
//                     child: SingleChildScrollView(
//                       physics: const BouncingScrollPhysics(),   
//                       child: FormFeild(),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ], 
//       ),
//     );
//   }
// }

import 'package:cream_ventory/screens/auth/desktop/screen_sign_up_desktop.dart';
import 'package:cream_ventory/screens/auth/widgets/sign_up_screen_form_feild.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
    final bool isSplitScreen = screenHeight < 600;
    
    final double horizontalPadding = isSmallScreen ? 16.0 : 17.0;
    
    // Responsive container height (48-52% of screen, with min/max constraints)
    final double containerHeight = () {
  if (kIsWeb) {
    // Web: increased from previous max of 480 → now up to 550
    return (screenHeight * 0.52).clamp(400.0, 550.0);
  } else if (isSplitScreen) {
    // Split screen: increased vertical usage
    return (screenHeight * 0.62).clamp(350.0, 480.0);
  } else if (isSmallScreen) {
    // Small screens: significantly taller
    return (screenHeight * 0.62).clamp(480.0, 600.0); 
  } else {
    // Regular screens: tallest variant
    return (screenHeight * 0.62).clamp(520.0, 680.0);
  }
}();
    
   // Adjust padding based on screen size
    final double containerPaddingHorizontal =
        screenWidth < 420 ? 17.75 * 0.7 : 16.75* 0.7; 
    final double containerPaddingVertical = 
        screenWidth < 420 ? 10.6 * 0.7 : 10.6; 
 
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
                      width: screenWidth - (2 * horizontalPadding),
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