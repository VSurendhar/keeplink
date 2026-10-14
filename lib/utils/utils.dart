import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Utils {
  static void showToast(
    String msg, {
    double fontSize = 14.0,
    Toast toastLength = Toast.LENGTH_SHORT,
    ToastGravity gravity = ToastGravity.BOTTOM,
  }) {
    Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: msg,
      backgroundColor: Colors.black.withValues(alpha: 0.7),
      textColor: Colors.white,
      fontSize: fontSize,
      toastLength: toastLength,
      gravity: gravity,
    );
    return;
  }
}
