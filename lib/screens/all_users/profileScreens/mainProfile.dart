import 'dart:io'; // For File
import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/info.dart';
import 'package:flutter_application_1/config.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/screens/all_users/profileScreens/Mysupervisor.dart';
import 'package:flutter_application_1/screens/all_users/profileScreens/personalInfoScreen.dart';
import 'package:flutter_application_1/screens/all_users/profileScreens/EditPasswordScreen.dart';
import 'package:flutter_application_1/screens/all_users/profileScreens/prgressTracker.dart';
import 'package:flutter_application_1/screens/login/welcome_screen.dart';
import 'package:flutter_application_1/widgets/custom_home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final String emaill;

  const ProfileScreen({required this.emaill, Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _profileImageUrl;
  String _role = ROLE; // Default role
  String? _userName;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      // Fetch the image URL
      final profileImageUrl = await fetchUserImage(widget.emaill);

      // Fetch the user's full name
      final userName = await getUserFullName(widget.emaill);

      // Update the state synchronously
      setState(() {
        _profileImageUrl = profileImageUrl;
        _userName = userName;
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
          storageRef.child('profilepicture/${widget.emaill}.jpg');
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

  Future<void> _handleLogout(BuildContext context) async {
    await SharedPreferences.getInstance().then((prefs) => prefs.clear());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You have been logged out')),
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomHomePage(
      emaill: widget.emaill,
      body: Column(
        children: [
          // Header
          Container(
            height: 70,
            color: offwhite,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: ourPink),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 8),
                const Text(
                  'My profile',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 58, 57, 57),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.logout, color: ourPink, size: 33),
                  onPressed: () {
                    _handleLogout(context);
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: ourPink,
                              backgroundImage: _profileImageUrl != null
                                  ? NetworkImage(_profileImageUrl!)
                                  : null,
                              child: _profileImageUrl == null
                                  ? const Icon(Icons.person,
                                      size: 50, color: Colors.white)
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _userName ?? "...",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ourPink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Personal Information Card
                    Card(
                      color: logoBar,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      child: ListTile(
                        leading: const Icon(Icons.info, color: ourPink),
                        title: const Text(
                          'Personal information',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: const Text('email ,name and birthdate'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PersonalInfoScreen(emaill: widget.emaill),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Progress Tracker Card (Only for ROLE = 'user')
                    if (_role == 'user')
                      Card(
                        color: logoBar,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        child: ListTile(
                          leading:
                              const Icon(Icons.track_changes, color: ourPink),
                          title: const Text(
                            'Progress tracker',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          subtitle: const Text(
                              'Track your reading, story creation, and course progress!'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // Navigate to Progress Tracker Screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProgressTrackerPage(
                                  email: EMAIL,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Settings Card
                    Card(
                      color: logoBar,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      child: ListTile(
                        leading: const Icon(Icons.settings, color: ourPink),
                        title: const Text(
                          'Settings',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        subtitle: const Text('Edit password'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditPasswordScreen(emaill: widget.emaill),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),
                    if (_role == 'user')
                      FutureBuilder(
                        future: fetchSuperEmail(EMAIL),
                        builder: (context, emailSnapshot) {
                          if (emailSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (emailSnapshot.hasError ||
                              !emailSnapshot.hasData ||
                              emailSnapshot.data == null) {
                            return const Center(
                                child: Text(
                                    'Unable to fetch supervisor information'));
                          }

                          final supervisorEmail = emailSnapshot.data as String;

                          return FutureBuilder(
                            future: getUserFullName(supervisorEmail),
                            builder: (context, nameSnapshot) {
                              if (nameSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (nameSnapshot.hasError ||
                                  !nameSnapshot.hasData ||
                                  nameSnapshot.data == null) {
                                return const Center(
                                    child: Text(
                                        'Unable to fetch supervisor name'));
                              }

                              final supervisorName =
                                  nameSnapshot.data as String;

                              return Card(
                                color: logoBar,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 5,
                                child: ListTile(
                                  leading:
                                      const Icon(Icons.person, color: ourPink),
                                  title: Text(
                                    'My supervisor: $supervisorName',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  //You can contact your supervisor for guidance
                                  subtitle: Text(
                                    '\n $supervisorEmail',
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SupervisorInfoPage(
                                          supervisorEmail: supervisorEmail,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
