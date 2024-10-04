import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:thesis_establishment/Establishment%20Dasboard/Dashboard.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


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
  bool isEditing = false;
  String description = '';
  String documentId = '';


  // Text editing controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController websiteController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  late TextEditingController _controller;
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _facebookController = TextEditingController();
  TextEditingController _instagramController = TextEditingController();
  TextEditingController _twitterController = TextEditingController();

  
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _controller = TextEditingController();
  }

  void dispose() {
    _controller.dispose(); // Dispose the controller when done
    super.dispose();
  }

  void onDescriptionChanged(String value) {
    setState(() {
      description = value; // Update 'description' with the new value
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()), // Navigate to DashboardPage
      );
    }
  }

  Future<void> _fetchUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        documentId = currentUser.uid;
        email = currentUser.email!;

        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('Establishments')
            .doc(documentId)
            .get();

        if (snapshot.exists) {
          setState(() {
            establishmentName = snapshot['Establishment Name'] ?? 'N/A';
            address = snapshot['Location'] ?? 'N/A';
            website = snapshot['Website'] ?? 'N/A';
            mobileNumber = snapshot['Mobile Number'] ?? 'N/A';

            // Set the initial values to the text controllers
            nameController.text = establishmentName;
            addressController.text = address;
            websiteController.text = website;
            mobileNumberController.text = mobileNumber;

            isLoading = false;
          });
        } else {
          print("No data found for the document.");
          isLoading = false;
        }
      }
    } catch (e) {
      print('Error fetching data: $e');
      isLoading = false;
    }
  }

  Future<void> _saveUserData() async {
  if (!mounted) return; // Ensure the widget is still mounted before proceeding

  try {
    await FirebaseFirestore.instance
        .collection('Establishments')
        .doc(documentId)
        .update({
      'Establishment Name': nameController.text,
      'Location': addressController.text,
      'Website': websiteController.text,
      'Mobile Number': mobileNumberController.text,
    });

    if (mounted) {
      setState(() {
        // Update the state with the saved data
        establishmentName = nameController.text;
        address = addressController.text;
        website = websiteController.text;
        mobileNumber = mobileNumberController.text;
        isEditing = false; // Exit editing mode
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );
    }
  } catch (e) {
    print('Error saving data: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile')),
      );
    }
  }
}


  // Editable container for fields
  Widget _buildEditableContainer(String labelText, TextEditingController controller, {List<TextInputFormatter>? inputFormatters}) {
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
          child: isEditing
              ? TextField(
                  controller: controller,
                  inputFormatters: inputFormatters,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                  ),
                )
              : Text(
                  controller.text.isNotEmpty ? controller.text : 'N/A',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
        ),
      ],
    );
  }

  // Non-editable container for fields
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
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 16.0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
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
                    // First white box
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
                              _buildEditableContainer("Establishment Name", nameController),
                              _buildEditableContainer("Address", addressController),
                              _buildEditableContainer("Website", websiteController),
                              _buildProfileContainer("Email Address", email),
                              _buildEditableContainer(
                                "Mobile Number", 
                                mobileNumberController, 
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(11),
                                ]
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                   // New second white box
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
              Text(
                "Photos",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C812A),
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFF2C812A), width: 2),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                        child: Text(
                          '+',
                          style: TextStyle(
                            fontSize: 40,
                            color: Color(0xFF2C812A),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 18),
                  Expanded(
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFF2C812A), width: 2),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                '*Drag and drop to rearrange your photos.\n'
                '*First photos above will be your cover/featured photo.\n'
                '*You can upload up to 5 photos.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Description",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C812A),
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Color(0xFF898989), width: 2),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  children: [
                    TextField(
                      maxLines: null,
                      controller: _controller,
                      onChanged: onDescriptionChanged,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(10),
                        hintText: 'Enter your description here...',
                      ),
                      // Increased height for the text field
                      style: TextStyle(height: 5.5),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16), // Space before social links
              // Social Links section
              Text(
                "Social Links",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C812A),
                ),
              ),
              SizedBox(height: 8),
              Row(
            children: [
              Text(
                "Facebook",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2C812A),
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.facebook, color: Color(0xFF2C812A)),
            ],
          ),
          SizedBox(height: 16),
          // Facebook container (editable when 'isEditing' is true)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Color(0xFFDADADA), width: 2),
              borderRadius: BorderRadius.circular(8.0),
            ),
            height: 50,
            child: TextFormField(
              controller: _facebookController,
              enabled: isEditing, // Editable when 'isEditing' is true
              decoration: InputDecoration(
                hintText: 'Enter Facebook link here...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(10),
              ),
              style: TextStyle(
                color: Color(0xFF2C812A),
              ),
            ),
          ),

          SizedBox(height: 16),

          // Instagram
          Row(
            children: [
              Text(
                "Instagram",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2C812A),
                ),
              ),
              SizedBox(width: 8),
              Icon(FontAwesomeIcons.instagram, color: Color(0xFF2C812A), size: 25.0),
            ],
          ),
          SizedBox(height: 16),

          // Instagram container (editable when 'isEditing' is true)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Color(0xFFDADADA), width: 2),
              borderRadius: BorderRadius.circular(8.0),
            ),
            height: 50,
            child: TextFormField(
              controller: _instagramController,
              enabled: isEditing, // Editable when 'isEditing' is true
              decoration: InputDecoration(
                hintText: 'Enter Instagram link here...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(10),
              ),
              style: TextStyle(
                color: Color(0xFF2C812A),
              ),
            ),
          ),

          SizedBox(height: 16),

          // Twitter
          Row(
            children: [
              Text(
                "Twitter",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2C812A),
                ),
              ),
              SizedBox(width: 8),
              Icon(FontAwesomeIcons.xTwitter, color: Color(0xFF2C812A), size: 25.0),
            ],
          ),
          SizedBox(height: 16),

          // Twitter container (editable when 'isEditing' is true)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Color(0xFFDADADA), width: 2),
              borderRadius: BorderRadius.circular(8.0),
            ),
            height: 50,
            child: TextFormField(
              controller: _twitterController,
              enabled: isEditing, // Editable when 'isEditing' is true
              decoration: InputDecoration(
                hintText: 'Enter Twitter link here...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(10),
              ),
              style: TextStyle(
                color: Color(0xFF2C812A),
              ),
            ),
          ),

          SizedBox(height: 20),

          // Buttons: Edit and Save
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isEditing = true; // Enable editing
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2C812A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // Square shape
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 35, vertical: 12),
                ),
                child: Text(
                  'Edit',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 5),
              ElevatedButton(
                onPressed: isEditing ? _saveUserData : null, // Save only when editing
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2C812A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // Square shape
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 35, vertical: 12),
                ),
                child: Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
            ]
                  )
                )
            )
          )
        ]
      )
    )
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