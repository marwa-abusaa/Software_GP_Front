import 'dart:convert';
import 'package:flutter_application_1/config.dart';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/users/courses_screen.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:http/http.dart' as http;


class ScoreScreen extends StatefulWidget {
  late String id;
  late int userScore;
  ScoreScreen({required this.userScore,required this.id,Key? key}) : super(key: key);
  @override
  _ScoreScreenState createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  late ConfettiController _confettiController;
  late String courseId=widget.id;
  List? items;
  String email=EMAIL;
  int totalMark=0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play(); // Start the confetti animation
    getQuestions(courseId);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }


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
   
        items = jsonResponse['success'];
  
        setState(() {});
    } else {
        print('Error: ${response.statusCode}');
        print('Response: ${response.body}');
    }
  }


    void addMark() async{
  
    if(email.isNotEmpty && courseId.isNotEmpty ){
  
      var regBody = {
        "userEmail":email,
        "courseId":courseId,
        "UserTotalMark":widget.userScore,
      };

      var response = await http.post(Uri.parse(addTotalMark),
          headers: {"Content-Type":"application/json"},
          body: jsonEncode(regBody)
      );

      var jsonResponse = jsonDecode(response.body);

      print(jsonResponse['status']);

      if(jsonResponse['status']){
      
      }else{
        print("SomeThing Went Wrong");
      }
    }
  }

  @override
  Widget build(BuildContext context) {


if (items != null && items!.isNotEmpty && items![0]['totalMark'] != null) {
  totalMark = int.parse('${items![0]['totalMark']}');
} else {
  totalMark = 0; // أو تحديد قيمة افتراضية أخرى
}


    // Define the score variables
    int correctAnswers = widget.userScore;
    //int totalQuestions = 9;
    double percent;

    if (totalMark != null && totalMark > 0) {
      percent = correctAnswers / totalMark;
    } else {
      percent = 0.0; // أو قيمة افتراضية أخرى مثل 0.0 إذا لم يكن هناك أي قيمة صالحة
    }


    return Scaffold(
      backgroundColor: offwhite,
      body: Stack(
        children: [

          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/back_score.png', // Replace with your image path
              fit: BoxFit.contain,
            ),
          ),
          // Confetti animation at the top
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 3.14 / 2, // Confetti falls straight down
              emissionFrequency: 0.05, // Controls the rate of confetti emission
              numberOfParticles: 10, // Number of particles emitted at once
              gravity: 0.2, // Make the confetti fall slower
              shouldLoop: false, // Confetti plays once
              colors: const [
                Colors.blue,
                Colors.red,
                Colors.green,
                Colors.yellow,
                Colors.purple,
              ],
            ),
          ),
          // Main content in the center
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.translate(
                  offset: Offset(0, -80),
                  child:  const Text(
                    'Your Score:',
                    style: TextStyle(
                      color: Color.fromARGB(255, 241, 185, 55),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                CircularPercentIndicator(
                  radius: 100.0,
                  lineWidth: 15.0,
                  percent: percent,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Text(
                    '${correctAnswers != null ? correctAnswers.toString() : '0'}/${totalMark != null ? totalMark.toString() : '0'}',
                    style: const TextStyle(
                      fontSize: 36.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                      Text(
                        '${(percent * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 18.0,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  progressColor: ourPink,
                  backgroundColor: const Color.fromARGB(255, 220, 218, 218),
                ),
                const SizedBox(height: 20),
                Transform.translate(
                  offset: Offset(0, 140),
                  child: ElevatedButton(
                    onPressed: () {
                      addMark();
                       Navigator.push(
                        context,
                       MaterialPageRoute(builder: (context) => CoursesScreen()),
                     );                     
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 58, 177, 180),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    ),
                    child: const Text(
                      'Back to Courses',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
