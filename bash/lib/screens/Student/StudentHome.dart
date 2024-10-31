import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'api_service.dart';

class Studenthome extends StatefulWidget {
  const Studenthome({super.key});

  @override
  State<Studenthome> createState() => _StudenthomeState();
}

class _StudenthomeState extends State<Studenthome> {
  List<Map<String, dynamic>> dishes = [];
  bool isLoading = true;
  Timer? _refreshTimer;

  final user = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();
    loadDishes();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      loadDishes();
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> loadDishes() async {
    try {
      final fetchedDishes = await ApiService.getDishes();
      setState(() {
        dishes = fetchedDishes;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load dishes: $e')),
      );
    }
  }

  Future<void> updateDishRating(int dishId, int rating) async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to rate dishes')),
      );
      return;
    }

    try {
      final response = await ApiService.rateDish(dishId, user!.uid, rating);

      if (response['average_rating'] != null) {
        setState(() {
          final dishIndex = dishes.indexWhere((d) => d['id'] == dishId);
          if (dishIndex != -1) {
            dishes[dishIndex]['rating'] = response['average_rating'];
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update rating: $e')),
      );
    }
  }

  Future<void> placeOrder(String name, String phone, Map<String, dynamic> dish,
      int quantity) async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please login to place orders')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      final orderItems = [
        {
          'name': dish['name'],
          'quantity': quantity,
        }
      ];

      final order = await ApiService.createOrder(
        userId: user!.uid,
        customer_name: name,
        total: dish['price'] * quantity,
        items: orderItems,
      );

      Navigator.of(context).pop(); // Dismiss loading animation
      Navigator.of(context).pop(); // Close the order dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order placed successfully! Order ID: ${order['id']}'),
          duration: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Dismiss loading animation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2 / 3,
          ),
          itemCount: dishes.length,
          itemBuilder: (context, index) {
            return buildDishCard(dishes[index], index);
          },
        ),
      ),
    );
  }

  Widget buildDishCard(Map<String, dynamic> dish, int index) {
    // Safely get the rating with a default value of 0
    final double rating = (dish['rating'] ?? 0).toDouble();

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dish['name'] ?? 'Unnamed Dish',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              dish['description'] ?? 'No description available',
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              "\$${(dish['price'] ?? 0.0).toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (i) {
                return IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    i < rating
                        ? Icons.star
                        : i < rating && rating.floor() != rating
                            ? Icons.star_half
                            : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  ),
                  onPressed: () {
                    if (dish['id'] != null) {
                      updateDishRating(dish['id'], i + 1);
                    }
                  },
                );
              }),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showOrderDialog(dish);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Text(
                  "Order Now",
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showOrderDialog(Map<String, dynamic> dish) {
    TextEditingController nameController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    int quantity = 1;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: EdgeInsets.all(24),
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Place Your Order",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Confirm your order details below.",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 24),
                    buildOrderField("Name", nameController, "Enter your name"),
                    SizedBox(height: 16),
                    buildOrderField(
                        "Phone", phoneController, "Enter your phone number"),
                    SizedBox(height: 16),
                    buildOrderInfoRow("Dish", dish['name']),
                    SizedBox(height: 16),
                    buildOrderInfoRow(
                        "Price", "\$${dish['price'].toStringAsFixed(2)}"),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Quantity",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  if (quantity > 1) quantity--;
                                });
                              },
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.grey[200],
                                padding: EdgeInsets.all(8),
                              ),
                            ),
                            Container(
                              width: 40,
                              alignment: Alignment.center,
                              child: Text(
                                quantity.toString(),
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  quantity++;
                                });
                              },
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.grey[200],
                                padding: EdgeInsets.all(8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    buildOrderInfoRow(
                      "Total",
                      "\$${(dish['price'] * quantity).toStringAsFixed(2)}",
                      bold: true,
                    ),
                    SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text("Cancel"),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              placeOrder(
                                nameController.text,
                                phoneController.text,
                                dish,
                                quantity,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              "Place Order",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildOrderField(
      String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget buildOrderInfoRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
