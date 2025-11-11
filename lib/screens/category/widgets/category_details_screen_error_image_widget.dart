// lib/screens/category/widgets/error_image_widget.dart
import 'package:flutter/material.dart';

class ErrorImageWidget extends StatelessWidget {
  const ErrorImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey[600]),
      ),
    );
  }
}