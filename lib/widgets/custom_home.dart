import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/api.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/screens/admin/addNewImage.dart';
import 'package:flutter_application_1/screens/StoryDesign/myBooks.dart';
import 'package:flutter_application_1/screens/chatting/chat_home.dart';
import 'package:flutter_application_1/screens/supervisors/childRequests.dart';
import 'package:flutter_application_1/screens/supervisors/supervisor_home_screen.dart';
import 'package:flutter_application_1/screens/users/follow/followScreen.dart';
import 'package:flutter_application_1/screens/users/home_screen.dart';
import 'package:flutter_application_1/screens/all_users/profileScreens/mainProfile.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_application_1/config.dart';
import 'package:http/http.dart' as http;


class CustomHomePage extends StatefulWidget {
  late String emaill;

  CustomHomePage({
    required this.emaill,
    Key? key,
    this.body,
  }) : super(key: key);
  final Widget? body;

  @override
  _CustomHomePageState createState() => _CustomHomePageState();
}

class _CustomHomePageState extends State<CustomHomePage> {

  Map<String, dynamic>? userScores;
  int? totalPoints;

  Future<void> fetchTotal() async {
    try {
      final response = await http.post(
        Uri.parse('$child/totalScore'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': EMAIL}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            totalPoints = data['total'];
          });
        }
      } else {
        print('Failed to fetch total: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching total: $e');
    }
  }

  Future<void> fetchUserScores() async {
    try {
      final response = await http.get(
        Uri.parse('$child?email=$EMAIL'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          setState(() {
            userScores = data['data'];
          });
        }
      } else {
        print('Failed to fetch user profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }
  //late String email_token;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchUserScores(); 
    fetchTotal();
    // Map<String,dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    // email_token = jwtDecodedToken['email'];
  }

  int currentTab = 0;

  void showScoreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        if (userScores == null){
            return const Center(child: CircularProgressIndicator());
        }
        return Dialog(
          backgroundColor: offwhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SizedBox(
            height: 400, // Increase the height here
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo image in center
                  Image.asset(
                    'assets/images/score.png', // Replace with your logo image
                    width: 70,
                    height: 70,
                  ),
                  const SizedBox(height: 10),

                  // "Score : 10"
                   Text(
                    'Score: $totalPoints',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: score),
                  ),
                  const SizedBox(height: 28),

                  // Star icon and text
                   Row(
                    children: [
                      Icon(Icons.star, color: score),
                      SizedBox(width: 10),

                      // Text.rich allows for multiple text styles
                      Text.rich(
                        // Start of Text.rich for styled text
                        TextSpan(
                          // Start of TextSpan
                          text: 'Created Stories: ', // Text before the number
                          style: const TextStyle(
                              color: Color.fromARGB(255, 111, 111, 111),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              fontFamily:
                                  'Times New Roman'), // Default text style
                          children: <TextSpan>[
                            // Start of children TextSpan
                            TextSpan(
                              text:
                                  userScores!['createdStroryNum'].toString(), // The number (5) that will have a different style
                              style: const TextStyle(
                                  color:
                                      score, // Change the color of the number to red
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18 // Make the number bold
                                  ),
                            ),
                          ], // End of children TextSpan
                        ), // End of TextSpan
                      ), // End of
                    ],
                  ),
                  const Divider(),

                  // Second entry
                   Row(
                    children: [
                      Icon(Icons.star, color: score),
                      SizedBox(width: 10),
                      // Text.rich allows for multiple text styles
                      Text.rich(
                        // Start of Text.rich for styled text
                        TextSpan(
                          // Start of TextSpan
                          text: 'Finished Courses: ', // Text before the number
                          style: const TextStyle(
                              color: Color.fromARGB(255, 111, 111, 111),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              fontFamily:
                                  'Times New Roman'), // Default text style
                          children: <TextSpan>[
                            // Start of children TextSpan
                            TextSpan(
                              text:
                                  userScores!['coursesNum'].toString(), // The number (5) that will have a different style
                              style: const TextStyle(
                                  color:
                                      score, // Change the color of the number to red
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18 // Make the number bold
                                  ),
                            ),
                          ], // End of children TextSpan
                        ), // End of TextSpan
                      ), // End of
                    ],
                  ),
                  const Divider(),

                  // Third entry
                   Row(
                    children: [
                      Icon(Icons.star, color: score),
                      SizedBox(width: 10),
                      // Text.rich allows for multiple text styles
                      Text.rich(
                        // Start of Text.rich for styled text
                        TextSpan(
                          // Start of TextSpan
                          text: 'Courses Score: ', // Text before the number
                          style: const TextStyle(
                              color: Color.fromARGB(255, 111, 111, 111),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              fontFamily:
                                  'Times New Roman'), // Default text style
                          children: <TextSpan>[
                            // Start of children TextSpan
                            TextSpan(
                              text:
                                  userScores!['points'].toString(), // The number (5) that will have a different style
                              style: const TextStyle(
                                  color:
                                      score, // Change the color of the number to red
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18 // Make the number bold
                                  ),
                            ),
                          ], // End of children TextSpan
                        ), // End of TextSpan
                      ), // End of
                    ],
                  ),
                  const Divider(),

                  // Fourth entry
                   Row(
                    children: [
                      Icon(Icons.star, color: score),
                      SizedBox(width: 10),
                      // Text.rich allows for multiple text styles
                      Text.rich(
                        // Start of Text.rich for styled text
                        TextSpan(
                          // Start of TextSpan
                          text: 'Competitions: ', // Text before the number
                          style: const TextStyle(
                              color: Color.fromARGB(255, 111, 111, 111),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily:
                                  'Times New Roman'), // Default text style
                          children: <TextSpan>[
                            // Start of children TextSpan
                            TextSpan(
                              text:
                                  userScores!['contestsNum'].toString(), // The number (5) that will have a different style
                              style: const TextStyle(
                                  color:
                                      score, // Change the color of the number to red
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18 // Make the number bold
                                  ),
                            ),
                          ], // End of children TextSpan
                        ), // End of TextSpan
                      ), // End of
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(110.0), // التحكم في ارتفاع الـ AppBar
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: offwhite, // لون الخلفية مشابه للصورة
          //elevation: 0, // إزالة الظل لجعلها مسطحة
          flexibleSpace: Stack(
            children: [
              Positioned(
                top: -19, // للتحكم في مكان الصورة
                left: -47, // لجعل الصورة على اليسار
                child: Image.asset(
                  'assets/images/logo2.png', // المسار إلى صورة الشعار
                  width: 220,
                  height: 220,
                ),
              ),
              Positioned(
                top: 51,
                right: 15,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (ROLE == "user") // Check if the role is "user"
                      GestureDetector(
                        onTap: () {
                          print("Score tapped");
                          showScoreDialog(context);
                        },
                        child: Image.asset(
                          'assets/images/score.png', // Path to the score image
                          width: 50,
                          height: 50,
                        ),
                      ),
                    if (ROLE ==
                        "user") // Display the score text only if role is "user"
                      const SizedBox(height: 2),
                    if (ROLE == "user")
                      totalPoints==null? Text('') : Text(
                         'Score: $totalPoints', // The text under the icon
                        style: const TextStyle(
                          fontSize: 13,
                          color: score, // Change the color as needed
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      body: widget.body, backgroundColor: offwhite,
      // backgroundColor: offwhite,
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 60.0, // Adjust the width as needed
        height: 60.0, // Adjust the height as needed
        child: FloatingActionButton(
          onPressed: () {
            print("Home tapped!");
            if (ROLE == "user") {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HomeScreen(
                          token: TOKEN,
                        )),
              );
            } else if (ROLE == "supervisor") {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SupervisorHomeScreen(
                          token: TOKEN,
                        )),
              );
            }
          }, // Adjust icon size if needed
          backgroundColor: iconsBar,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.home, size: 40),
        ),
      ),

      bottomNavigationBar: BottomAppBar(
        notchMargin: 6.0,
        height: 73,
        shape: const CircularNotchedRectangle(),
        color: ourPink,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            // Profile Icon
            GestureDetector(
              onTap: () {
                // Action for Profile
                print("Profile tapped!");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ProfileScreen(emaill: widget.emaill)),
                );
                setState(() {
                  //currentScreen=ProfileScreen(emaill: emaill);
                  currentTab = 1;
                });
                // Navigate to Profile Page or perform other action
              },
              child: Padding(
                padding: const EdgeInsets.only(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person,
                      color: currentTab == 1 ? iconsBar : Colors.white,
                      size: 30,
                    ),
                    // Text(
                    //   "Profile",
                    //   style: TextStyle(color: currentTab==1 ? iconsBar : Colors.white,),
                    // ),
                  ],
                ),
              ),
            ),
            // Stories Icon
            GestureDetector(
              onTap: () {
                // Action for Stories
                print("Stories tapped!");
                if (ROLE == "user") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyBooksPage()),
                  );
                } else if (ROLE == "supervisor") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookRequestPage(),
                    ),
                  );
                  print("All Stories Supervisor");
                }

                // Navigate to Stories Page or perform other action
                setState(() {
                  //currentScreen=MyStoriesScreen(emaill: emaill);
                  currentTab = 2;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 70),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.book,
                      color: currentTab == 2 ? iconsBar : Colors.white,
                      size: 30,
                    ),
                    // Text(
                    //   "Stories",
                    //   style: TextStyle(color: currentTab==2 ? iconsBar : Colors.white,),
                    // ),
                  ],
                ),
              ),
            ),
            // Notification Icon
            GestureDetector(
              onTap: () {
                // Action for Notifications
                print("Notifications tapped!");
                //// temp
                ///
                ///
                if (ROLE == 'user') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UsersPage(
                              currentUserEmail: EMAIL,
                            )),
                  );
                }
                // Navigate to Notifications Page or perform other action
                setState(() {
                  //currentScreen=Notifications(emaill: emaill);
                  currentTab = 3;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.group,
                      color: currentTab == 3 ? iconsBar : Colors.white,
                      size: 30,
                    ),
                    // Text(
                    //   "Notification",
                    //   style: TextStyle(color: currentTab==3 ? iconsBar : Colors.white,),
                    // ),
                  ],
                ),
              ),
            ),
            // Chat Icon
            GestureDetector(
              onTap: () {
                print("<<<<<<<<>>>>>>> email is " + EMAIL);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => chat_home_screen(
                          emaill: APIS.currentEmail.toString())),
                );
                // Action for Chat
                print("Chat tapped!");
                // Navigate to Chat Page or perform other action
                setState(() {
                  //currentScreen=Chatting(emaill: emaill);
                  currentTab = 4;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat,
                      color: currentTab == 4 ? iconsBar : Colors.white,
                      size: 30,
                    ),
                    // Text(
                    //   "Chat",
                    //   style: TextStyle(color: currentTab==4 ? iconsBar : Colors.white,),
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
