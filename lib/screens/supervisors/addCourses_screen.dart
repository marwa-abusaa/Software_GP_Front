import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/screens/supervisors/courseDetails_screen.dart';
import 'package:flutter_application_1/widgets/custom_home.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/config.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:velocity_x/velocity_x.dart';


class AddCoursesScreen extends StatefulWidget {
  final token;
  const AddCoursesScreen({@required this.token,Key? key}) : super(key: key);

  @override
  State<AddCoursesScreen> createState() => _AddCoursesScreenState();
}

class _AddCoursesScreenState extends State<AddCoursesScreen> {

  late String supervisorId;
  TextEditingController title = TextEditingController();
  TextEditingController courseType = TextEditingController();
  TextEditingController supervisorName = TextEditingController();
  TextEditingController description= TextEditingController();
  TextEditingController score = TextEditingController();
  TextEditingController link = TextEditingController();
  List? items;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Map<String,dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);

    supervisorId = jwtDecodedToken['_id'];
    getCoursesList(supervisorId);
  }

  void addCourse() async{
    if(title.text.isNotEmpty && courseType.text.isNotEmpty && supervisorName.text.isNotEmpty && description.text.isNotEmpty && score.text.isNotEmpty
    && link.text.isNotEmpty ){

      var regBody = {
        "supervisorId":supervisorId,
        "title":title.text,
        "courseType":courseType.text,
        "description":description.text,
        "supervisorName":supervisorName.text,
        "score":score.text,
        "link":link.text,
      };

      var response = await http.post(Uri.parse(newCourse),
          headers: {"Content-Type":"application/json"},
          body: jsonEncode(regBody)
      );

      var jsonResponse = jsonDecode(response.body);

      print(jsonResponse['status']);

      if(jsonResponse['status']){
        courseType.clear();
        title.clear();
        supervisorName.clear();
        description.clear();
        score.clear();
        link.clear();
        Navigator.pop(context);
        getCoursesList(supervisorId);
      }else{
        print("SomeThing Went Wrong");
      }
    }
  }

 void getCoursesList(supervisorId) async {
    print(supervisorId);
    var regBody = {
      "supervisorId": supervisorId
    };

    var response = await http.post(Uri.parse(getSupervisorCourses),
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


  void deleteItem(id) async{
    var regBody = {
      "id":id
    };

    var response = await http.post(Uri.parse(deleteCourse),
        headers: {"Content-Type":"application/json"},
        body: jsonEncode(regBody)
    );

    var jsonResponse = jsonDecode(response.body);
    if(jsonResponse['status']){
      getCoursesList(supervisorId);
    }

  }


  @override
  Widget build(BuildContext context) {
    return CustomHomePage(
  emaill: EMAIL,
  body: Stack( // Use Stack to overlay the button on top of the content
    children: [
      Column(
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              width: MediaQuery.of(context).size.width,
              color: ourPink,
              padding: const EdgeInsets.only(
                  top: 8.0, bottom: 15.0),
              child: const Column(
                children: [
                  Text(
                    'My Courses',
                    style:
                        TextStyle(fontSize: 25.0, fontWeight: FontWeight.w500,color: Colors.white),
                  ),
                ],
              ),
            ),

          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: items == null ? null: ListView.builder(
                        itemCount: items!.length,
                        itemBuilder: (context, int index) {
                          return Slidable(
                            key: const ValueKey(0),
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              dismissible: DismissiblePane(onDismissed: () {}),
                               extentRatio: 0.33,
                              children: [
                                SlidableAction(                                  
                                  backgroundColor: Color(0xFFFE4A49),
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Delete',
                                  onPressed: (BuildContext context) {
                                    print('${items![index]['_id']}');
                                    deleteItem('${items![index]['_id']}');
                                  },
                                ),
                              ],
                            ),
                            child: Card(
                              borderOnForeground: false,
                              child: ListTile(
                                leading: const Icon(Icons.task, color: ourPink),
                                title: Text('${items![index]['title']}',style: const TextStyle(fontSize: 16),),
                                subtitle: Text('${items![index]['courseType']}'),
                                trailing: const Icon(Icons.arrow_back,color: ourPink,),
                                onTap: () {
                                  // Navigate to CourseDetailScreen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>  CourseDetailsScreen(id: '${items![index]['_id']}', linkk: '${items![index]['link']}',),
                                    ),
                                  );
                                },
                              ),

                            ),
                          );
                        }),
              ),
            ),
          ),
        ],
      ),
      // Add custom circular button here
      Positioned(
        bottom: 16, // Adjust this value for spacing from the bottom
        right: 16,  // Adjust this value for spacing from the right
        child: GestureDetector(
          onTap: () {
            _displayTextInputDialog(context);
          },
          child: Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: ourBlue, // Button color
              shape: BoxShape.circle, // Circular shape
            ),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
    ],
  ),
);

  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: offwhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Container(
          height: 610,
          width: 700, // Set your desired width here
          child: SingleChildScrollView(  // Move SingleChildScrollView here
            child: Column(
              mainAxisSize: MainAxisSize.min,  // Ensure the Column takes minimum height
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Add Course',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: ourBlue),
                  ),
                ),
                TextField(
                  controller: title,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Title",
                    hintStyle: TextStyle(
                      fontSize: 15.0, 
                      color: Colors.grey, 
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ).p4().px8(),
                TextField(
                  controller: description,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Description",
                    hintStyle: TextStyle(
                      fontSize: 15.0, 
                      color: Colors.grey, 
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ).p4().px8(),
                TextField(
                  controller: courseType,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Course Type: video/website",
                    hintStyle: TextStyle(
                      fontSize: 15.0, 
                      color: Colors.grey, 
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ).p4().px8(),
                TextField(
                  controller: supervisorName,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Your Name",
                    hintStyle: TextStyle(
                      fontSize: 15.0, 
                      color: Colors.grey, 
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ).p4().px8(),
                TextField(
                  controller: score,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Score",
                    hintStyle: TextStyle(
                      fontSize: 15.0, 
                      color: Colors.grey, 
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ).p4().px8(),
                TextField(
                  controller: link,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Link",
                    hintStyle: TextStyle(
                      fontSize: 15.0, 
                      color: Colors.grey, 
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ).p4().px8(),
                SizedBox(height: 3,),
                SizedBox(
                  height: 60,
                  width: 150, // Set the width you want
                  child: ElevatedButton(                  
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ourBlue,
                    ),
                    onPressed: () {
                      addCourse();
                    },
                    child: Text("Add"),
                  ),
                )

              ],
            ),
          ),
        ),
      );
    },
  );
}



}