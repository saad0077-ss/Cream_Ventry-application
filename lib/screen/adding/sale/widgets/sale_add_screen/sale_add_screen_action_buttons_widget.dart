// sale_action_buttons_widget.dart
import 'package:cream_ventory/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class SaleActionButtonsWidget {
  /// Builds the action buttons (DELETE/UPDATE or SAVE & NEW/SAVE)
  static Widget buildActionButtons({
    required bool isEditMode,
    required bool isEditable,
    required VoidCallback? onDelete,
    required VoidCallback? onUpdate,
    required VoidCallback? onSaveAndNew,
    required VoidCallback? onSave,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: isEditMode
            ? [
                CustomActionButton(
                  label: 'DELETE',
                  backgroundColor: Colors.red,
                  onPressed: onDelete,
                ),
                CustomActionButton(
                  label: 'UPDATE',
                  backgroundColor: Colors.black,
                  onPressed:isEditable ? onUpdate : null,   
                ),   
              ]
            : [
                CustomActionButton(
                  label: 'SAVE & NEW',
                  backgroundColor: Colors.black,
                  onPressed: onSaveAndNew,
                ),
                CustomActionButton(
                  label: 'SAVE',
                  backgroundColor: Colors.red,  
                  onPressed: onSave,
                ),
              ],
      ),
    );
  }
}