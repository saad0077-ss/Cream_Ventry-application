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
                Expanded(
                  child: CustomActionButton(
                    label: 'DELETE',
                    backgroundColor: Colors.red,
                    onPressed: onDelete,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                ),
                SizedBox(width: 8),

                Expanded(
                  child: CustomActionButton(
                    label: 'UPDATE',
                    backgroundColor: const Color.fromARGB(255, 85, 172, 213),
                    onPressed: isEditable ? onUpdate : null,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ), 
                ),
              ]
            : [
                Expanded(
                  child: CustomActionButton(
                    label: 'SAVE & NEW',
                    backgroundColor: const Color.fromARGB(255, 80, 82, 84),
                    onPressed: onSaveAndNew,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: CustomActionButton(
                    label: 'SAVE',
                    backgroundColor: const Color.fromARGB(255, 85, 172, 213),
                    onPressed: onSave,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                ),
              ],
      ),
    );
  }
}
