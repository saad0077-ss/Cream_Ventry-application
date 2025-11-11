import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:io' show File;

class PartyImageHandler {
  final ImagePicker _picker = ImagePicker();
  final _uuid = const Uuid();

  // Returns Map with 'bytes' (Uint8List?) and 'path' (String, empty on web)
  Future<Map<String, dynamic>?> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image == null) return null;

      if (kIsWeb) {
        final Uint8List bytes = await image.readAsBytes();
        return {'bytes': bytes, 'path': ''};
      } else {
        final File file = File(image.path);
        final File permanentFile = await _saveImagePermanently(file);
        return {'bytes': null, 'path': permanentFile.path};
      }
    } catch (e) {
      print('Image pick error: $e');
      return null;
    }
  }

  Future<File> _saveImagePermanently(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${_uuid.v4()}.jpg';
    final permanentPath = '${directory.path}/$fileName';
    return await image.copy(permanentPath);
  }
}