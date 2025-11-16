import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final TextEditingController controller;
  final int maxLines;
  final Color? labelColor;
  final Color? focusColor;
  final Color? fillColor;
  final TextInputType? keyboardType;
  final void Function(String? value)? onChanged;
  final bool? readOnly;
  final bool? enabled;
  final Widget? suffixIcon;          // your own suffix (overrides everything)
  final Widget? prefixIcon;
  final String? Function(String?)? validator;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final double borderRadius;
  final EdgeInsets? contentPadding;

  // ---- NEW: control the info icon ----
  final bool showInfoIcon;          // set true only where you need it
  final String? infoMessage;        // tooltip text, defaults to label/hint

  const CustomTextField({
    super.key,
    this.labelText,
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
    this.showInfoIcon = false,      // default: no icon
    this.infoMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Build the *effective* suffix:
    // 1. custom suffixIcon (if any) -> highest priority
    // 2. info icon (only when showInfoIcon == true)
    // 3. null -> no suffix
    Widget? effectiveSuffix;
    if (suffixIcon != null) {
      effectiveSuffix = suffixIcon;
    } else if (showInfoIcon) {
      effectiveSuffix = Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Tooltip(
          message: infoMessage ?? labelText ?? hintText ?? 'Info',
          child: Icon(
            Icons.info_outline,
            color: Colors.blueGrey.shade600,
            size: 20,
          ),
        ),
      );
    }

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      readOnly: readOnly ?? false,
      enabled: enabled ?? true,
      onChanged: onChanged,
      validator: validator,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: enabled == false
            ? const Color.fromARGB(255, 63, 27, 27)
            : Colors.black87,
        fontSize: 16.0,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        errorText: errorText,
        suffixIcon: effectiveSuffix,
        prefixIcon: prefixIcon,
        filled: fillColor != null,
        fillColor: fillColor ?? Colors.grey[50],
        labelStyle: TextStyle(
          color: labelColor ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: Colors.blueGrey,
          fontWeight: FontWeight.w600,
        ),
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        enabledBorder: enabledBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(color: Colors.black87, width: 1.5),
            ),
        focusedBorder: focusedBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: focusColor ?? Colors.blueGrey, 
                width: 2.0,
              ),
            ),
        errorBorder: errorBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
        ),
      ),
    );
  }
}