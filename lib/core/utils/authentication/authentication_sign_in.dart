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
  // Demo Account Credentials
  static const String DEMO_USERNAME = 'demo_user';
  static const String DEMO_EMAIL = 'demo@creamventory.com';
  static const String DEMO_PASSWORD = 'demo123';
  static const String DEMO_USER_ID = 'demo_0';
  
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

  // Check if credentials match demo account
  static bool isDemoAccount(String usernameOrEmail, String password) {
    final input = usernameOrEmail.trim().toLowerCase();
    final pwd = password.trim();
    
    return (input == DEMO_USERNAME.toLowerCase() || input == DEMO_EMAIL.toLowerCase()) 
           && pwd == DEMO_PASSWORD;
  }

  // Create demo user model
  static UserModel createDemoUser() {
    return UserModel(
      id: DEMO_USER_ID,
      username: DEMO_USERNAME,
      email: DEMO_EMAIL,
      password: hashPassword(DEMO_PASSWORD),
      name: 'Demo User',
      distributionName: 'Demo Distribution',
      phone: '+1234567890',
      address: 'Demo Address, Demo City',
      profileImagePath: null,
    );   
  }

  // Login User Logic - Updated with demo account support
  static Future<void> loginUser({
    required BuildContext context,
    required String usernameOrEmail,
    required String password,
    required GlobalKey<FormState> formKey,
  }) async {
    if (formKey.currentState?.validate() ?? false) {
      final query = usernameOrEmail.trim().toLowerCase();

      try {
        UserModel? user;
        
        // Check if it's the demo account first
        if (isDemoAccount(usernameOrEmail, password)) {
          user = createDemoUser();
          
          // Save demo user session
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('currentUserId', DEMO_USER_ID);
          await prefs.setBool('isDemoUser', true);
          
          // Success Snackbar for Demo Account
          showTopSnackBar(
            Overlay.of(context),
            const CustomSnackBar.success(
              message: "Demo login successful! Explore the app!",
              icon: Icon(Icons.check_circle, color: Colors.white, size: 40),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Regular authentication (this already sets isLoggedIn and currentUserId)
          user = await UserDB.authenticateUser(query, password);
          
          if (user != null) {
            // Mark as not demo user
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isDemoUser', false);
            
            // Success Snackbar (Green)
            showTopSnackBar(
              Overlay.of(context),
              const CustomSnackBar.success(
                message: "Login successful! Welcome back!",
                icon: Icon(Icons.check_circle, color: Colors.white, size: 40),
                backgroundColor: Colors.green,
              ),
            );
          }
        }

        if (user != null) {
          // Navigate to HomeScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ScreenHome(user: user!)),
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