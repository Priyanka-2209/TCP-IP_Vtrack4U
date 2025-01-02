import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vtrack_for_you/screens/login.dart';
import 'package:vtrack_for_you/session/session_manager_login.dart';

import '../services/login_service.dart';
import '../util/snack_bar_util.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final LoginService _loginService = LoginService();


  @override
  void initState() {

    _checkSession();
    super.initState();
  }

  Future<void> _checkSession() async {
    var loginStatus = await _loginService.checkLoginStatus();
    if (loginStatus['isLoggedIn'] == true) {
      Navigator.pushReplacementNamed(context, '/tcp_connection');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
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
