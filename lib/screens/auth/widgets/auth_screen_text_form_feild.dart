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
  final String labelText;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
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
    

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 1000;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1000;

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
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: effectiveTextColor.withOpacity(0.8),
          fontSize: 20,
          fontFamily: fontFamily,
        ),
        filled: true,
        
        fillColor: effectiveFillColor,
        label: Text(
          labelText,
          style: TextStyle( 
            color: Colors.white,
            fontSize: 20
          ), 
        ),
      
        border: OutlineInputBorder(

          borderRadius: BorderRadius.circular(
            isDesktop ? 2.w : isTablet ? 6.w : 12.w, 
          ), 
          borderSide: BorderSide(
            width: 4 
          ),
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
