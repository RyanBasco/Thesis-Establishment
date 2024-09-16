import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thesis_establishment/Establishment%20Dasboard/Dashboard.dart';
import 'package:thesis_establishment/Landing%20Page%20with%20Login/EstablishmentSignuppage.dart';

class EstablishmentLogin extends StatefulWidget {
  @override
  _EstablishmentLoginState createState() => _EstablishmentLoginState();
}

class _EstablishmentLoginState extends State<EstablishmentLogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  // Function to handle login
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear any previous error messages
    });

    try {
      // Sign in with Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // If login is successful, navigate to the DashboardPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()), // Replace with your Dashboard page
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') {
          _errorMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          _errorMessage = 'Wrong password provided.';
        } else {
          _errorMessage = 'An error occurred. Please try again.';
        }
      });
    } finally {
      setState(() {
        _isLoading = false; // Stop the loading spinner
      });
    }
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFEEFFA9),
              Color(0xFFDBFF4C),
              Color(0xFF51F643),
            ],
            stops: [0.15, 0.54, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 80.0, 16.0, 16.0), // Adjust this value to move down
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset('assets/building.png', height: 150),
                  ),
                  SizedBox(height: 40),

                  // "Login" Text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF288F13), // Color #288F13
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Email Field with Icon
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF288F13), // Background color for email field
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.email, color: Colors.white), // Email Icon
                      ),
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: Colors.white), // White text inside
                    ),
                  ),
                  SizedBox(height: 20),

                  // Password Field with Icon
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF288F13), // Background color for password field
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.lock, color: Colors.white), // Lock Icon
                      ),
                      obscureText: true,
                      style: TextStyle(color: Colors.white), // White text inside
                    ),
                  ),
                  SizedBox(height: 10),

                  // Error message if any
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),

                  // Forgot password? text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(
                        color: Colors.black, // Black text color
                      ),
                    ),
                  ),
                  SizedBox(height: 40),

                  // Login Button with loading indicator
                  Center(
                    child: _isLoading
                        ? CircularProgressIndicator() // Show loading spinner when signing in
                        : ElevatedButton(
                            onPressed: _login, // Call the login function
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF288F13), // Button color
                              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15), // Increased size
                            ),
                            child: Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white, // Button text color
                                fontSize: 18,
                              ),
                            ),
                          ),
                  ),
                  SizedBox(height: 20),

                  // "Don't have an account? Sign up" text
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        // Navigate to the SignUpPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpPage()),
                        );
                      },
                      child: Text.rich(
                        TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(color: Colors.black),
                          children: [
                            TextSpan(
                              text: 'Sign up',
                              style: TextStyle(
                                color: Color(0xFF2D60F7), // Sign up text color
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
