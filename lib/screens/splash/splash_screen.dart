import 'package:cream_ventory/core/utils/splash/splash_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class ScreenSplash extends StatefulWidget {
  const ScreenSplash({super.key});

  @override
  State<ScreenSplash> createState() => _ScreenSplashState();
}

class _ScreenSplashState extends State<ScreenSplash>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _gradientController;
  late final AnimationController _textController;
  late final AnimationController _logoController;
  late final AnimationController _loadingController;

  late final Animation<Offset> _textAnimation;
  late final Animation<double> _logoFadeAnimation;
  late final Animation<double> _loadingScaleAnimation;

  late final Animation<Color?> _gradientColor1;
  late final Animation<Color?> _gradientColor2;
  late final Animation<Color?> _gradientColor3;
  late final Animation<Color?> _gradientColor4;

  @override
  void initState() {
    super.initState();

    // Lottie controller
    _controller = AnimationController(vsync: this); 

    // Gradient animation
    _gradientController = AnimationController(
      vsync: this, 
      duration: const Duration(seconds: 100),
    )..repeat(reverse: true);
     
    // Text slide-in
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..forward();

    // Logo fade-in
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    ); 

    // Loading pulse
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );

    // Animations
    _textAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    _loadingScaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOut),
    );

    // Sky Blue to White gradient animation
    _gradientColor1 = ColorTween(
      begin: const Color(0xFF87CEEB),
      end: const Color(0xFFB3E5FC),
    ).animate(_gradientController);

    _gradientColor2 = ColorTween(
      begin: const Color(0xFFB3E5FC),
      end: const Color(0xFFE1F5FE),
    ).animate(_gradientController);

    _gradientColor3 = ColorTween(
      begin: const Color(0xFFE1F5FE),
      end: const Color(0xFFFFFFFF),
    ).animate(_gradientController);

    _gradientColor4 = ColorTween(
      begin: const Color(0xFFFFFFFF),
      end: const Color(0xFF87CEEB),
    ).animate(_gradientController);     

    _startStaggeredAnimations();
    _navigateToNext();
  }

  void _startStaggeredAnimations() {
    _textController.forward();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _logoController.forward();
    });

    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) _loadingController.repeat(reverse: true);
    });
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      await NavigationUtils.navigateToNextScreen(context);
    }
  }

  @override 
  void dispose() {
    _controller.dispose();
    _gradientController.dispose();
    _textController.dispose();
    _logoController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(seconds: 3),
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _gradientColor1.value ?? const Color(0xFF87CEEB),
              _gradientColor2.value ?? const Color(0xFFB3E5FC),
              _gradientColor3.value ?? const Color(0xFFE1F5FE),
              _gradientColor4.value ?? const Color(0xFFFFFFFF),
            ],
            stops: const [0.0, 0.35, 0.65, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lottie Animation
              SizedBox(
                width: 250.r,
                height: 250.r,
                child: FadeTransition( 
                  opacity: _logoFadeAnimation, 
                  child: Lottie.asset(
                    'assets/animation/mainscene1.json',  
                    controller: _controller,
                    fit: BoxFit.contain,
                    repeat: true,
                    animate: true,
                    onLoaded: (composition) {
                      _controller
                        ..duration = composition.duration * 2
                        ..repeat();
                    }, 
                  ),
                ),
              ),
  
              SizedBox(height: 24.h),

              // App Name
              SlideTransition(
                position: _textAnimation,
                child: Text(
                  'CreamVentry',
                  style: TextStyle(
                    fontFamily: 'ABeeZee',
                    fontSize: 28,    
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold,
                    shadows: const [ 
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 1, 
                        color: Colors.black26,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 40),

              // SMALL Circular Progress Indicator
              SizedBox(
                width: 25,
                height: 25,   
                child: ScaleTransition(
                  scale: _loadingScaleAnimation,
                  child: CircularProgressIndicator(
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF0288D1), // Deep sky blue
                    ),
                    strokeWidth: 2, // Thin & elegant
                    backgroundColor: Colors.white.withOpacity(0.2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ); 
  }
}