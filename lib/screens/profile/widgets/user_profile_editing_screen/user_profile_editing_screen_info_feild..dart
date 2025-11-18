import 'package:cream_ventory/screens/profile/widgets/user_profile_editing_screen/user_profile_editing_screen_info_dialog.dart' show showInfoDialog;
import 'package:cream_ventory/widgets/text_field.dart';
import 'package:flutter/material.dart';

class InfoField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final String infoTitle;
  final String infoMessage;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;

  const InfoField({
    super.key,
    required this.labelText,
    required this.controller,
    required this.infoTitle,
    required this.infoMessage,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              labelText,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => showInfoDialog(context, infoTitle, infoMessage),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.info_outline, size: 18, color: Colors.black),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        CustomTextField(
          labelText: '',
          controller: controller,
          fillColor: Colors.white.withOpacity(0.15),
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
        ),
      ],
    );
  }
}