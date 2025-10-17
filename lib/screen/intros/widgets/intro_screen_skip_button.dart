import 'package:cream_ventory/screen/auth/sign_in_screen.dart';
import 'package:cream_ventory/utils/responsive_util.dart';
import 'package:flutter/material.dart';

class IntroSkipButton extends StatelessWidget {
  const IntroSkipButton({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context); // Initialize SizeConfig

    return Positioned(
      top: SizeConfig.blockHeight * 5,  // ~5% of screen height
      right: SizeConfig.blockWidth * 5, // ~5% of screen width
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ScreenSignIn()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(113, 0, 0, 0),
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockWidth * 5.5, // ~22px if screen width is 400
            vertical: SizeConfig.blockHeight * 0.8,  // ~2px if screen height is 250
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 5),
          ),
          elevation: 0,
        ),
        child: Text(
          "Skip",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'ADLaM',
            fontSize: SizeConfig.textMultiplier * 1.4, // ~14px on 100% scale
          ),
        ),
      ),
    );
  }
}
