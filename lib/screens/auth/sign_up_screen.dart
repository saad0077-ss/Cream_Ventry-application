import 'package:cream_ventory/screens/auth/desktop/screen_sign_up_desktop.dart';
import 'package:cream_ventory/screens/auth/widgets/auth_screen_center_text.dart';
import 'package:cream_ventory/screens/auth/widgets/sign_in_screen_text_container.dart';
import 'package:cream_ventory/screens/auth/widgets/sign_up_screen_form_feild.dart';
import 'package:cream_ventory/widgets/container.dart';
import 'package:cream_ventory/widgets/positioned.dart';
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
    
    final double bottomPadding = isSmallScreen ? 18.0 : 21.3;
    final double horizontalPadding = isSmallScreen ? 16.0 : 22.0;
    
    // Responsive container height (48-52% of screen, with min/max constraints)
    final double containerHeight = () {
      if (kIsWeb) {
        return (screenHeight * 0.48).clamp(350.0, 480.0);
      } else if (isSplitScreen) {
        // Split screen mode - use more vertical space
        return (screenHeight * 0.55).clamp(300.0, 400.0);
      } else if (isSmallScreen) {
        // Small screens
        return (screenHeight * 0.46).clamp(340.0, 390.0);
      } else {
        // Regular screens
        return (screenHeight * 0.48).clamp(360.0, 450.0);
      }
    }();
    
    final double containerPaddingHorizontal = isSmallScreen ? 16.0 : 22.5;
    final double containerPaddingVertical = isSmallScreen ? 14.0 : 20.0;

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
          // Text container
          TextContainer(),
          // Center text for sign-up
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
                    width: screenWidth - (2 * horizontalPadding),
                    color: Colors.black26,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),   
                      child: FormFeild(),
                    ),
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

// import 'package:cream_ventory/screens/auth/desktop/screen_sign_up_desktop.dart';
// import 'package:cream_ventory/screens/auth/widgets/auth_screen_center_text.dart';
// import 'package:cream_ventory/screens/auth/widgets/sign_in_screen_text_container.dart';
// import 'package:cream_ventory/screens/auth/widgets/sign_up_screen_form_feild.dart';
// import 'package:cream_ventory/widgets/container.dart';
// import 'package:cream_ventory/widgets/positioned.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'dart:ui';
// import 'dart:math' as math;
 
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
//   late Animation<Color?> _gradientAnimation3;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(seconds: 6),
//       vsync: this,
//     )..repeat(reverse: true);

//     _breatheAnimation = Tween<double>(begin: 1.0, end: 1.015).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: Curves.easeInOut,
//       ),
//     );

//     // Enhanced gradient with more vibrant colors
//     _gradientAnimation1 = ColorTween(
//       begin: const Color(0xFF667eea),
//       end: const Color(0xFF764ba2),
//     ).animate(_animationController);

//     _gradientAnimation2 = ColorTween(
//       begin: const Color(0xFF764ba2),
//       end: const Color(0xFFf093fb),
//     ).animate(_animationController);

//     _gradientAnimation3 = ColorTween(
//       begin: const Color(0xFFf093fb),
//       end: const Color(0xFF4facfe),
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
//     final isSmallScreen = screenWidth < 375;

//     // Use desktop layout for screens >= 1000px
//     if (screenWidth >= 1000) {
//       return ScreenSignUpDesktop(
//         animationController: _animationController,
//         breatheAnimation: _breatheAnimation,
//         gradientAnimation1: _gradientAnimation1,
//         gradientAnimation2: _gradientAnimation2,
//       );
//     }

//     // Responsive sizing with split-screen support
//     final bool isSplitScreen = screenHeight < 600;
//     final double bottomPadding = isSmallScreen ? 18.0 : 21.3.h;
//     final double horizontalPadding = isSmallScreen ? 16.0 : 22.w;
    
//     // Dynamic container height based on available screen space
//     final double containerHeight = () {
//       if (kIsWeb) {
//         return screenHeight * 0.48;
//       } else if (isSplitScreen) {
//         // For split screen: use percentage of available height
//         return screenHeight * 0.55;
//       } else if (isSmallScreen) {
//         return 360.0;
//       } else {
//         return 395.h;
//       }
//     }();
    
