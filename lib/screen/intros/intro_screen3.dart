import 'package:cream_ventory/screen/auth/sign_in_screen.dart';
import 'package:cream_ventory/widgets/background_image.dart';
import 'package:cream_ventory/widgets/button.dart';
import 'package:flutter/material.dart';

class ScreenIntro3 extends StatelessWidget {
  const ScreenIntro3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IntroBackground(imagePath: 'assets/image/sss.jpg'),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: CustomButton(
              label: 'Lets Get Started',
              onPressed: () {
                Navigator.of(context).pushReplacement( 
                  MaterialPageRoute(builder: (context) => ScreenSignIn()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
