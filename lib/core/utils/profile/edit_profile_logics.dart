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
  VoidCallback? onImageLoaded;

  // Controllers – now email and username are editable
  final TextEditingController usernameController = TextEditingController(); // NEW
  final TextEditingController emailController = TextEditingController();    // Editable
  final TextEditingController distributionController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // Initialize profile data for the current user
  Future<void> initializeProfile({VoidCallback? onUpdate}) async {
    onImageLoaded = onUpdate;
    try {
      final user = await UserDB.getCurrentUser();

      // Name (fallback to username if name is null)
      usernameController.text = user.name ?? user.username;


      // Email is now editable
      emailController.text = user.email;

      distributionController.text = user.distributionName ?? '';
      phoneController.text = user.phone ?? '';
      addressController.text = user.address ?? '';

      // Load existing profile image
      if (user.profileImagePath != null && user.profileImagePath!.isNotEmpty) {
        if (kIsWeb) {
          try {
            imageBytes = base64Decode(user.profileImagePath!);
          } catch (e) {
            debugPrint('Error decoding base64 image: $e');
          }
        } else {
          profileImage = File(user.profileImagePath!);
        }
      }

      onImageLoaded?.call();
    } catch (e) {
      debugPrint('Error initializing profile: $e');
    }
  }

  // Pick image for both web and native
  Future<void> pickImage(BuildContext context) async {
    try {
      XFile? pickedFile;
      if (kIsWeb) { 
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );
        if (result != null && result.files.single.bytes != null) {
          imageBytes = result.files.single.bytes;
          profileImage = null;
          pickedFile = XFile.fromData(imageBytes!);
        }
      } else {
        pickedFile = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );
        if (pickedFile != null) {
          profileImage = File(pickedFile.path);
          imageBytes = null;
          onImageLoaded?.call();
        }
      }

      if (pickedFile != null && !kIsWeb) {
        final permanentPath = await _saveImagePermanently(File(pickedFile.path));
        profileImage = File(permanentPath);
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

  // Save profile changes – now includes email & username
  Future<bool> saveProfile(BuildContext context) async {
  try {
    final user = await UserDB.getCurrentUser();

    // Get and validate inputs
    final newUsername = usernameController.text.trim();
    final newEmail = emailController.text.trim().toLowerCase();

    // === VALIDATION ===
    if (newUsername.isEmpty) {
      CustomSnackbar.show(
        context: context,
        message: 'Username cannot be empty',
        backgroundColor: Colors.red,
      );
      return false;
    }

    if (newUsername.length < 3) {
      CustomSnackbar.show(
        context: context,
        message: 'Username must be at least 3 characters',
        backgroundColor: Colors.red,
      );
      return false;
    }

    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(newUsername)) {
      CustomSnackbar.show(
        context: context,
        message: 'Username can only contain lowercase letters, numbers, and _',
        backgroundColor: Colors.red,
      );
      return false;
    }

    if (!RegExp(r'^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$').hasMatch(newEmail)) {
      CustomSnackbar.show(
        context: context,
        message: 'Please enter a valid email',
        backgroundColor: Colors.red,
      );
      return false;
    }
    // === END VALIDATION ===

    String? imagePath;
    if (kIsWeb && imageBytes != null) {
      imagePath = base64Encode(imageBytes!);
    } else if (profileImage != null) {
      imagePath = profileImage!.path;
    }

    // === PASS NEW VALUES ===
    final success = await UserDB.updateProfile(
      userId: user.id,
      name: newUsername.isEmpty ? null : newUsername,
      username: newUsername,           // ← This is now guaranteed non-empty
      email: newEmail,                 // ← Lowercased
      distributionName: distributionController.text.trim().isEmpty ? null : distributionController.text.trim(),
      phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
      address: addressController.text.trim().isEmpty ? null : addressController.text.trim(),
      profileImagePath: imagePath,
    );

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
        message: 'Username or email already in use',
        backgroundColor: Colors.red,
      );
      return false;
    }
  } catch (e) {
    debugPrint('Error saving profile: $e');
    CustomSnackbar.show(
      context: context,
      message: 'Failed to update profile: $e',
      backgroundColor: Colors.red,
    );
    return false;
  }
}

  // Dispose controllers
  void dispose() {
    usernameController.dispose();   
    emailController.dispose();
    distributionController.dispose();
    phoneController.dispose();
    addressController.dispose();
  }
}