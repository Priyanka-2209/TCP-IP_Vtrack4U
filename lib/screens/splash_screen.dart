import 'package:flutter/material.dart';
import 'package:vtrack_for_you/screens/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    _login();
    super.initState();
  }

  _login() async {
    await Future.delayed(Duration(milliseconds: 2000), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Login()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Container(
            child: Image.asset(
              'assets/images/splash_image.png',
              fit: BoxFit.cover,
            ),
            height: 150,
            width: 150,
          ),
        ),
      ),
    );
  }
}
