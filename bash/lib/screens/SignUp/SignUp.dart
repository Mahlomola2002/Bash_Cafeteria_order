import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  String? _role = 'Student';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  void _handleSignup() async {
    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (_validateFields(name, email, password, confirmPassword)) return;

    _showLoadingDialog();

    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        await _saveUserData(userCredential.user!.uid, name, email, _role!);
        Navigator.of(context).pop(); // Remove loading dialog
        _showSuccessMessage("Sign-up successful");
      }
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop(); // Remove loading dialog
      _showErrorMessage(_getErrorMessage(e));
    } catch (e) {
      Navigator.of(context).pop(); // Remove loading dialog
      _showErrorMessage('An unexpected error occurred. Please try again.');
      print('Unexpected error: $e');
    }
  }

  bool _validateFields(
      String name, String email, String password, String confirmPassword) {
    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showErrorMessage("Please fill out all fields");
      return true;
    }
    if (password != confirmPassword) {
      _showErrorMessage("Passwords do not match");
      return true;
    }
    return false;
  }

  Future<void> _saveUserData(
      String userId, String name, String email, String role) async {
    // Create a reference to the Firebase Realtime Database
    DatabaseReference userRef = FirebaseDatabase.instance.ref('users/$userId');

    try {
      // Set user data
      await userRef.set({
        'name': name,
        'role': role, // Ensure 'role' is passed as an argument
        'email': email,
        'createdAt': ServerValue.timestamp,
      });

      print('User data saved successfully!'); // Optional success message
    } catch (error) {
      print('Error saving user data: $error'); // Handle any errors
    }
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak';
      case 'email-already-in-use':
        return 'An account already exists for that email';
      case 'invalid-email':
        return 'Invalid email address format';
      default:
        return e.message ?? 'An error occurred during sign up';
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          const Center(child: CircularProgressIndicator()),
    );
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 231, 230, 230),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24.0),
            width: 400.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Sign up",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Create an account to use our platform",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 24),
                _buildInputLabel("Name"),
                _buildTextField(
                    controller: _nameController, hintText: "Enter your name"),
                const SizedBox(height: 16),
                _buildInputLabel("Email"),
                _buildTextField(
                    controller: _emailController, hintText: "m@example.com"),
                const SizedBox(height: 16),
                _buildInputLabel("Password"),
                _buildTextField(
                    controller: _passwordController,
                    hintText: "Enter your password",
                    obscureText: true),
                const SizedBox(height: 16),
                _buildInputLabel("Confirm Password"),
                _buildTextField(
                    controller: _confirmPasswordController,
                    hintText: "Re-enter your password",
                    obscureText: true),
                const SizedBox(height: 16),
                _buildInputLabel("Role"),
                _buildRoleSelection(),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleSignup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Sign up',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? ",
                        style: TextStyle(color: Colors.grey)),
                    GestureDetector(
                      onTap: () {
                        // Navigate to login page
                      },
                      child: const Text("Log in",
                          style: TextStyle(color: Colors.blue)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 1),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildRoleSelection() {
    return Column(
      children: [
        RadioListTile<String>(
          title: const Text('Student'),
          value: 'Student',
          groupValue: _role,
          onChanged: (String? value) => setState(() => _role = value),
          contentPadding: EdgeInsets.zero,
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
        ),
        RadioListTile<String>(
          title: const Text('Cafeteria Worker'),
          value: 'Cafeteria Worker',
          groupValue: _role,
          onChanged: (String? value) => setState(() => _role = value),
          contentPadding: EdgeInsets.zero,
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
        ),
      ],
    );
  }
}
