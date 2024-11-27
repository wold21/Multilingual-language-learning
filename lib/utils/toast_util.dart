import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class ToastUtils {
  static void show({
    required String message,
    ToastType type = ToastType.success,
    Duration duration = const Duration(seconds: 2),
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP, // 상단에 표시
      backgroundColor: _getBackgroundColor(type),
      textColor: Colors.white,
      fontSize: 16.0,
      timeInSecForIosWeb: duration.inSeconds,
    );
  }

  static Color _getBackgroundColor(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Colors.green.shade800;
      case ToastType.error:
        return Colors.red.shade800;
      case ToastType.info:
        return Colors.blue.shade800;
    }
  }
}

enum ToastType {
  success,
  error,
  info,
}
