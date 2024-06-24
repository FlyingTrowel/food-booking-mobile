import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // For making API requests

class RestaurantDetailsPage extends StatelessWidget {
  final int restaurantId;

  const RestaurantDetailsPage({Key? key, required this.restaurantId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurant Details'), // Placeholder title
      ),
      body: FutureBuilder<List<MenuItem>>(
        future: _fetchRestaurantMenus(restaurantId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final menuItems = snapshot.data!;
            return _buildRestaurantDetails(menuItems: menuItems, context: context);
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future<List<MenuItem>> _fetchRestaurantMenus(int restaurantId) async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/mobile/$restaurantId/menus'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final menuList = data['body'] as List;
      return menuList.map((menu) => MenuItem.fromJson(menu)).toList();

    } else {
      throw Exception('Failed to load restaurant menus');
    }
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


  Widget _buildRestaurantDetails({
    required List<MenuItem> menuItems,
    required BuildContext context,
  }) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant details fetching logic removed (assume separate API)
            if (menuItems.isNotEmpty) // Check if menu items exist
              Text('Menu:', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            if (menuItems.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final menuItem = menuItems[index];
                  return _buildMenuItemCard(menuItem, context); // Use context for navigation (optional)
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItemCard(MenuItem menuItem, BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(menuItem.name, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                Text(menuItem.description ?? 'No Description'), // Handle missing description
              ],
            ),
            Row(
              children: [
                Text('\$${menuItem.price}', style: TextStyle(fontSize: 16.0)),
                IconButton(
                  icon: Icon(Icons.add_shopping_cart),
                  onPressed: () async {
                    final token = await getAuthToken();
                    if (token == null) {
                      // Handle missing token (show login prompt?)
                      return;
                    }

                    final userId = await getUserIdFromToken(token);
                    if (userId == null) {
                      // Handle error parsing user ID from token
                      return;
                    }

                    final response = await http.get(
                      Uri.parse('http://10.0.2.2:8000/mobile/carts/add/${menuItem.id}/$userId'),
                    );
                    if (response.statusCode == 200) {
                      // Handle successful addition (limited feedback in this example)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${menuItem.name} added to cart!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } else {
                      // Handle error (limited feedback in this example)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error adding item to cart'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MenuItem {
  final int id;
  final String name;
  final String description;
  final num price;

  MenuItem.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        name = json['name'] as String,
        description = json['description'] ?? '', // Handle missing description
        price = json['price'] as num;
}

// Restaurant class remains unchanged


class Restaurant {
  final int id;
  final int userId;
  final String name;
  final String location;
  final String cuisine;
  final num? rating;
  final DateTime createdAt;
  final DateTime updatedAt;

  final List<MenuItem>? menu; // Add a menu property (nullable)

  Restaurant.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        userId = json['user_id'] as int,
        name = json['name'] as String,
        location = json['location'] as String,
        cuisine = json['cuisine'] as String,
        rating = json['rating'] as num?,
        createdAt = DateTime.parse(json['created_at'] as String),
        updatedAt = DateTime.parse(json['updated_at'] as String),
        menu = json.containsKey('menu') ? (json['menu'] as List).map((item) => MenuItem.fromJson(item)).toList() : null; // Parse menu if present

  // Getter for menu
  List<MenuItem>? get getMenu => menu;

}

// Function to retrieve token from secure storage (not shown here)
Future<String?> getAuthToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}

// Function to parse user ID from token (assuming JSON structure)
Future<int?> getUserIdFromToken(String token) async {
  final decodedToken = jsonDecode(token);
  final user = decodedToken['user']; // Assuming "user" key holds user data
  return user['id'] as int?; // Assuming "id" key holds user ID
}

