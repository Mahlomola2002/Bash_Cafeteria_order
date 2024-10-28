import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> dishes = [
    {
      "name": "Spaghetti Carbonara",
      "description": "Creamy pasta with bacon and parmesan",
      "price": 12.99,
      "rating": 4.0,
    },
    {
      "name": "Grilled Chicken Salad",
      "description": "Fresh greens with grilled chicken breast",
      "price": 10.99,
      "rating": 4.0,
    },
    {
      "name": "Vegetable Stir Fry",
      "description": "Mixed vegetables stir-fried with savory sauce",
      "price": 8.99,
      "rating": 4.2,
    },
    {
      "name": "Margherita Pizza",
      "description": "Classic pizza with tomato, mozzarella, and basil",
      "price": 9.99,
      "rating": 2.1,
    }
  ];

  String searchQuery = "";
  bool isLoading = false;

  // Controllers for the update form
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // Simulated API call
  Future<void> updateDishData(
      int index, Map<String, dynamic> updatedDish) async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 2));

    // Here you would typically make your API call
    // await api.updateDish(updatedDish);

    setState(() {
      dishes[index] = updatedDish;
    });
  }

  void _showUpdateDialog(Map<String, dynamic> dish, int index) {
    // Set initial values
    _nameController.text = dish['name'];
    _descriptionController.text = dish['description'];
    _priceController.text = dish['price'].toString();

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing while loading
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!isLoading)
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                      ],
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _nameController,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _priceController,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixText: '\$',
                      ),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                    ),
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (!isLoading)
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey,
                            ),
                          ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  // Validate inputs
                                  if (_nameController.text.isEmpty ||
                                      _descriptionController.text.isEmpty ||
                                      _priceController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Please fill all fields'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  // Show loading state
                                  setState(() {
                                    isLoading = true;
                                  });

                                  try {
                                    // Prepare updated dish data
                                    final updatedDish = {
                                      "name": _nameController.text,
                                      "description":
                                          _descriptionController.text,
                                      "price":
                                          double.parse(_priceController.text),
                                      "rating": dishes[index]['rating'],
                                    };

                                    // Update dish with loading animation
                                    await updateDishData(index, updatedDish);

                                    // Close dialog
                                    Navigator.pop(context);

                                    // Show success message
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Dish updated successfully'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } catch (e) {
                                    // Show error message
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to update dish'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } finally {
                                    // Reset loading state
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                },
                          child: isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text('Save changes'),
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
              child: Text(
                "Bash Cafe Menu",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
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
              dish['name'],
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              dish['description'],
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              "\$${dish['price'].toStringAsFixed(2)}",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                ...List.generate(5, (i) {
                  if (i < dish['rating'].floor()) {
                    return Icon(Icons.star, color: Colors.amber, size: 16);
                  } else if (i < dish['rating']) {
                    return Icon(Icons.star_half, color: Colors.amber, size: 16);
                  } else {
                    return Icon(Icons.star_border,
                        color: Colors.amber, size: 16);
                  }
                }),
              ],
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showUpdateDialog(dish, index),
                  icon: Icon(Icons.edit, size: 14),
                  label: Text("Update", style: TextStyle(fontSize: 10)),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.grey[200],
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    deleteDish(index);
                  },
                  icon: Icon(Icons.delete, size: 14),
                  label: Text("Delete", style: TextStyle(fontSize: 10)),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void deleteDish(int index) {
    setState(() {
      dishes.removeAt(index);
    });
  }
}
