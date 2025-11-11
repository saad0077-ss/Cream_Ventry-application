import 'package:cream_ventory/screens/auth/sign_up_screen.dart';
import 'package:cream_ventory/widgets/text_span.dart';
import 'package:flutter/material.dart';

class CreateAccount extends StatelessWidget {
  const CreateAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomTextSpan(
      spans: [
        TextSpanConfig(
          text: "Didn't have an account? ",
          style: const TextStyle(color: Colors.white),
        ),
        TextSpanConfig(
          text: "Create one",
          style: const TextStyle(color: Colors.blueAccent),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  ScreenSignUp()),
            );
          },
        ),
      ],
    );
  }
}
