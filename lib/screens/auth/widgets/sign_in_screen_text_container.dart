// import 'package:cream_ventory/widgets/container.dart';
// import 'package:cream_ventory/widgets/positioned.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class TextContainer extends StatelessWidget {
//   const TextContainer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final bool isDesktop = MediaQuery.of(context).size.width > 600;

//     return CustomPositioned(
//       type: PositionedType.basic,
//       bottom: 539.h, // ~7.5% of 812px design height
//       left: 18.75.w, // ~5% of 375px design width
//       right: 18.75.w, // ~5% of 375px design width
//       child: ReusableContainer(
//         padding: EdgeInsets.all(isDesktop ? 7 : 15), // Responsive padding
//         height: 219.24.h, // ~27% of 812px design height
//         width: isDesktop ? 200 : double.infinity,
//         color: Colors.black38,
//         borderRadius: BorderRadius.circular( 
//           isDesktop ? 6.w : 15.w,
//         ), // Responsive border radius
//         child: Center( 
//           child: Text(
//             '"WELCOME TO CREAMVENTORY\nLET\'S GET YOU SCOOPED IN!\nCREATE YOUR ACCOUNT AND\nSTART MANAGING YOUR ICE\nCREAM INVENTORY WITH\nJOY. 🍦✨"',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontFamily: 'holtwood',
//               color: Colors.white,
//               fontSize:isDesktop ? 20 : 16 ,
//               letterSpacing: 1, 
//               height: 1.7,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:cream_ventory/widgets/container.dart';
import 'package:cream_ventory/widgets/positioned.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';

class TextContainer extends StatefulWidget {
  const TextContainer({super.key});

  @override
  State<TextContainer> createState() => _TextContainerState();
}

class _TextContainerState extends State<TextContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isDesktop = screenWidth > 600;
    final bool isSmallScreen = screenWidth < 375;
    final bool isSplitScreen = screenHeight < 600;

    // Responsive sizing
    final double containerHeight = isSplitScreen 
        ? screenHeight * 0.30 
        : (isSmallScreen ? 190.0 : 219.24.h);
    final double fontSize = isDesktop ? 20 : (isSmallScreen ? 14 : 16);
    final double padding = isDesktop ? 7 : (isSmallScreen ? 12 : 15);
    final double borderRadius = isDesktop ? 6.w : (isSmallScreen ? 12.w : 15.w);

    return CustomPositioned(
      type: PositionedType.basic,
      bottom: isSplitScreen ? screenHeight * 0.60 : 539.h,
      left: isSmallScreen ? 14.w : 18.75.w,
      right: isSmallScreen ? 14.w : 18.75.w,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              height: containerHeight,
              width: isDesktop ? 200 : double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.25),
                    Colors.white.withOpacity(0.15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: isSmallScreen ? 20 : 25,
                    spreadRadius: -5,
                    offset: Offset(0, isSmallScreen ? 10 : 12),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 15,
                    spreadRadius: -8,
                    offset: const Offset(0, -4),
                  ),
                  // Colored glow effect
                  BoxShadow(
                    color: const Color(0xFF764ba2).withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: -10,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: isSmallScreen ? 12 : 15,
                    sigmaY: isSmallScreen ? 12 : 15,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(padding),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.12),
                          Colors.white.withOpacity(0.06),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            Colors.white,
                            Colors.white.withOpacity(0.95),
                            Colors.white,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ).createShader(bounds),
                        child: Text(
                          '"WELCOME TO CREAMVENTORY\nLET\'S GET YOU SCOOPED IN!\nCREATE YOUR ACCOUNT AND\nSTART MANAGING YOUR ICE\nCREAM INVENTORY WITH\nJOY. 🍦✨"',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'holtwood',
                            color: Colors.white,
                            fontSize: fontSize,
                            letterSpacing: isSmallScreen ? 0.8 : 1,
                            height: isSplitScreen ? 1.5 : 1.7,
                            fontWeight: FontWeight.w500,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.4),
                                offset: const Offset(0, 3),
                                blurRadius: 8,
                              ),
                              Shadow(
                                color: const Color(0xFF764ba2).withOpacity(0.3),
                                offset: const Offset(0, 0),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ), 
    );    
  }
}
