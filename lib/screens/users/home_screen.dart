import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/api.dart';
import 'package:flutter_application_1/api/info.dart';
import 'package:flutter_application_1/api/notification_services.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/screens/StoryDesign/story.dart';
import 'package:flutter_application_1/screens/books/bookMainPage.dart';
import 'package:flutter_application_1/screens/users/contests/contests_screen.dart';
import 'package:flutter_application_1/screens/users/courses_screen.dart';
import 'package:flutter_application_1/widgets/custom_home.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_application_1/config.dart';

class HomeScreen extends StatefulWidget {
  final token;
  const HomeScreen({@required this.token, Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String emaill;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    APIS.getSelfInfo();
    //APIS.getFirebaseMessagingToken();
    String deviceToken =
        "fo0_UbmvQBeTpi6J7rxGac:APA91bELUZqVpqwTtipKZCAu9w_OVmqW6kFxZVpV_ympp2NlD0jyo5qaZLAWKRwWS_ZiAFHrVhk55nqaI5QNV-qFS_gLXcos0v8p_GrvzXcHd8QYKJdYO60MhvWwsSMK2rILiDQmDSbQ";

    try {
      NotificationService.sendNotification(
        deviceToken,
        "Test Notification",
        "This is a test notification from Tiny Tales!",
      );
      print("Notification test completed");
    } catch (e) {
      print("Error while sending notification: $e");
    }
    NotificationService.sendNotificationToAll("all notification", "test test");
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    emaill = jwtDecodedToken['email'];
    EMAIL = emaill;
    // Fetch the superEmail asynchronously
    fetchSuperEmail(emaill).then((superEmail) {
      if (superEmail != null) {
        APIS.initializeSuperEmail(superEmail);
        print("Super email is<<<< $superEmail >>>>");
      } else {
        print("Failed to fetch superEmail.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomHomePage(
      emaill: emaill,
      //backgroundColor: offwhite,
      body: Column(children: [
        //const SizedBox(height: 1,),

        Expanded(
          flex: 0,
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  // Navigate to another screen when the image is tapped
                  print("tapppped");
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: ourPink, // Set the border color
                      width: 2, // Set the border width
                    ),
                    borderRadius: BorderRadius.circular(
                        12), // Optional: Set rounded corners
                  ),
                  child: Stack(
                    children: [
                      Opacity(
                        opacity: 0.6, // Set the opacity value here (0.0 to 1.0)
                        child: Image.asset(
                          'assets/images/advert.png', // Replace with the path to your image
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 135,
                        right: 0,
                        child: SizedBox(
                          width: 150, // Set the desired width
                          height: 25, // Set the desired height
                          child: ElevatedButton(
                            onPressed: () {
                              // Add action for the button
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: orangee, // Background color
                              textStyle: const TextStyle(
                                fontSize: 10, // Set font size
                                fontWeight: FontWeight.bold, // Set font weight
                                fontStyle: FontStyle.italic, // Set font style
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    12), // Set border radius
                              ),
                              padding: EdgeInsets.zero, // Remove padding
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .center, // Center the contents
                              children: [
                                //SizedBox(width: 5), // Add some spacing between text and icon
                                Icon(
                                  Icons
                                      .arrow_forward, // Change this to your desired arrow icon
                                  color: ourPink, // Icon color
                                  size: 16, // Adjust the size as needed
                                ),

                                Text(
                                  'Go to contests',
                                  style: TextStyle(color: ourPink),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 30,
        ),

        // Second part - Grid of 4 square buttons
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 20.0,
              mainAxisSpacing: 20.0,
              children: [
                // First Button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BookHomePage()),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFffe4cc),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book, color: ourPink, size: 50),
                        Text('All stories', style: TextStyle(color: ourPink)),
                      ],
                    ),
                  ),
                ),
                // Second Button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CoursesScreen()),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: orangee,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.school, color: ourPink, size: 50),
                        Text('Courses', style: TextStyle(color: ourPink)),
                      ],
                    ),
                  ),
                ),
                // Third Button
                GestureDetector(
                  onTap: () {
                    print("compppp tapped!");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ContestsScreen(
                                token: TOKEN,
                              )),
                    );
                    print(emaill);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: orangee,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.emoji_events, color: ourPink, size: 50),
                        Text('Contests', style: TextStyle(color: ourPink)),
                      ],
                    ),
                  ),
                ),
                // Fourth Button
                GestureDetector(
                  onTap: () {
                    print("Create stroy tapped!");
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditorPage()),
                    );
                    print(emaill);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFffe4cc),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.create, color: ourPink, size: 50),
                        Text('Create story', style: TextStyle(color: ourPink)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        //SizedBox(height: 50,)
      ]),
    );
  }
}
