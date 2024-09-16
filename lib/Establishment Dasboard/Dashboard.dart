import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0; // Default to Community
  String _searchQuery = ""; // State for search query

  // Data for the boxes (title and icon)
  final List<Map<String, dynamic>> _boxes = [
    {'title': 'QR', 'icon': Icons.qr_code},
    {'title': 'Records', 'icon': Icons.receipt},
    {'title': 'Review', 'icon': Icons.announcement},
    {'title': 'Analytics', 'icon': Icons.analytics},
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0,), // Reduced vertical padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bell Icon above the Search Bar
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.notifications, color: Colors.black, size: 40), // Bell icon
                    onPressed: () {
                      // Handle bell icon press
                    },
                  ),
                ),
                SizedBox(height: 8), // Reduced space between bell icon and search bar

                // Search Bar with white background and black text inside
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // White background for the search bar
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 8.0,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: _onSearchChanged, // Handle search query changes
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: Colors.black), // Black search icon
                      hintText: 'Search...',
                      hintStyle: TextStyle(color: Colors.black), // Black placeholder text
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0), // Adjust padding for a larger input area
                    ),
                    style: TextStyle(color: Colors.black), // Black text color inside search bar
                  ),
                ),
                SizedBox(height: 24), // Reduced space between search bar and the white boxes

                // Display filtered boxes
                ...filteredBoxes.map((box) => Container(
                  width: double.infinity,
                  height: 150,
                  padding: EdgeInsets.all(20.0),
                  margin: EdgeInsets.only(bottom: 16.0), // Reduced margin between boxes
                  decoration: BoxDecoration(
                    color: Colors.white, // White background for the box
                    borderRadius: BorderRadius.circular(16), // Rounded corners
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
                        width: 80.0, // Diameter of the circle
                        height: 80.0, // Diameter of the circle
                        decoration: BoxDecoration(
                          color: Color(0xFF288F13), // Circle color
                          shape: BoxShape.circle, // Make it a circle
                        ),
                        child: Icon(
                          box['icon'], // Dynamic icon
                          color: Colors.white,
                          size: 50.0, // Size of the icon
                        ),
                      ),
                      SizedBox(width: 16), // Space between circle and text
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              box['title'], // Dynamic title
                              style: TextStyle(
                                color: Colors.black, // Text color
                                fontSize: 22, // Font size
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios, // Arrow icon
                              color: Colors.black,
                              size: 24.0,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )).toList(),
                SizedBox(height: 20), // Reduced space at the bottom
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
            icon: Icon(Icons.groups_3_outlined, color: _selectedIndex == 0 ? Color(0xFF288F13) : Colors.black), // Community icon
            label: 'Community',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: _selectedIndex == 1 ? Color(0xFF288F13) : Colors.black), // Personal icon
            label: 'Personal',
            backgroundColor: Colors.white,
          ),
        ],
        selectedItemColor: Color(0xFF288F13), // Color for the selected item
        unselectedItemColor: Colors.black, // Color for the unselected items
        backgroundColor: Colors.white, // Background color of the BottomNavigationBar
        elevation: 8.0, // Elevation for shadow effect
      ),
    );
  }
}
