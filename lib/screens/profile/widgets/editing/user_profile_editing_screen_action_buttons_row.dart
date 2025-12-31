import 'package:cream_ventory/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class ActionButtonsRow extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const ActionButtonsRow({
    super.key,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomActionButton(
              height: 53,
              label: 'Cancel',
              backgroundColor: const Color.fromARGB(255, 80, 82, 84),
              onPressed: onCancel,
              fontSize: 19,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomActionButton(
              height: 53,
              label: 'Save Changes',
              backgroundColor: const Color.fromARGB(255, 85, 172, 213),
              onPressed: onSave,
              fontSize: 19,
            ),
          ),
        ],
      ),
    );
  }
}
