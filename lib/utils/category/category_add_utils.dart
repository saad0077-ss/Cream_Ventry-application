import 'dart:io';
import 'package:cream_ventory/db/functions/user_db.dart';
import 'package:cream_ventory/screen/adding/category/category_add_controller.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cream_ventory/db/functions/category_db.dart';
import 'package:cream_ventory/db/models/items/category/category_model.dart';
import 'package:uuid/uuid.dart';

Future<void> pickCategoryImage(CategoryAddController controller) async {
  if (controller.isPickingImage) return;
  
  controller.isPickingImage = true;
  try {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (picked != null) {
      controller.selectedImage = File(picked.path);
      controller.imageError = null;
    }
  } catch (e) {
    debugPrint('Error picking image: $e');
    // Handle error (show snackbar, etc.)
  } finally {
    controller.isPickingImage = false;
  }
}

Future<void> saveCategory({
  required CategoryAddController controller,
  required BuildContext context,
  required bool isEditing,
  required CategoryModel? categoryToEdit,
}) async {
  controller.validateFields();

  final user = await UserDB.getCurrentUser();
  final userId = user.id;
  
  if (!controller.isFormValid) {
    return;
  }

  try {
    final finalImagePath = await controller.processImage(
      categoryToEdit: categoryToEdit,
    );

    if (isEditing) {
      await CategoryDB.editCategory(
        categoryToEdit!.id, 
        controller.nameController.text.trim(),
        controller.descriptionController.text.trim(),
        finalImagePath, 
      );
      _showSuccessSnackBar(context, 'Category updated successfully!');
    } else {
      final newCategory = CategoryModel(
        id: const Uuid().v4(),
        name: controller.nameController.text.trim(),
        imagePath: finalImagePath,
        discription: controller.descriptionController.text.trim(),
        userId: userId,
      );
      await CategoryDB.addCategory(newCategory);
      _showSuccessSnackBar(context, 'Category added successfully!');
    }

    Navigator.pop(context);
  } catch (e) {
    _showErrorSnackBar(context, 'Failed to save category. Please try again.');
    debugPrint('Error saving category: $e');
  }
}

void _showSuccessSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

void _showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
    ),
  );
}