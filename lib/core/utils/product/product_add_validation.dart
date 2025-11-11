import 'package:cream_ventory/models/category_model.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class ValidationUtils {
  static bool validateFields({
    required TextEditingController nameController,
    required TextEditingController stockController,
    required TextEditingController salePriceController,
    required TextEditingController purchasePriceController,
    required CategoryModel? selectedCategory,
    required File? selectedImage,
    required Uint8List? selectedImageBytes, // Added for web
    required void Function(VoidCallback) setStateCallback,
    required void Function(String?) nameErrorCallback,
    required void Function(String?) stockErrorCallback,
    required void Function(String?) salePriceErrorCallback,
    required void Function(String?) purchasePriceErrorCallback,
    required void Function(String?) categoryErrorCallback,
    required void Function(String?) imageErrorCallback,
  }) {
    setStateCallback(() {
      nameErrorCallback(
          nameController.text.trim().isEmpty ? 'Product name is required.' : null);
      stockErrorCallback(int.tryParse(stockController.text.trim()) == null ||
              int.parse(stockController.text.trim()) < 0
          ? 'Stock must be a non-negative number.'
          : null);
      salePriceErrorCallback(double.tryParse(salePriceController.text.trim()) == null ||
              double.parse(salePriceController.text.trim()) <= 0
          ? 'Sale price must be a positive number.'
          : null);
      purchasePriceErrorCallback(double.tryParse(purchasePriceController.text.trim()) ==
                  null ||
              double.parse(purchasePriceController.text.trim()) <= 0
          ? 'Purchase price must be a positive number.'
          : null);
      categoryErrorCallback(
          selectedCategory == null ? 'Please select a category.' : null);
      imageErrorCallback(
          (kIsWeb ? selectedImageBytes == null : selectedImage == null)
              ? 'Please select an image.'
              : null);
    });

    return nameController.text.trim().isNotEmpty &&
        int.tryParse(stockController.text.trim()) != null &&
        int.parse(stockController.text.trim()) >= 0 &&
        double.tryParse(salePriceController.text.trim()) != null &&
        double.parse(salePriceController.text.trim()) > 0 &&
        double.tryParse(purchasePriceController.text.trim()) != null &&
        double.parse(purchasePriceController.text.trim()) > 0 &&
        selectedCategory != null &&
        (kIsWeb ? selectedImageBytes != null : selectedImage != null);
  }
}