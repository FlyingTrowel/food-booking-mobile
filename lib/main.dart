import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'navigation_service.dart'; // Add navigation service
import 'registration_page.dart';
import 'login_page.dart';
import 'home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigationService.instance.navigatorKey, // Provide navigator key
      home: LoginPage(), // Replace with your initial page
    );
  }
}

