import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/screens/supervisors/courseDetails_screen.dart';
import 'package:flutter_application_1/screens/users/allCoursesDetails_screen.dart';
import 'package:flutter_application_1/screens/users/myStories_screen.dart';
import 'package:flutter_application_1/widgets/custom_home.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/config.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:velocity_x/velocity_x.dart';


class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {

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
    // Map<String,dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);

    // supervisorId = jwtDecodedToken['_id'];
    getCourses();
  }


 void getCourses() async {

    var response = await http.get(Uri.parse(getAllCourses),
        headers: {"Content-Type": "application/json"},
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
                              dismissible: DismissiblePane(onDismissed: () { }),
                              extentRatio: 0.22,
                              children: const [
 
                              ],
                            ),
                            child: Card(
                              borderOnForeground: false,
                              child: ListTile(
                                leading: const Icon(Icons.task, color: ourPink),
                                title: Text('${items![index]['title']}',style: const TextStyle(fontSize: 16),),
                                subtitle: Text('${items![index]['courseType']}'),
                               
                                onTap: () {
                                   Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>  AllCourseDetailsScreen(id: '${items![index]['_id']}',linkk: '${items![index]['link']}'),
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
    
    ],
  ),
);

  }



}