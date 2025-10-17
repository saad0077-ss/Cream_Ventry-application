import 'package:cream_ventory/screen/auth/widgets/common/texts/auth_screen_center_text.dart';
import 'package:cream_ventory/screen/auth/widgets/signIn/sign_in_screen_form_feild_container.dart';
import 'package:cream_ventory/widgets/background_image.dart';
import 'package:cream_ventory/widgets/container.dart';
import 'package:cream_ventory/widgets/positioned.dart';
import 'package:flutter/material.dart';

class ScreenSignIn extends StatefulWidget {
  const ScreenSignIn({super.key});

  @override
  State<ScreenSignIn> createState() => _ScreenSignInState();
}

class _ScreenSignInState extends State<ScreenSignIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Get screen dimensions
          final double screenHeight = constraints.maxHeight;
          final double screenWidth = constraints.maxWidth;

          // Define responsive padding and sizes as fractions of screen dimensions
          final double bottomPadding = screenHeight * 0.03; // 3% of screen height
          final double horizontalPadding = screenWidth * 0.06; // 6% of screen width
          final double containerHeight = screenHeight * 0.45; // 50% of screen height
          final double containerPaddingHorizontal = screenWidth * 0.05; // 5% of screen width
          final double containerPaddingVertical = screenHeight * 0.05; // 4% of screen height
          final double borderRadius = screenWidth * 0.04; // 8% of screen width for rounded corners

          return Stack(
            children: [
              // Background image, assumed to be responsive in its own implementation
              IntroBackground(imagePath: 'assets/image/image.png'),
              // Semi-transparent overlay    
              Container(
                color: const Color.fromARGB(49, 0, 0, 0), 
              ),
              // Welcome text, assumed to handle its own responsiveness
              WelcomeText(),
              // Center text for sign-in, assumed to handle its own responsiveness
              CenterTextSignIn(),
              // Positioned container for form fields
              CustomPositioned(
                type: PositionedType.basic,
                bottom: bottomPadding,
                left: horizontalPadding,
                right: horizontalPadding,
                child: ReusableContainer(
                  padding: EdgeInsets.symmetric(
                    horizontal: containerPaddingHorizontal,
                    vertical: containerPaddingVertical,
                  ),
                  height: containerHeight,
                  width: screenWidth - (2 * horizontalPadding), // Full width minus padding
                  color: const Color.fromARGB(121, 0, 0, 0),
                  borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                  child: FormFeildContainer(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}  