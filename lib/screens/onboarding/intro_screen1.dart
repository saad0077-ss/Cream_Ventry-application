import 'package:cream_ventory/screens/onboarding/desktop/intro_screen1_desktop.dart';
import 'package:cream_ventory/screens/onboarding/intro_screen2.dart';
import 'package:cream_ventory/screens/onboarding/widgets/intro_screen_skip_button.dart';
import 'package:flutter/material.dart';

class ScreenIntro1 extends StatefulWidget {
  const ScreenIntro1({super.key});

  @override
  State<ScreenIntro1> createState() => _ScreenIntro1State();
}

class _ScreenIntro1State extends State<ScreenIntro1> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth >= 1000) {
      return const ScreenIntro1Desktop();  
    }

    final bool isDesktop = screenWidth >= 700;
    
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Stack(
            children: [
              // Full screen content
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildEnhancedFullScreen(context, isDesktop),
                ),
              ),
              
              // Skip button overlay
              const IntroSkipButton(),
            ],
          ); 
        },
      ),
    );
  }
  
  Widget _buildEnhancedFullScreen(BuildContext context, bool isDesktop) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6366F1), // Indigo
            const Color(0xFF8B5CF6), // Purple
            const Color(0xFFEC4899), // Pink
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 48 : 24,
            vertical: isDesktop ? 60 : 40,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Ice cream emoji with glow effect
              Container(
                padding: EdgeInsets.all(isDesktop ? 32 : 24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Text(
                  '🍦',
                  style: TextStyle(
                    fontSize: isDesktop ? 80 : 64,
                  ),
                ),
              ),
              
              SizedBox(height: isDesktop ? 48 : 36),
              
              // Welcome text
              Text(
                'WELCOME TO',
                style: TextStyle(
                  fontSize: isDesktop ? 18 : 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 4,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // App name with bold styling
              Text(
                'Creamventory',
                style: TextStyle(
                  fontSize: isDesktop ? 56 : 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1,
                  height: 1.1,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: isDesktop ? 32 : 24),
              
              // Description with better formatting
              Text(
                'Keep your flavors fresh, your stock full,\nand your customers happy.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isDesktop ? 20 : 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.95),
                  height: 1.6,
                  letterSpacing: 0.3,
                ),
              ),
              
              SizedBox(height: isDesktop ? 20 : 16),
              
              Text(
                'Manage your ice cream inventory\nwith a cherry on top!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isDesktop ? 18 : 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.85),
                  height: 1.6,
                  fontStyle: FontStyle.italic,
                ),
              ),
              
              const Spacer(),
              
              // Enhanced button
              Container(
                width: double.infinity,
                height: isDesktop ? 64 : 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.of(context).pushReplacement( 
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => 
                            const ScreenIntro2(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.1, 0),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutCubic,
                                )),
                                child: child,
                              ),
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 500),
                        ),
                      );
                    },
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                Color(0xFF6366F1), // Indigo
                                Color(0xFFEC4899), // Pink
                              ],
                            ).createShader(bounds),
                            child: Text(
                              'EXPLORE',
                              style: TextStyle(
                                fontSize: isDesktop ? 22 : 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                Color(0xFF6366F1),
                                Color(0xFFEC4899),
                              ],
                            ).createShader(bounds),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ), 
                ),
              ),
              
              SizedBox(height: isDesktop ? 24 : 16),
            ],
          ),
        ),
      ),
    );
  }
}