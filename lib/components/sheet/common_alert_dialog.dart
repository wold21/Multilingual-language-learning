import 'package:flutter/material.dart';

class CommonAlertDialog {
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'OK',
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).textTheme.titleMedium?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text(
                confirmText,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
