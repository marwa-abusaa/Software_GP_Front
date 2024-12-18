import 'dart:convert';
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/screens/supervisors/add_quiz.dart';
import 'package:flutter_application_1/screens/supervisors/show_quiz_marks.dart';
import 'package:flutter_application_1/screens/users/quiz_screen.dart';
import 'package:flutter_application_1/widgets/custom_home.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/config.dart';
import 'package:url_launcher/url_launcher.dart';

class CourseDetailsScreen extends StatefulWidget {
  
  final String id;
  final String linkk;
  CourseDetailsScreen({required this.id,Key? key, required this.linkk}) : super(key: key);

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
 
  late String courseId=widget.id;
  
  @override
  void initState() {
    super.initState(); 
  
    getCourseDetails(courseId);
  }
 



// Declare variables to hold course details
String title = '';
String description = '';
String courseType = '';
String score = '';
String link = '';

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


      });
      print("Done!!");
    } else {
      // Handle the case when the response status is false
      print("Failed to fetch course details");
    }
  }
void _showDialog(BuildContext context) {
  final TextEditingController numberController = TextEditingController();
  final TextEditingController fullMarkController = TextEditingController();

  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: 
           const Stack(
            children: [         
               Flexible(
                 child: Text('- You need to provide at least 6 questions. Only 5 will be displayed to the child, chosen randomly to ensure the questions vary for everyone.',
                  style: TextStyle(fontSize: 17,),textAlign: TextAlign.justify,),
               ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(
                  height: 20.0,  // The total vertical space occupied by the Divider.
                  color: ourBlue,  // The color of the line.
                  thickness: 2.0,  // The thickness of the line.
                  //indent: 10.0,  // Empty space to the left of the line.
                  //endIndent: 10.0,  // Empty space to the right of the line.              
              ),
                const Text('Enter Number of Questions    ', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                TextField(
                  controller: numberController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Enter a number',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
                const SizedBox(height: 15),
                const Text('Enter the full mark of the Quiz', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                TextField(
                  controller: fullMarkController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Enter the full mark',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // يغلق الحوار
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ourBlue,
                padding: EdgeInsets.all(9), // Remove padding
              ),
              onPressed: () {
                final enteredNumber = numberController.text;
                final enteredFullMark = fullMarkController.text;

                if (enteredNumber.isNotEmpty && int.tryParse(enteredNumber) != null &&
                    enteredFullMark.isNotEmpty && int.tryParse(enteredFullMark) != null) {
                  Navigator.pop(context); // يغلق الحوار
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddQuizPage(
                        numberOfQuestions: int.parse(enteredNumber),
                        fullMark: int.parse(enteredFullMark),
                        id: courseId,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter valid numbers for both fields!')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
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
                const SizedBox(width: 45.0), // Space between the icon and title
                const Text(
                  'My Courses',
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
                              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold,color: ourBlue,fontFamily: 'Times New Roman',fontStyle: FontStyle.italic,
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
                                    fontSize: 23,
                                    color: ourPink, // Specify the color here
                                  ),
                                  //TextStyle( color: ourPink,fontWeight: FontWeight.w900,fontSize: 23), // Change to your desired color
                                ),
                                TextSpan(
                                  text: '$description', // This part will have the second color
                                  style: const TextStyle(fontSize: 22, color: Colors.black,fontFamily: 'Times New Roman'), // Change to your desired color
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
                                    fontSize: 23,
                                    color: ourPink, // Specify the color here
                                  ),
                                  //TextStyle( color: ourPink,fontWeight: FontWeight.w900,fontSize: 23), // Change to your desired color
                                ),
                                TextSpan(
                                  text: '$courseType', // This part will have the second color
                                  style: const TextStyle(fontSize: 22, color: Colors.black,fontFamily: 'Times New Roman'), // Change to your desired color
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
                                    fontSize: 23,
                                    color: ourPink, // Specify the color here
                                  ),
                                  //TextStyle( color: ourPink,fontWeight: FontWeight.w900,fontSize: 23), // Change to your desired color
                                ),
                                TextSpan(
                                  text: '$score', // This part will have the second color
                                  style: const TextStyle(fontSize: 22, color: Colors.black,fontFamily: 'Times New Roman'),// Change to your desired color
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
                                    fontSize: 23,
                                    color: ourPink, // Specify the color here
                                  ),
                                  //TextStyle( color: ourPink,fontWeight: FontWeight.w900,fontSize: 23), // Change to your desired color
                                ),
                                TextSpan(
                                  text: '$link', // This part will have the second color
                                  style: const TextStyle(fontSize: 22, color: Color.fromARGB(255, 23, 127, 211),fontFamily: 'Times New Roman',decoration: TextDecoration.underline),
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
                    const SizedBox(height: 16.0), 
          
                    Center(
                  child: SizedBox(
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly, // لضبط الأزرار في منتصف الشاشة
                      children: [
                        SizedBox(
                          width: 150, // عرض الزر الأول
                          height: 45,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ourBlue,
                              padding: EdgeInsets.zero, // إزالة الحواف
                            ),
                            onPressed: () => _showDialog(context),
                            child: const Text("Add Quiz",style: TextStyle(fontSize: 16)),
                          ),
                        ),
                        const SizedBox(width: 10), // مسافة بين الزرين
                        SizedBox(
                          width: 150, 
                          height: 45,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 240, 202, 111), // لون مختلف للزر الثاني
                              padding: EdgeInsets.zero, // إزالة الحواف
                            ),
                            onPressed: () {
                              // الإجراء المطلوب عند الضغط على الزر الثاني
                              print("Second Button Pressed");
                                Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) =>  ClassroomScreen(title:title, id: courseId,)), 
                            );
                            },
                            child: const Text("Show Grades",style: TextStyle(fontSize: 16),),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                    const SizedBox(height: 30.0), 
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