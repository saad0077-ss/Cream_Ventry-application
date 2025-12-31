// import 'package:cream_ventory/core/constants/font_helper.dart';
import 'package:cream_ventory/widgets/text_span.dart';
import 'package:flutter/material.dart';

class CenterTextSignUp extends StatefulWidget {
  const CenterTextSignUp({super.key});

  @override
  State<CenterTextSignUp> createState() => _CenterTextSignUpState();
}

class _CenterTextSignUpState extends State<CenterTextSignUp>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _shimmerController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _shimmerAnimation;
  bool _isInitialized = false; 

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

    _isInitialized = true;
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
    if (!_isInitialized) {
      return const SizedBox.shrink();
    }
  
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMediumScreen = screenWidth >= 699 ; 
    final bool isMMScreen = screenWidth >=507 && screenWidth <=698;  
    final bool isSmallScreen = screenWidth >= 490 && screenWidth < 507; 
    final bool isSmallerrrScreen = screenWidth >= 427 && screenWidth <= 489;  
    final bool isSmallerScreen = screenWidth >= 416 && screenWidth < 427;
    final bool isVerySmallScreen = screenWidth < 416; 
    
    // Responsive font size
    final double fontSize = isMediumScreen 
        ? 30 
        : isSmallScreen  
            ? 30   
            : isSmallerScreen     
                ? 24       
                : isVerySmallScreen
                    ? 18
                    : isMediumScreen
                        ? 25
                        : isSmallerrrScreen
                            ? 25   
                            : isMMScreen
                                ? 28  
                                : 36;
                   
    // Responsive padding
    final EdgeInsets padding = isSmallScreen
        ? const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
        : isMediumScreen
            ? const EdgeInsets.symmetric(horizontal: 15, vertical: 15) 
            : const EdgeInsets.symmetric(horizontal: 28, vertical: 14);           
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(               
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
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
                width: isSmallScreen ? 1 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: isSmallScreen ? 15 : 20,
                  spreadRadius: -5,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: isSmallScreen ? 12 : 15,
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
                        text: 'CREATE',
                        style: TextStyle(
                          fontSize: fontSize,
                          fontFamily: 'holtwood',
                          color: Colors.white,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.4),
                              offset: const Offset(0, 4),
                              blurRadius: isSmallScreen ? 8 : 10,
                            ),
                            Shadow(
                              color: Colors.purple.withOpacity(0.3),
                              offset: const Offset(0, 0),
                              blurRadius: isSmallScreen ? 15 : 20,
                            ),
                          ],
                        ),
                      ),
                      TextSpanConfig(
                        text: ' ACCOUNT',
                        style: TextStyle(
                          fontSize: fontSize,
                          fontFamily: 'holtwood',
                          color: Colors.white,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.4),
                              offset: const Offset(0, 4),
                              blurRadius: isSmallScreen ? 8 : 10,
                            ),
                            Shadow(
                              color: Colors.blue.withOpacity(0.3),
                              offset: const Offset(0, 0),
                              blurRadius: isSmallScreen ? 15 : 20,
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMediumScreen = screenWidth >= 699 ; 
    final bool isSmallScreen = screenWidth >= 490 && screenWidth < 507; 
    final bool isSmallerrrScreen = screenWidth >= 385 && screenWidth < 489;  
    final bool isSmallerScreen = screenWidth >= 360 && screenWidth < 384 ;
    final bool isVerySmallScreen = screenWidth < 360;
    
    // Responsive font size
    final double fontSize = isMediumScreen 
        ? 32 
        : isSmallScreen  
            ? 40   
            : isSmallerScreen     
                ? 25       
                : isVerySmallScreen
                    ? 18
                    : isMediumScreen
                        ? 25
                        : isSmallerrrScreen
                            ? 28  
                            : 30;
    
    // Responsive padding
    final EdgeInsets padding = isSmallScreen
        ? const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
        : const EdgeInsets.symmetric(horizontal: 28, vertical: 14);
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
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
                width: isSmallScreen ? 1 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: isSmallScreen ? 15 : 20,
                  spreadRadius: -5,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: isSmallScreen ? 12 : 15,
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
                          fontSize: fontSize,
                          fontFamily: 'holtwood',
                          color: Colors.white,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.4),
                              offset: const Offset(0, 4),
                              blurRadius: isSmallScreen ? 8 : 10,
                            ),
                            Shadow(
                              color: Colors.purple.withOpacity(0.3),
                              offset: const Offset(0, 0),
                              blurRadius: isSmallScreen ? 15 : 20,
                            ),
                          ],
                        ),
                      ),
                      TextSpanConfig(
                        text: 'IN',
                        style: TextStyle(
                          fontSize: fontSize,
                          fontFamily: 'holtwood',
                          color: Colors.white,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.4),
                              offset: const Offset(0, 4),
                              blurRadius: isSmallScreen ? 8 : 10,
                            ),
                            Shadow(
                              color: Colors.blue.withOpacity(0.3),
                              offset: const Offset(0, 0),
                              blurRadius: isSmallScreen ? 15 : 20,
                            ),
                          ],
                        ),
                      ),
                      TextSpanConfig(
                        text: ' NOW',
                        style: TextStyle(
                          fontSize: fontSize,
                          fontFamily: 'holtwood',
                          color: Colors.white,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.4),
                              offset: const Offset(0, 4),
                              blurRadius: isSmallScreen ? 8 : 10,
                            ),
                            Shadow(
                              color: Colors.pink.withOpacity(0.3),
                              offset: const Offset(0, 0),
                              blurRadius: isSmallScreen ? 15 : 20,
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
    );
  }
}  