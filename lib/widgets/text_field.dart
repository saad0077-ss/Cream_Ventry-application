import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final String? errorText;
  final TextEditingController controller;
  final int maxLines;
  final Color? labelColor;
  final Color? focusColor;
  final Color? fillColor;
  final TextInputType? keyboardType;
  final Function(String? value)? onChanged;
  final bool? readOnly;
  final bool? enabled;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? Function(String?)? validator; // Validation function
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final double borderRadius; // Custom border radius
  final EdgeInsets? contentPadding; // Padding for text input

  const CustomTextField({
    super.key,
    required this.labelText,
    this.hintText,
    this.errorText,
    required this.controller,
    this.maxLines = 1,
    this.labelColor, 
    this.focusColor,
    this.fillColor,
    this.keyboardType,
    this.onChanged,
    this.readOnly,
    this.enabled,
    this.suffixIcon,
    this.prefixIcon,
    this.validator,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
    this.borderRadius = 12.0,  
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      readOnly: readOnly ?? false,
      enabled: enabled ?? true,
      onChanged: onChanged,
      validator: validator, 
      style: theme.textTheme.bodyMedium?.copyWith(
        color: enabled == false ? const Color.fromARGB(255, 63, 27, 27) : Colors.black87, 
        fontSize: 16.0,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        errorText: errorText,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        filled: fillColor != null,
        fillColor: fillColor ?? Colors.grey[50],
        labelStyle: TextStyle(
          color: labelColor ?? theme.primaryColor,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: Colors.grey[500],
          fontWeight: FontWeight.w400,
        ),
        contentPadding: contentPadding ?? const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 14.0,
        ),
        enabledBorder: enabledBorder ?? OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: Colors.black87,
            width: 1.5,       
          ),
        ),
        focusedBorder: focusedBorder ?? OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: focusColor ?? theme.primaryColor,
            width: 2.0,
          ),
        ),
        errorBorder: errorBorder ?? OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 2.0,
          ),
        ),
      ),
    );
  }
}             