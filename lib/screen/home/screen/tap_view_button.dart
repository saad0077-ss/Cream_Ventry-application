import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
     double buttonWidth =
        180.w; // Fixed pixel value (~43% of typical 400px screen width)
     double verticalPadding = 11.r; // Fixed pixel value
     double fontSize = 15; // Fixed pixel value
     double spacing = 6.w; // Fixed pixel value

    return Container(
      padding:  EdgeInsets.symmetric(vertical: 8.h), // Fixed pixel value
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onTapOne,
            child: Container(
              width: buttonWidth,
              padding:  EdgeInsets.symmetric(vertical: verticalPadding),
              decoration: BoxDecoration(
                color: isTabOneSelected ? Colors.blueGrey : Colors.white,
                border: Border.all(
                  color: isTabOneSelected ? Colors.grey : Colors.blueGrey,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(36.r), // Fixed pixel value
              ),
              alignment: Alignment.center,
              child: Text(
                title1,
                style: TextStyle(
                  color: isTabOneSelected ? Colors.white : Colors.black,
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
              padding:  EdgeInsets.symmetric(vertical: verticalPadding),
              decoration: BoxDecoration(
                color: isTabOneSelected ? Colors.white  : Colors.blueGrey,
                border: Border.all(
                  color: isTabOneSelected ? Colors.blueGrey : Colors.grey,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(32.r), // Fixed pixel value   
              ),
              alignment: Alignment.center,
              child: Text(
                title2,
                style: TextStyle(
                  color: isTabOneSelected ? Colors.black : Colors.white,
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
