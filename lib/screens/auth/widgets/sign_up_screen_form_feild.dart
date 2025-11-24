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
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SizedBox(height: 30), 
          CustomTextFormField(
            labelText: 'Username',
            controller: _usernameController,
            hintText: 'Enter your Username', 
            validator: SignInFunctions.validateUsername,
          ),
          SizedBox(height: 25), 
          CustomTextFormField(
            labelText: 'Email',
            controller: _emailController,
            hintText: 'Enter your Email',
            validator: SignInFunctions.validateEmail,
            type: TextInputType.emailAddress,        
          ),
          SizedBox(height: 25), 
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
          SizedBox(height: 40),
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
            secondaryText: 'IN',
          ),
        ],
      ),
    );
  }
}