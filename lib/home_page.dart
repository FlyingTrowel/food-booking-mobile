import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For making API requests
import 'package:mobile_grabfood/login_page.dart'; // Assuming login page route
import 'package:mobile_grabfood/order_page.dart';
import 'package:mobile_grabfood/restaurant_details_page.dart'; // Assuming restaurant details page route
import 'package:shared_preferences/shared_preferences.dart';

import 'cart_page.dart';
import 'navigation_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Restaurant>>? _restaurants;

  @override
  void initState() {
    super.initState();
    _restaurants = _fetchRestaurants();
  }

  Future<List<Restaurant>> _fetchRestaurants() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/mobile/restaurants'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final restaurantList = data['body'] as List;
      return restaurantList.map((restaurant) => Restaurant.fromJson(restaurant)).toList();
    } else {
      throw Exception('Failed to load restaurants');
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    // Implement logic to navigate back to login or another screen
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CartPage()),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Restaurant>>(
        future: _restaurants,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final restaurants = snapshot.data!;
            return ListView.builder(
              itemCount: restaurants.length,
              itemBuilder: (context, index) {
                final restaurant = restaurants[index];
                return InkWell(
                  onTap: () {
                    // Navigate to restaurant details page with ID
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RestaurantDetailsPage(restaurantId: restaurant.id),
                      ),
                    );
                  },
                  child: _buildRestaurantCard(restaurant),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Orders'),
        ],
        currentIndex: 0, // Set initial selected index (optional)
        onTap: (index) {
          // Handle navigation based on selected index
          if (index == 0) {
            // Navigate to orders page (replace with your implementation)
            NavigationService.instance.push(HomePage()); // Assuming orders route
          } else  if (index == 1) {
            // Navigate to orders page (replace with your implementation)
            NavigationService.instance.push(OrderPage()); // Assuming orders route
          }
        },
      ),
    );
  }

  Widget _buildRestaurantCard(Restaurant restaurant) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(restaurant.name, style: TextStyle(fontWeight: FontWeight.bold)),
            Text(restaurant.location),
            Text(restaurant.cuisine),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber),
                Text(restaurant.rating?.toString() ?? 'No Rating'), // Use null-ish coalescing operator (??)
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Restaurant {
  final int id;
  final int userId;
  final String name;
  final String location;
  final String cuisine;
  final num? rating;
  final DateTime createdAt;
  final DateTime updatedAt;

  Restaurant.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        userId = json['user_id'] as int,
        name = json['name'] as String,
        location = json['location'] as String,
        cuisine = json['cuisine'] as String,
        rating = json['rating'] as num?,
        createdAt = DateTime.parse(json['created_at'] as String),
        updatedAt = DateTime.parse(json['updated_at'] as String);
}
