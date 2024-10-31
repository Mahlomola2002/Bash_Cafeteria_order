import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> dishes = [];
  String searchQuery = "";
  bool isLoading = true;
  Timer? _refreshTimer;

  // Controllers for the update form
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchDishes();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchDishes();
    });
  }

  // Fetch dishes from the FastAPI backend
  Future<void> fetchDishes() async {
    try {
      final response =
          await http.get(Uri.parse('http://127.0.0.1:8000/dishes/'));
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        dishes =
            jsonResponse.map((dish) => dish as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load dishes');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error fetching dishes: $e'),
            backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteDish(int dishId) async {
    final url = Uri.parse('http://127.0.0.1:8000/dishes/$dishId');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        setState(() {
          dishes.removeWhere((dish) => dish['id'] == dishId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Dish deleted successfully'),
              backgroundColor: Colors.green),
        );
      } else {
        throw Exception("Failed to delete dish: ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> updateDish(int dishId, Map<String, dynamic> updatedDish) async {
    final url = Uri.parse('http://127.0.0.1:8000/dishes/$dishId');
    final headers = {"Content-Type": "application/json"};
    final body = jsonEncode(updatedDish);

    try {
      final response = await http.put(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        setState(() {
          dishes[dishes.indexWhere((dish) => dish['id'] == dishId)] =
              updatedDish;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Dish updated successfully'),
              backgroundColor: Colors.green),
        );
      } else {
        throw Exception("Failed to update dish: ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void _showUpdateDialog(Map<String, dynamic> dish, int index) {
    _nameController.text = dish['name'];
    _descriptionController.text = dish['description'];
    _priceController.text = dish['price'].toString();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Update Dish',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        prefixText: '\$',
                      ),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                    ),
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel'),
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.grey),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            if (_nameController.text.isEmpty ||
                                _descriptionController.text.isEmpty ||
                                _priceController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Please fill all fields'),
                                    backgroundColor: Colors.red),
                              );
                              return;
                            }

                            final updatedDish = {
                              "id": dish['id'],
                              "name": _nameController.text,
                              "description": _descriptionController.text,
                              "price": double.parse(_priceController.text),
                              "rating": dish['rating'],
                            };

                            await updateDish(dish['id'], updatedDish);
                            Navigator.pop(context);
                          },
                          child: Text('Save changes'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Expanded(
              child: Text("Bash Cafe Menu",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              flex: 2,
              child: Container(
                height: 40,
                child: TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Search Dish',
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      MediaQuery.of(context).size.width > 800 ? 4 : 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 2 / 3,
                ),
                itemCount: filteredDishes.length,
                itemBuilder: (context, index) {
                  return buildDishCard(filteredDishes[index], index);
                },
              ),
            ),
    );
  }

  List<Map<String, dynamic>> get filteredDishes {
    if (searchQuery.isEmpty) return dishes;
    return dishes
        .where((dish) => dish['name'].toLowerCase().contains(searchQuery))
        .toList();
  }

  Widget buildDishCard(Map<String, dynamic> dish, int index) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dish['name'],
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(dish['description'],
                style: TextStyle(fontSize: 10, color: Colors.grey)),
            SizedBox(height: 4),
            Text("\$${dish['price']}",
                style: TextStyle(fontSize: 14, color: Colors.green)),
            SizedBox(height: 4),
            StarRating(rating: dish['rating'].toDouble()), // Add this line
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showUpdateDialog(dish, index),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => deleteDish(dish['id']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final Color? color;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 20,
    this.color = Colors.amber,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            if (index < (rating / 2).floor()) {
              return Icon(Icons.star, size: size, color: color);
            } else if (index == (rating / 2).floor() && rating % 2 != 0) {
              return Icon(Icons.star_half, size: size, color: color);
            } else {
              return Icon(Icons.star_border, size: size, color: color);
            }
          }),
        ),
        SizedBox(width: 4),
      ],
    );
  }
}
