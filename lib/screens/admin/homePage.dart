import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/screens/admin/StatisticsPage.dart';
import 'package:flutter_application_1/screens/admin/addNewImage.dart';
import 'package:flutter_application_1/screens/admin/categories.dart';
import 'package:flutter_application_1/screens/admin/progressByAdmin.dart';
import 'package:flutter_application_1/screens/admin/settingsPage.dart';
import 'package:flutter_application_1/screens/admin/superRequst.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_application_1/config.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/api/api.dart';
import 'package:flutter_application_1/config.dart';
import 'package:jwt_decoder/jwt_decoder.dart';


class AdminHomePage extends StatefulWidget {
  // final token;
  const AdminHomePage({Key? key,}) : super(key: key);
  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {

  late String emaill;

   int _currentTabIndex = 0;

  String filter = ''; // Filter for search
  String userType = 'user'; // User type filter
 
  // صفحات التبويبات
  final List<Widget> _tabPages = [
    Center(child: Text('Actions page', style: TextStyle(fontSize: 24))),
    Center(child: Text('Users page', style: TextStyle(fontSize: 24))),
    Center(child: Text('Dashboard page', style: TextStyle(fontSize: 24))),
  ];

  // صفحات الأزرار السفلية
   final List<Widget> _bottomPages = [
    AdminHomePage(), // الصفحة الأولى
    SettingsAdmin(), // الصفحة الثانية
  ];

  int _currentBottomIndex = 0;

  List<dynamic> users = []; // Empty list for users
  bool isLoading = true; // To show loading spinner
  
   @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(TOKEN);
    emaill = jwtDecodedToken['email'];
    EMAIL = emaill;
    
    fetchUsers(); // Fetch users when the page loads
    fetchCounts();
  }

////delete user
Future<void> deleteUser(String email) async {
  const String apiUrl = myProfile; // استبدل بعنوان API الخاص بك

  try {
    var response = await http.delete(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    if (response.statusCode == 200) {
      print("User deleted successfully");
    } else {
      print("Failed to delete user: ${response.body}");
    }
  } catch (e) {
    print("Error: $e");
  }
}
  

///add new admin
void showRegistrationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {

      return StatefulBuilder(
        builder: (BuildContext context, setState) {
          return AlertDialog(
            title: const Text('Register New Admin',style: TextStyle(color: ourBlue,fontStyle: FontStyle.italic),),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 8,),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: dobController,
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth',
                      border: OutlineInputBorder(),
                    ),
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          dobController.text =
                              "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    items: const [
                      DropdownMenuItem(
                        value: 'Male',
                        child: Text('Male'),
                      ),
                      DropdownMenuItem(
                        value: 'Female',
                        child: Text('Female'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                    ),
                    dropdownColor:
                      offwhite, // Background color of dropdown menu
                       borderRadius: BorderRadius.circular(25),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel',style: TextStyle(color: Colors.red,fontStyle: FontStyle.italic),),
              ),
              ElevatedButton(
                onPressed: () {
                  if (emailController.text.isNotEmpty &&
                      passwordController.text.isNotEmpty &&
                      firstNameController.text.isNotEmpty &&
                      lastNameController.text.isNotEmpty &&
                      selectedGender != null &&
                      dobController.text.isNotEmpty) {
                    registerUser();                   
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill all fields.'),
                      ),
                    );
                  }
                  
                },
                 style: ElevatedButton.styleFrom(
                backgroundColor: ourBlue, // Change button color
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Adjust size
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // Rounded corners
                ),
                textStyle: const TextStyle(
                  fontSize: 18, // Font size
                  fontWeight: FontWeight.bold, // Bold text
                ),
              ),
                child: const Text('Add',style: TextStyle(fontStyle: FontStyle.italic),),
              ),
            ],
          );
        },
      );
    },
  );
}

bool _isNotValidate = false;
TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
    String? selectedGender;



  void registerUser() async {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      try {
        // Upload CV to Firebase Storage if user is supervisor
      
      bool isDone=false;
        var regBody = {
          "email": emailController.text,
          "password": passwordController.text,
          "firstName": firstNameController.text,
          "lastName": lastNameController.text,
          "gender": selectedGender,
          "birthdate": dobController.text,
          "role": "admin",
          "cv": "", 
        };

        var response = await http.post(
          Uri.parse(registration),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regBody),
        );

        if (response.statusCode == 201) {
          try {
            // Create the user in Firebase Authentication
            final newUser =
                await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: emailController.text,
              password: passwordController.text,
            );

            // Check if the user was successfully created
            if (newUser.user != null) {
              print("User created: ${newUser.user?.email}");

              // Set the current email globally
              APIS.initializeEmail(newUser.user!.email!);

              // Now, call createUser() to save user data to Firestore
              await APIS.createUser();
              isDone=true;

            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User creation failed.')));
            }
          } catch (e) {
            print("Error: $e");
            ScaffoldMessenger.of(context).showSnackBar( SnackBar(
                content: Text('An error occurred. Please try again.$e')));
          }

            if(isDone){
               // Clear the fields
                    emailController.clear();
                    passwordController.clear();
                    firstNameController.clear();
                    lastNameController.clear();
                    dobController.clear();
                    setState(() {
                      selectedGender = null;
                    });
            }
          var jsonResponse = jsonDecode(response.body);
          print(jsonResponse['status']);
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User registered successfully!')));
          
        } else if (response.statusCode == 409) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Email is already registered.')));
        } else if (response.statusCode == 400) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Invalid request. Please check your input.')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Something went wrong. Please try again later.')));
        }
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar( SnackBar(
            content: Text('An error occurred. Please try again.$e')));
      }
    } else {
      setState(() {
        _isNotValidate = true;
      });
    }
  }

