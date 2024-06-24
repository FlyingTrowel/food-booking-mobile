import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For making API requests (testing)
import 'registration_page.dart'; // Import your registration page
import 'login_page.dart'; // Import the login page

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0; // Index for handling current screen (0: Registration, 1: Login)
  final List<Widget> _pages = [RegistrationPage(), LoginPage()]; // List of pages

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registration & Login App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('App Name'),
        ),
        body: _pages[_currentIndex], // Display the current page based on index
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.app_registration), label: 'Register'),
            BottomNavigationBarItem(icon: Icon(Icons.login), label: 'Login'),
          ],
        ),
      ),
    );
  }
}

