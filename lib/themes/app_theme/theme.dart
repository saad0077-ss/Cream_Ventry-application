import 'package:flutter/material.dart';

class AppTheme {
  static const LinearGradient appGradient = LinearGradient(   
    begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFD6E6F2), // Soft blue-gray for a professional base
              Color(0xFF7BE7F0), // Subtle cyan to tie into app's branding
              Color(0xFFE8ECEF), // Light gray for depth
              Color(0xFFFFFFFF), // White for a clean finish
            ],
            stops: [0.0, 0.3, 0.7, 1.0], // Smooth transitions
  ); 
 

  static final cardBackground = Colors.grey[200];   
  static final itemBackground = Colors.purple[50];
  static const textGrey = Colors.grey;
}
      