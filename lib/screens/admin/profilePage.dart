import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/info.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io'; // For File
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_1/config.dart';
import 'package:http/http.dart' as http;


class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Controllers للحفاظ على البيانات المكتوبة في الحقول
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? _profileImageUrl;
  String? _userName;
  final ImagePicker _imagePicker = ImagePicker();


//update profile
 void updateProfile() async {
    if (EMAIL.isNotEmpty) {
      var reqBody = {
        "email": EMAIL,
        "firstName": firstnameController.text,
        "lastName": lastnameController.text,
      };

      var response = await http.patch(
        Uri.parse(myProfile),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody),
      );
      print("Updated code: " + response.statusCode.toString());

      if (response.statusCode == 200) {
        print("Updated successfully");
        showSuccessDialog(); // Show success popup
        initState();
      } else {
        showErrorSnackbar('Something went wrong. Please try again later.');
      }
    }
  }

   void showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

    void showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                color: ourPink,
                size: 80, // Increase the size of the tick icon
              ),
              SizedBox(height: 20),
              Text(
                'Data updated successfully!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center, // Center the text
              ),
            ],
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
             
                },
                child: const Text(
                  'OK',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

   @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    emailController.text=EMAIL;
  }

   Future<void> _fetchUserProfile() async {
    try {
      // Fetch the image URL
      final profileImageUrl = await fetchUserImage(EMAIL);

      // Fetch the user's full name
      final userName = await getUserFullName(EMAIL);

      List<String> nameParts = userName.split(' ');
      String firstName = nameParts.isNotEmpty ? nameParts[0] : '';
      String lastName = nameParts.length > 1 ? nameParts[1] : '';

      // Update the state synchronously
      setState(() {
        _profileImageUrl = profileImageUrl;
        _userName = userName;

      firstnameController.text = firstName;
      lastnameController.text = lastName;

      });
    } catch (e) {
      print('Error fetching profile data: $e');
    }
  }
    Future<void> _updateProfileImage(File imageFile) async {
    try {
      // Upload to Firebase
      final storageRef = FirebaseStorage.instance.ref();
      final profilePictureRef =
          storageRef.child('profilepicture/${EMAIL}.jpg');
      final uploadTask = await profilePictureRef.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Update in MongoDB
      final success = await updateUserImage(EMAIL, downloadUrl);
      if (success) {
        setState(() {
          _profileImageUrl = downloadUrl;
        });
      }
    } catch (e) {
      print('Error updating profile image: $e');
    }
  }

    Future<void> _pickImage() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      await _updateProfileImage(imageFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
       onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: orangee,
        body: SingleChildScrollView(
          child: Column(
            children: [
               const SizedBox(height: 80),
               Transform.translate(
                offset: Offset(-150, 0),
                 child: IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: ourPink),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  ),
               ),
               const SizedBox(height: 17),
              CircleAvatar(
                radius: 70,
                backgroundColor: ourPink,
                backgroundImage: _profileImageUrl != null ? NetworkImage(_profileImageUrl!): null,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: orangee,                   
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Icon(Icons.camera_alt, size: 25, color: ourBlue,)),
                  ),
                ),
              ),
             
              const SizedBox(height: 20),
              Container(
                decoration: const BoxDecoration(
                  color: offwhite,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                child: Column(
                  children: [
                   const Text(
                  'Profile',
                  style: TextStyle(
                    color: ourPink,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Raleway'
                  ),
                ),
                const SizedBox(height: 20),
                    _buildTextField(
                      label: 'First Name',
                      icon: Icons.person,
                      controller: firstnameController,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'Last Name',
                      icon: Icons.person_outline,
                      controller: lastnameController,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'Email',
                      icon: Icons.email,
                      controller: emailController,
                    ),
                    const SizedBox(height: 20),
                     _buildTextField(
                      label: 'Password',
                      icon: Icons.lock,
                      //hint: 'أدخل كلمة المرور',
                      controller: passwordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        // طباعة القيم المكتوبة في الحقول
                        print('First Name ${firstnameController.text}');
                        print('Last Name ${lastnameController.text}');
                        print('Email ${emailController.text}');
                        print('Password ${passwordController.text}');
                        updateProfile();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ourPink,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.save, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Save updates',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

Widget _buildTextField({
  required String label,
  required IconData icon,
  required TextEditingController controller,
  bool obscureText = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, color: ourPink),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Raleway'
            ),
          ),
        ],
      ),
      //const SizedBox(height: 5),
        TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          isDense: true, // تصغير الحقل النصي
          contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0), // التحكم بارتفاع الحقل
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
        ),
        readOnly: controller==emailController? true: false,
      ),
      const Divider(
        thickness: 1.5,
        color: Colors.grey,
      ),
      //const SizedBox(height: 15),
    ],
  );
}


}

