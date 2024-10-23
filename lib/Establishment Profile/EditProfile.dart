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

      // Fetch user data based on the email
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('establishments')
          .where('email', isEqualTo: email)
          .get();

      // Debugging: Check how many documents were found
      print('Documents found: ${snapshot.docs.length} for email: $email');

      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = snapshot.docs.first; // Get the first document

        setState(() {
          establishmentName = userDoc['establishmentName'] ?? 'N/A';
          address = userDoc['barangay'] ?? 'N/A';
          website = userDoc['website'] ?? 'N/A'; // Ensure the field name is correct
          mobileNumber = userDoc['contact'] ?? 'N/A';

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
       const SnackBar(content: Text('Profile updated successfully!')),
      );
    }
  } catch (e) {
    print('Error saving data: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(content: Text('Failed to save profile')),
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
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C812A),
          ),
        ),
       const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: isEditing
              ? TextField(
                  controller: controller,
                  inputFormatters: inputFormatters,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                )
              : Text(
                  controller.text.isNotEmpty ? controller.text : 'N/A',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
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
       const SizedBox(height: 16),
        Text(
          labelText,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C812A),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            value.isNotEmpty ? value : 'N/A',
            style: const TextStyle(fontSize: 16, color: Colors.black),
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
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
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
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.black,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 75),
                          const Text(
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
                              offset: const Offset(0, 3),
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
                                    decoration: const BoxDecoration(
                                      color: Colors.black,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 65,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Text(
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
              const Text(
                "Photos",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C812A),
                ),
              ),
             const SizedBox(height: 8),
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
                      child: const Center(
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
                 const SizedBox(width: 18),
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
             const SizedBox(height: 8),
              Text(
                '*Drag and drop to rearrange your photos.\n'
                '*First photos above will be your cover/featured photo.\n'
                '*You can upload up to 5 photos.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
             const Text(
                "Description",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C812A),
                ),
              ),
             const SizedBox(height: 8),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFF898989), width: 2),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  children: [
                    TextField(
                      maxLines: null,
                      controller: _controller,
                      onChanged: onDescriptionChanged,
                      decoration: const InputDecoration(
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
             const SizedBox(height: 16), // Space before social links
              // Social Links section
              const Text(
                "Social Links",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C812A),
                ),
              ),
              const SizedBox(height: 8),
              const Row(
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
          const SizedBox(height: 16),
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
              decoration: const InputDecoration(
                hintText: 'Enter Facebook link here...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(10),
              ),
              style: const TextStyle(
                color: Color(0xFF2C812A),
              ),
            ),
          ),

          SizedBox(height: 16),

          // Instagram
          const Row(
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
              decoration: const InputDecoration(
                hintText: 'Enter Instagram link here...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(10),
              ),
              style: const TextStyle(
                color: Color(0xFF2C812A),
              ),
            ),
          ),

        const SizedBox(height: 16),

          // Twitter
         const Row(
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
              decoration: const InputDecoration(
                hintText: 'Enter Twitter link here...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(10),
              ),
              style: const TextStyle(
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
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // Square shape
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 12),
                ),
                child: const Text(
                  'Edit',
                  style: TextStyle(color: Colors.white),
                ),
              ),
             const SizedBox(width: 5),
              ElevatedButton(
                onPressed: isEditing ? _saveUserData : null, // Save only when editing
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C812A),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // Square shape
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 12),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
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