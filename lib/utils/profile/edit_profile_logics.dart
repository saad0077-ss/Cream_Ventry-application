import 'dart:io';
import 'package:cream_ventory/db/functions/user_db.dart';
import 'package:cream_ventory/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class EditProfileLogic {
  File? profileImage;
  final picker = ImagePicker();
    final _uuid = Uuid();
    


  final TextEditingController nameController = TextEditingController();
  final TextEditingController distributionController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // Initialize profile data for the current user
  Future<void> initializeProfile() async {
    try {
      final user = await UserDB.getCurrentUser();
      emailController.text = user.email;
      nameController.text = user.name ?? user.username;
      distributionController.text = user.distributionName ?? '';
      phoneController.text = user.phone ?? '';
      addressController.text = user.address ?? '';
      if (user.profileImagePath != null && user.profileImagePath!.isNotEmpty) {
        profileImage = File(user.profileImagePath!);
      }
        } catch (e) {
      debugPrint('Error initializing profile: $e');
    }
  }                    

 Future<void> pickImage(BuildContext context) async {
  try {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final permanentPath = await _saveImagePermanently(File(image.path));
      profileImage = File(permanentPath); // Update profileImage directly
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Failed to pick image: $e"),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
      ),
    );
  }
}

  Future<String> _saveImagePermanently(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${_uuid.v4()}.jpg';
    final permanentPath = '${directory.path}/$fileName';
    final savedImage = await image.copy(permanentPath);
    return savedImage.path;
  }
  // Save profile changes
  Future<bool> saveProfile(BuildContext context) async {
    try {
      final user = await UserDB.getCurrentUser();

      // Update user profile using UserDB
      final success = await UserDB.updateProfile(
        userId: user.id,
        name: nameController.text.trim(),
        distributionName: distributionController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        profileImagePath: profileImage?.path,
      );

      debugPrint(user.profileImagePath); 

      if (success) {
        CustomSnackbar.show(
          context: context,
          message: 'Profile updated successfully!',
          backgroundColor: Colors.green,
        );
        return true;
      } else {
        CustomSnackbar.show(
          context: context,
          message: 'Failed to update profile. Please try again.',
          backgroundColor: Colors.red,
        );
        return false;
      }
    } catch (e) {
      CustomSnackbar.show(
        context: context,
        message: 'An error occurred while saving profile.',
        backgroundColor: Colors.red,
      );
      print('Error saving profile: $e');
      return false;
    }
  }

  // Dispose controllers to prevent memory leaks
  void dispose() {
    nameController.dispose();
    distributionController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
  }
}