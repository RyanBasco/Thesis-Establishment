import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:thesis_establishment/Establishment%20Profile/EstabProfile.dart'; // QR code package

class GenerateQR extends StatefulWidget {
  @override
  _GenerateQRState createState() => _GenerateQRState();
}

class _GenerateQRState extends State<GenerateQR> {
  int _selectedIndex = 0; // Default selection for bottom navigation bar
  String email = '';
  String establishmentName = 'Loading...'; // Placeholder text

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch Firestore data based on email when page loads
  }

  void _onItemTapped(int index) {
  setState(() {
    _selectedIndex = index;
  });

  if (index == 1) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EstablishmentProfile()), // Navigate to EstablishmentProfile
    );
  }
}

  void _navigateBack(BuildContext context) {
    Navigator.pop(context);
  }

  Future<void> fetchData() async {
    // Get the current user's email
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      email = user.email ?? '';

      // Fetch the establishment from Firestore using the email
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Establishments')
          .where('Email', isEqualTo: email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          establishmentName = snapshot.docs.first['Establishment Name'] ?? 'No Name Available';
        });
      } else {
        setState(() {
          establishmentName = 'Establishment not found';
        });
      }
    } else {
      setState(() {
        establishmentName = 'User not logged in';
      });
    }
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      _navigateBack(context);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(Icons.arrow_back, color: Colors.black),
                    ),
                  ),
                  SizedBox(width: 70),
                  Text(
                    'Generate QR',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              Container(
                width: double.infinity,
                height: 350, // Reduced height of the white box
                padding: EdgeInsets.all(20.0), // Added padding inside the white box
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6.0,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    email.isEmpty
                        ? CircularProgressIndicator() // Show loading until the data is fetched
                        : QrImageView(
                            data: email,
                            version: QrVersions.auto,
                            size: 200.0, // Adjusted size for a better fit
                          ),
                    SizedBox(height: 20), // Space between QR code and text
                    Text(
                      establishmentName, // Display establishment name below QR code
                      style: TextStyle(
                        fontSize: 25, // Increased font size
                        fontWeight: FontWeight.bold, // Made the text bold
                        color: Color(0xFF288F13), // Changed color to 0xFF288F13
                      ),
                      textAlign: TextAlign.center, // Center the text inside the box
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Add save image functionality here
                    },
                    icon: Icon(Icons.save, color: Colors.white),
                    label: Text(
                      'Save Image',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF288F13),
                      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Add copy image functionality here
                    },
                    icon: Icon(Icons.copy, color: Colors.white),
                    label: Text(
                      'Copy Image',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF288F13),
                      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.groups_3_outlined,
            color: _selectedIndex == 0 ? Color(0xFF288F13) : Colors.black,
          ),
          label: 'Community',
          backgroundColor: Colors.white,
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.person,
            color: _selectedIndex == 1 ? Color(0xFF288F13) : Colors.black,
          ),
          label: 'Personal',
          backgroundColor: Colors.white,
        ),
      ],
      selectedItemColor: Color(0xFF288F13),
      unselectedItemColor: Colors.black,
      backgroundColor: Colors.white,
      elevation: 8.0,
    ),
  );
}
}
