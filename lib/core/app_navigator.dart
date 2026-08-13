import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

var _currentRoute = "/";
String get currentRoute => _currentRoute;
void resetCurrentRoute() {
  _currentRoute = "/";
}

extension AppNavigator on BuildContext {
  void goSafe(String location, {Object? extra}) {
    _currentRoute = location;
    go(location, extra: extra);
  }
}
