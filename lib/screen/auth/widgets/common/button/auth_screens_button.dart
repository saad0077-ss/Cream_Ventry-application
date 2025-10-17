import 'package:cream_ventory/themes/font_helper/font_helper.dart';
import 'package:flutter/material.dart';

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
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 60),
        backgroundColor: Colors.lightBlueAccent,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: RichText(
        text: TextSpan(
          text: primaryText,
          style:AppTextStyles.textSpan, 
          children: [
            TextSpan(
              text: secondaryText,
              style: AppTextStyles.textSpan2, 
            ),
          ],
        ),
      ),
    );
  }
}