import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Global_API_Var/constant.dart';
import '../util/snack_bar_util.dart';

class LoginService {

  Future<bool> loginService(
      String email, String password, BuildContext context) async {
    try {
      var dio = Dio();
      var headers = {
        'Content-Type': 'application/json',
      };
      var data = json.encode({
        "email": email,
        "password": password,
      });
      var response = await dio.request(
        '${ApiConstants.baseUrl}userlogin',
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        var responseData = response.data;
        if (responseData['success'] == true) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', responseData['data']['token']);
          await prefs.setString('email', email);
          await prefs.setString('password', password);
          await prefs.setBool('isLoggedIn', true);

          await prefs.setInt('loginTimestamp', DateTime.now().millisecondsSinceEpoch);

          SnackBarUtil.showSnackBar(
              context: context,
              message: responseData['message'],
              backgroundColor: Colors.green,);
          return true;
        } else {
          SnackBarUtil.showSnackBar(
              context: context,
              message: 'Login failed: ${responseData['message']}',);
          return false;
        }
      } else if (response.statusCode == 401) {
        var responseData = response.data;
        String errorMessage = responseData['message'] ?? 'Unauthorized Access';
        SnackBarUtil.showSnackBar(
            context: context,
            message: errorMessage,);
      } else {
        SnackBarUtil.showSnackBar(
            context: context,
            message: 'Error: ${response.statusMessage}',
            backgroundColor: Colors.red,
            durationInSeconds: 1);
      }
      return false;
    } catch (e) {
      print('Error: $e');
      SnackBarUtil.showSnackBar(
          context: context,
          message: e is DioError && e.response?.data['message'] != null
              ? e.response?.data['message']
              : 'An unexpected error occurred. Please try again.',);
      return false;
    }

  }

  Future<void> saveRememberMe(bool value, String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', value);
    if (value) {
      await prefs.setString('email', email);
      await prefs.setString('password', password);
    } else {
      await prefs.remove('email');
      await prefs.remove('password');
    }
  }

  Future<Map<String, dynamic>> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    bool rememberMe = prefs.getBool('rememberMe') ?? false;

    int? loginTimestamp = prefs.getInt('loginTimestamp');

    if (loginTimestamp != null) {
      DateTime loginDateTime = DateTime.fromMillisecondsSinceEpoch(loginTimestamp);
      DateTime currentDateTime = DateTime.now();
      Duration sessionDuration = currentDateTime.difference(loginDateTime);

      if (sessionDuration.inDays > 7) {
        await prefs.remove('isLoggedIn');
        await prefs.remove('loginTimestamp');
        return {'isLoggedIn': false};
      }
    }

    if (isLoggedIn || rememberMe) {
      return {
        'isLoggedIn': true,
        'email': prefs.getString('email') ?? '',
        'password': prefs.getString('password') ?? '',
      };
    }
    return {'isLoggedIn': false};
  }
}
