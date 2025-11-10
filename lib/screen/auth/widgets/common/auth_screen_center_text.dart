import 'package:cream_ventory/themes/font_helper/font_helper.dart';
import 'package:cream_ventory/widgets/positioned.dart';
import 'package:cream_ventory/widgets/text_span.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CenterTextSignUp extends StatelessWidget {
  const CenterTextSignUp({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 700;
    return CustomPositioned(
      type: PositionedType.basic,
      left: 0,
      right: 0,
      bottom: 450.h, // ~57% of 812px design height 
      child: Center(
        child: CustomTextSpan(
          spans: [
            TextSpanConfig(
              text: 'CREATE',
              style: TextStyle(
                fontSize: isDesktop ? 60 : 30,
                fontFamily: 'holtwood',
                color: Colors.white,
              ),
            ),
            TextSpanConfig(
              text: ' ACCOUNT',
              style: TextStyle(
                fontSize: isDesktop ? 60 : 30,
                fontFamily: 'holtwood',
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WelcomeText extends StatelessWidget {
  const WelcomeText({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPositioned( 
      type: PositionedType.basic,
      bottom: 600.5.h, // ~12.5% of 812px design height
      left: 30.5.w, // ~10% of 375px design width
      child: Text(
        'WELCOME BACK 😊 \nHappy to see you again!',
        style: AppTextStyles.welcomeTitle, 
      ),
    );
  }
}

class CenterTextSignIn extends StatelessWidget {
  const CenterTextSignIn({super.key}); 

  @override
  Widget build(BuildContext context) {

    final bool isDesktop = MediaQuery.of(context).size.width >= 700;
    return CustomPositioned(
      type: PositionedType.basic,
      left: 0,
      right: 0,
      bottom: 440.h, // ~50% of 812px design height 
      child: Center(
        child: CustomTextSpan(
          spans: [
            TextSpanConfig(
              text: 'SIGN ',
              style: TextStyle(
                fontSize: isDesktop? 60 : 35,
                fontFamily: 'holtwood',
                color: Colors.white,
              ),
            ),
            TextSpanConfig(
              text: 'IN',
              style: TextStyle(
                fontSize: isDesktop? 60 : 35,
                fontFamily: 'holtwood',
                color: Colors.white,  
              ),
            ),
            TextSpanConfig(
              text: ' NOW',
              style: TextStyle(
                fontSize:isDesktop? 60 : 35 ,
                fontFamily: 'holtwood',
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
