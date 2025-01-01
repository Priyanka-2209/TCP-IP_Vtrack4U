import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Global_API_Var/constant.dart';
import '../util/snack_bar_util.dart';

class TransactionUpdateService {
  Future<String> transactionUpdate(int id, String status,
      BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    print('Status: $status');
    if (token.isEmpty) {
      SnackBarUtil.showSnackBar(
        context: context,
        message: 'Authentication token not found. Please login again.',
      );
      throw Exception('Authentication token not found. Please login again.');
    }

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var data = {"status": status};
    print("Data: $data");

    var dio = Dio();
    final String url =
        '${ApiConstants.baseUrl}tcptransactionsupdatebyid/$id';

    try {
      var response = await dio.post(
        url, options: Options(headers: headers,), data: data,);

      if(response.statusCode == 200) {
        String successMessage = response.data['message'];
        print('Transaction Update Response: ${response.data}');
        return successMessage;
      } else {
        throw Exception( 'Failed to update transaction. Please try again.',);
      }
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }
}