import 'package:flutter/material.dart';

import '../main.dart';

extension ContextExt on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  void showErrorMessage([String? message]) {
    showDialog(
      context: this,
      builder: (context) => AlertDialog(
        title: Text("Message"),
        content: Text(message ?? "Something when wrong"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Ok"),
          ),
        ],
      ),
    );
  }
}

class LoginManager {
  LoginManager._();
  static Future<bool> saveLogin() => storagePref.setBool("isLoggedIn", true);
  static bool get isLoggedIn => storagePref.getBool("isLoggedIn") ?? false;
  static Future<bool> removeLogin() => storagePref.remove("isLoggedIn");
}

void showLoadingDialog(BuildContext context, {String text = "Loading..."}) {
  showDialog(
    context: context,
    barrierDismissible: false, // user cannot dismiss by tapping outside
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(text, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    },
  );
}

void hideLoadingDialog(BuildContext context) {
  Navigator.of(context, rootNavigator: true).pop();
}
