 import 'package:cream_ventory/screen/intros/intro_screen3.dart';
import 'package:cream_ventory/screen/intros/widgets/intro_screen_container.dart';
import 'package:cream_ventory/screen/intros/widgets/intro_screen_skip_button.dart';
import 'package:cream_ventory/utils/responsive_util.dart';
import 'package:cream_ventory/widgets/background_image.dart';
import 'package:cream_ventory/widgets/button.dart';
import 'package:flutter/material.dart';

class ScreenIntro2 extends StatelessWidget {
  const ScreenIntro2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IntroBackground(imagePath: 'assets/image/ice3.jpg'),
          IntroSkipButton(),
          IntroBottomContainer( 
            containerHeight: SizeConfig.screenHeight * 0.29,  
            description:
                '"NEXT UP: EASY INVENTORY\nMANAGEMENT AT YOUR\nFINGERTIPS!👉"',
            button: CustomButton(
              label: 'NEXT',
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const ScreenIntro3()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
