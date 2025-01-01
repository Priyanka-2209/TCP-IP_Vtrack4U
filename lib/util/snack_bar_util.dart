import 'package:flutter/material.dart';

class SnackBarUtil {
  static void showSnackBar({
    required BuildContext context,
    required String message,
    Color backgroundColor = Colors.red,
    int durationInSeconds = 2,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: durationInSeconds),
      ),
    );
  }
}
