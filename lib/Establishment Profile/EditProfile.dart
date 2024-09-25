import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String establishmentName = '';
  String address = '';
  String website = '';
  String email = '';
  String mobileNumber = '';
  bool isLoading = true;

  // Add a unique document ID for the user's data
  String documentId = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Call the data fetching function
  }

  Future<void> _fetchUserData() async {
    try {
      // Get the current logged-in user
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Generate a unique document ID (you can use a different method if needed)
        documentId = currentUser.uid; // Use the user's UID as the document ID
        email = currentUser.email!;

        // Fetch data from Firestore using the document ID
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('Establishments')
            .doc(documentId)
            .get();

        if (snapshot.exists) {
          // Log the fetched values for debugging
          print("Fetched Data: ${snapshot.data()}");

          setState(() {
            establishmentName = snapshot['Establishment Name'] ?? 'N/A';
            address = snapshot['Location'] ?? 'N/A';
            website = snapshot['Website'] ?? 'N/A';
            mobileNumber = snapshot['Mobile Number'] ?? 'N/A';
            isLoading = false; // Loading is done
          });
        } else {
          print("No data found for the document.");
          isLoading = false; // Set isLoading to false even if no data is found
        }
      }
    } catch (e) {
      print('Error fetching data: $e');
      isLoading = false; // Set isLoading to false in case of an error
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
        child: isLoading // Check if data is still loading
            ? Center(child: CircularProgressIndicator()) // Show loading indicator
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 16.0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context); // Go back to the previous page
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.black,
                                size: 24,
                              ),
                            ),
                          ),
                          SizedBox(width: 75),
                          Text(
                            "Edit Profile",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20.0),
                      child: Container(
                        width: double.infinity,
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
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 65,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Text(
                                    "Upload Image",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C812A),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              _buildProfileContainer("Establishment Name", establishmentName),
                              _buildProfileContainer("Address", address),
                              _buildProfileContainer("Website", website),
                              _buildProfileContainer("Email Address", email),
                              _buildProfileContainer("Mobile Number", mobileNumber),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Handle 'Edit' button action
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF2C812A),
                              padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              "Edit",
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Handle 'Save' button action
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF2C812A),
                              padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              "Save",
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildProfileContainer(String labelText, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Text(
          labelText,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C812A),
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            value.isNotEmpty ? value : 'N/A',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
      ],
    );
  }
}
