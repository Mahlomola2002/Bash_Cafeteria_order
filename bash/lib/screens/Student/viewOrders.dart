import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Models
class Order {
  final String id;
  final String userId;
  final String status;
  final String? customer_name; // Make this nullable
  final double total;
  final DateTime timestamp;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.userId,
    required this.status,
    this.customer_name, // No need for 'required' since it's now nullable
    required this.total,
    required this.timestamp,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['userId'],
      status: json['status'],
      customer_name: json['customer_name'], // Change to customerName
      total: json['total'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
    );
  }
}

class OrderItem {
  final String name;
  final int quantity;

  OrderItem({required this.name, required this.quantity});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['name'],
      quantity: json['quantity'],
    );
  }
}

class ViewOrder extends StatefulWidget {
  const ViewOrder({Key? key}) : super(key: key);

  @override
  _ViewOrderState createState() => _ViewOrderState();
}

class _ViewOrderState extends State<ViewOrder> {
  String _selectedFilter = 'all';
  List<Order> _orders = []; // Changed type from List<Map<String, dynamic>>
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final String userId = await _getCurrentUserId();

      // Update the URL to include the user ID
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/View_orders/$userId'),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> ordersData = json.decode(response.body);
        setState(() {
          _orders = ordersData.map((data) {
            try {
              return Order.fromJson(data);
            } catch (e) {
              print('Error parsing order data: $data');
              print('Error details: $e');
              rethrow;
            }
          }).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching orders: $error');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load orders: $error';
      });
    }
  }

  Future<String> _getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text('Error: $_errorMessage'))
                    : _orders.isEmpty
                        ? const Center(child: Text('No orders found'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: _orders.length,
                            itemBuilder: (context, index) {
                              return _buildOrderCard(_orders[index]);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FilterChip(
            label: const Text('All'),
            selected: _selectedFilter == 'all',
            onSelected: (selected) {
              setState(() {
                _selectedFilter = 'all';
                _fetchOrders();
              });
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Pending'),
            selected: _selectedFilter == 'pending',
            onSelected: (selected) {
              setState(() {
                _selectedFilter = 'pending';
                _fetchOrders();
              });
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Completed'),
            selected: _selectedFilter == 'completed',
            onSelected: (selected) {
              setState(() {
                _selectedFilter = 'completed';
                _fetchOrders();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ExpansionTile(
        title: Text('Order #${order.id}'),
        subtitle: Text(
          'Status: ${order.status}',
          style: TextStyle(
            color: order.status == 'completed' ? Colors.green : Colors.orange,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Customer: ${order.customer_name}'),
                const SizedBox(height: 8),
                Text('Total: \$${order.total.toStringAsFixed(2)}'),
                const SizedBox(height: 8),
                Text('Date: ${order.timestamp.toString()}'),
                const SizedBox(height: 8),
                const Text('Items:'),
                ..._buildOrderItems(order.items),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOrderItems(List<OrderItem> items) {
    return items.map<Widget>((item) {
      return Padding(
        padding: const EdgeInsets.only(left: 16, top: 4),
        child: Text('- ${item.name} x${item.quantity}'),
      );
    }).toList();
  }

  Future<void> _updateOrderStatus(String orderId) async {
    try {
      final response = await http.put(
        Uri.parse('http://127.0.0.1:8000/orders/$orderId/status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': 'completed'}),
      );

      print('Update response status: ${response.statusCode}');
      print('Update response body: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order marked as completed'),
            backgroundColor: Colors.green,
          ),
        );
        _fetchOrders();
      } else {
        throw Exception('Failed to update order: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
