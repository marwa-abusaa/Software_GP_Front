import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/config.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/screens/users/your_score.dart';


class QuizPage extends StatefulWidget {
  final String id;
   QuizPage({required this.id,Key? key}) : super(key: key);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
   int? selectedIndex; // Store the index of the selected answer
  //final int correctAnswerIndex = 2; // Index of the correct answer
   bool hasAnswered = false; // Track if the user has already selected an answer
   ///backend
   String userEmail=EMAIL;
   late String courseId=widget.id;
   List? items;
   int currentIndex=0;
   ////timer
     late StreamController<int> _timerStreamController;
   int remainingSeconds = 20; // الوقت بالثواني
   Color iconColor = ourPink; // اللون الأساسي (pink)
   Color textColor = Color(0xFF5E5C66); // اللون الأساسي (pink)
   /////
   int userScore=0;
   int invidualScore=0;
   /////
  bool isPageActive = true; 

 @override
  void initState() {
    super.initState();
    getQuestions(courseId);
    _timerStreamController = StreamController<int>();
    startTimer();
  }

  @override
  void dispose() {
    _timerStreamController.close();
    super.dispose();
  }

    void startTimer() {
    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      
      if (remainingSeconds > 0) {
        _timerStreamController.add(remainingSeconds--);

        // تغيير لون الأيقونة عند 3 ثوانٍ
        if (remainingSeconds == 3) {
          setState(() {
            iconColor = Colors.red;
            textColor=Colors.red;
          });
        }
      } else {
        // عند انتهاء الوقت، يتم الانتقال لصفحة العلامات
        timer.cancel();
        if(isPageActive){
          Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>  ScoreScreen(userScore: userScore, id: courseId,)), 
        );
        }
        
      }
    });
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




  @override
  Widget build(BuildContext context) {
    final options = items != null
    ? [
        '${items![currentIndex]['answer1']}',
        '${items![currentIndex]['answer2']}',
        '${items![currentIndex]['answer3']}',
      ]
    : [];

    int? correctAnswerIndex;
    if (items != null  &&
        items![currentIndex] != null &&
        items![currentIndex].containsKey('correctAnswer') &&
        items![currentIndex]['correctAnswer'] != null) {
      correctAnswerIndex = options.indexOf(items![currentIndex]['correctAnswer']);
    } else {
      correctAnswerIndex = -1; // أو أي قيمة افتراضية
    }

    String formattedTime = "00:${remainingSeconds.toString().padLeft(2, '0')}";

    double percent;
    if (currentIndex + 1 != null && currentIndex + 1  > 0) {
      percent = (currentIndex + 1)  / 5;
    } else {
      percent = 0.0; // أو قيمة افتراضية أخرى مثل 0.0 إذا لم يكن هناك أي قيمة صالحة
    }
  
    return Scaffold(
      backgroundColor: offwhite,
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Image.asset(
              'assets/images/b2.png', // Replace with your image path
              alignment: Alignment.center,
              height: 820,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 150),
                Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // Progress Bar Row
    Row(
      children: [
        Expanded(
          child: Stack(
            children: [
              Transform.translate(
                offset: Offset(275, -50),
                child: Container(
                  child:  items == null ? null:Text(
                          'Score:$invidualScore/${items![currentIndex]['questionMark']}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 52, 150, 55)
                          ),
                        ),
                ),
              ),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0DFF6), // Lighter purple background
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percent, // Update this based on progress
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7E57C2), // Light green color
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
    //const SizedBox(height: 4), // Space between rows

    // Text and Timer Row
     Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Question ${currentIndex + 1} of 5',
          style: const TextStyle(
            fontSize: 17,
            color: Color(0xFF5E5C66), // Darker text color
            fontWeight: FontWeight.bold,
          ),
        ),
         Row(
           children: [
                            Icon(
                              Icons.timer, // Clock icon
                              color: iconColor, // Yellow color
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            StreamBuilder<int>(
                              stream: _timerStreamController.stream,
                              initialData: remainingSeconds,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  String formattedTime = "00:${snapshot.data!.toString().padLeft(2, '0')}";
                                  return Text(
                                    formattedTime,
                                    style:  TextStyle(
                                      fontSize: 18,
                                      color: textColor, // Darker text color
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                } else {
                                  return Text("00:00",
                                    style:  TextStyle(
                                      fontSize: 18,
                                      color: textColor, // Darker text color
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
        ),
      ],
    ),
  ],
),

                const SizedBox(height: 61),
               Center(
                  child: Transform.translate(
                    offset: const Offset(0, -30),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      width: 400, // Set a fixed width
                      height: 140, // Set a fixed height
                      decoration: BoxDecoration(
                        //color: Colors.red,
                        borderRadius: BorderRadius.circular(27),
                        boxShadow: [
                          // BoxShadow(
                          //   color: Colors.black.withOpacity(0.1),
                          //   blurRadius: 10,
                          //   offset: const Offset(0, 1),
                          // ),
                        ],
                      ),
                      child:  items == null ? null:Center(
                        child: Text(
                          '${items![currentIndex]['question']}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                //const SizedBox(height: 0),
                Expanded(
                  child: ListView.builder(
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      bool isCorrect = index == correctAnswerIndex;
                      bool isSelected = index == selectedIndex;
                      double topMargin = 0;
                      double bottomMargin = 0;
                      if (index == 0) {
                        topMargin = 1.0;
                        bottomMargin = 15.0;
                      } else if (index == 1) {
                        topMargin = 13.0;
                        bottomMargin = 10.0;
                      } else if (index == 2) {
                        topMargin = 19.0;
                        bottomMargin = 10.0;
                      }

                      return GestureDetector(
                          onTap: () {
                          if (!hasAnswered) {
                            setState(() {
                              selectedIndex = index;
                              hasAnswered = true;
                              if(selectedIndex==correctAnswerIndex){
                                userScore +=int.parse('${items![currentIndex]['questionMark']}');
                                invidualScore=int.parse('${items![currentIndex]['questionMark']}');
                              }
                            });
                          }
                        },
                        child: Align(
                          alignment: Alignment.center,
                          child: Transform.translate(
                            offset: const Offset(29, 0),
                            child: Container(
                              width: 310,
                              height: 57,
                              margin: EdgeInsets.only(
                                top: topMargin,
                                bottom: bottomMargin,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 25),
                              decoration:  BoxDecoration(
                                color: Colors.transparent,
                                border: Border(

                                  top: BorderSide(color: hasAnswered
                                      ? (isCorrect
                                          ? Colors.green // Highlight correct answer
                                          : (isSelected ? Colors.red : Colors.grey))
                                      : Colors.grey,
                                  width: 2,),

                                  right: BorderSide(color: hasAnswered
                                      ? (isCorrect
                                          ? Colors.green // Highlight correct answer
                                          : (isSelected ? Colors.red : Colors.grey))
                                      : Colors.grey,
                                  width: 2,),

                                  bottom: BorderSide(color: hasAnswered
                                      ? (isCorrect
                                          ? Colors.green // Highlight correct answer
                                          : (isSelected ? Colors.red : Colors.grey))
                                      : Colors.grey,
                                  width: 2,),

                                  left: BorderSide.none,
                                ),
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(25),
                                  bottomRight: Radius.circular(25),
                                ),
                              ),
                               child: Row(
                                children: [
                                  Expanded(
                                    child: options.isNotEmpty ? Text(
                                        options[index],
                                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                                      )
                                    :const Text(
                                     '',
                                      style: TextStyle(fontSize: 16, color: Colors.black87),
                                    ),
                                  ),
                                  if (hasAnswered && isCorrect)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                  if (hasAnswered && isSelected && !isCorrect)
                                    const Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if(currentIndex<4){
                        setState(() {
                         currentIndex++;
                         hasAnswered = false;
                         invidualScore=0;
                         
                       });
                      }
                      else{   
                        setState(() {
                          isPageActive=false;
                        });                    
                        Navigator.push(
                         context,
                         MaterialPageRoute(builder: (context) => ScoreScreen( userScore: userScore, id: courseId,)),
                        );                     
                      }
                       
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9575CD),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
                      minimumSize: const Size(160, 20), // Explicit minimum width and height
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Next",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        SizedBox(width: 6), // Space between text and icon
                        Icon(
                          Icons.arrow_forward, // Arrow icon
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
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