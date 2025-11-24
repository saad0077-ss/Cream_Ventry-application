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

// Import top_snackbar_flutter
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

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
      // Web: Use file_picker
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result != null && result.files.single.bytes != null) {
        imageBytes = result.files.single.bytes!;
        imagePath = 'data:image/png;base64,${base64Encode(imageBytes)}';

        controller.selectedImagePath = imagePath;
        controller.selectedImageBytes = imageBytes;
        controller.imageError = null;

        _showSuccess(context, "Image selected successfully!");
      }
    } else {
      // Mobile: Use image_picker
      final XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        final permanentPath = await _saveImagePermanently(File(pickedFile.path));
        imagePath = permanentPath;

        controller.selectedImage = File(permanentPath);
        controller.selectedImagePath = imagePath;
        controller.imageError = null;

        _showSuccess(context, "Image attached!");
      }
    }

    // User canceled → show subtle info
    if (imagePath == null) {
      _showInfo(context, "No image selected");
    }
  } catch (e) {
    debugPrint('Error picking image: $e');
    controller.imageError = 'Failed to pick image';
    _showError(context, "Failed to pick image");
  } finally {
    controller.isPickingImage = false;
  }
}

Future<String> _saveImagePermanently(File image) async {
  final directory = await getApplicationDocumentsDirectory();
  final fileName = '${const Uuid().v4()}.jpg';
  final imagesDir = '${directory.path}/category_images';
  await Directory(imagesDir).create(recursive: true);
  final permanentPath = '$imagesDir/$fileName';
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

  if (!controller.isFormValid) {
    _showError(context, "Please fix the errors above");
    return;
  }

  final user = await UserDB.getCurrentUser();
  final userId = user.id;

  try {
    final finalImagePath = await controller.processImage(categoryToEdit: categoryToEdit);

    if (isEditing) {
      await CategoryDB.editCategory(
        categoryToEdit!.id,
        controller.nameController.text.trim(),
        controller.descriptionController.text.trim(),
        finalImagePath,
      );
      _showSuccess(context, "Category updated successfully!");
    } else {
      final newCategory = CategoryModel(
        id: const Uuid().v4(),
        name: controller.nameController.text.trim(),
        imagePath: finalImagePath,
        discription: controller.descriptionController.text.trim(),
        userId: userId,
      );
      await CategoryDB.addCategory(newCategory);
      _showSuccess(context, "Category added successfully!");
    }

    if (context.mounted) {
      Navigator.pop(context);
    }
  } catch (e) {
    debugPrint('Error saving category: $e');
    _showError(context, "Failed to save category. Please try again.");
  }
}

// Reusable Top Snackbar Helpers
void _showSuccess(BuildContext context, String message) {
  if (!context.mounted) return;
  showTopSnackBar(
    Overlay.of(context),
    CustomSnackBar.success(
      message: message,
      icon: const Icon(Icons.check_circle, color: Colors.white, size: 40),
      backgroundColor: Colors.green.shade600,
    ),
  );
}

void _showError(BuildContext context, String message) {
  if (!context.mounted) return;
  showTopSnackBar(
    Overlay.of(context),
    CustomSnackBar.error(
      message: message,
      icon: const Icon(Icons.error_outline, color: Colors.white, size: 40),
      backgroundColor: Colors.red.shade600,
    ),
  );
}

void _showInfo(BuildContext context, String message) {
  if (!context.mounted) return;
  showTopSnackBar(
    Overlay.of(context),
    CustomSnackBar.info( 
      message: message,
      backgroundColor: Colors.orange.shade700,
      icon: const Icon(Icons.info_outline, color: Colors.white, size: 40),
    ),
  );
}    