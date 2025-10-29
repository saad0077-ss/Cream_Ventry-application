import 'package:cream_ventory/themes/font_helper/font_helper.dart';
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
    return SizedBox(
      width: width ?? 160, // Default to 160 pixels (~40% of typical mobile screen)
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
              color: borderColor ?? Colors.transparent,
            ),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.regular(
            fontSize: fontSize ?? 16, // Fixed pixel text size             
          ),
        ),
      ),
    );
  }
}