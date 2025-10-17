import 'package:cream_ventory/db/functions/user_db.dart';
import 'package:cream_ventory/db/models/user/user_model.dart';
import 'package:cream_ventory/screen/home/home_screen.dart';
import 'package:cream_ventory/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

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

  // Login User Logic
  static Future<void> loginUser({
    required BuildContext context,
    required String usernameOrEmail,
    required String password,
    required GlobalKey<FormState> formKey,
  }) async {
    if (formKey.currentState?.validate() ?? false) {
      final query = usernameOrEmail.trim().toLowerCase();
                            
      try {
        // Authenticate user using UserDB
        UserModel? user = await UserDB.authenticateUser(query, password);
        // Set isLoggedIn to true after successful loginUser
        final prefs = await SharedPreferences.getInstance(); 
        await prefs.setBool('isLoggedIn', true);


        if (user != null) {
          CustomSnackbar.show(
            context: context,
            message: 'Welcome back, ${user.username}!',
            backgroundColor: Colors.green,
          );

          // Navigate to HomeScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>  ScreenHome(user: user,)),
          );
        } else {
          CustomSnackbar.show(
            context: context,
            message: 'Incorrect username/email or password',
            backgroundColor: Colors.red,
          );
        }
      } catch (e) {
        CustomSnackbar.show(
          context: context,
          message: 'An error occurred. Please try again.',
          backgroundColor: Colors.red,
        );
        print('Login error: $e');
      }
    } else {
      CustomSnackbar.show(
        context: context,
        message: 'Please fill out all fields correctly',
        backgroundColor: Colors.red,
      );
    }
  }
}