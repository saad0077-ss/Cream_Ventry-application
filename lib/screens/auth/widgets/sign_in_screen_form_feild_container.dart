import 'package:cream_ventory/screens/auth/widgets/auth_screen_center_text.dart';
import 'package:cream_ventory/screens/auth/widgets/sign_in_screen_account_create.dart';
import 'package:cream_ventory/screens/auth/widgets/auth_screens_button.dart';
import 'package:cream_ventory/screens/auth/widgets/auth_screen_text_form_feild.dart';
import 'package:cream_ventory/core/utils/authentication/authentication_sign_in.dart';
import 'package:flutter/material.dart';

class FormFeildContainer extends StatefulWidget {
  const FormFeildContainer({super.key});

  @override
  State<FormFeildContainer> createState() => _FormFeildContainerState();
}

class _FormFeildContainerState extends State<FormFeildContainer> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _handleLogin() {
    LoginFunctions.loginUser(
      context: context,
      usernameOrEmail: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
      formKey: _formKey,
    );
  }
 
  bool rememberMe = false;
  bool isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Detect small screens and split-screen mode
    final bool isSmallScreen = screenWidth < 420;
    final bool isSplitScreen = screenHeight < 600;

    final bool isDesktopScreen = screenHeight >= 1000;
    
    // Responsive spacing
    final double topSpacing = () {
      if (isSplitScreen) return 12.0;
      if (isSmallScreen) return 40.0;
      return 30.0;  
    }(); 
    
    final double fieldSpacing = () {
      if (isSplitScreen) return 16.0;
      if (isSmallScreen) return 20.0;
      return 25.0; 
    }();
    
    final double afterPasswordSpacing = () {
      if (isSplitScreen) return 12.0;
      if (isSmallScreen) return 15.0;
      return 19.0;
    }();
    
    final double buttonTopSpacing = () {
      if (isSplitScreen) return 12.0;
      if (isSmallScreen) return 15.0;
      return 19.0;
    }();
    
    final double afterButtonSpacing = () {
      if (isSplitScreen) return 14.0;
      if (isSmallScreen) return 16.0; 
      return 20.0;
    }();

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: topSpacing),
            isDesktopScreen ? SizedBox() : CenterTextSignIn(),
            SizedBox(height: isDesktopScreen ? null : 40),  
            CustomTextFormField(
              labelText: 'Username or Email', 
              controller: _usernameController,
              hintText: 'Username or Email',
              validator: LoginFunctions.validateUsernameOrEmail, 
            ),
            SizedBox(height: fieldSpacing), 
            CustomTextFormField(
              labelText: 'Password',
              controller: _passwordController,
              hintText: 'Password',
              validator: LoginFunctions.validatePassword,
              isPassword: true,
              isPasswordVisible: isPasswordVisible,
              togglePasswordVisibility: () {
                setState(() {
                  isPasswordVisible = !isPasswordVisible;
                }); 
              },  
            ),
            SizedBox(height: afterPasswordSpacing),
            SizedBox(height: buttonTopSpacing), 
            AuthButton(
              onPressed: _handleLogin,
              primaryText: 'SIGN',
              secondaryText: 'IN',
            ),
            SizedBox(height: afterButtonSpacing),
            CreateAccount(),
            // Add bottom padding for better scrolling in split-screen
            if (isSplitScreen) SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}