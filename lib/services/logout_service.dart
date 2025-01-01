import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Global_API_Var/constant.dart';
import '../util/snack_bar_util.dart';

class UserLogOutService {
  final Dio dio = Dio();

  Future<void> logout_user(String token, BuildContext context) async {
    var headers = {
      'Authorization': 'Bearer $token',
      'Cookie': 'vtrack4u_tcp_ip_session=$token',
    };

    try {
      var response = await dio.post(
        '${ApiConstants.baseUrl}userlogout',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        print(response);
        var responseData = response.data;
        if (responseData['success'] == true) {
          SnackBarUtil.showSnackBar(
            context: context,
            message: responseData['message'],
            backgroundColor: Colors.green,);
        }
      } else {
        print('Error: ${response.statusMessage}');
        return null;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }
}
