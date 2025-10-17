import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double fontSize;
  final Color backgroundColor;
  final String font;
  final double borderRadius;
  final Color fontColor;

  const CustomButton({
    super.key, 
    required this.label,
    required this.onPressed,
    this.fontSize = 20,
    this.backgroundColor = const Color.fromARGB(86, 177, 163, 163),
    this.font = 'holtwood',
    this.borderRadius = 10,
    this.fontColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 80)
      ), 
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          color: fontColor,
          fontFamily: font,
        ),
      ),
    );
  }
}