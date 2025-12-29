// sale_action_buttons_widget.dart
import 'package:cream_ventory/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SaleActionButtonsWidget {
  /// Builds the action buttons (DELETE/UPDATE or SAVE & NEW/SAVE)
  static Widget buildActionButtons({
    required bool isEditMode,
    required bool isEditable,
    required VoidCallback? onDelete, 
    required VoidCallback? onUpdate,
    required VoidCallback? onSaveAndNew,
    required VoidCallback? onSave,
    required bool isSmallScreen,
    required bool isMediumScreen,
  }) {
    final bool shouldExpand = isSmallScreen || isMediumScreen;
    
    return Padding(
      padding: EdgeInsets.only(top: 16.0.h, bottom: 16.0.h, left: 16.0.w, right: 16.0.w),
      child: Row(
        mainAxisAlignment:shouldExpand? MainAxisAlignment.spaceAround: MainAxisAlignment.center, 
        children: isEditMode
            ? [
                if (shouldExpand)
                  Expanded(    
                    child: CustomActionButton( 
                      label: 'DELETE',
                      backgroundColor: Colors.red,
                      onPressed: onDelete,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    ),
                  )
                else
                  CustomActionButton( 
                    height: 48,
                    width: 500,
                    label: 'DELETE',
                    backgroundColor: Colors.red,
                    onPressed: onDelete,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                SizedBox(width: 8.h),
                if (shouldExpand)
                  Expanded(
                    child: CustomActionButton(
                      label: 'UPDATE',
                      backgroundColor: const Color.fromARGB(255, 85, 172, 213),
                      onPressed: isEditable ? onUpdate : null,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    ), 
                  )
                else
                  CustomActionButton(
                    height: 48,
                    width: 500,
                    label: 'UPDATE',
                    backgroundColor: const Color.fromARGB(255, 85, 172, 213),
                    onPressed: isEditable ? onUpdate : null,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
              ]
            : [
                if (shouldExpand)
                  Expanded(
                    child: CustomActionButton(
                      label: 'SAVE & NEW',
                      backgroundColor: const Color.fromARGB(255, 80, 82, 84),
                      onPressed: onSaveAndNew,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    ),
                  )
                else
                  CustomActionButton(
                    height: 48,
                    width: 500,
                    label: 'SAVE & NEW',
                    backgroundColor: const Color.fromARGB(255, 80, 82, 84),
                    onPressed: onSaveAndNew,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                SizedBox(width: 8.h),
                if (shouldExpand)
                  Expanded(
                    child: CustomActionButton(
                      label: 'SAVE',
                      backgroundColor: const Color.fromARGB(255, 85, 172, 213),
                      onPressed: onSave,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    ),
                  )
                else
                  CustomActionButton(
                    height: 48,
                    width: 500,
                    label: 'SAVE',
                    backgroundColor: const Color.fromARGB(255, 85, 172, 213),
                    onPressed: onSave,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
              ],
      ),
    );
  }
}