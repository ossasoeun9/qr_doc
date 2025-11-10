import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_doc/core/utils.dart';

import '../collection/user_collection.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formState = GlobalKey<FormState>();
  final _usernameCtr = TextEditingController();
  final _passwordCtr = TextEditingController();

  bool _isLoading = false;

  void _login() async {
    if (_isLoading) return;
    bool isValid = _formState.currentState?.validate() ?? false;
    if (isValid) {
      setState(() {
        _isLoading = true;
      });
      try {
        var user = await UserCollection().login(
          _usernameCtr.text,
          _passwordCtr.text,
        );
        setState(() {
          _isLoading = false;
        });
        if (user == null) {
          _showError("Username or password is incorrect");
          return;
        }
        await LoginManager.saveLogin();
        await user.saveToStorage();
        _goToHome();
      } catch (e) {
        debugPrint(e.toString());
        setState(() {
          _isLoading = false;
        });
        _showError();
      }
    }
  }

  void _showError([String? message]) {
    context.showErrorMessage(message);
  }

  void _goToHome() {
    context.go("/");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 18),
          constraints: BoxConstraints(maxWidth: 500),
          child: Form(
            key: _formState,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/logo_cir.png",
                  height: 100,
                  width: 100,
                ),
                Text(
                  "Welcome to QR DOC",
                  style: context.textTheme.titleLarge?.copyWith(
                    color: context.colorScheme.primary,
                  ),
                ),
                Text(
                  "Please, enter username and password to login",
                  style: TextStyle(color: context.colorScheme.secondary),
                ),
                const SizedBox(height: 100),
                TextFormField(
                  controller: _usernameCtr,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (str) {
                    if (str?.isNotEmpty != true) {
                      return "Please, enter password";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _passwordCtr,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (str) {
                    if (str?.isNotEmpty != true) {
                      return "Please, enter password";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: FilledButton(
                    onPressed: _login,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isLoading) ...{
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: context.colorScheme.onPrimary,
                              strokeWidth: 3,
                            ),
                          ),
                          const SizedBox(width: 10),
                        } else
                          const SizedBox(width: 30),
                        const Text("Log In"),
                        const SizedBox(width: 30),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 200),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
