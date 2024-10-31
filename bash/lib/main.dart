import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:bash/screens/SignUp/logIn.dart';
import 'package:bash/screens/Student/StudentNavBar.dart';
import 'package:bash/screens/admin/adminNavbar.dart'; // Keep only one import for AdminNavBar

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyBQuE0JBVyhkQZRW3TO5sGGcFFo0JJrRzk",
      appId: "cafe-2bd00",
      databaseURL: "https://cafe-2bd00-default-rtdb.firebaseio.com",
      messagingSenderId: "1032949834293",
      projectId: "1032949834293",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Name',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Add some additional theme settings for consistency
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/student-dashboard': (context) => const StudentNavbar(), // Add const
        '/cafeteria-dashboard': (context) => const AdminNavBar(), // Add const
      },
      debugShowCheckedModeBanner: false, // Remove debug banner
    );
  }
}
