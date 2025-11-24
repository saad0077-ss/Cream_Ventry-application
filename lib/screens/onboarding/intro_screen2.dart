import 'package:cream_ventory/screens/auth/sign_in_screen.dart';
import 'package:cream_ventory/screens/onboarding/desktop/intro_screen2_desktop.dart';
import 'package:cream_ventory/widgets/background_image.dart';
import 'package:cream_ventory/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScreenIntro2 extends StatelessWidget {
  const ScreenIntro2({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Use desktop layout if screen width > 1000
    if (screenWidth > 1000) {
      return const ScreenIntro2Desktop();
    }
     
    // Mobile/Tablet layout
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFFF5F7),
              const Color(0xFFFFF9E6),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top decorative header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Decorative line
                    Container(
                      width: 60,
                      height: 4 ,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFF6B9D),
                            Color(0xFFFEC163),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6B9D).withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    
                    // Title
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFFFF6B9D),
                          Color(0xFFFE8B9C),
                          Color(0xFFFEC163),
                        ],
                      ).createShader(bounds),
                      child: Text(
                        'READY TO\nSCOOP INTO\nSUCCESS?',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          height: 1.3,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    
                    // Subtitle
                    Text(
                      'Your journey to effortless\ninventory management starts here.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),

              // Animation in the middle
              Expanded(
                child: Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B9D).withOpacity(0.1),
                          blurRadius: 30,
                          spreadRadius: 5, 
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: IntroBackground(
                        imagePath: 'assets/animation/intro2.json',
                        fit: BoxFit.contain,
                        loopAnimation: true,
                        reverseAnimation: false,
                        animationSpeed: 1.0,
                        animateChild: true,
                        animationScale: 0.85, 
                      ),
                    ),
                  ),
                ),
              ),

             
              SizedBox(height: 20.h),

              // Button at bottom
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.r),
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
                    fontSize: 18,
                    borderRadius: 10.r,
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const ScreenSignIn(),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
} 