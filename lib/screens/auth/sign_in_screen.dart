// import 'package:cream_ventory/screens/auth/desktop/screen_sign_in_desktop.dart';
// import 'package:cream_ventory/screens/auth/widgets/auth_screen_center_text.dart';
// import 'package:cream_ventory/screens/auth/widgets/sign_in_screen_form_feild_container.dart';
// import 'package:cream_ventory/widgets/container.dart';
// import 'package:cream_ventory/widgets/positioned.dart';
// import 'package:flutter/material.dart';

// class ScreenSignIn extends StatefulWidget {
//   const ScreenSignIn({super.key});

//   @override
//   State<ScreenSignIn> createState() => _ScreenSignInState();
// }

// class _ScreenSignInState extends State<ScreenSignIn>
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

//     // Use desktop layout for screens >= 1000px
//     if (screenWidth >= 1000) {
//       return ScreenSignInDesktop(
//         animationController: _animationController,
//         breatheAnimation: _breatheAnimation,
//         gradientAnimation1: _gradientAnimation1,
//         gradientAnimation2: _gradientAnimation2,
//       );
//     }

//     // Mobile/Tablet layout
//     final double screenHeight = MediaQuery.of(context).size.height;
//     final double bottomPadding = 24.3;
//     final double horizontalPadding = 22.5;

// // Responsive container height (45% of screen, min 320, max 420)
//     final double containerHeight = (screenHeight * 0.45).clamp(320.0, 420.0);

// // Adjust padding based on screen size
//     final double containerPaddingHorizontal =
//         screenWidth < 420 ? 17.75 * 0.7 : 17.75;
//     final double containerPaddingVertical =
//         screenWidth < 420 ? 10.6 * 0.7 : 10.6;
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
//           Container(
//             color: const Color.fromARGB(49, 0, 0, 0),
//           ),
//           // Welcome text
//           WelcomeText(),
//           // Center text for sign-in
//           CenterTextSignIn(),
//           // Positioned container for form fields with breathing animation
//           CustomPositioned(
//             type: PositionedType.basic,
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
//                       horizontal: MediaQuery.of(context).size.width < 420
//                           ? containerPaddingHorizontal * 0.7
//                           : containerPaddingHorizontal,
//                       vertical: MediaQuery.of(context).size.width < 420
//                           ? containerPaddingVertical * 0.7
//                           : containerPaddingVertical,
//                     ),
//                     height: MediaQuery.of(context).size.width < 420
//                         ? containerHeight * 0.9
//                         : containerHeight,
//                     width: MediaQuery.of(context).size.width -
//                         (2 * horizontalPadding),
//                     color: Colors.black26,
//                     child: FormFeildContainer(),
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
import 'package:cream_ventory/screens/auth/desktop/screen_sign_in_desktop.dart';
import 'package:cream_ventory/screens/auth/widgets/sign_in_screen_form_feild_container.dart';
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
    final double screenHeight = MediaQuery.of(context).size.height;
    final double horizontalPadding = 22.5;

    // Responsive container height (55% of screen, min 400, max 520)
    final double containerHeight = (screenHeight * 0.59).clamp(400.0, 520.0);

    // Adjust padding based on screen size
    final double containerPaddingHorizontal =
        screenWidth < 420 ? 17.75 * 0.7 : 17.75;
    final double containerPaddingVertical =
        screenWidth < 420 ? 10.6 * 0.7 : 10.6;
    
    return Scaffold( 
      body: Stack(
        children: [
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
          Container(
            color: const Color.fromARGB(49, 0, 0, 0),
          ),
                 Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: AnimatedBuilder(
                animation: _breatheAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _breatheAnimation.value,
                    child: Container(
                      height: screenWidth < 420
                          ? containerHeight * 0.9
                          : containerHeight,
                      width: screenWidth - (2 * horizontalPadding),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 1.5,
                        ), 
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
                            horizontal: screenWidth < 420
                                ? containerPaddingHorizontal * 0.7
                                : containerPaddingHorizontal,
                            vertical: screenWidth < 420
                                ? containerPaddingVertical * 0.7
                                : containerPaddingVertical,
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
                          child: FormFeildContainer(),
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