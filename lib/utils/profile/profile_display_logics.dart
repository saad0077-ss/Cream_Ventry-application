import 'package:cream_ventory/db/functions/user_db.dart';
import 'package:cream_ventory/screen/auth/sign_in_screen.dart';
import 'package:cream_ventory/user_profile/screen/user_password_change.dart';
import 'package:cream_ventory/user_profile/screen/user_profile_edit_page.dart';
import 'package:cream_ventory/widgets/snack_bar.dart';
import 'package:flutter/material.dart';

class ProfileDisplayLogic {
  final BuildContext context;

  ProfileDisplayLogic(this.context);

  // Navigate back to previous screen
  void navigateBack() {                 
    Navigator.of(context).pop();
  }

  // Navigate to Change Password screen
  void navigateToChangePassword() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ChangePassword(),
      ),
    );
  }

  // Navigate to Edit Profile screen
  void navigateToEditProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EditProfilePage(),
      ),
    );
  }

  // Logout user and navigate to SignIn screen
  Future<void> logout() async {
    try {
      await UserDB.logoutUser();
      
      CustomSnackbar.show(
        context: context,
        message: 'Logged out successfully!',
        backgroundColor: Colors.green,
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const ScreenSignIn(),
        ),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      CustomSnackbar.show(
        context: context,
        message: 'Error logging out. Please try again.',
        backgroundColor: Colors.red,
      );
      print('Logout error: $e');
    }
  }
}