import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageUtils {
  static final ImagePicker _picker = ImagePicker();
  static final Uuid _uuid = Uuid();

  static Future<void> pickAndSaveImage({
    required BuildContext context,
    required void Function(String?) setImagePathCallback,
    required void Function(Uint8List?) setImageBytesCallback,
  }) async {
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
          imagePath = base64Encode(imageBytes); // Store as base64 string
          setImageBytesCallback(imageBytes);
          setImagePathCallback(imagePath);
        }
      } else {
        // Native: Use image_picker
        final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 80,
        );
        if (pickedFile != null) {
          final permanentPath = await _saveImagePermanently(File(pickedFile.path));
          imagePath = permanentPath;
          setImagePathCallback(imagePath);
          setImageBytesCallback(null); // Clear bytes for native
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static Future<String> _saveImagePermanently(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${_uuid.v4()}.jpg';
    final permanentPath = '${directory.path}/images/$fileName';
    await Directory('${directory.path}/images').create(recursive: true);
    final savedImage = await image.copy(permanentPath);
    return savedImage.path;
  }
}