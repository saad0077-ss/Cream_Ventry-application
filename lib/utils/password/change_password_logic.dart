import 'package:cream_ventory/db/functions/user_db.dart';
import 'package:cream_ventory/widgets/snack_bar.dart';
import 'package:flutter/material.dart';

class ChangePasswordLogic {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  bool get isNewPasswordVisible => _isNewPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;

  void toggleNewPasswordVisibility() {
    _isNewPasswordVisible = !_isNewPasswordVisible;
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
  }

  String? validateNewPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'New password is required';
    }
    if (value.trim().length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateConfirmPassword(String? value, String newPassword) {
    if (value == null || value.trim().isEmpty) {
      return 'Confirm password is required';
    }
    if (value.trim() != newPassword.trim()) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<bool> changePassword(BuildContext context) async {
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // Validate passwords
    final newPasswordError = validateNewPassword(newPassword);
    final confirmPasswordError = validateConfirmPassword(confirmPassword, newPassword);

    if (newPasswordError != null || confirmPasswordError != null) {
      CustomSnackbar.show(
        context: context,
        message: newPasswordError ?? confirmPasswordError!,
        backgroundColor: Colors.red,
      );
      return false;
    }  

    try {
      // Get the current user
      final user = await UserDB.getCurrentUser();

      // Update password using UserDB
      final success = await UserDB.updatePassword(
        userId: user.id,
        newPassword: newPassword,
      );

      if (success) {
        CustomSnackbar.show(
          context: context,
          message: 'Password updated successfully!',
          backgroundColor: Colors.green,
        );
        return true;
      } else {
        CustomSnackbar.show(
          context: context,
          message: 'Failed to update password. Please try again.',
          backgroundColor: Colors.red,
        );
        return false;
      }
    } catch (e) {
      CustomSnackbar.show(
        context: context,
        message: 'An error occurred while updating password.',
        backgroundColor: Colors.red,
      );
      print('Change password error: $e');
      return false;
    }
  }

  void showConfirmDialog(BuildContext context, {required VoidCallback onConfirm}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Password Change'),
          content: const Text('Are you sure you want to change your password?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                onConfirm(); // Proceed with password change
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  // Dispose controllers to prevent memory leaks
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
  }
}