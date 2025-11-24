import 'dart:convert';
import 'dart:io';
import 'package:cream_ventory/database/functions/user_db.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

// Import top_snackbar_flutter
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class EditProfileLogic {
  File? profileImage;
  Uint8List? imageBytes;
  final picker = ImagePicker();
  final _uuid = Uuid();
  VoidCallback? onImageLoaded;

  // Controllers – email & username now editable
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController distributionController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // Initialize profile data
  Future<void> initializeProfile({VoidCallback? onUpdate}) async {
    onImageLoaded = onUpdate;
    try {
      final user = await UserDB.getCurrentUser();

      usernameController.text = user.name ?? user.username;
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

  // Pick image (Web + Mobile)
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

      // Optional: Show small success feedback
      if (pickedFile != null) {
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.info(
            message: "Profile picture updated!",
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: "Failed to pick image: ${e.toString()}",
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

  // Save profile changes (with full validation)
  Future<bool> saveProfile(BuildContext context) async {
    try {
      final user = await UserDB.getCurrentUser();

      final newUsername = usernameController.text.trim();
      final newEmail = emailController.text.trim().toLowerCase();

      // === VALIDATION ===
      if (newUsername.isEmpty) {
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.error(message: "Username cannot be empty"),
        );
        return false;
      }

      if (newUsername.length < 3) {
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.error(message: "Username must be at least 3 characters"),
        );
        return false;
      }

      if (!RegExp(r'^[a-z0-9_]+$').hasMatch(newUsername)) {
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.error(
            message: "Username can only contain lowercase letters, numbers, and _",
          ),
        );
        return false;
      }

      if (!RegExp(r'^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$').hasMatch(newEmail)) {
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.error(message: "Please enter a valid email"),
        );
        return false;
      }

      // === IMAGE PATH ===
      String? imagePath;
      if (kIsWeb && imageBytes != null) {
        imagePath = base64Encode(imageBytes!);
      } else if (profileImage != null) {
        imagePath = profileImage!.path;
      }

      // === UPDATE PROFILE ===
      final success = await UserDB.updateProfile(
        userId: user.id,
        name: newUsername.isEmpty ? null : newUsername,
        username: newUsername,
        email: newEmail,
        distributionName: distributionController.text.trim().isEmpty
            ? null
            : distributionController.text.trim(),
        phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
        address: addressController.text.trim().isEmpty ? null : addressController.text.trim(),
        profileImagePath: imagePath,
      );

      if (success) {
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.success(
            message: "Profile updated successfully!",
            icon: Icon(Icons.check_circle, color: Colors.white, size: 40),
          ),
        );
        return true;
      } else {
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.error(
            message: "Username or email already in use",
          ),
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: "Failed to update profile: ${e.toString()}",
        ),
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