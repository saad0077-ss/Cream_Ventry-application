
import 'package:cream_ventory/core/theme/theme.dart';
import 'package:cream_ventory/core/utils/profile/edit_profile_logics.dart';
import 'package:cream_ventory/screens/profile/widgets/user_profile_editing_screen/user_profile_editing_screen_action_buttons_row.dart';
import 'package:cream_ventory/screens/profile/widgets/user_profile_editing_screen/user_profile_editing_screen_info_feild..dart';
import 'package:cream_ventory/screens/profile/widgets/user_profile_editing_screen/user_profile_editing_screen_profile_avatar.dart'; 
import 'package:cream_ventory/widgets/app_bar.dart';
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
    _logic.initializeProfile(onUpdate: () => setState(() {}));
  }

  @override
  void dispose() {
    _logic.dispose();  
    super.dispose();
  }

  @override
  Widget build(BuildContext context) { 
    return Scaffold(
      appBar: const CustomAppBar(title: 'Edit Profile', fontSize: 35),
      body: Container(
        width: double.infinity,
        height: double.infinity ,
        decoration: const BoxDecoration(gradient: AppTheme.appGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                ProfileAvatar(logic: _logic),
                const SizedBox(height: 50),

                // Username
                InfoField(
                  labelText: 'Username',
                  controller: _logic.usernameController,
                  infoTitle: 'Username Requirements',
                  infoMessage:
                      '• Must be 3-30 characters\n• Only letters, numbers, and underscores allowed\n• Cannot be changed after registration',
                  validator: _validateUsername,
                ),

                const SizedBox(height: 24),
                InfoField(
                  labelText: 'Distribution Name',
                  controller: _logic.distributionController,
                  infoTitle: 'Distribution Name',
                  infoMessage:
                      '• Your business or company name\n• 2-50 characters allowed\n• Can include letters, numbers, spaces, and common symbols (&.,()-)',
                  validator: _validateDistributionName,
                ),

                const SizedBox(height: 24),
                InfoField(
                  labelText: 'Email',
                  controller: _logic.emailController,
                  keyboardType: TextInputType.emailAddress,
                  infoTitle: 'Email Address',
                  infoMessage:
                      '• Used for account verification and notifications\n• Must be a valid email format\n• Cannot be changed after registration',
                  validator: _validateEmail,
                ),

                const SizedBox(height: 24),
                InfoField(
                  labelText: 'Mobile Number',
                  controller: _logic.phoneController,
                  keyboardType: TextInputType.phone,
                  infoTitle: 'Phone Number',
                  infoMessage:
                      '• Must have 10-15 digits\n• Can include country code (optional)\n• Used for account recovery and notifications',
                  validator: _validatePhone,
                ),

                const SizedBox(height: 24),
                InfoField(
                  labelText: 'Address',
                  controller: _logic.addressController,
                  maxLines: 3,
                  infoTitle: 'Business Address',
                  infoMessage:
                      '• Your business or distribution address\n• Must be 10-200 characters\n• Include street, city, state, and postal code for accuracy',
                  validator: _validateAddress,
                ),

                const SizedBox(height: 50),
                ActionButtonsRow(
                  onCancel: () => Navigator.pop(context),
                  onSave: () async {
                    if (_formKey.currentState!.validate()) {
                      final success = await _logic.saveProfile(context);
                      if (success) Navigator.of(context).pop();
                    }
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Validation Methods
  String? _validateUsername(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Username is required';
    if (trimmed.length < 3) return 'Username must be at least 3 characters';
    if (trimmed.length > 30) return 'Username cannot exceed 30 characters';
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(trimmed)) {
      return 'Only letters, numbers, and underscore allowed';
    }
    return null;
  }

  String? _validateDistributionName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Distribution name is required';
    if (trimmed.length < 2) return 'Must be at least 2 characters';
    if (trimmed.length > 50) return 'Cannot exceed 50 characters';
    if (!RegExp(r'^[a-zA-Z0-9\s&.,()-]+$').hasMatch(trimmed)) {
      return 'Only letters, numbers, spaces and common symbols';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(trimmed)) {
      return 'Invalid email format';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Phone number is required';
    final digitsOnly = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 10) return 'Must have at least 10 digits';
    if (digitsOnly.length > 15) return 'Cannot exceed 15 digits';
    if (!RegExp(r'^[\+]?[0-9\s\-\(\)]+$').hasMatch(trimmed)) {
      return 'Invalid phone format';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Address is required';
    if (trimmed.length < 10) return 'Address too short (min 10 chars)';
    if (trimmed.length > 200) return 'Address too long (max 200 chars)';
    return null;
  }
}