import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/screens/users/attempt_quiz.dart';
import 'package:flutter_application_1/widgets/custom_home.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/config.dart';
import 'package:flutter/gestures.dart'; // For TapGestureRecognizer
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';




class AllCourseDetailsScreen extends StatefulWidget {
  final String id;
  final  linkk;
  AllCourseDetailsScreen({required this.id,required this.linkk,Key? key}) : super(key: key);

  @override
  State<AllCourseDetailsScreen> createState() => _AllCourseDetailsScreenState();
}

class _AllCourseDetailsScreenState extends State<AllCourseDetailsScreen> {
 
  late String courseId=widget.id;
  String email=EMAIL;
  bool isAttempt=false;
  bool isQuiz=false;

  //URL of th YouTube Video
 late final videoURL = widget.linkk;
late YoutubePlayerController playerController;

 void getQuestions(String courseId) async {
  print(courseId);
  var regBody = {
    "courseId": courseId
  };

   var response = await http.post(Uri.parse(getQuizQuestions),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody) // This sends the JSON body
    );

    if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
         setState(() {
          isQuiz=true;
        });

    } else {
        print('Error: ${response.statusCode}');
        print('Response: ${response.body}');
    }
  }

   void checkAttempt() async{
     
      var regBody = {
        "userEmail":email,
        "courseId":courseId,
      };

      var response = await http.post(Uri.parse(checkUserQuizAttempt),
          headers: {"Content-Type":"application/json"},
          body: jsonEncode(regBody)
      );

      var jsonResponse = jsonDecode(response.body);

      print(jsonResponse['status']);

      if(jsonResponse['status']){
        print('done');
        setState(() {
          isAttempt=false;
        });
      
      }else{
         print(' not done');
        setState(() {
          isAttempt=true;
        });
      }
    
  }
  // Method to seek forward 10 seconds
  void seekForward() {
    final currentPosition = playerController.value.position;
    final duration = playerController.value.metaData.duration;
    if (currentPosition.inSeconds + 10 < duration.inSeconds) {
      playerController.seekTo(
        currentPosition + const Duration(seconds: 10),
      );
    }
  }
  // Method to seek backward 10 seconds
  void seekBackward() {
    final currentPosition = playerController.value.position;
    if (currentPosition.inSeconds - 10 > 0) {
      playerController.seekTo(currentPosition - const Duration(seconds: 10));
    }
  }

 @override
void initState() {
  super.initState();

  // استدعاء الدوال الأخرى
  getCourseDetails(courseId);
  checkAttempt();
  getQuestions(courseId);
  getMyGrade(email, courseId);

  //// الفيديو
  if (videoURL.contains("youtu.be")) {
    final videoId = YoutubePlayer.convertUrlToId(videoURL);

    if (videoId != null) {
      // تهيئة وحدة التحكم بالفيديو
      playerController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false, // عدم تشغيل الفيديو تلقائياً
        ),
      );
    } else {
      debugPrint("تعذر استخراج معرف الفيديو من الرابط: $videoURL");
    }
  } else {
    debugPrint("الرابط لا يحتوي على 'youtu.be': $videoURL");
  }
}





// Declare variables to hold course details
String title = '';
String description = '';
String courseType = '';
String score = '';
String link = '';
String supervisorName='';

///grade
String myGrade='';
String fullMark='';

void getCourseDetails(String courseId) async {
  print(courseId);
  var regBody = {
    "id": courseId
  };

  var response = await http.post(
    Uri.parse(getCourseDetailss),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(regBody), // This sends the JSON body
  );

  var jsonResponse = jsonDecode(response.body);
  if (jsonResponse['status']) {
    setState(() {
        title = jsonResponse['success']['title'];
        description = jsonResponse['success']['description'];
        courseType = jsonResponse['success']['courseType'];
        score = jsonResponse['success']['score'].toString(); // Convert to string if needed
        link = jsonResponse['success']['link'];
        supervisorName = jsonResponse['success']['supervisorName'];
      });
      print("Done!!");
    } else {
      // Handle the case when the response status is false
      print("Failed to fetch course details");
    }
  }

   void getMyGrade(email,courseId) async {
    print(email+courseId);
    var regBody = {
      "courseId": courseId,
      "userEmail": email
    };

    var response = await http.post(Uri.parse(getMyCourseGrade),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody) // This sends the JSON body
    );

    if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);        
        setState(() {
           myGrade = jsonResponse['success'][0]['UserTotalMark'].toString();
           fullMark = jsonResponse['success'][0]['totalMark'].toString();
        });
    } else {
        print('Error: ${response.statusCode}');
        print('Response: ${response.body}');
    }
}

