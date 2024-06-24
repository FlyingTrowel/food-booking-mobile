import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For making API requests (testing)
import 'package:mobile_grabfood/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../navigation_service.dart'; // Import navigation service

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _password = '';

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Simulate API call for registration (replace with actual API call)
      final response = await http.post(Uri.parse('http://10.0.2.2:8000/mobile/register'), body: {
        'name': _name,
        'email': _email,
        'password': _password,
      });

      if (response.statusCode == 201) {
        // Handle successful registration (store token and navigate)
        final token = response.body; // Replace with actual token extraction
        _storeToken(token);
        NavigationService.instance.push(LoginPage()); // Navigate to login
      } else {
        // Handle registration error (show error message)
        print('Registration failed: ${response.body}');
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
        title: Text('Registration'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
                onSaved: (value) => setState(() => _name = value!),
              ),
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
                onPressed: _register,
                child: Text('Register'),
              ),
              TextButton(
                onPressed: () => NavigationService.instance.goBack(), // Go back to login
                child: Text('Already have an account? Login Here'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
