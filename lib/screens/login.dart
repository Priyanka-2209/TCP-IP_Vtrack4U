import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vtrack_for_you/screens/dashboard.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  var focusNodeEmail = FocusNode();
  var focusNodePassword = FocusNode();

  bool isFocusedEmail = false;
  bool isFocusedPassword = false;

  String emailError = '';
  String passwordError = '';

  bool btnEnable = false;
  bool _isObscured = true;
  bool? _isChecked = false;

  String email = '';
  String password = '';

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _checkLoginStatus();

    focusNodeEmail.addListener(() {
      setState(() {
        isFocusedEmail = focusNodeEmail.hasFocus;
        if (!isFocusedEmail && emailController.text.trim().isEmpty) {
          emailError = 'Please Enter Email Address.';
        } else {
          emailError = '';
        }
      });
    });

    focusNodePassword.addListener(() {
      setState(() {
        isFocusedPassword = focusNodePassword.hasFocus;
        if (!isFocusedPassword && passwordController.text.trim().isEmpty) {
          passwordError = 'Please Enter Password.';
        } else {
          passwordError = '';
        }
        btnEnable = passwordController.text.length >= 6;
      });
    });

    emailController.addListener(() {
      if (emailError.isNotEmpty && emailController.text.trim().isNotEmpty) {
        setState(() {
          emailError = '';
        });
      }
    });

    passwordController.addListener(() {
      if (passwordError.isNotEmpty &&
          passwordController.text.trim().isNotEmpty) {
        setState(() {
          passwordError = '';
        });
      }
    });
  }

  Future<void> loginUser() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

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
        'https://absolutewebservices.in/vtrack4utcpip/api/userlogin',
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

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Dashboard()),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                responseData['message'],
                style: TextStyle(color: Colors.white),
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                  'Login failed: ${responseData['message']}',
                  style: TextStyle(color: Colors.white),
                ),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.red,
                duration: Duration(seconds: 1)),
          );
        }
      }
      else if (response.statusCode == 401) {
        var responseData = response.data;
        String errorMessage = responseData['message'] ?? 'Unauthorized Access';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: TextStyle(color: Colors.white),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                'Error: ${response.statusMessage}',
                style: TextStyle(color: Colors.white),
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
              duration: Duration(seconds: 1)),
        );
      }
    }
    catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
              'You have entered wrong credentials.',
              style: TextStyle(color: Colors.white),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            duration: Duration(seconds: 1)),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    bool rememberMe = prefs.getBool('rememberMe') ?? false;

    if (isLoggedIn && rememberMe) {
      String savedEmail = prefs.getString('email') ?? '';
      String savedPassword = prefs.getString('password') ?? '';

      emailController.text = savedEmail;
      passwordController.text = savedPassword;

      _isChecked = true;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Dashboard()));
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.sizeOf(context).height;
    var screenWidth = MediaQuery.sizeOf(context).width;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF123456),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: screenHeight * 0.13,
        backgroundColor: const Color(0xFF123456),
        title: Container(
          alignment: Alignment.bottomLeft,
          width: double.infinity,
          child: const Text(
            'Sign In',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        padding: EdgeInsets.only(
            left: 20.0,
            right: 20,
            top: screenHeight * 0.03,
            bottom: screenHeight * 0.03),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  'Welcome',
                  style: TextStyle(
                      color: Color(0xFF123456),
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: screenHeight * 0.01,
                ),
                const Text(
                  'To keep connected with us please login with your personal info',
                  style: TextStyle(color: Color(0xFF123456), fontSize: 14),
                ),
                SizedBox(
                  height: screenHeight * 0.02,
                ),
                _buildTextField(
                  controller: emailController,
                  isFocused: isFocusedEmail,
                  errorText: emailError,
                  labelText: 'Email Address',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  focusNode: focusNodeEmail,
                ),
                SizedBox(
                  height: screenHeight * 0.02,
                ),
                _buildTextField(
                  controller: passwordController,
                  isFocused: isFocusedPassword,
                  errorText: passwordError,
                  labelText: 'Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _isObscured,
                  toggleObscureText: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  focusNode: focusNodePassword,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Transform.scale(
                          child: Checkbox(
                            tristate: false,
                            value: _isChecked,
                            onChanged: (bool? newValue) async {
                              setState(() {
                                _isChecked = newValue;
                              });
                            },
                            activeColor: const Color(0xFF123456),
                            checkColor: Colors.white,
                          ),
                          scale: 1,
                        ),
                        SizedBox(width: screenWidth * 0.002),
                        const Text(
                          'Remember me?',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF123456),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              width: screenWidth * 0.95,
              height: screenHeight * 0.06,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF123456)),
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (emailController.text.trim().isEmpty) {
                          setState(() {
                            emailError = 'Email Address cannot be empty';
                          });
                        }
                        if (passwordController.text.trim().isEmpty) {
                          setState(() {
                            passwordError = 'Password cannot be empty';
                          });
                        }
                        if (emailError.isEmpty && passwordError.isEmpty) {
                          setState(() {
                            _isLoading = true;
                          });

                          await Future.delayed(Duration(seconds: 2));

                          loginUser();
                        } else {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      },
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        backgroundColor: Color(0xFF123456),
                      )
                    : const Text(
                        'Sign In',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    String? errorText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    void Function()? toggleObscureText,
    required bool isFocused,
    required FocusNode focusNode,
    required TextInputAction textInputAction,
  }) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: screenWidth * 0.95,
          height: screenHeight * 0.06,
          decoration: BoxDecoration(
            color: isFocused ? Colors.white : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              if (errorText != null && errorText.isNotEmpty)
                BoxShadow(
                  color: Colors.red,
                  blurRadius: 1.0,
                  spreadRadius: 0.5,
                ),
              if (isFocused && (errorText == null || errorText.isEmpty))
                BoxShadow(
                  color: const Color(0xFF123456).withOpacity(1.0),
                  blurRadius: 1.0,
                  spreadRadius: 0.5,
                ),
            ],
          ),
          child: TextField(
            textAlignVertical: TextAlignVertical.center,
            style: const TextStyle(fontSize: 14),
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            obscureText: obscureText,
            decoration: InputDecoration(
              prefixIcon: Icon(prefixIcon),
              suffixIcon: toggleObscureText != null
                  ? GestureDetector(
                      onTap: toggleObscureText,
                      child: Icon(obscureText
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                    )
                  : null,
              border: InputBorder.none,
              labelText: labelText,
              labelStyle: const TextStyle(color: Colors.grey),
            ),
          ),
        ),
        if (errorText != null && errorText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 8.0),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}