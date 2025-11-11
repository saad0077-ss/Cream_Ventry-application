import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DottedTextField extends StatelessWidget {
  final String hintText;
  final Function(String) onChanged;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const DottedTextField({
    required this.hintText,
    required this.onChanged,
    this.controller,
    this.keyboardType,
    this.inputFormatters,
    super.key, required InputDecoration decoration,
  });
 
  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      padding: EdgeInsets.zero,
      borderPadding: EdgeInsets.all(2),
      borderType: BorderType.RRect,
      radius: Radius.circular(4),
      dashPattern: [3, 3],
      color: Colors.black,
      strokeWidth: 2,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        ),
        onChanged: onChanged,
      ),
    );
  }
}