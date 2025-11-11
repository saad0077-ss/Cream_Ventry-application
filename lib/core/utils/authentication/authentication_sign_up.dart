import 'package:cream_ventory/database/functions/user_db.dart';
import 'package:cream_ventory/screens/home/home_screen.dart';
import 'package:cream_ventory/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInFunctions {
  // Navigate to Home after Sign-Up
  static Future<void> navigateToHome({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required TextEditingController usernameController,
    required TextEditingController emailController,
    required TextEditingController passwordController,
  }) async {
    if (formKey.currentState!.validate()) {
      try {
        final username = usernameController.text.trim().toLowerCase();
        final email = emailController.text.trim().toLowerCase();
        final password = passwordController.text.trim();

        // Create new user using UserDB
         await UserDB.createUser(
          email: email,
          username: username,
          password: password, 
        );
 
        final user = await UserDB.getCurrentUser();

        // Set isLoggedIn to true after successful sign-up 
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        await UserDB.setLoggedInStatus(true,user.id); // Set login status in UserDB

        
        // Show success SnackBar                      
        CustomSnackbar.show(
          context: context,
          message: 'Successfully Registered!',
          backgroundColor: Colors.green,
        );

        // Navigate to HomeScreen after short delay
        await Future.delayed(const Duration(seconds: 1));
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) =>  ScreenHome(user: user,)),
          (route) => false,
        );
      } catch (e) {
        String errorMessage;
        if (e.toString().contains('already exists')) {
          errorMessage = 'Email or username already taken.';
        } else {
          errorMessage = 'Registration failed. Please try again.';                  
        }
        CustomSnackbar.show(
          context: context,
          message: errorMessage,
          backgroundColor: Colors.red,
        );
        debugPrint('Registration error: $e');
      }
    } else {
      CustomSnackbar.show(
        context: context,
        message: 'Please fill out all fields correctly',
        backgroundColor: Colors.red,
      );
    }
  }

  // Validate Username
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    final usernameRegex = RegExp(r'^[a-z0-9_]{3,}$');
    if (!usernameRegex.hasMatch(value.trim().toLowerCase())) {
      return 'Username must be at least 3 characters (lowercase, numbers, or underscores)';
    }
    return null;
  }

  // Validate Email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$');
    if (!emailRegex.hasMatch(value.trim().toLowerCase())) {
      return 'Enter a valid email';
    }
    return null;
  }

  // Validate Password
  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.trim().length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}