import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CartItem {
  final int id;
  final String name;
  final String description;
  final num price;
  final int quantity;

  CartItem.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        name = json['name'] as String,
        description = json['description'] ?? '',
        price = json['price'] as num,
        quantity = json['quantity'] as int;
}

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Future<List<CartItem>>? _cartItems;

  @override
  void initState() {
    super.initState();
    _cartItems = _fetchCartItems();
  }


  Future<List<CartItem>> _fetchCartItems() async {
    final token = await getAuthToken();
    if (token == null) {
      // Handle missing token (show login prompt?)
      return []; // Empty list on missing token
    }

    final userId = await getUserIdFromToken(token);
    if (userId == null) {
      // Handle error parsing user ID from token
      return []; // Empty list on missing user ID
    }

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/mobile/carts/$userId'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final cartList = data['body'] as List;
      return cartList.map((cartItem) => CartItem.fromJson(cartItem)).toList();
    } else {
      // Handle error fetching cart items
      return []; // Empty list on error
    }
  }

  Future<void> _onCheckout() async {
    final token = await getAuthToken();
    if (token == null) {
      // Handle missing token (show login prompt?)
      return; // Empty list on missing token
    }

    final userId = await getUserIdFromToken(token);
    if (userId == null) {
      // Handle error parsing user ID from token
      return; // Empty list on missing user ID
    }

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/mobile/carts/checkout/$userId'),
    );
    if (response.statusCode == 200) {
      // Handle successful checkout (clear cart or show confirmation)
      _cartItems = _fetchCartItems(); // Refresh cart data after checkout
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Checkout successful!'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context); // Pop back to previous page
    } else {
      // Handle error during checkout
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during checkout'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: FutureBuilder<List<CartItem>>(
        future: _cartItems,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final cartItems = snapshot.data!;
            if (cartItems.isEmpty) {
              return Center(child: Text('Your cart is empty'));
            }
            return ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final cartItem = cartItems[index];
                return _buildCartItemCard(cartItem);
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(10.0),
        child: ElevatedButton(
          onPressed: _onCheckout,
          child: Text('Checkout'),
        ),
      ),
    );
  }

  Widget _buildCartItemCard(CartItem cartItem) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.name,
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                Text(cartItem.description ?? 'No Description'),
                // Handle missing description
              ],
            ),
            Row(
              children: [
                Text(
                  '\$${(cartItem.price * cartItem.quantity).toStringAsFixed(
                      2)}',
                  style: TextStyle(fontSize: 16.0),
                ),
                Text(' (x${cartItem.quantity})',
                    style: TextStyle(fontSize: 14.0)),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<int?> getUserIdFromToken(String token) async {
    final decodedToken = jsonDecode(token);
    final user = decodedToken['user']; // Assuming "user" key holds user data
    return user['id'] as int?; // Assuming "id" key holds user ID
  }
}

