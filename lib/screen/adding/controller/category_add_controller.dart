import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cream_ventory/db/models/items/category/category_model.dart';
import 'package:uuid/uuid.dart';

class CategoryAddController {
  String? nameError;
  String? descriptionError;
  String? imageError;
  bool isPickingImage = false;
  final bool _isEditing;

  final TextEditingController nameController;
  final TextEditingController descriptionController;
  File? selectedImage;

  CategoryAddController({
    CategoryModel? categoryToEdit,
    bool isEditing = false,
  })  : _isEditing = isEditing,
        nameController = TextEditingController(
          text: isEditing ? categoryToEdit?.name ?? '' : '',
        ),
        descriptionController = TextEditingController(
          text: isEditing ? categoryToEdit?.discription ?? '' : '',
        ) {
    // Initialize selectedImage in constructor body
    if (isEditing && categoryToEdit != null) {
      selectedImage = File(categoryToEdit.imagePath);
    }
  }

  bool get isEditing => _isEditing;
  bool get isFormValid => nameError == null &&
      descriptionError == null &&
      imageError == null;

  void validateFields() {
    nameError = nameController.text.trim().isEmpty
        ? "Category name is required."
        : null;
    descriptionError = descriptionController.text.trim().isEmpty
        ? "Category description is required."
        : null;
    imageError = selectedImage == null ? "Please select an image." : null;
  }

  Future<String> processImage({required CategoryModel? categoryToEdit}) async {
    if (isEditing && selectedImage!.path == categoryToEdit!.imagePath) {
      return selectedImage!.path;
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final imagePath = '${dir.path}/${const Uuid().v4()}.png';
      await selectedImage!.copy(imagePath);
      return imagePath;
    }
  }

  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
  }
}