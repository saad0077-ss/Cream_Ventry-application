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
                      Stack(
                        children: [
                          CircleAvatar(  
                            radius: 60,
                            backgroundImage:kIsWeb
                                ? (_logic.imageBytes != null
                                    ? MemoryImage(_logic.imageBytes!)
                                    : const AssetImage('assets/image/account.png'))
                                : (_logic.profileImage != null
                                    ? FileImage(_logic.profileImage!)
                                    : const AssetImage('assets/image/account.png')) as ImageProvider,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,   
                            child: GestureDetector(
                              onTap: () async {
                                await _logic.pickImage(context);
                                setState(() {}); // Rebuild to update image
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
                      CustomTextField(
                        labelText: 'Enter Username',
                        controller: _logic.nameController,
                        fillColor: Colors.black12,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Username is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      CustomTextField(
                        labelText: 'Enter Distribution Name',
                        controller: _logic.distributionController,
                        fillColor: Colors.black12,
                      ),
                      const SizedBox(height: 30),
                      CustomTextField(
                        labelText: 'Enter Your Email Id',
                        controller: _logic.emailController,
                        keyboardType: TextInputType.emailAddress,
                        fillColor: Colors.black12,
                        enabled: false, // Non-editable email
                      ),
                      const SizedBox(height: 30),
                      CustomTextField(
                        labelText: 'Enter Mobile Number',
                        controller: _logic.phoneController,
                        keyboardType: TextInputType.phone,
                        fillColor: Colors.black12,
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            final phoneRegex = RegExp(r'^\+?[\d\s-]{10,}$');
                            if (!phoneRegex.hasMatch(value.trim())) {
                              return 'Enter a valid phone number';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      CustomTextField(
                        labelText: 'Enter Your Address',
                        controller: _logic.addressController,
                        maxLines: 2,
                        fillColor: Colors.black12,
                      ),
                      const SizedBox(height: 60),
                      Row(
                        children: [
                          Expanded(
                            child: CustomActionButton(
                              label: 'Cancel',
                              backgroundColor: Colors.black,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              fontSize: 19,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomActionButton(
                              label: 'Save',
                              backgroundColor: Colors.red,
                              onPressed: () async {
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