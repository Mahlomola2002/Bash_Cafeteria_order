import 'package:bash/screens/admin/addNewDish.dart';
import 'package:bash/screens/admin/home.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: HomeWrapper(),
    );
  }
}

class HomeWrapper extends StatefulWidget {
  @override
  _HomeWrapperState createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  int _currentIndex = 0;
  final List<Widget> _children = [HomePage(), AddNewDish(), Text("dance")];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _currentIndex,
        children: _children,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(0),
          boxShadow: [
            BoxShadow(
              blurRadius: 10.0,
              spreadRadius: 2.0,
              offset: Offset(5.0, 5.0),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
          child: GNav(
            backgroundColor: Colors.white,
            rippleColor: Colors.grey[200]!,
            hoverColor: Colors.grey[100]!,
            haptic: true,
            tabBorderRadius: 15,
            curve: Curves.easeOutExpo,
            duration: Duration(milliseconds: 300),
            gap: 8,
            color: Colors.grey[600], // Darker color for inactive tabs
            activeColor: Colors.black, // Blue color for active tab
            iconSize: 24,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            onTabChange: onTabTapped,
            tabs: [
              GButton(
                icon: Icons.home_filled,
                text: "Home",
              ),
              GButton(
                icon: Icons.add_circle_outline, // Outline style for consistency
                text: "Add Dish",
              ),
              GButton(
                icon: Icons
                    .receipt_long, // Use `receipt_long` for a better orders icon
                text: 'View Orders',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
