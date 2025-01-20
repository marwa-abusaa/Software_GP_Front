import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/screens/supervisors/childRequests.dart';
import 'package:flutter_application_1/screens/users/home_screen.dart';
import 'package:flutter_application_1/screens/all_users/profileScreens/mainProfile.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_application_1/config.dart';

class CustomSupervisorHomePage extends StatefulWidget {
  CustomSupervisorHomePage({
    super.key,
    this.body,
  });
  final Widget? body;

  @override
  _CustomSupervisorHomePageState createState() =>
      _CustomSupervisorHomePageState();
}

class _CustomSupervisorHomePageState extends State<CustomSupervisorHomePage> {
  //late String email_token;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Map<String,dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    // email_token = jwtDecodedToken['email'];
  }

  int currentTab = 0;

  void showScoreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                  const Text(
                    'Score: 10',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: score),
                  ),
                  const SizedBox(height: 28),

                  // Star icon and text
                  const Row(
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
                                  '5', // The number (5) that will have a different style
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
                  const Row(
                    children: [
                      Icon(Icons.star, color: Colors.yellow),
                      SizedBox(width: 10),
                      // Text.rich allows for multiple text styles
                      Text.rich(
                        // Start of Text.rich for styled text
                        TextSpan(
                          // Start of TextSpan
                          text: 'Read Stories: ', // Text before the number
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
                                  '5', // The number (5) that will have a different style
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
                  const Row(
                    children: [
                      Icon(Icons.star, color: Colors.yellow),
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
                                  '5', // The number (5) that will have a different style
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
                  const Row(
                    children: [
                      Icon(Icons.star, color: Colors.yellow),
                      SizedBox(width: 10),
                      // Text.rich allows for multiple text styles
                      Text.rich(
                        // Start of Text.rich for styled text
                        TextSpan(
                          // Start of TextSpan
                          text: 'Competitions Won: ', // Text before the number
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
                                  '5', // The number (5) that will have a different style
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
                top: 51, // لضبط محاذاة النص مع الشعار
                right: 15, // لضبط محاذاة الصورة على اليمين
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        print("Score tapped");
                        // استدعاء الدالة لعرض الـ score أو تنفيذ إجراء
                        showScoreDialog(context);
                      },
                      child: Image.asset(
                        'assets/images/score.png', // المسار إلى صورة التقييم
                        width: 50,
                        height: 50,
                      ),
                    ),
                    const SizedBox(height: 2), // مسافة بين الصورة والنص
                    const Text(
                      'Score: 0', // The text under the icon
                      style: TextStyle(
                        fontSize: 10,
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

      body: widget.body,
      // backgroundColor: offwhite,

      //backgroundColor: offwhite,

//         body: Column(
//           children: [
//             Expanded(
//               flex: 1,
//               child: Stack(
//                 children: [
//           Positioned(
//             top: -15,  // Adjust this value to move the image further down or up
//             left: -45, // Adjust this value to move the image further left or right
//             child: Image.asset(
//               'assets/images/logo2.png', // Replace with the path to your image
//               width: 210,  // Adjust the width of the image
//               height: 210, // Adjust the height of the image
//             ),
//           ),
//           Positioned(
//             top: 50, // Same top alignment for the logo and score
//             left: 0, // Stretch across the width of the screen
//             right: -5, // Stretch across the width of the screen
//             child: Row(
//               children: [
//                 // Spacer to push the score icon to the right side
//                 const Spacer(),
//                Column(
//   children: [
//     GestureDetector(
//       onTap: () {
//         print(emaill);
//         // Call the function to show the dialog
//         showScoreDialog(context);
//       },
//       child: Image.asset(
//         'assets/images/score.png',  // Replace with the path to your image
//         width: 50,  // Adjust the width of the image
//         height: 50, // Adjust the height of the image
//       ),
//     ),
//     const Text(
//       'Score: 0',  // The text under the icon
//       style: TextStyle(
//         fontSize: 10,
//         color: score,  // Change the color as needed
//       ),
//     ),
//   ],
// ),

//                 const SizedBox(width: 20), // Add some padding on the right
//               ],
//             ),
//           ),
//         ],

//               )
//             ),

//             Expanded(
//               flex: 5,
//               child: PageStorage(
//                child: currentScreen,
//                bucket: bucket,
//               )
//             )

//           ],

//         ),
      //   Stack(
      //   children: [
      //     Positioned(
      //       top: -15,  // Adjust this value to move the image further down or up
      //       left: -45, // Adjust this value to move the image further left or right
      //       child: Image.asset(
      //         'assets/images/logo2.png', // Replace with the path to your image
      //         width: 210,  // Adjust the width of the image
      //         height: 210, // Adjust the height of the image
      //       ),
      //     ),
      //     Positioned(
      //       top: 50, // Same top alignment for the logo and score
      //       left: 0, // Stretch across the width of the screen
      //       right: -5, // Stretch across the width of the screen
      //       child: Row(
      //         children: [
      //           // Spacer to push the score icon to the right side
      //           const Spacer(),
      //           Column(
      //             children: [
      //               Image.asset(
      //         'assets/images/score.png', // Replace with the path to your image
      //         width: 50,  // Adjust the width of the image
      //         height: 50, // Adjust the height of the image
      //       ),
      //               const Text(
      //                 'Score: 0', // The text under the icon
      //                 style: TextStyle(
      //                   fontSize: 10,
      //                   color: score, // Change the color as needed
      //                 ),
      //               ),
      //             ],
      //           ),
      //           const SizedBox(width: 20), // Add some padding on the right
      //         ],
      //       ),
      //     ),
      //   ],
      // ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 60.0, // Adjust the width as needed
        height: 60.0, // Adjust the height as needed
        child: FloatingActionButton(
          onPressed: () {
            // Action for Profile
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HomeScreen(
                        token: TOKEN,
                      )),
            );
            print("Home tapped!");
            // setState(() {
            //   currentScreen=HomeScreen();
            //   currentTab=0;
            // });
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
                      builder: (context) => ProfileScreen(
                            emaill: EMAIL,
                          )),
                );
                // setState(() {
                //   currentScreen=ProfileScreen(emaill: emaill);
                //   currentTab=1;
                // });
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
                print("All Stories Supervisor tapped!");
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
                      Icons.notifications,
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
