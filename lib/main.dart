import 'package:cream_ventory/core/notification/notification_setup.dart';
import 'package:cream_ventory/database/hive_initialization.dart';
import 'package:cream_ventory/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await HiveInitialization.initialize(); 
  
  runApp(const MyApp());
}
 
class MyApp extends StatelessWidget { 
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        home: const ScreenSplash(),
      ),
    );
  }  
}  