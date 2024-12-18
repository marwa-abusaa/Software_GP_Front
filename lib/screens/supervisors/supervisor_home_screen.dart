import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/screens/login/addContest_screen.dart';
import 'package:flutter_application_1/screens/supervisors/addCourses_screen.dart';
import 'package:flutter_application_1/screens/supervisors/allchildren.dart';
import 'package:flutter_application_1/widgets/custom_home.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_application_1/config.dart';
import 'package:flutter_application_1/api/notification_services.dart';

class SupervisorHomeScreen extends StatefulWidget {
  final token;
  const SupervisorHomeScreen({@required this.token, Key? key})
      : super(key: key);

  @override
  State<SupervisorHomeScreen> createState() => _SupervisorHomeScreenState();
}

class _SupervisorHomeScreenState extends State<SupervisorHomeScreen> {
  late String emaill;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    emaill = jwtDecodedToken['email'];
    EMAIL = emaill;
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
  }

  @override
  Widget build(BuildContext context) {
    return CustomHomePage(
      emaill: EMAIL,
      //backgroundColor: offwhite,
      body: Column(children: [
        //const SizedBox(height: 18,),
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
                                  'Go to competitions',
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
                      MaterialPageRoute(
                          builder: (context) => SupervisorChildrenPage(
                                superEmail: EMAIL,
                              )),
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
                        Icon(Icons.face, color: ourPink, size: 50),
                        Text('Children',
                            style: TextStyle(
                                color: ourPink, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                // Second Button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddCoursesScreen(
                                token: TOKEN,
                              )),
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
                        Icon(Icons.add, color: ourPink, size: 50),
                        Text('Add Courses',
                            style: TextStyle(
                                color: ourPink, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                // Third Button
                GestureDetector(
                  // onTap: () {
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(builder: (context) => ThirdScreen()),
                  //   );
                  // },
                  child: Container(
                    decoration: BoxDecoration(
                      color: orangee,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book, color: ourPink, size: 50),
                        Text('Usesr\'s Stories',
                            style: TextStyle(
                                color: ourPink, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                // Fourth Button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddCompetitionsScreen(
                                token: TOKEN,
                              )),
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
                        Icon(Icons.military_tech, color: ourPink, size: 50),
                        Text('Add Contest',
                            style: TextStyle(
                                color: ourPink, fontWeight: FontWeight.bold)),
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
