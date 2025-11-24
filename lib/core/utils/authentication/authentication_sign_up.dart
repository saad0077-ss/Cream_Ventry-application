import 'package:cream_ventory/database/functions/user_db.dart';
import 'package:cream_ventory/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import top_snackbar_flutter
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

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

        // Create new user
        await UserDB.createUser(
          email: email,
          username: username,
          password: password,
        );

        final user = await UserDB.getCurrentUser();

        // Save login state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await UserDB.setLoggedInStatus(true, user.id);

        // Success Top Snackbar
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.success(
            message: "Successfully Registered! Welcome!",
            icon: Icon(Icons.sentiment_very_satisfied, color: Colors.white, size: 40),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to Home after short delay
        await Future.delayed(const Duration(milliseconds: 1200));
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => ScreenHome(user: user)),
            (route) => false,
          );
        }
      } catch (e) {
        String errorMessage;
        if (e.toString().contains('already exists')) {
          errorMessage = 'Email or username already taken.';
        } else {
          errorMessage = 'Registration failed. Please try again.';
        }

        // Error Top Snackbar
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(
            message: errorMessage,
            icon: const Icon(Icons.error_outline, color: Colors.white, size: 40),
            backgroundColor: Colors.red.shade600,
          ),
        );
        debugPrint('Registration error: $e');
      }
    } else {
      // Form validation failed
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.info(
          message: "Please fill out all fields correctly",
          backgroundColor: Colors.orange,
          icon: Icon(Icons.info_outline, color: Colors.white, size: 40),
        ),
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