import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_application_1/config.dart';
import 'package:flutter_application_1/constants/app_colors.dart';

class ClassroomScreen extends StatefulWidget {
  final String id;
  final String title;
  ClassroomScreen({required this.id,Key? key, required this.title}) : super(key: key);

  @override
  _ClassroomScreenState createState() => _ClassroomScreenState();
}

class _ClassroomScreenState extends State<ClassroomScreen> {
  late String courseId=widget.id;
  late String title=widget.title;
  List? items;
  bool isAscending = true; 

   @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMarks(courseId);
  }

  
   int selectedOption = 0;

  double calculateAverage(List items) {
  // التحقق من أن القائمة غير فارغة
  if (items.isEmpty) return 0.0;

  // جمع القيم
  double total = 0.0;
  for (var item in items) {
    total += double.tryParse(item['UserTotalMark'].toString()) ?? 0.0;
  }

  // حساب المتوسط
  double average = total / items.length;

  return average;
}

void sortItems(String criteria) {
  if (items == null || items!.isEmpty) return;

  setState(() {
    if (criteria == 'Name') {
      // ترتيب حسب الاسم
      items!.sort((a, b) => isAscending
          ? a['userName'].toString().compareTo(b['userName'].toString())
          : b['userName'].toString().compareTo(a['userName'].toString()));
    } else if (criteria == 'Grade') {
      // ترتيب حسب العلامة
      items!.sort((a, b) => isAscending
          ? double.parse(a['UserTotalMark'].toString())
              .compareTo(double.parse(b['UserTotalMark'].toString()))
          : double.parse(b['UserTotalMark'].toString())
              .compareTo(double.parse(a['UserTotalMark'].toString())));
    }
  });
}



    void getMarks(courseId) async {
    print(courseId);
    var regBody = {
      "courseId": courseId
    };

    var response = await http.post(Uri.parse(getChildrenMark),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody) // This sends the JSON body
    );

    if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        items = jsonResponse['success'];
        print('items: ${items}');
        setState(() {});
    } else {
        print('Error: ${response.statusCode}');
        print('Response: ${response.body}');
    }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: offwhite, // Purple background
      appBar: AppBar(
      title: Text('Children\'s Grades', style: TextStyle(color: Colors.white)),
      backgroundColor: ourPink,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white), // Change the icon color here
        onPressed: () {
          Navigator.pop(context); // Navigation to the previous screen
        },
      ),
    ),

      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              color: offwhite, // Dark purple
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Container(
                    padding: const EdgeInsets.fromLTRB(15, 5, 10, 0),
                     child: Text(
                      title,
                      style: const TextStyle(
                        color: ourBlue,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Times New Roman',
                        fontStyle: FontStyle.italic,
                        decoration: TextDecoration.underline,decorationColor:ourBlue,
                      ),
                      
                                       ),
                   ),
                 
                  const SizedBox(height: 20),
                  
                  Center(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                     decoration: BoxDecoration(                   
                    borderRadius: BorderRadius.circular(20),
                    //border: Border.all(color: ourPink, width: 1),
                    color: const Color(0xFFfce7b6),
                  ),
                      height: 60,
                      width: 365,                     
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _infoText('Total no.', items==null? '':items!.length.toString()),
                          _infoText('FullMark', items==null? '':'${items![0]['totalMark']}'),
                          _infoText('Average', items==null? '': calculateAverage(items!).toString()),
                        ],
                      ),
                    ),
                  ),
                   const Divider(
                  height: 20.0,  // The total vertical space occupied by the Divider.
                  color: ourPink,  // The color of the line.
                  thickness: 2.0,  // The thickness of the line.
                  indent: 22.0,  // Empty space to the left of the line.
                  endIndent: 22.0,  // Empty space to the right of the line.              
              ),
                ],
              ),
            ),

            // Attendance Info
            Container(
              //color: const Color(0xFF6E4FCD),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
              child: Row(
        //mainAxisSize: MainAxisSize.min,
         mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Text('Sort By',style: TextStyle(
              color: ourPink,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Times New Roman',
              fontStyle: FontStyle.italic
             ),),
          const SizedBox(height: 17),
          
          Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedOption = 0; // اختيار "Name"
                      sortItems('Name'); // ترتيب حسب الاسم
                    });
                  },
                  child: Container(
                    width: 100,
                    height: 50,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    decoration: BoxDecoration(
                      color: selectedOption == 0 ? ourBlue : Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: ourBlue, width: 1),
                    ),
                    child: Center(
                      child: Text(
                        'Name',
                        style: TextStyle(
                          color: selectedOption == 0 ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedOption = 1; // اختيار "Mark"
                      sortItems('Grade'); // ترتيب حسب العلامة
                    });
                  },
                  child: Container(
                    width: 100,
                    height: 50,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    decoration: BoxDecoration(
                      color: selectedOption == 1 ? ourBlue : Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: ourBlue, width: 1),
                    ),
                    child: Center(
                      child: Text(
                        'Grade',
                        style: TextStyle(
                          color: selectedOption == 1 ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isAscending ? Icons.arrow_downward : Icons.arrow_upward,
                    color: ourPink,
                    size: 32,
                  ),
                  onPressed: () {
                    setState(() {
                      isAscending = !isAscending; // تبديل الاتجاه
                      sortItems(selectedOption == 0 ? 'Name' : 'Grade'); // تطبيق الترتيب
                    });
                  },
                ),
              ],
            ),

          
            

        ],
      ),
    
            ),

            // Table Section with Scrollbar
         Expanded(
  child: Padding(
    padding: const EdgeInsets.all(20.0),
    child: Container(
      decoration: const BoxDecoration(
        color: const Color(0xFFf8ecec),
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            decoration: const BoxDecoration(
            color: const Color(0xFFd68f8f), // Background color for header
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
            padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20),
            child:  Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Transform.translate(
                  offset: Offset(15, 0),
                   child: const Text(
                     '#',
                     style: TextStyle(
                         fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                   ),
                 ),
                Transform.translate(
                  offset: Offset(8, 0),
                  child: const Text(
                    'Name',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                  ),
                ),
                Transform.translate(
                  offset: Offset(-5, 0),
                  child: const Text(
                    'Grade',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                  ),
                ),

              ],
            ),
          ),
          //const Divider(),

          // Scrollable Table with Scrollbar
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: ScrollbarTheme(
                data: ScrollbarThemeData(
                  thumbColor: MaterialStateProperty.all(Color(0xFFd68f8f)), // Purple color
                  thickness: MaterialStateProperty.all(6),
                  radius: const Radius.circular(10),
                  minThumbLength: 50,
                ),
                child: Scrollbar(
                  thickness: 6,
                  radius: const Radius.circular(10),
                  //thumbVisibility: true,
                  child: items == null  ? 
                  const Center(
                child: Text(
                  'No one has submitted the quiz yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            :  ListView.builder(
                    itemCount: items!.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${index + 1}'),
                            Text('${items![index]['userName']}'),                         
                            Text('${items![index]['UserTotalMark']}'),                                                      
                          ],
                        ),
                      );
                    },
                  ),
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

  Widget _infoText(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _attendanceColumn(String Nameber, String label) {
    return Column(
      children: [
        Center(
          child: Text(
            Nameber,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
