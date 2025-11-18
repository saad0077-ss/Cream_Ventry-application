import 'package:cream_ventory/screens/auth/widgets/auth_screen_text_form_feild.dart';
import 'package:cream_ventory/core/utils/profile/change_password_logic.dart';
import 'package:cream_ventory/widgets/background_image.dart';
import 'package:cream_ventory/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  final ChangePasswordLogic _logic = ChangePasswordLogic();

  @override
  void dispose() {
    _logic.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          IntroBackground(imagePath: 'assets/image/icecream cxard 2.jpg'),

          // Centered content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'RESET YOUR',
                      style: TextStyle(
                        color: Colors.red, 
                        fontWeight: FontWeight.bold,
                        fontSize: 61,
                        fontFamily: 'BalooBhaina',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Text(
                      'PASSWORD',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 60,
                        fontFamily: 'BalooBhaina',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 125),

                    // New Password
                    CustomTextFormField(
                      controller: _logic.newPasswordController,
                      hintText: 'Enter New Password',
                      isPassword: true,
                      isPasswordVisible: _logic.isNewPasswordVisible,
                      togglePasswordVisibility: () {
                        setState(() { 
                          _logic.toggleNewPasswordVisibility();
                        });
                      },
                      validator: _logic.validateNewPassword,
                      fillColor: Colors.white60,
                      textColor: Colors.black,
                    ),
                    const SizedBox(height: 60),

                    // Confirm Password
                    CustomTextFormField(
                      controller: _logic.confirmPasswordController,
                      hintText: 'Confirm Password',
                      isPassword: true,
                      isPasswordVisible: _logic.isConfirmPasswordVisible,
                      togglePasswordVisibility: () {
                        setState(() {
                          _logic.toggleConfirmPasswordVisibility();
                        });
                      },
                      validator: (value) =>
                          _logic.validateConfirmPassword(value, _logic.newPasswordController.text),
                      fillColor: Colors.white60,
                      textColor: Colors.black,
                    ),
                    const SizedBox(height: 100),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: CustomActionButton(
                            label: 'Cancel',
                            backgroundColor: Colors.red,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            borderColor: Colors.white,
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: CustomActionButton(
                            label: 'Change',
                            backgroundColor: Colors.black,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _logic.showConfirmDialog(
                                  context,
                                  onConfirm: () async {
                                    final success = await _logic.changePassword(context);
                                    if (success) {
                                      Navigator.pop(context);
                                    }
                                  },
                                );
                              }
                            },
                            borderColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}