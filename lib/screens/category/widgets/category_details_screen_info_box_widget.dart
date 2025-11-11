// lib/screens/category/widgets/info_box_widget.dart
import 'package:flutter/material.dart';
import 'package:cream_ventory/core/constants/font_helper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InfoBoxWidget extends StatelessWidget {
  final String label, value;
  final double screenWidth;
  const InfoBoxWidget({super.key, required this.label, required this.value, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.w500.copyWith(fontSize: 14, color: Colors.grey[600])),
         SizedBox(height: 6.h), 
        Container(
          width: screenWidth * 0.4,
          padding:  EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[100],
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 3))],
          ),
          child: Text(value, style: AppTextStyles.bold13.copyWith(fontSize: 16, color: Colors.black87), textAlign: TextAlign.center),
        ),
      ],
    );
  }
}