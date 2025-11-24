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
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ), // Responsive height (~2.5% of 812px design height)
            CustomTextFormField(
              labelText: 'Username or Email' ,
              controller: _usernameController,
              hintText: 'Username or Email',
              validator: LoginFunctions.validateUsernameOrEmail, 
            ),
            SizedBox(
              height: 25,
            ), 
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
            SizedBox(
              height: 19,
            ), // Responsive height (~2.3% of 812px design height)
            SizedBox(
              height: 19,
            ), 
            AuthButton(
              onPressed: _handleLogin,
              primaryText: 'SIGN',
              secondaryText: 'IN',
            ),
            SizedBox(
              height: 20,
            ), // Responsive height (~2.5% of 812px design height)
            CreateAccount(),
          ],
        ),
      ),
    );
  }
}
