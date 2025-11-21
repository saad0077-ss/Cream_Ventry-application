import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DottedTextField extends StatefulWidget {
  final String hintText;
  final Function(String) onChanged;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final InputDecoration decoration;

  const DottedTextField({
    required this.hintText,
    required this.onChanged,
    required this.decoration,
    this.controller,
    this.keyboardType,
    this.inputFormatters,
    super.key,
  });

  @override
  State<DottedTextField> createState() => _DottedTextFieldState();
}

class _DottedTextFieldState extends State<DottedTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() {
            _isFocused = hasFocus;
          });
        },
        child: TextField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          decoration: widget.decoration.copyWith( 
            hintText: widget.hintText,
          ),
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}