import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Assuming these are defined in your constants file
const Color logoColor = Colors.blueGrey;
const Color mainColor = Colors.blue;

class GraphLegend extends StatelessWidget {
  final String selectedPeriod;

  const GraphLegend({
    super.key,
    required this.selectedPeriod,
  });

  @override
  Widget build(BuildContext context) {

    final isSmallScreen = MediaQuery.of(context).size.width < 375;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center ,
      children: [
        SizedBox(width: 20.w),
        SizedBox(
          width: 20.w,
          child: const Divider( 
            color: mainColor,
            thickness: 2,
          ),
        ),
        Text(
          selectedPeriod == 'Monthly' ? 'Current Month' : 'Current Week',
          style:  TextStyle(color: mainColor,fontSize:isSmallScreen? 10:14.r),
        ),
        SizedBox(width: 28.w),
        SizedBox(
          width: 20.w, 
          child: const Divider(  
            color: Colors.red,
            thickness: 2,
          ),
        ),
        Text(
          selectedPeriod == 'Monthly' ? 'Previous Month' : 'Previous Week',
          style:  TextStyle(color: Colors.red,fontSize:isSmallScreen? 10:14.r),
        ),
      ],
    );
  }
}