///display users
    Future<void> fetchUsers() async {
    // Replace with your API URL
    try {
      final response = await http.get(Uri.parse("${url}all-users?role=$userType"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          users = data['users'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print('Error fetching users: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  //dashboard
   String supervisorsCount = "0";
  String usersCount = "0";
  String coursesCount = "0";
  String contestsCount = "0";
   Future<void> fetchCounts() async {
      print(supervisorsCount);
  
    try {
      // URLs
      final supervisorsUrl = Uri.parse("http://192.168.1.116:3000/users/supervisor");
       final usersUrl = Uri.parse("http://192.168.1.116:3000/users/user");
       final coursesUrl = Uri.parse("http://192.168.1.116:3000/courses");
       final contestsUrl = Uri.parse("http://192.168.1.116:3000/contests");

      // Fetch data
      final supervisorsResponse = await http.get(supervisorsUrl);
       final usersResponse = await http.get(usersUrl);
       final coursesResponse = await http.get(coursesUrl);
       final contestsResponse = await http.get(contestsUrl);

      // Parse JSON and update state
      setState(() {
        supervisorsCount = json.decode(supervisorsResponse.body)['count'].toString();
         usersCount = json.decode(usersResponse.body)['count'].toString();
         coursesCount = json.decode(coursesResponse.body)['count'].toString();
         contestsCount = json.decode(contestsResponse.body)['count'].toString();     
      });
             // عرض الـ SnackBar بعد تحديث البيانات
   
    } catch (error) {
      print("Error fetching counts: $error");
      // يمكنك التعامل مع الأخطاء هنا، مثل عرض رسالة للمستخدم
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: offwhite,
       appBar: PreferredSize(
        preferredSize: Size.fromHeight(88.0), // التحكم في ارتفاع الـ AppBar
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: offwhite, // لون الخلفية مشابه للصورة
          //elevation: 0, // إزالة الظل لجعلها مسطحة
          flexibleSpace: Stack(
            children: [
              Positioned(
                top: -19, // للتحكم في مكان الصورة
                left: -47, // لجعل الصورة على اليسار
                child: Image.asset(
                  'assets/images/logo2.png', // المسار إلى صورة الشعار
                  width: 220,
                  height: 220,
                ),
              ),
              
            ],
          ),
        ),
      ),
    body:
     Column(
        children: [
          SizedBox(height: 10,),
          // التبويبات تحت AppBar
          TabBarSection(
            currentIndex: _currentTabIndex,
            onTabSelected: (index) {
              setState(() {
                _currentTabIndex = index;
              });
            },
          ),

          if(_currentTabIndex==0)
          Expanded(           
        child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // الدائرة العلوية
            Positioned(
              top: 75 , // قرب الدائرة للأعلى
              child: CircularButton(
                text: "Accept supervisor",
                icon: Icons.check_circle,
                isEven: false,
                onTap: () {
                Navigator.push(
                   context,
                   MaterialPageRoute(
                   builder: (context) => SupervisorRequestsPage(),
                   ),
                 );
                },
              ),
            ),
            // الدائرة اليمنى
            Positioned(
              right: -7, // قرب الدائرة لليمين
              child: CircularButton(
                text: "Add category",
                icon: Icons.add_box,
                isEven: true,
                onTap: () {
                   Navigator.push(
                   context,
                   MaterialPageRoute(
                   builder: (context) => BookCategoriesPage(),
                   ),
                 );
                },
              ),
            ),
            // الدائرة السفلية
            Positioned(
              bottom: 75, // قرب الدائرة للأسفل
              child: CircularButton(
                text: "Add image",
                icon: Icons.image,
                isEven: false,
                onTap: () {
                  Navigator.push(
                   context,
                   MaterialPageRoute(
                   builder: (context) => AddImagePage(),
                   ),
                 );
                },
              ),
            ),
            // الدائرة اليسرى
            Positioned(
              left: -7, // قرب الدائرة لليسار
              child: CircularButton(
                text: "Add admin",
                icon: Icons.person_add,
                isEven: true,
                onTap: () {
                 showRegistrationDialog(context); 
                },
              ),
            ),
            // الدائرة الوسطى
            Center(
              child: CircularButton(
                text: "",
                icon: Icons.admin_panel_settings,
                isEven: false,
                isCenter: true,
                onTap: () {
                  print("Center button pressed");
                },
              ),
            ),
          ],
        ),
      ),
          ),

           if(_currentTabIndex==1)
           Expanded(
            child:  isLoading
           ? Center(child: CircularProgressIndicator()) // Show loading spinner
         : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  onChanged: (value) {
                                    setState(() {
                                      filter = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Search by name',
                                    hintStyle: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      color: Colors.black,
                                    ),
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 0),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    prefixIcon: const Icon(Icons.search),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    userType = userType == 'supervisor'
                                        ? 'user'
                                        : 'supervisor';
                                  });
                                  fetchUsers();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                      255, 63, 160, 161),
                                  fixedSize: Size(
                                    MediaQuery.of(context).size.width * 0.43,
                                    44,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                child: Text(
                                  userType == 'supervisor'
                                      ? 'Show Children'
                                      : 'Show Supervisors',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
  child: SingleChildScrollView(
    scrollDirection: Axis.vertical, // تمرير عمودي بدون Scrollbar
    child: ScrollbarTheme(
      data: ScrollbarThemeData(
        thumbColor: MaterialStateProperty.all(ourBlue),
        thickness: MaterialStateProperty.all(6),
        radius: const Radius.circular(10),
      ),
      child: Scrollbar(
        thumbVisibility: true, // يظهر فقط للتمرير الأفقي
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal, // تمرير أفقي
          child: DataTable(
            columns: const [
              DataColumn(
                  label: Text('ID',
                      style: TextStyle(color: ourPink))),
              DataColumn(
                  label: Text('Name',
                      style: TextStyle(color: ourPink))),
              DataColumn(
                  label: Text('Email',
                      style: TextStyle(color: ourPink))),
              DataColumn(
                  label: Text('Gender',
                      style: TextStyle(color: ourPink))),
              DataColumn(
                  label: Text('Actions',
                      style: TextStyle(color: ourPink))),
            ],
            rows: users
                .where((user) =>
                    filter.isEmpty ||
                    user['firstName']
                        .toLowerCase()
                        .contains(filter.toLowerCase()))
                .map(
                  (user) => DataRow(
                    cells: [
                      DataCell(Text((users.indexOf(user) + 1).toString())),
                      DataCell(Text(
                          '${user['firstName']} ${user['lastName']}')),
                      DataCell(Text(user['email'])),
                      DataCell(
                        user['gender'] == 'Female'
                            ? Icon(Icons.female,
                                color: ourPink)
                            : Icon(Icons.male,
                                color: Color.fromARGB(
                                    255, 61, 157, 235)),
                      ),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: ourBlue),
                            onPressed: () {
                              // Edit action
                            },
                          ),
                          IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () async {
                        // عرض مربع حوار التأكيد قبل الحذف
                        bool confirmDelete = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: offwhite,
                              title:  Text('Confirm Delete',style: TextStyle(color:Colors.green[300])),
                              content: const Text('Are you sure you want to delete this user?',style: TextStyle(fontSize: 17)),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Cancel',style: TextStyle(color:Colors.black)),
                                  onPressed: () {
                                    Navigator.of(context).pop(false); // إغلاق الحوار مع قيمة false
                                  },
                                ),
                                TextButton(
                                  child: const Text('Delete',style: TextStyle(color:Colors.red),),
                                  onPressed: () {
                                    Navigator.of(context).pop(true); // إغلاق الحوار مع قيمة true
                                  },
                                ),
                              ],
                            );
                          },
                        ) ?? false; // التأكد من أن القيمة الافتراضية هي false

                        if (confirmDelete) {
                          // الحصول على البريد الإلكتروني للمستخدم
                          String userEmail = user['email'];

                          // استدعاء دالة الحذف
                          await deleteUser(userEmail);

                          // حذف المستخدم من قائمة المستخدمين
                          setState(() {
                            users.remove(user);
                          });

                          // إظهار رسالة تأكيد
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('User deleted successfully')),
                          );
                        }
                      },
                    )

                        ],
                      )),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ),
    ),
  ),
)

                      ],
                    ),
      ),

         if(_currentTabIndex==2)
            Expanded(child: SingleChildScrollView(
              child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
              VerticalCard(
                title: "Number of supervisors",
                value: supervisorsCount,
                color: ourBlue,
                isButton: false,
              ),
              const SizedBox(height: 16),
               VerticalCard(
                title: "Number of children",
                value: usersCount,
                color: const Color.fromARGB(255, 224, 125, 125),
                isButton: false,
              ),
              const SizedBox(height: 16),
               VerticalCard(
                title: "Number of courses",
                value: coursesCount,
                color: const Color.fromARGB(255, 239, 200, 109),
                isButton: false,
              ),
              const SizedBox(height: 16),
               VerticalCard(
                title: "Number of contests",
                value: contestsCount,
                color:const Color.fromARGB(255, 52, 150, 55),
                isButton: false,
              ),
              const SizedBox(height: 16),
               VerticalCard(
                title: "Children Progress",
                value: 'Tap to show progress',
                isButton: true,
                color:ourBlue,
                targetPage: AdminProgressPage(),
              ),
              const SizedBox(height: 16),
               VerticalCard(
                title: "Demographics",
                value: 'Tap to show user statistics',
                color:const Color.fromARGB(255, 224, 125, 125),
                isButton: true,
                targetPage: StatisticsPage(),
              ),
                        ],
                      ),
                    ),
            ),
       )

        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 224, 132, 132),
        currentIndex: _currentBottomIndex,
        onTap: (index) {
          setState(() {
            _currentBottomIndex = index;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => _bottomPages[index],
              ),
            );
          });
        },
         selectedItemColor: iconsBar, // لون الخط عند التحديد
         unselectedItemColor: Colors.white, // لون الخط عند عدم التحديد
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

  class TabBarSection extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  TabBarSection({required this.currentIndex, required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: const Color(0xfffbdfa0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TabBarItem(
            text: 'Actions' ,
            isSelected: currentIndex == 0,
            onTap: () => onTabSelected(0),            
          ),
          TabBarItem(
            text: 'All users',
            isSelected: currentIndex == 1,
            onTap: () => onTabSelected(1),
          ),
          TabBarItem(
            text: 'Dashboard',
            isSelected: currentIndex == 2,
            onTap: () => onTabSelected(2),
          ),
        ],
      ),
    );
  }
}

