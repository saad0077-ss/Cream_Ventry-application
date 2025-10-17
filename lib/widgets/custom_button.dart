
import 'package:cream_ventory/themes/font_helper/font_helper.dart';
import 'package:cream_ventory/utils/responsive_util.dart';
import 'package:flutter/material.dart';

class CustomActionButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final VoidCallback onPressed;
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
    // Ensure SizeConfig is initialized
    SizeConfig.init(context);

    return SizedBox(
      width: width ?? SizeConfig.blockWidth * 40, // Default to 40% of screen width
      child: ElevatedButton(
        onPressed: onPressed, 
        style: ElevatedButton.styleFrom(
          padding: padding ??
              EdgeInsets.symmetric(
                vertical: SizeConfig.blockHeight *1.5, 
                horizontal: SizeConfig.blockWidth * 2,
              ),
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 6), // Responsive radius
            side: BorderSide(
              color: borderColor ?? Colors.transparent,
            ),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.regular(
            fontSize: fontSize ?? SizeConfig.textMultiplier * 2 , // Responsive text size
          ),
        ),
      ),
    );
  }
}
