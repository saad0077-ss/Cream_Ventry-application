// lib/utils/navigation_utils.dart
import 'package:cream_ventory/database/functions/user_db.dart';
import 'package:cream_ventory/screens/home/home_screen.dart';
import 'package:cream_ventory/screens/onboarding/intro_screen1.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class NavigationUtils {
  static Future<void> navigateToNextScreen(BuildContext context) async {
  await Future.delayed(const Duration(seconds: 4 ));
   
  bool isLoggedIn = await AuthUtils.checkUserLoginStatus();
  debugPrint("Splash check - isLoggedIn: $isLoggedIn");

  Widget targetScreen;
    if (isLoggedIn) {
      try {
        final user = await UserDB.getCurrentUser();
        targetScreen = ScreenHome(user: user);
      } catch (e) {
        debugPrint("Error getting current user: $e");
        // Fallback to intro screen if user retrieval fails
        targetScreen = const ScreenIntro1();     
      }
    } else {
      targetScreen = const ScreenIntro1();
    }




  Navigator.of(context).pushReplacement(
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slideTween = Tween<Offset>(
        begin: Offset(1.0, 0.0), // From right to left
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOut));

      final fadeTween = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeInOut));  

      return SlideTransition(
        position: animation.drive(slideTween),
        child: FadeTransition(
          opacity: animation.drive(fadeTween),  
          child: child,
        ),
      );
    },
    transitionDuration: Duration(milliseconds: 1200),  
  ),
);

}

}      

class AuthUtils{
  static Future<bool> checkUserLoginStatus() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false ;
    return isLoggedIn;
  }
}
