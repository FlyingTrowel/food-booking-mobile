import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderItem {
  final int id;
  final String name;
  final String description;
  final num price;
  final int quantity;

  OrderItem.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        name = json['name'] as String,
        description = json['description'] ?? '',
        price = json['price'] as num,
        quantity = json['quantity'] as int;
}

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  Future<List<OrderItem>>? _orderItems;

  @override
  void initState() {
    super.initState();
    _orderItems = _fetchOrderItems();
  }


  Future<List<OrderItem>> _fetchOrderItems() async {
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
      Uri.parse('http://10.0.2.2:8000/mobile/orders/$userId'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final orderList = data['body'] as List;
      return orderList.map((orderItem) => OrderItem.fromJson(orderItem)).toList();
    } else {
      // Handle error fetching cart items
      return []; // Empty list on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
      ),
      body: FutureBuilder<List<OrderItem>>(
        future: _orderItems,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final orderItems = snapshot.data!;
            if (orderItems.isEmpty) {
              return Center(child: Text('Your orders is empty'));
            }
            return ListView.builder(
              itemCount: orderItems.length,
              itemBuilder: (context, index) {
                final orderItem = orderItems[index];
                return _buildOrderItemCard(orderItem);
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildOrderItemCard(OrderItem orderItem) {
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
                  orderItem.name,
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                Text(orderItem.description ?? 'No Description'),
                // Handle missing description
              ],
            ),
            Row(
              children: [
                Text(
                  '\$${(orderItem.price * orderItem.quantity).toStringAsFixed(
                      2)}',
                  style: TextStyle(fontSize: 16.0),
                ),
                Text(' (x${orderItem.quantity})',
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

