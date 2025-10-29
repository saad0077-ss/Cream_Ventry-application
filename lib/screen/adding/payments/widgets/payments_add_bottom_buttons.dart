import 'package:cream_ventory/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class BottomButtons extends StatelessWidget {
  final bool isEditMode;
  final VoidCallback onSave;
  final VoidCallback onSaveAndNewOrDelete;

  const BottomButtons({
    super.key,
    required this.isEditMode,
    required this.onSave,
    required this.onSaveAndNewOrDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        children: [
          Expanded(
            child: CustomActionButton(
              label: isEditMode ? 'DELETE' : 'SAVE & NEW',
              backgroundColor: Colors.red.shade400,
              onPressed: onSaveAndNewOrDelete,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomActionButton(
              label: isEditMode ? 'UPDATE' : 'SAVE',
              backgroundColor: Colors.black87,
              onPressed: onSave,
            ),
          ),
        ],
      ),
    );
  }
}