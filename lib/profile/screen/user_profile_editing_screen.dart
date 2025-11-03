import 'package:cream_ventory/themes/app_theme/theme.dart';
import 'package:cream_ventory/utils/profile/edit_profile_logics.dart';
import 'package:cream_ventory/widgets/app_bar.dart';
import 'package:cream_ventory/widgets/custom_button.dart';
import 'package:cream_ventory/widgets/text_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final EditProfileLogic _logic = EditProfileLogic();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _logic.initializeProfile();
  }

  @override
  void dispose() {
    _logic.dispose();
    super.dispose();
  }

  // Custom validation method for read-only fields (like username)
  String? _validateUsername(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Username is required';
    }
    if (trimmed.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (trimmed.length > 30) { 
      return 'Username cannot exceed 30 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(trimmed)) {
      return 'Only letters, numbers, and underscore allowed';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Edit Profile',
        fontSize: 35,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(gradient: AppTheme.appGradient),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      // ---------- Profile Picture ----------
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: kIsWeb
                                ? (_logic.imageBytes != null
                                    ? MemoryImage(_logic.imageBytes!)
                                    : const AssetImage('assets/image/account.png'))
                                : (_logic.profileImage != null
                                    ? FileImage(_logic.profileImage!)
                                    : const AssetImage('assets/image/account.png'))
                                    as ImageProvider,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () async {
                                await _logic.pickImage(context);
                                setState(() {});
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 16,
                                child: const Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 70),

                      // ---------- Username (Read-Only + Validated) ----------
                      CustomTextField(
                        labelText: 'Username',
                        controller: _logic.nameController,
                        fillColor: Colors.black12,
                        enabled: false, // Read-only
                        // Validator still runs on form validate
                        validator: _validateUsername,
                      ),

                      const SizedBox(height: 30),

                      // ---------- Distribution Name ----------
                      CustomTextField(
                        labelText: 'Enter Distribution Name',
                        controller: _logic.distributionController,
                        fillColor: Colors.black12,
                        validator: (value) {
                          final trimmed = value?.trim() ?? '';
                          if (trimmed.isEmpty) {
                            return 'Distribution name is required';
                          }
                          if (trimmed.length < 2) {
                            return 'Must be at least 2 characters';
                          }
                          if (trimmed.length > 50) {
                            return 'Cannot exceed 50 characters';
                          }
                          if (!RegExp(r'^[a-zA-Z0-9\s&.,()-]+$').hasMatch(trimmed)) {
                            return 'Only letters, numbers, spaces and common symbols';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 30),

                      // ---------- Email (Read-Only) ----------
                      CustomTextField(
                        labelText: 'Email',
                        controller: _logic.emailController,
                        keyboardType: TextInputType.emailAddress,
                        fillColor: Colors.black12,
                        enabled: false,
                      ),

                      const SizedBox(height: 30),

                      // ---------- Mobile Number ----------
                      CustomTextField(
                        labelText: 'Enter Mobile Number',
                        controller: _logic.phoneController,
                        keyboardType: TextInputType.phone,
                        fillColor: Colors.black12,
                        validator: (value) {
                          final trimmed = value?.trim() ?? '';
                          if (trimmed.isEmpty) {
                            return 'Phone number is required';
                          }

                          final digitsOnly = trimmed.replaceAll(RegExp(r'\D'), '');
                          if (digitsOnly.length < 10) {
                            return 'Must have at least 10 digits';
                          }
                          if (digitsOnly.length > 15) {
                            return 'Cannot exceed 15 digits';
                          }

                          // Optional: Allow + at start, spaces, dashes
                          if (!RegExp(r'^[\+]?[0-9\s\-\(\)]+$').hasMatch(trimmed)) {
                            return 'Invalid phone format';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 30),

                      // ---------- Address ----------
                      CustomTextField(
                        labelText: 'Enter Your Address',
                        controller: _logic.addressController,
                        maxLines: 3,
                        fillColor: Colors.black12,
                        validator: (value) {
                          final trimmed = value?.trim() ?? '';
                          if (trimmed.isEmpty) {
                            return 'Address is required';
                          }
                          if (trimmed.length < 10) {
                            return 'Address too short (min 10 chars)';
                          }
                          if (trimmed.length > 200) {
                            return 'Address too long (max 200 chars)';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 60),

                      // ---------- Action Buttons ----------
                      Row(
                        children: [
                          Expanded(
                            child: CustomActionButton(
                              label: 'Cancel',
                              backgroundColor: Color.fromARGB(255, 80, 82, 84), 
                              onPressed: () => Navigator.pop(context),
                              fontSize: 19,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomActionButton(
                              label: 'Save',
                              backgroundColor: Color.fromARGB(255, 85, 172, 213), 
                              onPressed: () async {
                                // Trigger all validators (including read-only fields)
                                if (_formKey.currentState!.validate()) {
                                  final success = await _logic.saveProfile(context);
                                  if (success) {
                                    Navigator.of(context).pop();
                                  }
                                }
                              },
                              fontSize: 19,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}