import 'package:cream_ventory/utils/responsive_util.dart';
import 'package:flutter/material.dart';

class IntroBottomContainer extends StatelessWidget {
  final String description;
  final Widget button;
  final double? containerHeight;

  const IntroBottomContainer({
    super.key,
    required this.description,
    required this.button,
    this.containerHeight,
  }); 

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Positioned(
      bottom: SizeConfig.blockHeight * 2, // Slightly elevate from bottom for floating effect
      left: SizeConfig.blockWidth * 2, // Margin from left
      right: SizeConfig.blockWidth * 2, // Margin from right
      child: Container(
        height: containerHeight ?? SizeConfig.screenHeight * 0.39, 
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockWidth * 2, 
          vertical: SizeConfig.blockHeight * 4,
        ),
        decoration: BoxDecoration(
          color: const Color.fromARGB(113, 0, 0, 0),
          borderRadius: BorderRadius.all(
            Radius.circular(SizeConfig.blockWidth * 5), // Rounded corners on all sides
          ),
          boxShadow: [
            BoxShadow( 
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.3), // Shadow for floating effect
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4), // Shadow slightly below
            ),
          ],
        ), 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(top: SizeConfig.blockHeight * 2),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: SizeConfig.textMultiplier *1.9, 
                  fontFamily: 'holtwood',
                  color: Colors.white,
                  height: 1.6,
                ),
              ),
            ),
            button,
          ],
        ),
      ),
    );
  }
}