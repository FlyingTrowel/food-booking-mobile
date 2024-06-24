import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _password = '';
  String _email = ''; // Optional

  Future<void> registerUser(String name, String password, String email) async {
    final url = Uri.parse('http://10.0.2.2:8000/mobile/register'); // Replace with your actual API URL
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'password': password,
        'email': email, // Optional
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Handle successful registration (show success message, navigate)
      print('Registration successful!');
      // ... (Implement success handling)
    } else {
      // Handle error (display error message)
      print('Registration failed: ${response.body}');
      // ... (Show error message to user)
    }
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
                    return 'Please enter a username';
                  }
                  return null;
                },
                onSaved: (value) => setState(() => _name = value!),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email (Optional)'),
                keyboardType: TextInputType.emailAddress,
                onSaved: (value) => setState(() => _email = value!),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
                onSaved: (value) => setState(() => _password = value!),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    registerUser(_name, _password, _email);
                  }
                },
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
