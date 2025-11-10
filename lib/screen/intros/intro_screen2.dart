import 'package:cream_ventory/screen/auth/sign_in_screen.dart';
import 'package:cream_ventory/widgets/background_image.dart';
import 'package:cream_ventory/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScreenIntro2 extends StatelessWidget {
  const ScreenIntro2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Stack(
          children: [
            /// Background Lottie animation
            Positioned.fill(
              child: IntroBackground(
                imagePath: 'assets/animation/intro2.json',   
                fit: BoxFit.cover,
                loopAnimation: true,
                reverseAnimation: false,
                animationSpeed: 1.0, // Adjusted to a reasonable default
                animateChild: true,    
                animationScale: 0.7,                                          
              ),
            ),   

            /// Foreground content (button)
            Positioned(
              bottom: 10.h,
              left: 20.w,    
              right: 20.w,
              child: SafeArea(
                child: CustomButton(
                  label: "Let's Get Started",
                  fontSize: 18.r, // Responsive font size
                  borderRadius: 10.r, // Responsive border radius
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
          ],
        ),
      ),
    );
  }
}    