@override
Widget build(BuildContext context) {
  return CustomHomePage(
    emaill: EMAIL,
    body: Stack( // Use Stack to overlay the button on top of the content
      children: [
        Column(
          children: [
           Container(
            width: MediaQuery.of(context).size.width,
            color: ourPink,
            padding: const EdgeInsets.only(top: 8.0, bottom: 15.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white), // Arrow icon
                  onPressed: () {
                    Navigator.of(context).pop(); // Navigate back to the previous page
                  },
                ),
                const SizedBox(width: 77.0), // Space between the icon and title
                const Text(
                  'Courses',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

            const SizedBox(height: 20,),
            Expanded(
              child: SingleChildScrollView( // يمكن استخدام SingleChildScrollView للسماح بالتمرير إذا كانت المعلومات طويلة
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // الصف الذي يحتوي على الأيقونة والعنوان
                     Padding(
                      padding: EdgeInsets.only(left: 16.0, ),
                      child: Row(                      
                        children: [
                          const Icon(Icons.task,color: ourBlue,size: 36,), // الأيقونة
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              '$title', // العنوان
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: ourBlue,fontFamily: 'Times New Roman',fontStyle: FontStyle.italic,
                              decoration: TextDecoration.underline,decorationColor:ourBlue),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5.0), // مسافة بين الصف والعناصر الأخرى
                    Container(  
                      decoration: BoxDecoration(
                        color: logoBar,
                        border: Border.all(
                          width: 2, // Width of the border
                          color: const Color.fromARGB(255, 218, 174, 132)
                        ),
                        borderRadius: BorderRadius.circular(30), // Make it circular
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey, // Color of the shadow
                            //blurRadius: 6.0, // Blur radius of the shadow
                           // offset: Offset(2, 2), // Position of the shadow
                          ),
                        ],
                      ),                
                      width: MediaQuery.of(context).size.width,         
                      padding: const EdgeInsets.all(16.0),
                      margin: const EdgeInsets.all(8.0),
                      //color: logoBar, // لون خلفية للجزء الخاص بالمعلومات
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                 TextSpan(
                                  text: 'Description: ', // This part will have the first color
                                  style: GoogleFonts.arvo().copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 21,
                                    color: ourPink, // Specify the color here
                                  ),
                                  //TextStyle( color: ourPink,fontWeight: FontWeight.w900,fontSize: 23), // Change to your desired color
                                ),
                                TextSpan(
                                  text: '$description', // This part will have the second color
                                  style: const TextStyle(fontSize: 20, color: Colors.black,fontFamily: 'Times New Roman'), // Change to your desired color
                                ),
                              ],
                            ),
                          ),
                          const Divider(
                            color: ourPink, // Change the color of the divider
                            thickness: 3, // Set the thickness of the divider
                            height: 20, // Set the height of the divider (space around it)
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Course Type: ', // This part will have the first color
                                  style: GoogleFonts.arvo().copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 21,
                                    color: ourPink, // Specify the color here
                                  ),
                                  //TextStyle( color: ourPink,fontWeight: FontWeight.w900,fontSize: 23), // Change to your desired color
                                ),
                                TextSpan(
                                  text: '$courseType', // This part will have the second color
                                  style: const TextStyle(fontSize: 20, color: Colors.black,fontFamily: 'Times New Roman'), // Change to your desired color
                                ),
                              ],
                            ),
                          ),
                          const Divider(
                            color: ourPink,
                            thickness: 3,
                            height: 20,
                          ),
                           RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Spervisor: ', // This part will have the first color
                                  style: GoogleFonts.arvo().copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 21,
                                    color: ourPink, // Specify the color here
                                  ),
                                  //TextStyle( color: ourPink,fontWeight: FontWeight.w900,fontSize: 23), // Change to your desired color
                                ),
                                TextSpan(
                                  text: '$supervisorName', // This part will have the second color
                                  style: const TextStyle(fontSize: 20, color: Colors.black,fontFamily: 'Times New Roman'),// Change to your desired color
                                ),
                              ],
                            ),
                          ),
                          const Divider(
                            color: ourPink,
                            thickness: 3,
                            height: 20,
                          ),                    
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Score: ', // This part will have the first color
                                  style: GoogleFonts.arvo().copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 21,
                                    color: ourPink, // Specify the color here
                                  ),
                                  //TextStyle( color: ourPink,fontWeight: FontWeight.w900,fontSize: 23), // Change to your desired color
                                ),
                                TextSpan(
                                  text: '$score', // This part will have the second color
                                  style: const TextStyle(fontSize: 20, color: Colors.black,fontFamily: 'Times New Roman'),// Change to your desired color
                                ),
                              ],
                            ),
                          ),
                          const Divider(
                            color: ourPink,
                            thickness: 3,
                            height: 20,
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Go to course:                                 ', // This part will have the first color
                                  style: GoogleFonts.arvo().copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 21,
                                    color: ourPink, // Specify the color here
                                  ),
                                  //TextStyle( color: ourPink,fontWeight: FontWeight.w900,fontSize: 23), // Change to your desired color
                                ),
                                TextSpan(
                                  text: '$link', // This part will have the second color
                                  style: const TextStyle(fontSize: 20, color: Color.fromARGB(255, 23, 127, 211),fontFamily: 'Times New Roman',decoration: TextDecoration.underline),
                                 recognizer: TapGestureRecognizer()
                                 ..onTap = () {
                                   final Uri url = Uri.parse(link);
                                  launchUrl(url);
                                    },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                    ),
                    const SizedBox(height: 5.0), 
                    if(link.contains("youtu.be"))
                       const Positioned(
                      // top: 20,
                      // left: 20,
                      // right: 20,
                      child: Center(
                        child: Text(
                          "Or Show the video here",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ourBlue,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 5,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                   const SizedBox(height: 5.0), 
                   if(link.contains("youtu.be"))
                 Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: ourBlue, // لون الإطار
                          width: 4,                // عرض الإطار
                        ),
                        borderRadius: BorderRadius.circular(10), // زوايا دائرية
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26, // لون الظل
                            blurRadius: 8,         // مدى انتشار الظل
                            offset: Offset(2, 2),  // اتجاه الظل
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10), // نفس الزوايا للإطار
                        child: YoutubePlayer(controller: playerController),
                      ),
                    ),
                    Positioned(
                      top: 100, right: 100, left: 100, bottom: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: seekBackward,
                            icon: const Icon(
                              Icons.replay_10,
                              size: 30,
                              color: Colors.white54,
                            ),
                          ),
                          const SizedBox(width: 30),
                          IconButton(
                            onPressed: seekForward,
                            icon: const Icon(
                              Icons.forward_10,
                              size: 30,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                    const SizedBox(height: 25.0),
                    if(link.contains("youtu.be"))
                     const Divider(
                            color: ourPink,
                            thickness: 3,
                            height: 20,
                            indent: 18.0,  // Empty space to the left of the line.
                          endIndent: 18.0,
                          ), 
                          const SizedBox(height: 20.0),
                    Row(
                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                     if(isQuiz)
                    Center(
                      child: SizedBox(
                          height: 50,
                          width: 150, // Set the width you want
                           child: ElevatedButton(   
                           style: ElevatedButton.styleFrom(
                            backgroundColor: ourBlue,
                            padding: EdgeInsets.zero, // Remove padding
                          ),
                      onPressed: () {
                        if(!isAttempt){
                          Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AttemptQuiz(id:courseId, contScore: int.parse(score))),
                         );
                        }else{
                        showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Container(
                              height: 20,
                              child: const Center(
                                child: Text(
                                  "You can't attempt this quiz again.",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  softWrap: true, // السماح بتفاف النص داخل الحاوية
                                  overflow: TextOverflow.visible, 
                                ),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close the dialog
                                },
                                child:  Transform.translate(
                                  offset: Offset(0, 15),
                                  child: const Center(
                                    child: Text(
                                      "OK",
                                      style: TextStyle(
                                        color: ourPink,
                                        fontSize: 18,
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
                      },
                      child: const Text("Attempt Quiz"),
                            ),
                    ),
                    ),
                    if(isAttempt)
                    Row(
                      children: [
                        const Icon(
                        Icons.star, // استخدام أيقونة النجمة
                        color: Color(0xFFF7CE6E), // لون الأيقونة
                        size: 24, // حجم الأيقونة
                      ),
                        Text('Your Grade: ${myGrade}''/''${fullMark}', 
                            style: const TextStyle(
                              color: ourBlue,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Times New Roman',
                              fontStyle: FontStyle.italic,
                              //decoration: TextDecoration.underline,decorationColor:ourBlue,
                            ),),
                      ],
                    )
                      ],
                    ),
                
                   const SizedBox(height: 30,)
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

}