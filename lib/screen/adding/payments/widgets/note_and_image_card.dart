import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NoteAndImageCard extends StatelessWidget {
  final TextEditingController noteController;
  final String? imagePath; // Changed to String? for path
  final Uint8List? imageBytes; // Added for web image bytes
  final VoidCallback onImageTap;

  const NoteAndImageCard({
    super.key,
    required this.noteController,
    required this.imagePath,
    required this.imageBytes,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine image provider
    ImageProvider? imageProvider;
    if (imagePath != null && imagePath!.isNotEmpty) {
      if (kIsWeb) {
        try {
          // Web: Use base64 image
          final bytes = imageBytes ?? base64Decode(imagePath!);
          imageProvider = MemoryImage(bytes);
        } catch (e) {
          debugPrint('Error decoding base64 image: $e');
          imageProvider = null;
        }
      } else {
        // Native: Use file path
        imageProvider = FileImage(File(imagePath!));
      }
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white.withOpacity(0.95),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: 'Add Note',
                  labelStyle: const TextStyle(color: Colors.black54),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                ),
                maxLines: 3,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26, width: 1.5),
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: onImageTap,
                  child: imageProvider == null
                      ? const Center(
                          child: Icon(
                            Icons.image,
                            color: Colors.black54,
                            size: 32,
                          ),
                        )
                      : Image(
                          image: imageProvider,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.red,
                              size: 32,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}