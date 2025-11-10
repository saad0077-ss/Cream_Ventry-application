import 'package:cream_ventory/widgets/container.dart';
import 'package:cream_ventory/widgets/positioned.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TextContainer extends StatelessWidget {
  const TextContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 600;

    return CustomPositioned(
      type: PositionedType.basic,
      bottom: 539.h, // ~7.5% of 812px design height
      left: 18.75.w, // ~5% of 375px design width
      right: 18.75.w, // ~5% of 375px design width
      child: ReusableContainer(
        padding: EdgeInsets.all(isDesktop ? 7 : 15), // Responsive padding
        height: 219.24.h, // ~27% of 812px design height
        width: isDesktop ? 200 : double.infinity,
        color: Colors.black38,
        borderRadius: BorderRadius.circular( 
          isDesktop ? 6.w : 15.w,
        ), // Responsive border radius
        child: Center( 
          child: Text(
            '"WELCOME TO CREAMVENTORY\nLET\'S GET YOU SCOOPED IN!\nCREATE YOUR ACCOUNT AND\nSTART MANAGING YOUR ICE\nCREAM INVENTORY WITH\nJOY. 🍦✨"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'holtwood',
              color: Colors.white,
              fontSize:isDesktop ? 20 : 16 ,
              letterSpacing: 1, 
              height: 1.7,
            ),
          ),
        ),
      ),
    );
  }
}
