import 'package:cream_ventory/screen/intros/intro_screen2.dart';
import 'package:cream_ventory/screen/intros/widgets/intro_screen_container.dart';
import 'package:cream_ventory/screen/intros/widgets/intro_screen_skip_button.dart';
import 'package:cream_ventory/widgets/background_image.dart';
import 'package:cream_ventory/widgets/button.dart';
import 'package:flutter/material.dart';

class ScreenIntro1 extends StatelessWidget {
  const ScreenIntro1({super.key});

  @override
  Widget build(BuildContext context) {

    final bool _isDesktop = MediaQuery.of(context).size.width >= 700; 
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // Calculate the aspect ratio of the screen
          final double aspectRatio = constraints.maxWidth / constraints.maxHeight;
          
    
          // Print constraints for debugging
          print('Screen size: ${constraints.maxWidth}x${constraints.maxHeight}, Aspect ratio: $aspectRatio');
    
          return Stack(
            children: [ 
              IntroBackground(                                        
                imagePath: 'assets/animation/Untitled file.json',
                fit: BoxFit.cover, // Ensure animation scales nicely
                loopAnimation: false, // Loop the animation     
                animationSpeed: 0.5, // Slightly slower for smooth effect       
                gradientOverlay: LinearGradient(     
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,                                                                                                           
                  colors: [
                    Colors.blueAccent.withOpacity(0.3), // Pastel blue
                    Colors.pinkAccent.withOpacity(0.3), // Pastel pink
                  ],
                ),
                animateChild: true, // Fade-in effect for child
              ),
              IntroSkipButton(),  
              IntroBottomContainer(
                containerHeight: _isDesktop ? 340 : 320, 
                description:
                    '"WELCOME TO Creamventory!🍦\nKEEP YOUR FLAVORS FRESH,\nYOUR STOCK FULL, AND YOUR\nCUSTOMERS HAPPY. LET\'S\nMANAGE YOUR ICE CREAM\nINVENTORY WITH A CHERRY\nON TOP!"',
                button: CustomButton(
                  label: 'EXPLORE',
                  fontSize: _isDesktop?20: 18, // Responsive font size
                  onPressed: () {
                    Navigator.of(context).pushReplacement( 
                      MaterialPageRoute(builder: (context) => const ScreenIntro2()),
                    );
                  },
                ),
              ),
            ],
          ); 
        },
      ),
    );
  }
}