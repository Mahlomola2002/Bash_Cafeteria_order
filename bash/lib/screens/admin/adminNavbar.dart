import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:bash/screens/admin/home.dart';
import 'package:bash/screens/admin/addNewDish.dart';
import 'package:bash/screens/admin/viewOrder.dart';

class AdminNavBar extends StatefulWidget {
  const AdminNavBar({Key? key}) : super(key: key);

  @override
  _AdminNavBarState createState() => _AdminNavBarState();
}

class _AdminNavBarState extends State<AdminNavBar> {
  int _currentIndex = 0;

  // Define pages with const constructors where possible
  final List<Widget> _adminPages = const [
    HomePage(),
    AddNewDish(),
    ViewOrder(), // New view order page
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Add app bar for consistent UI

      body: IndexedStack(
        index: _currentIndex,
        children: _adminPages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10.0,
              spreadRadius: 2.0,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12.0),
            child: GNav(
              backgroundColor: Colors.white,
              rippleColor: Colors.grey,
              hoverColor: Colors.grey[100]!,
              haptic: true,
              tabBorderRadius: 15,
              curve: Curves.easeOutExpo,
              duration: const Duration(milliseconds: 300),
              gap: 8,
              color: Colors.grey[600],
              activeColor: Colors.black,
              iconSize: 24,
              tabBackgroundColor: Colors.grey[200]!,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              onTabChange: onTabTapped,
              tabs: const [
                GButton(
                  icon: Icons.home_filled,
                  text: "Home",
                ),
                GButton(
                  icon: Icons.add_circle_outline,
                  text: "Add Dish",
                ),
                GButton(
                  icon: Icons.receipt_long,
                  text: 'Orders',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Add New Dish';
      case 2:
        return 'View Orders';
      default:
        return 'Cafeteria Admin';
    }
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Pop the dialog
                Navigator.pop(context);
                // Navigate to login page and remove all previous routes
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
