import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:qr_code_tools/qr_code_tools.dart';
import 'package:thesis_establishment/Establishment%20Profile/EstabProfile.dart'; // Import the QR code tools

class UploadQR extends StatefulWidget {
  @override
  _UploadQRState createState() => _UploadQRState();
}

class _UploadQRState extends State<UploadQR> {
  int _selectedIndex = 0; // Default selection for bottom navigation bar
  FilePickerResult? _selectedFiles;
  List<PlatformFile> _validFiles = [];

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
  

  Future<void> _pickFiles() async {
    try {
      _selectedFiles = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'gif'],
        allowMultiple: true,
      );

      if (_selectedFiles != null) {
        List<PlatformFile> validatedFiles = [];
        for (var file in _selectedFiles!.files) {
          // Check if the file contains a valid QR code
          String? qrCodeContent = await QrCodeToolsPlugin.decodeFrom(file.path!);
          if (qrCodeContent != null && qrCodeContent.isNotEmpty) {
            validatedFiles.add(file);
          } else {
            // Show the error dialog if the file doesn't have a valid QR code
            _showInvalidQRCodeDialog();
          }
        }

        setState(() {
          _validFiles = validatedFiles;
        });
      }
    } catch (e) {
      print("Error occurred while picking files: $e");
    }
  }

  // Function to display an error dialog if the uploaded image doesn't have a valid QR code
  void _showInvalidQRCodeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('QR Code is Not Valid'),
          content: Text(
            'Uploaded image is not a valid QR code image. Please upload a valid QR code image.',
          ),
          actions: [
            Center(
              child: SizedBox(
                width: 200, // Set button width
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFF288F13), // Button background color
                  ),
                  child: Text(
                    'Okay',
                    style: TextStyle(
                      color: Colors.white, // Button text color
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Navigate back
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.arrow_back, color: Colors.black),
                    ),
                  ),
                  SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 80.0), // Adjust this value to move the text
                    child: Text(
                      'Upload QR',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.left, // Align the text to the left
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Center(
                child: _buildUploadContainer(), // White box with the image and button
              ),
            ),
          ],
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

  // Build the white box with the upload button and image
  Widget _buildUploadContainer() {
    return Container(
      width: 350,
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(top: 10, bottom: 60),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Upload your files',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Container(
            width: 310,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Image.asset(
                'assets/Addfile.png', // Replace with your image asset path
                width: 120,
                height: 120,
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Supported file types: PNG, JPG, GIF (Max 5MB)',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 150, // Adjust the width as needed
              child: ElevatedButton(
                onPressed: _pickFiles, // Pick files when pressed
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF288F13), // Button background color
                  foregroundColor: Colors.white, // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  child: Text(
                    'UPLOAD',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_validFiles.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Selected files:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ListView.separated(
                    shrinkWrap: true,
                    itemCount: _validFiles.length,
                    itemBuilder: (context, index) {
                      return Text(
                        _validFiles[index].name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: 5);
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
