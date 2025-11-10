// lib/screens/category/widgets/category_image_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'dart:convert';

import 'package:cream_ventory/db/models/items/category/category_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'category_details_screen_error_image_widget.dart'; // Fixed relative path

class CategoryImageWidget extends StatelessWidget {
  final CategoryModel category;

  const CategoryImageWidget({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6.r,
            offset: const Offset(0, 3),
          ),
        ],
      ), 
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    // 1. Asset Image
    if (category.isAsset) {
      return Image.asset(
        category.imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const ErrorImageWidget(),
      );
    }

    // 2. Web: Base64 Image
    if (kIsWeb && category.imagePath.startsWith('data:image')) {
      try {
        final base64Data = category.imagePath.split(',').last;
        final bytes = base64Decode(base64Data);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const ErrorImageWidget(),
        );
      } catch (_) {
        return const ErrorImageWidget();
      }
    }

    // 3. Mobile: File Path
    try {
      final file = File(category.imagePath);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const ErrorImageWidget(),
        );
      } else { 
        return const ErrorImageWidget();
      }
    } catch (_) {
      return const ErrorImageWidget();
    }
  }
}