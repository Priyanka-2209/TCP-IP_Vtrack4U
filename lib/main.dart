import 'package:flutter/material.dart';
import 'package:vtrack_for_you/screens/login.dart';
import 'package:vtrack_for_you/screens/splash_screen.dart';

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


