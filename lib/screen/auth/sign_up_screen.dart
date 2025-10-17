import 'package:cream_ventory/screen/auth/widgets/common/texts/auth_screen_center_text.dart';
import 'package:cream_ventory/screen/auth/widgets/common/texts/sign_in_screen_text_container.dart';
import 'package:cream_ventory/screen/auth/widgets/signUp/sign_up_screen_form_feild.dart';
import 'package:cream_ventory/utils/responsive_util.dart';
import 'package:cream_ventory/widgets/background_image.dart';
import 'package:cream_ventory/widgets/container.dart';
import 'package:cream_ventory/widgets/positioned.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb; // Import for platform detection
import 'package:flutter/material.dart';

class ScreenSignUp extends StatefulWidget {
  const ScreenSignUp({super.key});

  @override
  State<ScreenSignUp> createState() => _ScreenSignUpState();
}

class _ScreenSignUpState extends State<ScreenSignUp> {
  @override
  Widget build(BuildContext context) {
    // Initialize SizeConfig to ensure responsive calculations
    SizeConfig.init(context);

    return Scaffold(
      // Disable resizeToAvoidBottomInset on web/desktop to prevent unnecessary resizing
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Get screen dimensions for additional flexibility
          final double screenWidth = constraints.maxWidth;
          final double screenHeight = constraints.maxHeight;

          // Define responsive padding and sizes using SizeConfig
          final double bottomPadding =
              SizeConfig.blockHeight * 3; // 3% of screen height
          final double horizontalPadding =
              SizeConfig.blockWidth * 6; // 6% of screen width
          // Adjust container height for web/desktop to avoid overflow
          final double containerHeight = kIsWeb
              ? screenHeight *
                    0.5 // Larger height for web
              : SizeConfig.screenHeight * 0.49; // 40% for mobile
          final double containerPaddingHorizontal =
              SizeConfig.blockWidth * 6; // 5% of screen width
          final double containerPaddingVertical =
              SizeConfig.blockHeight * 3; // 3% of screen height
          final double borderRadius =
              SizeConfig.blockWidth *
              3; // 3% of screen width for rounded corners

          return Stack(
            children: [
              // Background image, assumed to be responsive
              Positioned.fill(
                child: IntroBackground(
                  imagePath: 'assets/image/icecream cxard 2.jpg',
                ),
              ),
              // Semi-transparent overlay for better contrast
              Container(color: const Color.fromARGB(49, 0, 0, 0)),
              // Text container, assumed to handle its own responsiveness
              TextContainer(),
              // Center text for sign-up, assumed to handle its own responsiveness
              CenterTextSignUp(),
              // Positioned container for form fields
              CustomPositioned(
                type: PositionedType.fill,
                bottom: bottomPadding,
                left: horizontalPadding,
                right: horizontalPadding,
                child: ReusableContainer(
                  padding: EdgeInsets.symmetric(
                    horizontal: containerPaddingHorizontal,
                    vertical: containerPaddingVertical,
                  ),
                  height: containerHeight,
                  width:
                      screenWidth -
                      (2 * horizontalPadding), // Full width minus padding
                  color: const Color.fromARGB(186, 0, 0, 0),
                  borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                  child: SingleChildScrollView(child: FormFeild()),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
