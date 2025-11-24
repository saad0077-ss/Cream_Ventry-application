import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

// Import top_snackbar_flutter
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

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
        // Web: Use file_picker
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );

        if (result != null && result.files.single.bytes != null) {
          imageBytes = result.files.single.bytes!;
          imagePath = base64Encode(imageBytes);
          setImageBytesCallback(imageBytes);
          setImagePathCallback(imagePath);

          // Success feedback on web
          showTopSnackBar(
            Overlay.of(context),
            const CustomSnackBar.success(
              message: "Image selected successfully!",
              icon: Icon(Icons.image, color: Colors.white, size: 40),
            ),
          );
        } else {
          // User canceled or no image
          showTopSnackBar(
            Overlay.of(context),
            const CustomSnackBar.info(
              message: "No image selected",
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        // Mobile: Use image_picker
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
          setImageBytesCallback(null);

          // Success feedback on mobile
          showTopSnackBar(
            Overlay.of(context),
            const CustomSnackBar.success(
              message: "Image updated!",
              icon: Icon(Icons.check_circle, color: Colors.white, size: 40),
            ),
          );
        } else {
          // User canceled
          showTopSnackBar(
            Overlay.of(context),
            const CustomSnackBar.info(
              message: "Image selection canceled",
              backgroundColor: Colors.grey,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: "Failed to pick image: ${e.toString()}",
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  // Save image permanently on device
  static Future<String> _saveImagePermanently(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${_uuid.v4()}.jpg';
    final imagesDir = Directory('${directory.path}/images');
     
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    
    final permanentPath = '${imagesDir.path}/$fileName';
    final savedImage = await image.copy(permanentPath);
    return savedImage.path;
  }
}