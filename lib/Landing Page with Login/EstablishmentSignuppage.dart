import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:thesis_establishment/Landing%20Page%20with%20Login/EstablishmentLoginpage.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _establishmentNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _passwordError;
  String? _emailError;

  // Password validation function
  String? validatePassword(String password) {
    final passwordRegex = RegExp(r'^(?=.*[0-9])(?=.*[A-Z]).{6,}$');
    if (!passwordRegex.hasMatch(password)) {
      return 'Password must start with a capital letter, contain at least one number, and be 6+ characters long';
    }
    return null;
  }

  // Email validation function
  String? validateEmail(String email) {
    if (!email.contains('@')) {
      return 'Email must contain @';
    }
    return null;
  }

  // Check if passwords match
  bool doPasswordsMatch() {
    return _passwordController.text == _confirmPasswordController.text;
  }

  // Sign up function
  Future<void> signUp() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final establishmentName = _establishmentNameController.text;
    final location = _locationController.text;

    setState(() {
      _emailError = validateEmail(email);
    });

    if (_emailError == null && _passwordError == null && doPasswordsMatch()) {
      try {
        // Check if the email is already registered
        final emailExists = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
        if (emailExists.isNotEmpty) {
          setState(() {
            _emailError = 'Email is already registered';
          });
          return;
        }

        // Create user in Firebase Authentication
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Store data in Firebase Realtime Database
        final databaseRef = FirebaseDatabase.instance.ref().child('Establishment ID');
        await databaseRef.child(userCredential.user!.uid).set({
          'Establishment Name': establishmentName,
          'Location': location,
          'Email': email,
          'Password': password,
        });

        // Store data in Cloud Firestore
        await FirebaseFirestore.instance.collection('Establishments').doc(userCredential.user!.uid).set({
          'Establishment Name': establishmentName,
          'Location': location,
          'Email': email,
          'Password': password,
        });

        // Show success dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Success',
                style: TextStyle(color: Color(0xFF288F13)),
              ),
              content: Text('Your account has been created successfully'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => EstablishmentLogin()), // Navigate to login page
                    );
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Arrow and "Sign Up" Text
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Navigate back on arrow click
                    },
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back, color: Color(0xFF288F13)),
                        SizedBox(width: 8.0),
                        Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF288F13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),

                  // Establishment Name Field
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0), // Padding to adjust length
                    decoration: BoxDecoration(
                      color: Color(0xFF288F13),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _establishmentNameController,
                      decoration: InputDecoration(
                        labelText: 'Establishment Name',
                        labelStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Location Field
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0), // Padding to adjust length
                    decoration: BoxDecoration(
                      color: Color(0xFF288F13),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Location',
                        labelStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Email Field
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0), // Padding to adjust length
                    decoration: BoxDecoration(
                      color: Color(0xFF288F13),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                      ),
                      style: TextStyle(color: Colors.white),
                      onChanged: (value) {
                        setState(() {
                          _emailError = validateEmail(value);
                        });
                      },
                    ),
                  ),
                  if (_emailError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _emailError!,
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  SizedBox(height: 20),

                  // Password Field
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0), // Padding to adjust length
                    decoration: BoxDecoration(
                      color: Color(0xFF288F13),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      onChanged: (value) {
                        setState(() {
                          _passwordError = validatePassword(value);
                        });
                      },
                    ),
                  ),
                  if (_passwordError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _passwordError!,
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  SizedBox(height: 20),

                  // Confirm Password Field
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0), // Padding to adjust length
                    decoration: BoxDecoration(
                      color: Color(0xFF288F13),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        labelStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      onChanged: (value) {
                        setState(() {}); // Rebuild to check if passwords match
                      },
                    ),
                  ),
                  if (!doPasswordsMatch() && _confirmPasswordController.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Passwords do not match',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  SizedBox(height: 40),

                  // Sign Up Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        await signUp(); // Call the sign-up function
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF288F13), // Button color
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15), // Increased size
                      ),
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.white, // Button text color
                          fontSize: 18,
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
