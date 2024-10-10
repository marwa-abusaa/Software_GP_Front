import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/screens/all_users/profileScreens/personalInfoScreen.dart';
import 'package:flutter_application_1/screens/all_users/profileScreens/EditPasswordScreen.dart';
import 'package:flutter_application_1/screens/login/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class ProfileScreen extends StatelessWidget {
  late String emaill;

  ProfileScreen({required this.emaill, Key? key}) : super(key: key);

  Future<void> _handleLogout(BuildContext context) async {
    // Clear user session or token here (this could involve shared preferences, etc.)
    // Example:
    await SharedPreferences.getInstance().then((prefs) => prefs.clear());

    // Optionally show a message to the user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You have been logged out')),
    );

    // Navigate to the login screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WelcomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(emaill);
    return Scaffold(
      backgroundColor: offwhite, // Background color for the screen
      body: Column(
        children: [
          // Custom Header
          // Custom Header
          Container(
            height: 80, // Set the height you need
            color: offwhite, // Background color matches the rest of the screen
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Back button
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: ourPink),
                  onPressed: () {
                    Navigator.pop(context); // Action to go back
                  },
                ),
                const SizedBox(width: 8), // Space between back button and title
                const Text(
                  'My profile',
                  style: TextStyle(
                    fontSize: 22, // Adjust font size as needed
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 58, 57, 57),
                  ),
                ),
                const Spacer(), // Push logout button to the end
                // Logout button
                IconButton(
                  icon: const Icon(Icons.logout, color: ourPink, size: 33,),
                  onPressed: () {
                    // Handle logout
                    _handleLogout(context);
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              // Makes the screen scrollable
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Aligns text to start
                  children: [
                    // Profile Icon
                    const Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: ourPink,
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "User name",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ourPink, // Text color matches the theme
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                        height: 32), // Space between avatar and cards

                    // Personal Information Card
                    Card(
                      color: logoBar,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5, // Shadow for a professional look
                      child: ListTile(
                        leading: const Icon(Icons.info,
                            color: ourPink), // Add an icon here
                        title: const Text(
                          'Personal information',
                          style: TextStyle(
                              fontWeight:
                                  FontWeight.bold, // Makes the title bold
                              fontSize: 14),
                        ),
                        subtitle: const Text('email and phone number'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // Print email
                          print("marwaAya" + emaill);
                          // Navigate to Personal Information Screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PersonalInfoScreen(emaill: emaill),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16), // Space between cards

                    // Progress Tracker Card
                    Card(
                      color: logoBar,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      child: ListTile(
                        leading: const Icon(Icons.track_changes,
                            color: ourPink), // Add an icon here
                        title: const Text(
                          'Progress tracker',
                          style: TextStyle(
                              fontWeight:
                                  FontWeight.bold, // Makes the title bold
                              fontSize: 15),
                        ),
                        subtitle: const Text('مش عارفة شو اكتب'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // Navigate to Service Information Screen
                        },
                      ),
                    ),
                    const SizedBox(height: 16), // Space between cards

                    // Settings Card
                    Card(
                      color: logoBar,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      child: ListTile(
                        leading: const Icon(Icons.settings,
                            color: ourPink), // Add an icon here
                        title: const Text(
                          'Settings',
                          style: TextStyle(
                              fontWeight:
                                  FontWeight.bold, // Makes the title bold
                              fontSize: 15),
                        ),
                        subtitle: const Text('Edit password'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // Print email
                          print("marwaAya" + emaill);
                          // Navigate to Settings Screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditPasswordScreen(emaill: emaill),
                            ),
                          );
                        },
                      ),
                    ),
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
