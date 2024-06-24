import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For storing token

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _token = ''; // Variable to store token (initially empty)

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('token');
    setState(() {
      _token = storedToken ?? ''; // Set token from SharedPreferences or empty string
    });
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Check login status on initialization
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to the Home Page!'),
            if (_token.isNotEmpty) Text('Token: $_token'), // Display token if available
            ElevatedButton(
              onPressed: () async {
                // Simulate logout (remove token from SharedPreferences)
                final prefs = await SharedPreferences.getInstance();
                prefs.remove('token');
                setState(() {
                  _token = ''; // Clear token state
                });
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
