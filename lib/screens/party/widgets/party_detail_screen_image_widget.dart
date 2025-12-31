import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'dart:convert';
import 'package:cream_ventory/models/party_model.dart';

class PartyImageWidget extends StatelessWidget {
  final PartyModel party;

  const PartyImageWidget({super.key, required this.party});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(11),
      child: _buildImage(),
    );
  }

  Widget _buildImage() {
    // If no image path, show default icon
    if (party.imagePath.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: Center(
          child: Icon(
            Icons.person,
            size: 28,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    // 1. Web: Base64 Image
    if (kIsWeb && party.imagePath.startsWith('data:image')) {
      try {
        final base64Data = party.imagePath.split(',').last;
        final bytes = base64Decode(base64Data);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        );
      } catch (_) {
        return _buildErrorWidget();
      }
    }

    // 2. Mobile: File Path
    if (!kIsWeb) {
      try {
        final file = File(party.imagePath);
        if (file.existsSync()) {
          return Image.file(
            file,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
          );
        } else {
          return _buildErrorWidget();
        }
      } catch (_) {
        return _buildErrorWidget();
      }
    }

    // 3. Fallback
    return _buildErrorWidget();
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.person,
          size: 28,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}