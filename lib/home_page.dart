import 'package:flutter/material.dart';
import 'package:mobile_grabfood/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import for navigation (replace with your implementation)
import '../navigation_service.dart'; // Assuming NavigationService

class HomePage extends StatelessWidget {
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    // Implement logic to navigate back to login or another screen
    NavigationService.instance.push(LoginPage()); // Assuming login route
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              // Handle cart button press (navigate to cart page if needed)
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to the Home Page!'),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Orders'),
        ],
        currentIndex: 0, // Set initial selected index (optional)
        onTap: (index) {
          // Handle navigation based on selected index
          if (index == 1) {
            // Navigate to orders page (replace with your implementation)
            NavigationService.instance.push(HomePage()); // Assuming orders route
          }
        },
      ),
    );
  }
}
