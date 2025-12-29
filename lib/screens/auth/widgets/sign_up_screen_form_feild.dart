import 'package:cream_ventory/screens/auth/widgets/auth_screen_center_text.dart';
import 'package:cream_ventory/screens/auth/widgets/auth_screens_button.dart';
import 'package:cream_ventory/screens/auth/widgets/auth_screen_text_form_feild.dart';
import 'package:cream_ventory/core/utils/authentication/authentication_sign_up.dart';
import 'package:flutter/material.dart';

class FormFeild extends StatefulWidget {
  const FormFeild({super.key});

  @override
  State<FormFeild> createState() => _FormFeildState();
}

class _FormFeildState extends State<FormFeild> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
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
    final bool isdesktopScreen = screenWidth >= 1000;
 
    // Responsive spacing 
    final double topSpacing = () {
      if (isSplitScreen) return 15.0;
      if (isSmallScreen) return 35.0;
      return 35.0;
    }();

    final double fieldSpacing = () {
      if (isSplitScreen) return 14.0;
      if (isSmallScreen) return 22.0;
      return 30.0;
    }();

    final double buttonTopSpacing = () {
      if (isSplitScreen) return 20.0;
      if (isSmallScreen) return 25.0;
      return 30.0;
    }();

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: topSpacing),
          isdesktopScreen ? SizedBox() : CenterTextSignUp(),
          SizedBox(height: isdesktopScreen ? null : 40),
          CustomTextFormField( 
            labelText: 'Username', 
            controller: _usernameController, 
            hintText: 'Enter your Username',
            validator: SignInFunctions.validateUsername,
          ),
          SizedBox(height: fieldSpacing),
          CustomTextFormField(
            labelText: 'Email',
            controller: _emailController,
            hintText: 'Enter your Email',
            validator: SignInFunctions.validateEmail,
            type: TextInputType.emailAddress,
          ),
          SizedBox(height: fieldSpacing),
          CustomTextFormField(
            labelText: 'Password',
            controller: _passwordController,
            hintText: 'Enter your Password',
            validator: SignInFunctions.validatePassword,
            isPasswordVisible: isPasswordVisible,
            isPassword: true,
            togglePasswordVisibility: () {
              setState(() {
                isPasswordVisible = !isPasswordVisible;
              });
            },
          ),
          SizedBox(height: buttonTopSpacing),
          AuthButton(
            onPressed: () {
              SignInFunctions.navigateToHome(
                context: context,
                emailController: _emailController,
                formKey: _formKey,
                passwordController: _passwordController,
                usernameController: _usernameController,
              );
            },
            primaryText: 'SIGN',
            secondaryText: 'UP',
          ),
          // Add bottom spacing for better scrolling experience
          if (isSplitScreen) SizedBox(height: 10),
        ],
      ),
    );
  }
}
