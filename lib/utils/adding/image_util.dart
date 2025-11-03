// lib/utils/image_utils.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ImageUtils {
  static ImageProvider getImage(
    String? path, {
    bool isAsset = false,
    String fallback = 'assets/image/placeholder.png',
  }) {
    const defaultImage = AssetImage('assets/image/placeholder.png');

    if (path == null || path.isEmpty) return defaultImage;

    // Handle asset images first
    if (isAsset) {
      return AssetImage(path);
    }

    // Handle web images (base64)
    if (kIsWeb) {
      // Check if it's a base64 string with data:image prefix
      if (path.startsWith('data:image')) {
        try {
          final base64Data = path.split(',').last;
          return MemoryImage(base64Decode(base64Data));
        } catch (e) {
          debugPrint('Base64 decode error: $e');
          return defaultImage;
        }
      } else {
        // Try direct base64 decode
        try {
          return MemoryImage(base64Decode(path));
        } catch (e) {
          debugPrint('Base64 error: $e');
          return defaultImage;
        }
      }
    } else {
      // Handle mobile file paths
      final file = File(path);
      return file.existsSync() ? FileImage(file) : defaultImage;
    }
  }

  // Alternative method that returns a Widget instead of ImageProvider
  static Widget buildImage(
    String? path, {
    bool isAsset = false,
    BoxFit fit = BoxFit.cover,
    Widget? errorWidget,
  }) {
    if (path == null || path.isEmpty) {
      return errorWidget ?? _buildDefaultErrorWidget();
    }

    // Handle asset images
    if (isAsset) {
      return Image.asset(
        path,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ?? _buildDefaultErrorWidget(),
      );
    }

    // Handle web images (base64)
    if (kIsWeb && path.startsWith('data:image')) {
      try {
        final base64Data = path.split(',').last;
        final imageBytes = base64Decode(base64Data);
        return Image.memory(
          imageBytes,
          fit: fit,
          errorBuilder: (context, error, stackTrace) =>
              errorWidget ?? _buildDefaultErrorWidget(),
        );
      } catch (e) {
        debugPrint('Base64 decode error: $e');
        return errorWidget ?? _buildDefaultErrorWidget();
      }
    } else if (!kIsWeb) {
      // Handle mobile file paths
      try {
        final file = File(path);
        if (file.existsSync()) {
          return Image.file(
            file, 
            fit: fit,
            errorBuilder: (context, error, stackTrace) =>
                errorWidget ?? _buildDefaultErrorWidget(),
          );
        } else {
          return errorWidget ?? _buildDefaultErrorWidget();
        }
      } catch (e) {
        debugPrint('File image error: $e');
        return errorWidget ?? _buildDefaultErrorWidget();
      }
    }

    return errorWidget ?? _buildDefaultErrorWidget();
  }

  static Widget _buildDefaultErrorWidget() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 40,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}