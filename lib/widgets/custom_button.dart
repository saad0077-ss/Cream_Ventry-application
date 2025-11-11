import 'package:cream_ventory/core/constants/font_helper.dart';
import 'package:flutter/material.dart';

class CustomActionButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final VoidCallback?  onPressed;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final double? fontSize;

  const CustomActionButton({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.onPressed,
    this.width,
    this.padding,
    this.borderColor,
    this.fontSize,
  }); 

  @override
  Widget build(BuildContext context) {

    final bool isSmallScreen = MediaQuery.of(context).size.width < 400;

    smallfontSize() {
      if (isSmallScreen) {
        return 12.0; // Smaller font size for small screens
      } else {
        return 19.0; // Default font size for larger screens
      }
    }

    return SizedBox(
      width: width ?? 170, 
      child: ElevatedButton(
        onPressed: onPressed, 
        style: ElevatedButton.styleFrom(
          padding: padding ??
              const EdgeInsets.symmetric(
                vertical: 12, // Fixed pixel size
                horizontal: 16, // Fixed pixel size
              ),
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24), // Fixed pixel radius
            side: BorderSide(
              color: borderColor ?? Colors.blueGrey,
              width: 2 
            ),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.regular(      
            fontSize: fontSize ??  smallfontSize(), // Fixed pixel text size                  
          ),
        ),
      ),
    );
  }
}