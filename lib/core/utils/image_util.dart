// lib/utils/image_utils.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ImageUtils {
  /// Get ImageProvider from either path or bytes
  static ImageProvider getImage(
    String? path, {
    Uint8List? bytes,
    bool isAsset = false,
    String fallback = 'assets/image/placeholder.png',
  }) {
    const defaultImage = AssetImage('assets/image/placeholder.png');

    // Priority 1: If bytes are provided, use them directly
    if (bytes != null && bytes.isNotEmpty) {
      return MemoryImage(bytes);
    }

    // Priority 2: Check path
    if (path == null || path.isEmpty) return defaultImage;

    // Handle asset images
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
      try {
        final file = File(path);
        return file.existsSync() ? FileImage(file) : defaultImage;
      } catch (e) {
        debugPrint('File error: $e');
        return defaultImage;
      }
    }
  }

  /// Build Image Widget from either path or bytes
  static Widget buildImage(
    String? path, {
    Uint8List? bytes,
    bool isAsset = false,
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    Widget? errorWidget,
  }) {
    // Priority 1: If bytes are provided, use them directly
    if (bytes != null && bytes.isNotEmpty) {
      return Image.memory(
        bytes,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Memory image error: $error');
          return errorWidget ?? _buildDefaultErrorWidget();
        },
      );
    }

    // Priority 2: Check path
    if (path == null || path.isEmpty) {
      return errorWidget ?? _buildDefaultErrorWidget();
    }

    // Handle asset images
    if (isAsset) {
      return Image.asset(
        path,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Asset image error: $error');
          return errorWidget ?? _buildDefaultErrorWidget();
        },
      );
    }

    // Handle web images (base64)
    if (kIsWeb) {
      if (path.startsWith('data:image')) {
        try {
          final base64Data = path.split(',').last;
          final imageBytes = base64Decode(base64Data);
          return Image.memory(
            imageBytes,
            fit: fit,
            width: width,
            height: height,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Base64 decode error: $error');
              return errorWidget ?? _buildDefaultErrorWidget();
            },
          );
        } catch (e) {
          debugPrint('Base64 decode error: $e');
          return errorWidget ?? _buildDefaultErrorWidget();
        }
      } else {
        // Try direct base64 decode
        try {
          final imageBytes = base64Decode(path);
          return Image.memory(
            imageBytes,
            fit: fit,
            width: width,
            height: height,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Base64 error: $error');
              return errorWidget ?? _buildDefaultErrorWidget();
            },
          );
        } catch (e) {
          debugPrint('Base64 error: $e');
          return errorWidget ?? _buildDefaultErrorWidget();
        }
      }
    } else {
      // Handle mobile file paths
      try {
        final file = File(path);
        if (file.existsSync()) {
          return Image.file(
            file,
            fit: fit,
            width: width,
            height: height,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('File image error: $error');
              return errorWidget ?? _buildDefaultErrorWidget();
            },
          );
        } else {
          debugPrint('File does not exist: $path');
          return errorWidget ?? _buildDefaultErrorWidget();
        }
      } catch (e) {
        debugPrint('File image error: $e');
        return errorWidget ?? _buildDefaultErrorWidget();
      }
    }
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

  /// Helper to build circular avatar with image
  static Widget buildCircularImage(
    String? path, {
    Uint8List? bytes,
    bool isAsset = false,
    double radius = 50,
    Widget? placeholder,
  }) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[200],
      backgroundImage: bytes != null && bytes.isNotEmpty
          ? MemoryImage(bytes)
          : getImage(path, bytes: bytes, isAsset: isAsset),
      child: (bytes == null || bytes.isEmpty) && (path == null || path.isEmpty)
          ? placeholder ??
              Icon(
                Icons.person,
                size: radius,
                color: Colors.grey[600],
              )
          : null,
    );
  }
}