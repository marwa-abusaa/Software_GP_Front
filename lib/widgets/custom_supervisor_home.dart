import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/screens/users/home_screen.dart';
import 'package:flutter_application_1/screens/users/myStories_screen.dart';
import 'package:flutter_application_1/screens/all_users/profileScreens/mainProfile.dart';
import 'package:flutter_application_1/screens/login/signin_screen.dart';
import 'package:flutter_application_1/screens/supervisors/supervisor_home_screen.dart';
import 'package:jwt_decoder/jwt_decoder.dart';


class CustomSupervisorHomePage extends StatefulWidget {

  final token;
  const CustomSupervisorHomePage({@required this.token,Key? key}) : super(key: key);

  @override
  _CustomSupervisorHomePageState createState() => _CustomSupervisorHomePageState();
}

class _CustomSupervisorHomePageState extends State<CustomSupervisorHomePage> {
  late String emaill;
   @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Map<String,dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    emaill = jwtDecodedToken['email'];
    
  }


  int currentTab = 0;
  final List<Widget> screens=[
     SupervisorHomeScreen(),
  ];

  final PageStorageBucket bucket= PageStorageBucket();
  Widget currentScreen= SupervisorHomeScreen();





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: offwhite,

        body: Column(
          children: [
            Expanded(
              flex: 1,
              child: Stack(
                children: [
          Positioned(
            top: -15,  // Adjust this value to move the image further down or up
            left: -45, // Adjust this value to move the image further left or right
            child: Image.asset(
              'assets/images/logo2.png', // Replace with the path to your image
              width: 210,  // Adjust the width of the image
              height: 210, // Adjust the height of the image
            ),
          ),
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
        ], 
                
              )
            ),

            Expanded(
              flex: 5,
              child: PageStorage(
               child: currentScreen,
               bucket: bucket,              
              )
            )

          ],

        ),
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
      width: 60.0,  // Adjust the width as needed
      height: 60.0, // Adjust the height as needed
      child: FloatingActionButton(
        onPressed: () {
          // Action for Profile
          print("Home tapped!");
          print(emaill);
          setState(() {
            currentScreen=SupervisorHomeScreen();
            currentTab=0;
          });
        },  // Adjust icon size if needed
        backgroundColor: iconsBar,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const CircleBorder(),
        child:  const Icon(Icons.home, size: 40),      
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
          setState(() {
            currentScreen=ProfileScreen(emaill: emaill,);
            currentTab=1;
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
                color: currentTab==1 ? iconsBar : Colors.white,
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
          print("All Stories tapped!");
          // Navigate to Stories Page or perform other action
           setState(() {
            //currentScreen=AllScreen();
            currentTab=2;
          });
        },
        child: Padding(
          padding: const EdgeInsets.only(right: 70),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.book,
                color: currentTab==2 ? iconsBar : Colors.white,
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
            currentTab=3;
          });
        },
        child: Padding(
          padding: const EdgeInsets.only(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.notifications,
               color: currentTab==3 ? iconsBar : Colors.white,
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
            currentTab=4;
          });
        },
        child: Padding(
          padding: const EdgeInsets.only(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chat,
               color: currentTab==4 ? iconsBar : Colors.white,
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