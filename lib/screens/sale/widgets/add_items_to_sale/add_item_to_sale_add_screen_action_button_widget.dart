import 'package:cream_ventory/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class AddItemActionButtonsWidget {
  /// Builds the action buttons using CustomActionButton
  static Widget buildActionButtons({
    required bool isEditMode,
    required VoidCallback onSaveAndNew,
    required VoidCallback onSave,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          // Save & New Button
          Expanded(
            child: CustomActionButton(
              label: 'Save & New',
              backgroundColor: const Color.fromARGB(255, 80, 82, 84),
              onPressed: onSaveAndNew,
            ),
          ),
          const SizedBox(width: 8),

          // Save / Update Button
          Expanded(
            child: CustomActionButton(
              label: isEditMode ? 'Update' : 'Save',
              backgroundColor: const Color.fromARGB(255, 85, 172, 213), 

              onPressed: onSave,
            ),
          ),
        ],
      ),
    );
  }
}
 