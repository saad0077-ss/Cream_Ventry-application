import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cream_ventory/models/category_model.dart';
import 'package:uuid/uuid.dart';

class CategoryAddController {
  String? nameError;
  String? descriptionError;
  String? imageError;
  bool isPickingImage = false;
  final bool _isEditing;

  final TextEditingController nameController;
  final TextEditingController descriptionController;
  
  // For mobile platforms
  File? selectedImage;
  
  // For web platform
  String? selectedImagePath; // Can be file path (mobile) or base64 (web)
  Uint8List? selectedImageBytes; // For web preview

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
    // Initialize image data in constructor body
    if (isEditing && categoryToEdit != null) {
      selectedImagePath = categoryToEdit.imagePath;
      
      // Only set selectedImage for mobile platforms with file paths
      if (!kIsWeb && !categoryToEdit.isAsset) {
        try {
          selectedImage = File(categoryToEdit.imagePath);
        } catch (e) {
          debugPrint('Error initializing image file: $e');
        }
      }
    }
  }

  bool get isEditing => _isEditing;
  
  bool get isFormValid => nameError == null &&
      descriptionError == null &&
      imageError == null;

  // Check if image is selected (works for both web and mobile)
  bool get hasImage {
    if (kIsWeb) {
      return selectedImagePath != null && selectedImagePath!.isNotEmpty;
    } else {
      return selectedImage != null || 
             (selectedImagePath != null && selectedImagePath!.isNotEmpty);
    }
  }

  void validateFields() {
    nameError = nameController.text.trim().isEmpty
        ? "Category name is required."
        : null;
    descriptionError = descriptionController.text.trim().isEmpty
        ? "Category description is required."
        : null;
    imageError = !hasImage ? "Please select an image." : null;
  }

  Future<String> processImage({required CategoryModel? categoryToEdit}) async {
    // If editing and image hasn't changed, return existing path
    if (isEditing && 
        categoryToEdit != null && 
        selectedImagePath == categoryToEdit.imagePath) {
      return selectedImagePath!;
    } 

    // For web platform
    if (kIsWeb) {
      // Return the base64 string directly (already has data:image prefix)
      if (selectedImagePath != null && selectedImagePath!.startsWith('data:image')) {
        return selectedImagePath!;
      }
      throw Exception('Invalid image path for web platform');
    }

    // For mobile platform - save to permanent location
    if (selectedImage != null) {
      final dir = await getApplicationDocumentsDirectory();
      final imagePath = '${dir.path}/images/${const Uuid().v4()}.jpg';
      
      // Ensure directory exists
      await Directory('${dir.path}/images').create(recursive: true);
      
      // Copy image to permanent location
      await selectedImage!.copy(imagePath);
      return imagePath;
    }

    // If we have a path but no File object (shouldn't happen in normal flow)
    if (selectedImagePath != null) {
      return selectedImagePath!;
    }

    throw Exception('No image selected');
  }

  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
  }
}