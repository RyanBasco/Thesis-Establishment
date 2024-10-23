import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import for Firebase Auth

/// Define the ChartData class
class ChartData {
  final String xValue; // Store formatted Date as a String
  final double yValue; // Store TotalSpend

  ChartData(this.xValue, this.yValue);
}

class Analytics extends StatefulWidget {
  @override
  _AnalyticsState createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  String selectedOption = 'Monthly'; // Default selected option
  List<ChartData> chartData = []; // For storing chart data
  bool isLoading = true;
  String? userEmail; // To store the logged-in user's email

  @override
  void initState() {
    super.initState();
    fetchUserEmail(); // Fetch the logged-in user's email
  }

  // Fetch the logged-in user's email
  Future<void> fetchUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email;
      });
      fetchTotalSpendData(); // Fetch the TotalSpend data based on email
    }
  }

  // Fetch the TotalSpend data from Firestore where the email matches
  Future<void> fetchTotalSpendData() async {
    if (userEmail == null) return;

    QuerySnapshot visitsSnapshot = await FirebaseFirestore.instance
        .collection('Visits')
        .where('Email', isEqualTo: userEmail) // Filter by email
        .get();

    List<ChartData> fetchedData = [];
   for (var doc in visitsSnapshot.docs) {
  var data = doc.data() as Map<String, dynamic>;
  double totalSpend = data['TotalSpend'] ?? 0.0; // Fetch TotalSpend field

  DateTime date;

  if (data['Date'] is Timestamp) {
    // Convert Firestore Timestamp to DateTime
    Timestamp dateTimestamp = data['Date'];
    date = dateTimestamp.toDate();
  } else if (data['Date'] is String) {
    // Try parsing the string date in various formats
    String dateString = data['Date'];

    try {
      // First, try to parse assuming 'yyyy-MM-dd' format (e.g., 2024-10-22)
      date = DateFormat('yyyy-MM-dd').parse(dateString.split(' ')[0]); // Splitting if 'at 0' exists
    } catch (e) {
      try {
        // If it fails, attempt parsing with another format if necessary
        date = DateFormat('MMM dd, yyyy').parse(dateString);
      } catch (e) {
        // If parsing fails, default to the current date
        date = DateTime.now();
      }
    }
  } else {
    // If the Date field is missing or in an unknown format, default to the current date
    date = DateTime.now();
  }

  // Format the DateTime into a human-readable string
  String formattedDate = DateFormat('MMM dd, yyyy').format(date);

  // Add the data to the fetched list
  fetchedData.add(ChartData(formattedDate, totalSpend));
}

    setState(() {
      chartData = fetchedData;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
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
                        Navigator.pop(context); // Navigate back
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
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 95), // Space between icon and text
                    const Text(
                      'Analytics',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20), // Space between Analytics and Dashboard text
                const Padding(
                  padding: EdgeInsets.only(left: 10.0), // Adjust as needed
                  child: Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 10), // Space before main content
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 15.0), // Adjust as needed
                      child: Text(
                        'Total Sales',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        _buildOption('Monthly'),
                        _buildOption('Weekly'),
                        _buildOption('Daily'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20), // Reduced padding
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : chartData.isEmpty
                            ? const Center(child: Text('No data available for this user'))
                            : SfCartesianChart(
                                primaryXAxis: CategoryAxis(), // Use CategoryAxis for string x-values
                                series: <CartesianSeries>[
                                  ColumnSeries<ChartData, String>(
                                    dataSource: chartData,
                                    xValueMapper: (ChartData data, _) => data.xValue,
                                    yValueMapper: (ChartData data, _) => data.yValue,
                                    color: const Color(0xFF288F13), // Bar color
                                    width: 0.5,
                                  ),
                                ],
                              ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Default selection for this page
        onTap: (int index) {
          // Add navigation logic if needed
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.groups_3_outlined,
              color: Color(0xFF288F13),
            ),
            label: 'Community',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: Colors.black,
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

  Widget _buildOption(String option) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOption = option;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          color: selectedOption == option ? const Color(0xFF288F13) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedOption == option ? const Color(0xFF288F13) : Colors.black,
          ),
        ),
        child: Text(
          option,
          style: TextStyle(
            color: selectedOption == option ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
