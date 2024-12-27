import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vtrack_for_you/screens/login.dart';
import 'package:vtrack_for_you/services/change_password_service.dart';

import '../custom_feild/CustomTextFeild.dart';
import '../modal/fetch_user_data_modal.dart';
import '../services/user_service.dart';

class ChangePassword extends StatefulWidget {
  ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  late UserService _userService;
  FetchUserDataModal? _userData;

  final TextEditingController _oldPassword = TextEditingController();
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _cnfmPassword = TextEditingController();

  var focusNodeOldPassword = FocusNode();
  var focusNodeNewPassword = FocusNode();
  var focusNodeCnfmPassword = FocusNode();

  bool isFocusedOldPassword = false;
  bool isFocusedNewPassword = false;
  bool isFocusedCnfmPassword = false;

  bool isEmptyOldPassword = false;
  bool isEmptyNewPassword = false;
  bool isEmptyCnfmPassword = false;

  bool isnewpasswordvalid = true;
  bool oldpasswordVisible = false;
  bool newpasswordVisible = false;
  bool cnfmpasswordVisible = false;

  @override
  void initState() {
    oldpasswordVisible = true;
    newpasswordVisible = true;
    cnfmpasswordVisible = true;

    focusNodeOldPassword.addListener(() {
      setState(() {
        isFocusedOldPassword = focusNodeOldPassword.hasFocus;
        if (!isFocusedOldPassword) {
          isEmptyOldPassword = _oldPassword.text.trim().isEmpty;
        }
      });
    });

    focusNodeNewPassword.addListener(() {
      setState(() {
        isFocusedNewPassword = focusNodeNewPassword.hasFocus;
        if (!isFocusedNewPassword) {
          isEmptyNewPassword = _newPassword.text.trim().isEmpty;
        }
      });
    });

    focusNodeCnfmPassword.addListener(() {
      setState(() {
        isFocusedCnfmPassword = focusNodeCnfmPassword.hasFocus;
        if (!isFocusedCnfmPassword) {
          isEmptyCnfmPassword = _cnfmPassword.text.trim().isEmpty;
        }
      });
    });
    _userService = UserService();
    _fetchUserData();
    super.initState();
  }

  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    if (token.isNotEmpty) {
      FetchUserDataModal? fetchedData = await _userService.getUserInfo(token);
      setState(() {
        _userData = fetchedData;
      });
      if (_userData != null) {
        print("User Data: $_userData");
      }
    } else {
      print("Token is missing.");
    }
  }

  @override
  void dispose() {
    _oldPassword.dispose();
    _newPassword.dispose();
    _cnfmPassword.dispose();
    focusNodeNewPassword.dispose();
    focusNodeCnfmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    var screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: const Color(0xFF123456),
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: screenHeight * 0.13,
              backgroundColor: const Color(0xFF123456),
              leading: IconButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/dashboard', (route) => false);
                  },
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  )),
              title: Container(
                alignment: Alignment.bottomLeft,
                width: double.infinity,
                child: const Text(
                  'Change Password',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.0,
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        'Old Password',
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: CustomTextField(
                        hintText: 'Old Password',
                        isFocused: isFocusedOldPassword,
                        isEmpty: isEmptyOldPassword,
                        controller: _oldPassword,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        isDarkMode: isDarkMode,
                        onChanged: (value) {
                          setState(() {
                            isEmptyOldPassword = value.trim().isEmpty;
                          });
                        },
                        focusNode: focusNodeOldPassword,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        'New Password',
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: CustomTextField(
                        hintText: 'New Password',
                        isFocused: isFocusedNewPassword,
                        isEmpty: isEmptyNewPassword,
                        controller: _newPassword,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        isDarkMode: isDarkMode,
                        onChanged: (value) {
                          setState(() {
                            isEmptyNewPassword = value.trim().isEmpty;
                          });
                        },
                        focusNode: focusNodeNewPassword,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        'Confirm Password',
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: CustomTextField(
                        hintText: 'Confirm Password',
                        isFocused: isFocusedCnfmPassword,
                        isEmpty: isEmptyCnfmPassword,
                        controller: _cnfmPassword,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        isDarkMode: isDarkMode,
                        onChanged: (value) {
                          setState(() {
                            isEmptyCnfmPassword = value.trim().isEmpty;
                          });
                        },
                        focusNode: focusNodeCnfmPassword,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: screenHeight * 0.02),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              isnewpasswordvalid = true;
                            });

                            if (_newPassword.text.trim().isEmpty ||
                                _cnfmPassword.text.trim().isEmpty) {
                              setState(() {
                                isEmptyNewPassword =
                                    _newPassword.text.trim().isEmpty;
                                isEmptyCnfmPassword =
                                    _cnfmPassword.text.trim().isEmpty;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  content: Text('Fields are empty'),
                                ),
                              );
                            } else if (_newPassword.text.length < 4) {
                              setState(() {
                                isnewpasswordvalid =
                                    false; // Update validation state
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  content: Text(
                                      'Password must be at least 4 characters.'),
                                ),
                              );
                            } else if (_newPassword.text !=
                                _cnfmPassword.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  content: Text(
                                      'New password & confirm password do not match.'),
                                ),
                              );
                            } else {
                              updatePassword();
                            }
                          },
                          child: Text(
                            'Submit',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF123456),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> updatePassword() async {
    var dio = Dio();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final password = prefs.getString('password') ?? '';
    final url =
        'https://absolutewebservices.in/vtrack4utcpip/api/changepassword/${_userData?.id}';

    if (password != _oldPassword.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Old Password is incorrect',
          style: TextStyle(color: Colors.white),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
      ));
    } else {
      print('URL: $url');
      print('Password: $password');

      try {
        showLoadingIndicator(context);

        final response = await dio.post(
          url,
          data: {
            'password': _oldPassword.text.trim(),
            'new_password': _newPassword.text.trim(),
            're_new_password': _cnfmPassword.text.trim(),
          },
          options: Options(
            validateStatus: (status) => status != null && status < 500,
            headers: {
              'Authorization': 'Bearer $token',
              'Cookie': 'vtrack4u_tcp_ip_session=$token',
            },
          ),
        );

        print('Data: ${response.data}');
        hideLoadingIndicator();

        if (response.statusCode == 200) {
          showSnackBar(
              context, 'User Password updated successfully!', Colors.green);
          await prefs.clear();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Login()),
            (route) => false,
          );
        } else {
          final errorMessage =
              response.data['message'] ?? 'Failed to update user Password';
          showSnackBar(context, errorMessage, Colors.red);
        }
      } on DioError catch (e) {
        hideLoadingIndicator();
        showSnackBar(context, 'Error: ${e.message}', Colors.red);
      } catch (e) {
        hideLoadingIndicator();
        showSnackBar(context, 'An unexpected error occurred: $e', Colors.red);
      }
    }
  }

  void showSnackBar(
      BuildContext context, String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          content: Text(message)),
    );
  }

  void showLoadingIndicator(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
  }

  void hideLoadingIndicator() {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