//     final double containerPaddingHorizontal = isSmallScreen ? 16.0 : (isSplitScreen ? 18.0 : 22.5.w);
//     final double containerPaddingVertical = isSmallScreen ? 16.0 : (isSplitScreen ? 14.0 : 20.h);

//     return Scaffold( 
//       body: Stack(
//         children: [
//           // Animated gradient background with floating orbs
//           AnimatedBuilder( 
//             animation: _animationController, 
//             builder: (context, child) {
//               return Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       _gradientAnimation1.value ?? const Color(0xFF667eea),
//                       _gradientAnimation2.value ?? const Color(0xFF764ba2),
//                       _gradientAnimation3.value ?? const Color(0xFFf093fb),
//                     ],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     stops: const [0.0, 0.5, 1.0],
//                   ),
//                 ),
//                 child: Stack(
//                   children: [
//                     // Floating orbs - adjusted for small screens
//                     ...List.generate(isSmallScreen ? 2 : 3, (index) {
//                       return AnimatedBuilder(
//                         animation: _animationController,
//                         builder: (context, child) {
//                           final offset = math.sin(_animationController.value * 
//                               2 * math.pi + index * math.pi / 3) * 
//                               (isSmallScreen ? 30 : 50);
//                           return Positioned(
//                             top: 100.0 + (index * (isSmallScreen ? 180.0 : 150.0)) + offset,
//                             left: (index % 2 == 0) ? -50 : null,
//                             right: (index % 2 != 0) ? -50 : null,
//                             child: Container(
//                               width: isSmallScreen ? 150 : 200,
//                               height: isSmallScreen ? 150 : 200,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 gradient: RadialGradient(
//                                   colors: [
//                                     Colors.white.withOpacity(0.1),
//                                     Colors.white.withOpacity(0.0),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     }),
                    
//                     // Animated particles/stars
//                     ...List.generate(isSmallScreen ? 8 : 12, (index) {
//                       return AnimatedBuilder(
//                         animation: _animationController,
//                         builder: (context, child) {
//                           final xOffset = math.cos(_animationController.value * 
//                               2 * math.pi + index * 0.5) * 15;
//                           final yOffset = math.sin(_animationController.value * 
//                               2 * math.pi + index * 0.3) * 20;
//                           final opacity = 0.3 + 
//                               (math.sin(_animationController.value * 2 * math.pi + index) * 0.3);
                          
//                           return Positioned(
//                             left: (screenWidth * (index * 0.09)) + xOffset,
//                             top: (screenHeight * ((index * 0.08) % 1)) + yOffset,
//                             child: Container(
//                               width: isSmallScreen ? 3 : 4,
//                               height: isSmallScreen ? 3 : 4,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: Colors.white.withOpacity(opacity),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.white.withOpacity(opacity * 0.5),
//                                     blurRadius: 8,
//                                     spreadRadius: 2,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     }),
                    
//                     // Mesh gradient overlay effect
//                     Positioned.fill(
//                       child: AnimatedBuilder(
//                         animation: _animationController,
//                         builder: (context, child) {
//                           return CustomPaint(
//                             painter: MeshGradientPainter(
//                               animationValue: _animationController.value,
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
          
//           // Glassmorphism overlay with animated opacity
//           AnimatedBuilder(
//             animation: _animationController,
//             builder: (context, child) {
//               final opacity = 0.2 + (math.sin(_animationController.value * 2 * math.pi) * 0.05);
//               return Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       Colors.black.withOpacity(opacity),
//                       Colors.black.withOpacity(opacity + 0.1),
//                     ],
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                   ),
//                 ),
//               );
//             },
//           ),

//           // Decorative corner elements
//           if (!isSmallScreen) ...[
//             // Top left corner decoration
//             Positioned(
//               top: 40,
//               left: 20,
//               child: AnimatedBuilder(
//                 animation: _animationController,
//                 builder: (context, child) {
//                   return Transform.rotate(
//                     angle: _animationController.value * 2 * math.pi * 0.1,
//                     child: Container(
//                       width: 60,
//                       height: 60,
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                           color: Colors.white.withOpacity(0.2),
//                           width: 2,
//                         ),
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
            
