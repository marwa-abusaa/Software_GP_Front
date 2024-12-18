
import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/screens/users/quiz_screen.dart';

class AttemptQuiz extends StatefulWidget {
  final String id;
  AttemptQuiz({required this.id,Key? key}) : super(key: key);
  @override
  _AttemptQuizState createState() => _AttemptQuizState();
}

class _AttemptQuizState extends State<AttemptQuiz> {
  // Example state variables
  bool isButtonPressed = false;

  late String courseId=widget.id;


  void _showDialog(BuildContext context) {

  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:  Center(child: const Text('You have 1 attempt.',style: TextStyle(fontSize: 20) )),
         // content: ,
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
             
                  Navigator.pop(context); // يغلق الحوار
                 Navigator.push(
                     context,
                      MaterialPageRoute(builder: (context) => QuizPage(id:courseId)),
                  );
                
              },
              child: const Text('Attempt Quiz'),
            ),
          ],
        );
      },
    );
}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: offwhite,
        body: Column(
          children: [
            // Top Image Section
            Positioned(
              child: Image.asset(
                'assets/images/start_quiz.png', // Replace with your image path
                alignment: Alignment.center,
                height: 320,
                width: double.infinity,
              ),
            ),

            // Expanded Section with Yellow Box
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, 0),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(230, 249, 215, 105),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(80),
                      topRight: Radius.circular(80),
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Purple Box Section
                     Transform.translate(
  offset: const Offset(0, 80),
  child: Container(
    height: 195,
    width: 320,
    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
    decoration: BoxDecoration(
      color: offwhite, // استبدل `offwhite` إذا كنت تستخدم لونًا محددًا.
      borderRadius: BorderRadius.circular(5),
    ),
    child: Scrollbar( // لإظهار مؤشر التمرير.
      thumbVisibility: true, // يجعل شريط التمرير مرئيًا دائمًا.
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Let\'s Start Quiz!',
              style: TextStyle(
                color: Colors.black,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Instructions: There are 5 questions, each with 3 options and a mark. You cannot go back to previous questions.Answer all the questions before the time runs out.',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                // Handle NEXT button tap
              },
              child: Container(
                //padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              
                
              ),
            ),
          ],
        ),
      ),
    ),
  ),
),


                      // Spacer for the button
                      const Spacer(),

                      // Contact Us Button
                      Center(
                        child: SizedBox(
                          width: 220,
                          child: ElevatedButton(
                          onPressed: () => _showDialog(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ourPink,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Attempt Quiz",
                                  style: TextStyle(fontSize: 18, color: Colors.white),
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
            ),
          ],
        ),
      ),
    );
  }
}
