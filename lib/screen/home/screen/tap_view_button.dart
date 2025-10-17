import 'package:cream_ventory/utils/responsive_util.dart';
import 'package:flutter/material.dart';

class TabButtons extends StatelessWidget {
  final bool isTabOneSelected;
  final VoidCallback onTapOne;
  final VoidCallback onTapTwo;
  final String title1;
  final String title2;

  const TabButtons({
    super.key,
    required this.isTabOneSelected,
    required this.onTapOne,
    required this.onTapTwo,
    required this.title1,
    required this.title2,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    double buttonWidth = SizeConfig.blockWidth * 47; // ~43% of screen width
    double verticalPadding = SizeConfig.blockHeight * 1.2;
    double fontSize = SizeConfig.textMultiplier * 1.7;
    double spacing = SizeConfig.blockWidth * 1.4; 

    return Container(
      padding: EdgeInsets.symmetric(vertical: SizeConfig.blockHeight * 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector( 
            onTap: onTapOne,
            child: Container(
              width: buttonWidth,
              padding: EdgeInsets.symmetric(vertical: verticalPadding),
              decoration: BoxDecoration(
                color: isTabOneSelected
                    ? Colors.red.shade100
                    : Colors.white,
                border: Border.all(
                  color: isTabOneSelected ? Colors.red : Colors.grey,
                ),
                borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 9),
              ),
              alignment: Alignment.center,
              child: Text(
                title1,
                style: TextStyle(
                  color: isTabOneSelected ? Colors.red : Colors.black,
                  fontFamily: 'ADLaM',
                  fontSize: fontSize,
                ),
              ),
            ),
          ),
          SizedBox(width: spacing),
          GestureDetector(
            onTap: onTapTwo,
            child: Container(
              width: buttonWidth,
              padding: EdgeInsets.symmetric(vertical: verticalPadding),
              decoration: BoxDecoration(
                color: isTabOneSelected
                    ? Colors.white
                    : Colors.red.shade100,
                border: Border.all(
                  color: isTabOneSelected ? Colors.grey : Colors.red,
                ),
                borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 8),
              ),
              alignment: Alignment.center,
              child: Text(
                title2,
                style: TextStyle(
                  color: isTabOneSelected ? Colors.black : Colors.red,
                  fontFamily: 'ADLaM',
                  fontSize: fontSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
