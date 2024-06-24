import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For making API requests (testing)
import 'package:mobile_grabfood/registration_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../navigation_service.dart';
import 'home_page.dart'; // Import navigation service

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  Future<void> _checkTokenAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      // Token exists, navigate to home
      NavigationService.instance.push(HomePage());
    } else {
      // No token, proceed with login
      _login();
    }
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Simulate API call for login (replace with actual API call)
      final response = await http.post(Uri.parse('http://10.0.2.2:8000/mobile/login'), body: {
        'email': _email,
        'password': _password,
      });

      if (response.statusCode == 200) {
        // Handle successful login (store token and navigate)
        final token = response.body; // Replace with actual token extraction
        _storeToken(token);
        NavigationService.instance.push(HomePage());
      } else {
        // Handle login error (show error message)
        print('Login failed: ${response.body}');
        // ... (Show error message to user)
      }
    }
  }

  void _storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
                onSaved: (value) => setState(() => _email = value!),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                onSaved: (value) => setState(() => _password = value!),
              ),
              ElevatedButton(
                onPressed: _checkTokenAndNavigate,
                child: Text('Login'),
              ),
              TextButton(
                onPressed: () => NavigationService.instance.push(RegistrationPage()), // Navigate to registration
                child: Text('Don\'t have an account? Register Here'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
