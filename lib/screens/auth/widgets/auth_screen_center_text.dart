// import 'package:cream_ventory/core/constants/font_helper.dart';
// import 'package:cream_ventory/widgets/positioned.dart';
// import 'package:cream_ventory/widgets/text_span.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class CenterTextSignUp extends StatelessWidget {
//   const CenterTextSignUp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final bool isDesktop = MediaQuery.of(context).size.width >= 700;
//     return CustomPositioned(
//       type: PositionedType.basic,
//       left: 0,
//       right: 0,
//       bottom: 450.h, // ~57% of 812px design height 
//       child: Center(
//         child: CustomTextSpan(
//           spans: [
//             TextSpanConfig(
//               text: 'CREATE',
//               style: TextStyle(
//                 fontSize: isDesktop ? 60 : 30,
//                 fontFamily: 'holtwood',
//                 color: Colors.white,
//               ),
//             ),
//             TextSpanConfig(
//               text: ' ACCOUNT',
//               style: TextStyle(
//                 fontSize: isDesktop ? 60 : 30,
//                 fontFamily: 'holtwood',
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class WelcomeText extends StatelessWidget {
//   const WelcomeText({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return CustomPositioned( 
//       type: PositionedType.basic,
//       bottom: 600.5.h, // ~12.5% of 812px design height
//       left: 30.5.w, // ~10% of 375px design width
//       child: Text(
//         'WELCOME BACK 😊 \nHappy to see you again!',
//         style: AppTextStyles.welcomeTitle, 
//       ),
//     );
//   }
// }

// class CenterTextSignIn extends StatelessWidget {
//   const CenterTextSignIn({super.key}); 

//   @override
//   Widget build(BuildContext context) {

//     final bool isDesktop = MediaQuery.of(context).size.width >= 700;
//     return CustomPositioned(
//       type: PositionedType.basic,
//       left: 0,
//       right: 0,
//       bottom: 440.h, // ~50% of 812px design height 
//       child: Center(
//         child: CustomTextSpan(
//           spans: [
//             TextSpanConfig(
//               text: 'SIGN ',
//               style: TextStyle(
//                 fontSize: isDesktop? 60 : 35,
//                 fontFamily: 'holtwood',
//                 color: Colors.white,
//               ),
//             ),
//             TextSpanConfig(
//               text: 'IN',
//               style: TextStyle(
//                 fontSize: isDesktop? 60 : 35,
//                 fontFamily: 'holtwood',
//                 color: Colors.white,  
//               ),
//             ),
//             TextSpanConfig(
//               text: ' NOW',
//               style: TextStyle(
//                 fontSize:isDesktop? 60 : 35 ,
//                 fontFamily: 'holtwood',
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:cream_ventory/core/constants/font_helper.dart';
import 'package:cream_ventory/widgets/positioned.dart';
import 'package:cream_ventory/widgets/text_span.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CenterTextSignUp extends StatefulWidget {
  const CenterTextSignUp({super.key});

  @override
  State<CenterTextSignUp> createState() => _CenterTextSignUpState();
}

class _CenterTextSignUpState extends State<CenterTextSignUp>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 700;
    return CustomPositioned(
      type: PositionedType.basic,
      left: 0,
      right: 0,
      bottom: 450.h,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Center(               
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.white.withOpacity(0.95),
                    Colors.white,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ).createShader(bounds),
                child: CustomTextSpan(
                  spans: [
                    TextSpanConfig(
                      text: 'CREATE',
                      style: TextStyle(
                        fontSize: isDesktop ? 60 : 30,
                        fontFamily: 'holtwood',
                        color: Colors.white,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(0, 4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    TextSpanConfig(
                      text: ' ACCOUNT',
                      style: TextStyle(
                        fontSize: isDesktop ? 60 : 30,
                        fontFamily: 'holtwood',
                        color: Colors.white,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(0, 4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WelcomeText extends StatefulWidget {
  const WelcomeText({super.key});

  @override
  State<WelcomeText> createState() => _WelcomeTextState();
}

class _WelcomeTextState extends State<WelcomeText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
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
    return CustomPositioned(
      type: PositionedType.basic,
      bottom: 600.5.h,
      left: 30.5.w,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.08),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 15,
                    spreadRadius: -3,
                  ),
                ],
              ),
              child: Text(
                'WELCOME BACK 😊 \nHappy to see you again!',
                style: AppTextStyles.welcomeTitle.copyWith(
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.4),
                      offset: const Offset(0, 2),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CenterTextSignIn extends StatefulWidget {
  const CenterTextSignIn({super.key});

  @override
  State<CenterTextSignIn> createState() => _CenterTextSignInState();
}

class _CenterTextSignInState extends State<CenterTextSignIn>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _shimmerController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    
    // Main entrance animation
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Continuous shimmer animation
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 700;
    
    return CustomPositioned(
      type: PositionedType.basic,
      left: 0,
      right: 0,
      bottom: 440.h,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.08),
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
                    blurRadius: 20,
                    spreadRadius: -5,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 15,
                    spreadRadius: -8,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: AnimatedBuilder(
                animation: _shimmerAnimation,
                builder: (context, child) {
                  return ShaderMask(
                    blendMode: BlendMode.srcATop,
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.8),
                          Colors.white,
                          Colors.white.withOpacity(0.9),
                          Colors.white,
                          Colors.white.withOpacity(0.8),
                        ],
                        stops: const [0.0, 0.4, 0.5, 0.6, 1.0],
                        begin: Alignment(_shimmerAnimation.value, 0),
                        end: Alignment(_shimmerAnimation.value + 1, 0),
                      ).createShader(bounds);
                    },
                    child: CustomTextSpan(
                      spans: [
                        TextSpanConfig(
                          text: 'SIGN ',
                          style: TextStyle(
                            fontSize: isDesktop ? 60 : 35,
                            fontFamily: 'holtwood',
                            color: Colors.white,
                            letterSpacing: 2.5,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.4),
                                offset: const Offset(0, 4),
                                blurRadius: 10,
                              ),
                              Shadow(
                                color: Colors.purple.withOpacity(0.3),
                                offset: const Offset(0, 0),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                        ),
                        TextSpanConfig(
                          text: 'IN',
                          style: TextStyle(
                            fontSize: isDesktop ? 60 : 35,
                            fontFamily: 'holtwood',
                            color: Colors.white,
                            letterSpacing: 2.5,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.4),
                                offset: const Offset(0, 4),
                                blurRadius: 10,
                              ),
                              Shadow(
                                color: Colors.blue.withOpacity(0.3),
                                offset: const Offset(0, 0),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                        ),
                        TextSpanConfig(
                          text: ' NOW',
                          style: TextStyle(
                            fontSize: isDesktop ? 60 : 35,
                            fontFamily: 'holtwood',
                            color: Colors.white,
                            letterSpacing: 2.5,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.4),
                                offset: const Offset(0, 4),
                                blurRadius: 10,
                              ),
                              Shadow(
                                color: Colors.pink.withOpacity(0.3),
                                offset: const Offset(0, 0),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}