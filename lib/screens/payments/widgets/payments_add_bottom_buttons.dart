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
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 1123;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: isSmallScreen ? MainAxisAlignment.spaceAround : MainAxisAlignment.center,
        children: isEditMode
            ? [
                if (isSmallScreen)
                  Expanded(
                    child: CustomActionButton(
                      label: 'Delete',
                      backgroundColor: Colors.red,
                      onPressed: onSaveAndNewOrDelete,
                    ),
                  )
                else
                  CustomActionButton(
                    height: 48,
                    width: 500,
                    label: 'Delete',
                    backgroundColor: Colors.red,
                    onPressed: onSaveAndNewOrDelete,
                  ),
                SizedBox(width: 8),
                if (isSmallScreen)
                  Expanded(
                    child: CustomActionButton(
                      label: 'Update',
                      backgroundColor: Color.fromARGB(255, 85, 172, 213),
                      onPressed: onSave,
                    ),
                  )
                else
                  CustomActionButton(
                    height: 48,
                    width: 500,
                    label: 'Update',
                    backgroundColor: Color.fromARGB(255, 85, 172, 213),
                    onPressed: onSave,
                  ),
              ]
            : [
                if (isSmallScreen)
                  Expanded(
                    child: CustomActionButton(
                      label: 'Save & New',
                      backgroundColor: const Color.fromARGB(255, 80, 82, 84),
                      onPressed: onSaveAndNewOrDelete,
                    ),
                  )
                else
                  CustomActionButton(
                    height: 48, 
                    width: 500,
                    label: 'Save & New',
                    backgroundColor: const Color.fromARGB(255, 80, 82, 84),
                    onPressed: onSaveAndNewOrDelete,
                  ),
                SizedBox(width: 8),
                if (isSmallScreen)
                  Expanded(
                    child: CustomActionButton(
                      label: 'Save',
                      backgroundColor: Color.fromARGB(255, 85, 172, 213),
                      onPressed: onSave,
                    ),
                  )
                else
                  CustomActionButton(
                    height: 48,
                    width: 500,
                    label: 'Save',
                    backgroundColor: Color.fromARGB(255, 85, 172, 213),
                    onPressed: onSave,
                  ),
              ],
      ),
    );
  }
} 