import 'dart:convert';
import 'dart:io';
import 'package:cream_ventory/database/functions/user_db.dart';
import 'package:cream_ventory/widgets/snack_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class EditProfileLogic {
  File? profileImage;
  Uint8List? imageBytes; 
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
        if (kIsWeb) { 
          // Web: Assume profileImagePath is base64 or a URL
          try {
            imageBytes = base64Decode(user.profileImagePath!);
          } catch (e) {
            debugPrint('Error decoding base64 image: $e');
          }  
        } else {   
          // Native: Load as File
          profileImage = File(user.profileImagePath!);
        }   
      }
        } catch (e) {
      debugPrint('Error initializing profile: $e');
    }
  }                    

 // Pick image for both web and native
  Future<void> pickImage(BuildContext context) async {
    try {
      XFile? pickedFile;
      if (kIsWeb) {
        // Web: Use file_picker for reliability
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );
        if (result != null && result.files.single.bytes != null) {
          imageBytes = result.files.single.bytes;  
          profileImage = null; // Clear File for web
          pickedFile = XFile.fromData(imageBytes!);
        }
      } else {
        // Native: Use image_picker
        pickedFile = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );
        if (pickedFile != null) {
          profileImage = File(pickedFile.path);
          imageBytes = null; // Clear bytes for native
        }
      }

      if (pickedFile != null) {
        if (!kIsWeb) {
          // Native: Save image permanently
          final permanentPath = await _saveImagePermanently(File(pickedFile.path));
          profileImage = File(permanentPath);
        }
        // Web: imageBytes already set
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to pick image: $e"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('Image picker error: $e');
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
      String? imagePath;

      if (kIsWeb && imageBytes != null) {
        // Web: Store image as base64
        imagePath = base64Encode(imageBytes!);
      } else if (profileImage != null) {
        // Native: Store file path
        imagePath = profileImage!.path;
      }

      // Update user profile using UserDB
      final success = await UserDB.updateProfile(
        userId: user.id,
        name: nameController.text.trim(),
        distributionName: distributionController.text.trim(),    
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        profileImagePath: imagePath,
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