class TabBarItem extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  TabBarItem({required this.text, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? ourPink: Colors.black,
            ),
          ),
          if (isSelected)
            Container(
              margin: EdgeInsets.only(top: 4),
              height: 2,
              width: 50,
              color: ourPink,
            ),
        ],
      ),
    );
  }
}
class CircularButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  final bool isCenter;
  final bool isEven;

  const CircularButton({
    required this.text,
    required this.icon,
    required this.onTap,
    this.isCenter = false, 
    required this.isEven,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isCenter ? 78 : isEven? 148: 138, // حجم أصغر للدوائر
        height: isCenter ? 78 : 150, // حجم أصغر للدوائر
        margin: EdgeInsets.all(10), // مساحة بين الدوائر
        decoration: BoxDecoration(
          color: isCenter ? Colors.transparent : isEven? const Color.fromARGB(255, 216, 127, 127): const Color.fromARGB(255, 97, 181, 183),
          shape: BoxShape.circle,
          // border: Border.all(
          //   color: offwhite,
          //   width: 2,
          // ),
          
            boxShadow: [
      BoxShadow(
        color: isCenter? offwhite: Colors.black.withOpacity(0.6), // لون الظل مع شفافية خفيفة
        offset: Offset(4, 4), // اتجاه الظل (إزاحة X و Y)
        blurRadius: 6, // تأثير التمويه للظل
        spreadRadius: 2, // توسيع الظل
      ),
    ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isCenter ? const Color.fromARGB(255, 238, 186, 65): offwhite,
              size: isCenter ? 55 : 40, // حجم أصغر للأيقونات
            ),
            if (!isCenter)
              Text(
                text,
                style: const TextStyle(
                  color: offwhite,
                  fontSize: 15, // حجم أصغر للنصوص
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}



class VerticalCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final bool isButton;
  final Widget? targetPage;  // الصفحة التي سيتم التنقل إليها (اختياري)

  // تعيين قيم افتراضية للمتغيرات
  VerticalCard({
    this.title = "",  // قيمة افتراضية فارغة
    this.value = "",  // قيمة افتراضية فارغة
    this.color = Colors.blue,  // قيمة افتراضية لون أزرق
    this.isButton = false,  // قيمة افتراضية هي false (أي ليس زرًا)
    this.targetPage,  // الصفحة ليست إجبارية
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 5,
            width: double.infinity,
            color: color,
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 16),
          // إضافة شرط لتنفيذ التنقل فقط عندما يكون isButton = true
          isButton
              ? InkWell(  // لتمكين التفاعل عند الضغط
                  onTap: () {
                    // التنقل إلى الصفحة المحددة فقط إذا كانت targetPage موجودة
                    if (targetPage != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => targetPage!),
                      );
                    }
                  },
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                )
              : Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
        ],
      ),
    );
  }
}











