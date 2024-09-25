import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thesis_establishment/Establishment%20Dasboard/GenerateQR.dart';
import 'package:thesis_establishment/Establishment%20Dasboard/ScanQR.dart';
import 'package:thesis_establishment/Establishment%20Dasboard/UploadQR.dart';
import 'package:thesis_establishment/Establishment%20Profile/EstabProfile.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0; // Default to Community
  String _searchQuery = ""; // State for search query
  String establishmentName = 'Loading...'; // Placeholder for establishment name

  // Define the data for the boxes
  final List<Map<String, dynamic>> _boxes = [
    {'title': 'Scan QR', 'icon': Icons.qr_code},
    {'title': 'Upload QR', 'icon': Icons.qr_code_2},
    {'title': 'Generate QR', 'icon': Icons.qr_code_scanner},
    {'title': 'Records', 'icon': Icons.receipt},
    {'title': 'Review', 'icon': Icons.announcement},
    {'title': 'Analytics', 'icon': Icons.analytics},
  ];

  @override
  void initState() {
    super.initState();
    fetchEstablishmentName(); // Fetch establishment name on init
  }

  void fetchEstablishmentName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String email = user.email ?? '';
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

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  void _navigateToScanQR(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScanQR()), // Navigate to ScanQR page
    );
  }

  void _navigateToUploadQR(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UploadQR()), // Navigate to UploadQR page
    );
  }

  void _navigateToGenerateQR(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GenerateQR()), // Navigate to GenerateQR page
    );
  }

  @override
Widget build(BuildContext context) {
  // Filter boxes based on search query
  final filteredBoxes = _boxes.where((box) {
    return box['title']!.toLowerCase().contains(_searchQuery);
  }).toList();

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
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align name and icon horizontally
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      establishmentName, // Display fetched establishment name
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.notifications, color: Colors.black, size: 40),
                    onPressed: () {
                      // Handle bell icon press
                    },
                  ),
                ],
              ),
              SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 8.0,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Colors.black),
                    hintText: 'Search...',
                    hintStyle: TextStyle(color: Colors.black),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
                  ),
                  style: TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(height: 24),
              ...filteredBoxes.map((box) {
                return GestureDetector(
                  onTap: () {
                    if (box['title'] == 'Scan QR') {
                      _navigateToScanQR(context);
                    } else if (box['title'] == 'Upload QR') {
                      _navigateToUploadQR(context); // Navigate to UploadQR page
                    } else if (box['title'] == 'Generate QR') {
                      _navigateToGenerateQR(context); // Navigate to GenerateQR
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    padding: EdgeInsets.all(20.0),
                    margin: EdgeInsets.only(bottom: 16.0),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 80.0,
                          height: 80.0,
                          decoration: BoxDecoration(
                            color: Color(0xFF288F13),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            box['icon'], // Dynamic icon
                            color: Colors.white,
                            size: 50.0,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                box['title'],
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.black,
                                size: 24.0,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              SizedBox(height: 20),
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
          icon: Icon(Icons.groups_3_outlined, color: _selectedIndex == 0 ? Color(0xFF288F13) : Colors.black),
          label: 'Community',
          backgroundColor: Colors.white,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, color: _selectedIndex == 1 ? Color(0xFF288F13) : Colors.black),
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
