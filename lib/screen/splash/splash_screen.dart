import 'package:cream_ventory/utils/splash/splash_utils.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ScreenSplash extends StatefulWidget {

  const ScreenSplash({super.key});

  @override
  State<ScreenSplash> createState() => _ScreenSplashState();
}

class _ScreenSplashState extends State<ScreenSplash> with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Wait for 3 seconds before navigating
    await Future.delayed(const Duration(seconds: 2));
    await NavigationUtils.navigateToNextScreen(context);
  } 

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double screenWidth = constraints.maxWidth;
          final double animationSize = screenWidth < 600 ? screenWidth * 0.8 : screenWidth * 0.5;

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration( 
              gradient: LinearGradient(
                colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)], // Light blue gradient
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(  
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: animationSize,
                    height: animationSize,
                    child: Lottie.asset(
                      'assets/animation/Main Scene.json',
                      controller: _controller,
                      fit: BoxFit.contain,
                      repeat: true,
                      animate: true,
                      onLoaded: (composition) {
                        _controller
                          ..duration = composition.duration * 2 // Double the duration to slow down
                          ..repeat(); // Keep looping during the 3-second delay
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'CreamVentry',
                    style: TextStyle(                                    
                      fontFamily: 'ABeeZee',
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Optional loading indicator
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}