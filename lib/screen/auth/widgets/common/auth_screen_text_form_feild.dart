import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?) validator;
  final bool isPassword;
  final bool isPasswordVisible;
  final VoidCallback? togglePasswordVisibility;
  final String fontFamily;
  final Color? textColor;
  final Color? fillColor;
  final TextInputType type;

  const CustomTextFormField({
    super.key,
    required this.controller,
    this.type = TextInputType.text,
    required this.hintText,
    required this.validator,
    this.isPassword = false,
    this.isPasswordVisible = false,
    this.togglePasswordVisibility,
    this.fontFamily = 'ABeeZee',
    this.textColor,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 600;

    final Color effectiveTextColor = textColor ?? Colors.white;
    final Color effectiveFillColor =
        fillColor ??
        (isPassword
            ? const Color.fromARGB(31, 255, 255, 255)
            : const Color.fromARGB(40, 255, 255, 255));

    return TextFormField(
      controller: controller,
      obscureText: isPassword && !isPasswordVisible,
      style: TextStyle(
        color: effectiveTextColor,
        fontSize: 16,
      ), // Added responsive font size
      keyboardType: type,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: effectiveTextColor.withOpacity(0.8),
          fontSize: 20, // Responsive font size
          fontFamily: fontFamily,
        ),
        filled: true,
        fillColor: effectiveFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            isDesktop ? 2.w : 12.w,
          ), // Responsive border radius
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: effectiveTextColor,
                  size: 24, 
                ),
                onPressed: togglePasswordVisibility,
              )
            : null,
      ),
      validator: validator,
    );
  }
}
