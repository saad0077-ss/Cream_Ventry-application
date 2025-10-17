import 'package:cream_ventory/themes/font_helper/font_helper.dart';
import 'package:cream_ventory/utils/responsive_util.dart';
import 'package:cream_ventory/widgets/container.dart';
import 'package:cream_ventory/widgets/positioned.dart';
import 'package:flutter/material.dart';

class TextContainer extends StatelessWidget {
  const TextContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPositioned(
      type: PositionedType.basic,
      top: 60,
      left: 20,
      right: 20,
      child: ReusableContainer(
        padding: const EdgeInsets.all(8),
        height:  SizeConfig.screenHeight * 0.27,
        color: const Color.fromARGB(146, 0, 0, 0),
        borderRadius: BorderRadius.circular(15),
        child: Center( 
          child: Text(
            '"WELCOME TO CREAMVENTORY\nLET\'S GET YOU SCOOPED IN!\nCREATE YOUR ACCOUNT AND\nSTART MANAGING YOUR ICE\nCREAM INVENTORY WITH\nJOY. 🍦✨"',
            textAlign: TextAlign.center,
            style: AppTextStyles.signUpText
          ),
        ),
      ),
    );
  }
}