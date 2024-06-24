import 'package:flutter/material.dart';

class NavigationService {
  static final NavigationService instance = NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  factory NavigationService() {
    return instance;
  }

  NavigationService._internal();

  void push(Widget page) {
    navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => page));
  }

  void goBack() => navigatorKey.currentState!.pop();
}
