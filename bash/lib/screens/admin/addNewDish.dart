import 'package:flutter/material.dart';

class AddNewDish extends StatefulWidget {
  const AddNewDish({super.key});

  @override
  State<AddNewDish> createState() => AddNewDishState();
}

class AddNewDishState extends State<AddNewDish> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Expanded(
              child: Text(
                "Add New Dish",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
          'Add New Dish Form Goes Here',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
