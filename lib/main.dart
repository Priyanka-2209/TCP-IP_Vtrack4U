import 'package:flutter/material.dart';
import 'package:vtrack_for_you/screens/dashboard.dart';
import 'package:vtrack_for_you/screens/login.dart';
import 'package:vtrack_for_you/screens/splash_screen.dart';
import 'package:vtrack_for_you/screens/update_profile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/' : (context) => SplashScreen(),
        '/login' : (context) => Login(),
        '/dashboard' : (context) => Dashboard(),
        '/update_profile' : (context) => UpdateProfile(),
      },
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor:  Color(0xFF123456)),
        useMaterial3: true,
      ),
    );
  }
}