//             // Top right corner decoration
//             Positioned(
//               top: 60,
//               right: 30,
//               child: AnimatedBuilder(
//                 animation: _animationController,
//                 builder: (context, child) {
//                   return Transform.rotate(
//                     angle: -_animationController.value * 2 * math.pi * 0.15,
//                     child: Container(
//                       width: 40,
//                       height: 40,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         border: Border.all(
//                           color: Colors.white.withOpacity(0.25),
//                           width: 2,
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],

//           // Text container
//           TextContainer(),
          
//           // Center text for sign-up
//           CenterTextSignUp(),
          
//           // Enhanced form container with glassmorphism effect
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
//                   child: Container(
//                     height: containerHeight,
//                     width: MediaQuery.of(context).size.width - (2 * horizontalPadding),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(isSmallScreen ? 24 : 28),
//                       gradient: LinearGradient(
//                         colors: [
//                           Colors.white.withOpacity(0.25),
//                           Colors.white.withOpacity(0.15),
//                         ],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       border: Border.all(
//                         color: Colors.white.withOpacity(0.3),
//                         width: 1.5,
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.2),
//                           blurRadius: isSmallScreen ? 25 : 30,
//                           spreadRadius: -5,
//                           offset: Offset(0, isSmallScreen ? 12 : 15),
//                         ),
//                         BoxShadow(
//                           color: Colors.white.withOpacity(0.1),
//                           blurRadius: isSmallScreen ? 15 : 20,
//                           spreadRadius: -10,
//                           offset: const Offset(0, -5),
//                         ),
//                       ],
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(isSmallScreen ? 24 : 28),
//                       child: BackdropFilter(
//                         filter: ImageFilter.blur(
//                           sigmaX: isSmallScreen ? 12 : 15,
//                           sigmaY: isSmallScreen ? 12 : 15,
//                         ),
//                         child: Container(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: containerPaddingHorizontal,
//                             vertical: containerPaddingVertical,
//                           ),
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               colors: [
//                                 Colors.white.withOpacity(0.1),
//                                 Colors.white.withOpacity(0.05),
//                               ],
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                             ),
//                           ),
//                           child: SingleChildScrollView(
//                             physics: const BouncingScrollPhysics(),
//                             child: FormFeild(),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
          
//           // Bottom decorative line
//           if (!isSmallScreen)
//             Positioned(
//               bottom: 10,
//               left: screenWidth * 0.3,
//               right: screenWidth * 0.3,
//               child: AnimatedBuilder(
//                 animation: _animationController,
//                 builder: (context, child) {
//                   return Container(
//                     height: 3,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(2),
//                       gradient: LinearGradient(
//                         colors: [
//                           Colors.white.withOpacity(0.0),
//                           Colors.white.withOpacity(0.4),
//                           Colors.white.withOpacity(0.0),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// // Custom painter for mesh gradient effect
// class MeshGradientPainter extends CustomPainter {
//   final double animationValue;

//   MeshGradientPainter({required this.animationValue});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..style = PaintingStyle.fill;

//     // Create animated mesh points
//     for (int i = 0; i < 3; i++) {
//       final xPos = size.width * (0.2 + i * 0.3);
//       final yPos = size.height * (0.3 + math.sin(animationValue * 2 * math.pi + i) * 0.2);
      
//       final gradient = RadialGradient(
//         colors: [
//           Colors.white.withOpacity(0.03),
//           Colors.white.withOpacity(0.0),
//         ],
//         stops: const [0.0, 1.0],
//       );

//       paint.shader = gradient.createShader(
//         Rect.fromCircle(
//           center: Offset(xPos, yPos),
//           radius: 150,
//         ),
//       );

//       canvas.drawCircle(Offset(xPos, yPos), 150, paint);
//     }
//   }    
 
//   @override
//   bool shouldRepaint(MeshGradientPainter oldDelegate) {
//     return oldDelegate.animationValue != animationValue;
//   }
// }