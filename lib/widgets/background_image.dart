import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroBackground extends StatelessWidget {
  final String imagePath; // Path to image or Lottie animation (.json)
  final BoxFit fit;
  final Widget? child;
  final Gradient? gradientOverlay;
  final Color? colorOverlay;
  final Alignment alignment;
  final bool loopAnimation; // Control Lottie animation looping
  final bool reverseAnimation; // Control Lottie animation reverse
  final double animationSpeed; // Control Lottie animation speed
  final bool animateChild; // Add fade-in animation for child
  final double animationScale; // Scale factor for Lottie animation size

  const IntroBackground({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover ,
    this.child,
    this.gradientOverlay,
    this.colorOverlay,
    this.alignment = Alignment.center, 
    this.loopAnimation = true,
    this.reverseAnimation = false,
    this.animationSpeed = 0.1,
    this.animateChild = true,
    this.animationScale = 0.7, // Default to 50% of screen size 
  });
     
  // Default radial gradient for aesthetic overlay around centered animation
 

  // Check if the path is a Lottie animation file
  bool _isLottieFile(String path) {
    return path.toLowerCase().endsWith('.json');
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive animation sizing
    final screenSize = MediaQuery.of(context).size;
    final animationSize = screenSize.width * animationScale; // Responsive size

    return Stack(
      children: [
        // Background (Lottie or Image)
        SizedBox.expand(
          child: _isLottieFile(imagePath)                         
              ? Center(
                  child: SizedBox(
                    width: animationSize,
                    height: animationSize,
                    child: Lottie.asset(
                      imagePath,
                      fit: fit,
                      repeat: loopAnimation,
                      reverse: reverseAnimation,
                      animate: true,
                      frameRate: FrameRate.max,
                      // The controller property is removed because LottieController is not defined and not needed here.
                      // To control animation speed, use delegates or control externally if needed.
                      onLoaded: (composition) {
                        print('Lottie animation loaded: $imagePath');
                      },
                      errorBuilder: (context, error, stackTrace) { 
                        debugPrint('Error loading Lottie animation ($imagePath): $error\n$stackTrace');
                        return Image.asset(
                          'assets/image/ice2.jpg', // Fallback image
                          fit: fit,
                          errorBuilder: (context, error, stackTrace) { 
                            print('Error loading fallback image: $error');
                            return Container(     
                              color:  Colors.white,
                              child: const Center(
                                child: Text(
                                  'Failed to load background',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ), 
                            );
                          },
                        );
                      },
                    ),
                  ),
                )
              : Image.asset(
                  imagePath,
                  fit: fit,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading image ($imagePath): $error');
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Text(
                          'Failed to load background',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  },
                ),
        ),
        // Color overlay (if provided)
        if (colorOverlay != null)
          Container(
            color: colorOverlay!,
          ),
       
        if (child != null)
          Align(
            alignment: alignment,
            child: animateChild
                ? AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeIn,
                    child: child,
                  )
                : child,
          ),
      ],
    );
  }
}