import 'package:cream_ventory/database/functions/user_db.dart';
import 'package:cream_ventory/models/user_model.dart';
import 'package:cream_ventory/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Import top_snackbar_flutter
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class LoginFunctions {
  // Hash Password
  static String hashPassword(String password) {
    return sha256.convert(utf8.encode(password.trim())).toString();
  }

  // Validate Username or Email
  static String? validateUsernameOrEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter username or email';
    }
    final emailRegex = RegExp(r'^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$');
    if (emailRegex.hasMatch(value.trim().toLowerCase())) {
      return null; // Valid email
    }
    final usernameRegex = RegExp(r'^[a-z0-9_]{3,}$');
    if (usernameRegex.hasMatch(value.trim().toLowerCase())) {
      return null; // Valid username
    }
    return 'Enter a valid email or username (lowercase, min 3 characters)';
  }

  // Validate Password
  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter password';
    }
    if (value.trim().length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Login User Logic - Updated with top_snackbar_flutter
  static Future<void> loginUser({
    required BuildContext context,
    required String usernameOrEmail,
    required String password,
    required GlobalKey<FormState> formKey,
  }) async {
    if (formKey.currentState?.validate() ?? false) {
      final query = usernameOrEmail.trim().toLowerCase();

      try {
        UserModel? user = await UserDB.authenticateUser(query, password);

        // Save login state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        if (user != null) {
          // Success Snackbar (Green)
          showTopSnackBar(
            Overlay.of(context),
            const CustomSnackBar.success(
              message: "Login successful! Welcome back!",
              icon: Icon(Icons.check_circle, color: Colors.white, size: 40),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to HomeScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ScreenHome(user: user)),
          );
        } else {
          // Error: Invalid credentials
          showTopSnackBar(
            Overlay.of(context),
            const CustomSnackBar.error(
              message: "Incorrect username/email or password",
              icon: Icon(Icons.error, color: Colors.white, size: 40),
            ),
          );
        }
      } catch (e) {
        // General error
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.error(
            message: "An error occurred. Please try again.",
          ),
        );
        print('Login error: $e');
      }
    } else {
      // Form validation failed
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.info(
          message: "Please fill out all fields correctly",
          backgroundColor: Colors.orange,
        ), 
      );
    }
  }
}