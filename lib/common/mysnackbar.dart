import 'package:flutter/material.dart';

class MySnackBar {
  static void show(
    BuildContext context, {
    required String message,
    Color background = Colors.blue,
    Color textColor = Colors.white,
    int durationSeconds = 2,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor, fontSize: 16),
        ),
        backgroundColor: background,
        duration: Duration(seconds: durationSeconds),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
