import 'package:cream_ventory/core/constants/font_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
    required this.onPressed,
    required this.primaryText,
    required this.secondaryText,
  });

  final VoidCallback onPressed;
  final String primaryText;
  final String secondaryText;

  @override
  Widget build(BuildContext context) {
    return SizedBox( 
      width: double.infinity,
      height: 50.h, // Responsive height
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lightBlueAccent,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r), // Responsive radius
          ),
        ),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: primaryText,
            style: AppTextStyles.textSpan,
            children: [
              TextSpan(   
                text: secondaryText,
                style: AppTextStyles.textSpan2
              ),
            ],
          ),
        ),
      ),
    );
  }
}
