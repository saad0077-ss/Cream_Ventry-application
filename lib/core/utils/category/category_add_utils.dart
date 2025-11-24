import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:cream_ventory/database/functions/user_db.dart';
import 'package:cream_ventory/screens/controller/category_add_controller.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cream_ventory/database/functions/category_db.dart';
import 'package:cream_ventory/models/category_model.dart';
import 'package:uuid/uuid.dart';

Future<void> pickCategoryImage(
  CategoryAddController controller,
  BuildContext context,
) async {
  if (controller.isPickingImage) return;
  
  controller.isPickingImage = true;
  try {
    String? imagePath;
    Uint8List? imageBytes;

    if (kIsWeb) {
      // Web: Use file_picker for reliability
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result != null && result.files.single.bytes != null) {
        imageBytes = result.files.single.bytes!;
        // Store as base64 string with data URI prefix for web
        imagePath = 'data:image/png;base64,${base64Encode(imageBytes)}';
        
        // Update controller with the picked image
        controller.selectedImagePath = imagePath;
        controller.selectedImageBytes = imageBytes;
        controller.imageError = null;
      }
    } else {
      // Native: Use image_picker
      final XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        final permanentPath = await _saveImagePermanently(File(pickedFile.path));
        imagePath = permanentPath;
        
        // Update controller with the picked image
        controller.selectedImage = File(permanentPath);
        controller.selectedImagePath = imagePath;
        controller.imageError = null;
      }
    }

    if (imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No image selected'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    debugPrint('Error picking image: $e');
    controller.imageError = 'Failed to pick image';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to pick image: $e'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    controller.isPickingImage = false;
  }
}

Future<String> _saveImagePermanently(File image) async {
  final directory = await getApplicationDocumentsDirectory();
  final fileName = '${const Uuid().v4()}.jpg';
  final permanentPath = '${directory.path}/images/$fileName';
  await Directory('${directory.path}/images').create(recursive: true);
  final savedImage = await image.copy(permanentPath);
  return savedImage.path;
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