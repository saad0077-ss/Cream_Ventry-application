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
          style: const TextStyle(color: mainColor),
        ),
        SizedBox(width: 30.w),
        SizedBox(
          width: 20.w,
          child: const Divider(
            color: Colors.red,
            thickness: 2,
          ),
        ),
        Text(
          selectedPeriod == 'Monthly' ? 'Previous Month' : 'Previous Week',
          style: const TextStyle(color: Colors.red),
        ),
      ],
    );
  }
}