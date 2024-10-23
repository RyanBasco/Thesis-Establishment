import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Inputvalue extends StatefulWidget {
  final String scannedCode;

  const Inputvalue({Key? key, required this.scannedCode}) : super(key: key);

  @override
  _InputvalueState createState() => _InputvalueState();
}

class _InputvalueState extends State<Inputvalue> {
  final TextEditingController _totalSpendController = TextEditingController();
  String? establishmentName; // To store the fetched establishment name
  String? fullName; // To store the full name
  String? selectedCategory; // To store the selected category

  // List of categories
  final List<String> categories = [
    'Accommodation',
    'Food and Beverages',
    'Transportation',
    'Attractions and Activities',
    'Shopping',
    'Entertainment',
    'Wellness and Spa Services',
    'Adventure and Outdoor Activities',
    'Travel Insurance',
    'Local Tours and Guides',
  ];

  @override
  void initState() {
    super.initState();
    extractFullName(); // Extract the full name from scanned code
  }

  void extractFullName() {
    // Assuming the scanned code format is "Maria Santos, ID : 'Document ID'"
    List<String> parts = widget.scannedCode.split(',');

    if (parts.isNotEmpty) {
      setState(() {
        // Extract the full name and trim any whitespace
        fullName = parts[0].trim(); // The full name is the first part
      });
    } else {
      // Handle cases where the name format might not be as expected
      setState(() {
        fullName = null; // Clear full name if not valid
      });
    }
  }

  Future<void> saveData() async {
  final userEmail = FirebaseAuth.instance.currentUser?.email;
  if (userEmail != null) {
    final totalSpend = _totalSpendController.text.trim();
    if (totalSpend.isNotEmpty && fullName != null) { // Check for fullName instead of establishmentName
      final now = DateTime.now();

      // Extract the document ID from the scanned code
      String documentID = '';
      List<String> parts = widget.scannedCode.split(',');

      if (parts.length > 1) {
        // Assuming the second part contains the ID in the format "ID : 'Document ID'"
        String idPart = parts[1].trim();
        // Extract the document ID using regex or string manipulation
        RegExp regex = RegExp(r"'([^']+)'");
        final match = regex.firstMatch(idPart);
        if (match != null) {
          documentID = match.group(1)!; // Extracted Document ID
        }
      }

      await FirebaseFirestore.instance.collection('Visits').add({
        'UID': widget.scannedCode, // Store only the extracted document ID
        'FullName': fullName, // Store the full name separately
        'TotalSpend': double.tryParse(totalSpend), // Ensure only numeric values
        'Category': selectedCategory, // Store the selected category
        'Date': '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}', // Standard date format
        'Time': '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}', // Standard time format
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data saved successfully!')),
      );
      _totalSpendController.clear(); // Clear the input field after saving
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the total spend and ensure the full name is available.')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User not found.')),
    );
  }
}




  @override
  Widget build(BuildContext context) {
    // Use full name to display
    String displayName = fullName ?? 'Loading...';

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
        child: Center(
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6.0,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter Total Spend:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 10), // Added space for better UI
                // Display the full name
                const Text(
                  'Full Name:', // Label for Full Name
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  displayName, // Display the full name
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                ),
                const SizedBox(height: 20),

                // Categories Section
                const Text(
                  'Categories:',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white, // Change to white
                    border: Border.all(color: Colors.black), // Add black border
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    hint: const Text('Select a category'),
                    isExpanded: true,
                    items: categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Total Spend:',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _totalSpendController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter amount',
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: saveData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF288F13),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
