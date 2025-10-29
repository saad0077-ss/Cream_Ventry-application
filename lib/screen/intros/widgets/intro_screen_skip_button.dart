import 'package:cream_ventory/screen/auth/sign_in_screen.dart';
import 'package:flutter/material.dart';

class IntroSkipButton extends StatelessWidget {
  const IntroSkipButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40, // Fixed pixel value (~5% of typical screen height)
      right: 20, // Fixed pixel value (~5% of typical screen width)
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ScreenSignIn()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(113, 0, 0, 0),
          padding: const EdgeInsets.symmetric(
            horizontal: 22, // Fixed pixel value
            vertical: 6, // Fixed pixel value
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Fixed pixel radius
          ),
          elevation: 0,
        ),
        child: const Text(
          "Skip", 
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'ADLaM',
            fontSize: 14, // Fixed pixel font size
          ),
        ),
      ),
    );
  }
}