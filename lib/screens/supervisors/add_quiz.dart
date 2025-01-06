import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/config.dart';


class AddQuizPage extends StatefulWidget {
  int numberOfQuestions;
  int fullMark;
   final String id;
   AddQuizPage({required this.id,required this.numberOfQuestions,required this.fullMark,Key? key}) : super(key: key);
  @override
  _AddQuizPageState createState() => _AddQuizPageState();
}

class _AddQuizPageState extends State<AddQuizPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late int n;
  late int totalMark=widget.fullMark;

  final List<TextEditingController> _questionControllers = [];

  final List<List<TextEditingController>> _answersControllers = [];

   List<TextEditingController> _scoreControllers = [];

   final List<int> _correctAnswers = [];



    @override
  void initState() {
    super.initState();
    n = widget.numberOfQuestions; // تعيين n بعد التهيئة

    _questionControllers.addAll(List.generate(n, (_) => TextEditingController()));
    
    _answersControllers.addAll(List.generate(n, (_) => List.generate(3, (_) => TextEditingController()), ));
    _scoreControllers = List.generate(n, (_) => TextEditingController());

    _correctAnswers.addAll(List.generate(n, (_) => -1)); 

  }

@override
void dispose() {
  for (var questionController in _questionControllers) {
    questionController.dispose();
  }
  // for (var scoreController in _scoreControllers) {
  //   scoreController.dispose();
  // }
  for (var answerControllers in _answersControllers) {
    for (var controller in answerControllers) {
      controller.dispose();
    }
  }
  super.dispose();
}

  void addQuestion() async{
    if(_questionControllers[_currentPage].text.isNotEmpty && _answersControllers[_currentPage][0].text.isNotEmpty && _answersControllers[_currentPage][1].text.isNotEmpty && _answersControllers[_currentPage][2].text.isNotEmpty &&_scoreControllers[_currentPage].text.isNotEmpty){

      var regBody = {
      "question": _questionControllers[_currentPage].text,
      "answer1": _answersControllers[_currentPage][0].text,
      "answer2": _answersControllers[_currentPage][1].text,
      "answer3": _answersControllers[_currentPage][2].text,
      "courseId":widget.id,
      "correctAnswer": _answersControllers[_currentPage][_correctAnswers[_currentPage]].text,
      "questionMark": int.parse(_scoreControllers[_currentPage].text),
      "totalMark": totalMark
      };

      var response = await http.put(Uri.parse(addQuestions),
          headers: {"Content-Type":"application/json"},
          body: jsonEncode(regBody)
      );

      var jsonResponse = jsonDecode(response.body);

      print(jsonResponse['status']);

      if(jsonResponse['status']){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
          content: Text("Question is added successfully!"),
          duration: Duration(seconds: 2), 
          backgroundColor: Color.fromARGB(255, 52, 150, 55),
         ),
       );
        print("Done!");
      }else{
        print("SomeThing Went Wrong");
      }
    }
    else{
       ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
          content: Text("fields are empty!"),
          duration: Duration(seconds: 2), 
          backgroundColor: Colors.red,
         ),
       );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: offwhite,

      body: Column(
        children: [
          const SizedBox(height: 40),
          // Progress Bar and Question Info
           // Back button
                Align(
                   alignment: Alignment.topLeft,
                  child: IconButton(                  
                    icon: const Icon(Icons.arrow_back, color: ourPink,size: 30,),
                    onPressed: () {
                      Navigator.pop(context); // Action to go back
                    },
                  ),
                ),
                const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                Container(
                  height: 10,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (_currentPage + 1) / n,
                      color: ourBlue,
                      backgroundColor: const Color.fromARGB(255, 191, 221, 222),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Question ${_currentPage + 1} of ${n}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5E5C66),
                      ),
                    ),
                    const Text(
                      "Score",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 52, 150, 55),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                 Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                     SizedBox(
                      width: 50, // عرض الحقل النصي
                      height: 40,
                      child: TextField(
                        controller: _scoreControllers[_currentPage],
                        keyboardType: TextInputType.number,
                         style: const TextStyle(
                          fontSize: 20, // حجم الخط
                        ),
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                             enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 52, 150, 55),
                              width: 1.5 // لون الحدود عندما لا يكون الحقل نشطًا
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 6), 
                        ),
                        
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Quiz Card
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: n,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return SingleChildScrollView(child: _buildQuizCard(index));
              },
            ),
          ),
          // Next Button
          Padding(
  padding: const EdgeInsets.symmetric(vertical: 20.0),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly, // توزيع الأزرار على الجوانب
    children: [
      // زر Previous
      ElevatedButton(
        onPressed: () {
        addQuestion();
        },
        child: const Text('Add'),
        style: ElevatedButton.styleFrom(
          backgroundColor: ourPink, // لون زر السابق
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        ),
      ),
      const SizedBox(height: 20,),
      // زر Next
      ElevatedButton(
        onPressed: () {
          if (_currentPage < n) {
            //_clearFields();
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
          if(_currentPage==n-1){
            Navigator.pop(context);
          }
        },      
        child: _currentPage ==(n-1) ? const Text('Finish'):const Text('Next'),
        style: ElevatedButton.styleFrom(
          backgroundColor: ourBlue, // لون زر التالي
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        ),
      ),
    ],
  ),
),

        ],
      ),
    );
  }

  Widget _buildQuizCard(int index) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Layer 1: Shadow for the card
            Positioned(
              bottom: 10,
              child: Container(
                height: 150,
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.purple.shade200.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 5,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
              ),
            ),
            // Main card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(255, 225, 199, 16).withOpacity(0.2),
                    offset: const Offset(0, 10),
                    blurRadius: 20,
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                     const SizedBox(height: 15),
                        Text(
                      'Question ${index + 1}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 225, 193, 16),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Question TextField
                    TextField(
                        controller: _questionControllers[index],
                        decoration: InputDecoration(
                          labelText: 'Enter Question',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15), // شكل الحواف
                            borderSide: const BorderSide(
                              color: Colors.grey, // لون الحواف الافتراضي
                              width: 1.5, // سمك الحواف
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 50, // التحكم في ارتفاع الحقل
                            horizontal: 15, // المسافة الأفقية بين النص والحواف
                          ),
                        ),
                        maxLines: null, // يسمح بالعديد من الأسطر
                        style: const TextStyle(
                          height: 1.5, // التحكم في المسافة بين السطور
                        ),
                      ),

                    const SizedBox(height: 40),
                    // Answer Fields
              Column(
                  children: List.generate(3, (answerIndex) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _answersControllers[index][answerIndex], // Controller لكل إجابة
                              decoration: InputDecoration(
                                labelText: 'Answer ${answerIndex + 1}',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Radio<int>(
                            value: answerIndex,
                            groupValue: _correctAnswers[index], // الإجابة الصحيحة للسؤال الحالي
                            onChanged: (value) {
                              setState(() {
                                _correctAnswers[index] = value!; // تحديث الإجابة الصحيحة للسؤال
                              });
                            },
                            activeColor: Colors.green, // اللون عند التحديد
                          ),
                        ],
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                  const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                        Align(
                  alignment: Alignment.topLeft,
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.start, // تصغير حجم الـ Row ليحتوي فقط الأسهم
                    children: [
                    Icon(Icons.arrow_back_ios, color: Colors.grey, size: 14), // سهم صغير
                    Icon(Icons.arrow_back_ios, color: Colors.grey, size: 14),
                    Icon(Icons.arrow_back_ios, color: Colors.grey, size: 14),
                   ],
                 ),
                 ),
                     Align(
                      alignment: Alignment.topRight,
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.end, // تصغير حجم الـ Row ليحتوي فقط الأسهم
                        children: [
                        Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14), // سهم صغير
                        Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
                        Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
                       ],
                     ),
                     ),
              
                   ],
                 ),
                  //const SizedBox(height: 20),
              

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
