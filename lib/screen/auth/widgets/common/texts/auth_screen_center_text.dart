import 'package:cream_ventory/themes/font_helper/font_helper.dart';
import 'package:cream_ventory/utils/responsive_util.dart';
import 'package:cream_ventory/widgets/positioned.dart';
import 'package:cream_ventory/widgets/text_span.dart';
import 'package:flutter/material.dart';

class CenterTextSignUp extends StatelessWidget {
  const CenterTextSignUp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPositioned(
      type: PositionedType.basic,
      left: SizeConfig.blockWidth * 0.90,
      right: SizeConfig.blockWidth * 0.90 ,
      bottom:  SizeConfig.screenHeight * 0.57,
      child: Center(  
        child: CustomTextSpan(
          spans: [
            TextSpanConfig(
              text: 'CREATE',
              style: AppTextStyles.holtwood35White,
            ),
            TextSpanConfig(
              text: '  ACCOUNT',
              style:AppTextStyles.holtwood35White,
            ),
          ],
        ),
      ),
    );
  }
}

class WelcomeText extends StatelessWidget {
  const WelcomeText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPositioned(
      type: PositionedType.basic,
      top: 100,
      left: 40,
      child: Text(
        'WELCOME BACK 😊 \nHappy to see you again!',
        style: AppTextStyles.welcomeTitle
      ),
    );
  }
}

class CenterTextSignIn extends StatelessWidget {
  const CenterTextSignIn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPositioned(
      type: PositionedType.basic,
      left: 0,
      right: 0,
      bottom: SizeConfig.blockHeight * 50,
      child: Center( 
        // This CustomTextSpan is used to make a sentence seperate words and give different styles to it
        child: CustomTextSpan(
          spans: [
            // Inside this span we will give the seperated style to the texts inside TextSpanConfig
            TextSpanConfig(
              text: 'SIGN ',
              style: AppTextStyles.holtwood40White,
            ),
            TextSpanConfig(
              text: 'IN',
              style: AppTextStyles.holtwood40Accent,
            ),
            TextSpanConfig(
              text: ' NOW',
              style:  AppTextStyles.holtwood40White,
            ),
          ],
        ),
      ),
    );
  }
}

