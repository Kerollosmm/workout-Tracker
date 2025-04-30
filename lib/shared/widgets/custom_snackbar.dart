import 'package:flutter/material.dart';

class CustomSnackbar {
  static SnackBar success({required String message}) => SnackBar(
    backgroundColor: Colors.green.shade800,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    content: Row(
      children: [
        Icon(Icons.check_circle, color: Colors.white),
        SizedBox(width: 12),
        Expanded(child: Text(message)),
      ],
    ),
  );

  static SnackBar error({required String message}) => SnackBar(
    backgroundColor: Colors.red.shade800,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    content: Row(
      children: [
        Icon(Icons.error_outline, color: Colors.white),
        SizedBox(width: 12),
        Expanded(child: Text(message)),
      ],
    ),
  );
}
