import 'package:flutter/material.dart';

class Dialogs {
  static void showSnackbar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.deepPurple.shade300.withOpacity(.8),
    ));
  }

  static void showProgressIndicator(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (_) => Center(child: CircularProgressIndicator(color: Colors.deepPurple.shade300,)),
    );
  }
}
