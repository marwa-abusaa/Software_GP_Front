import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/info.dart';
import 'package:flutter_application_1/config.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/screens/admin/aboutApp.dart';
import 'package:flutter_application_1/screens/admin/profilePage.dart';
import 'package:flutter_application_1/screens/login/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;



class SettingsAdmin extends StatefulWidget {
  const SettingsAdmin({Key? key}) : super(key: key);
  
  @override
  _SettingsAdminState createState() => _SettingsAdminState();
}

class _SettingsAdminState extends State<SettingsAdmin> {
  // حالات المفاتيح التبديلية
  bool isNotificationsOn = true;
  bool isDarkModeOn = false;
  bool isLocationOn = true;

   @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }
  String? _profileImageUrl;
    Future<void> _fetchUserProfile() async {
    try {
      // Fetch the image URL
      final profileImageUrl = await fetchUserImage(EMAIL);


      // Update the state synchronously
      setState(() {
        _profileImageUrl = profileImageUrl;     
      });
    } catch (e) {
      print('Error fetching profile data: $e');
    }
  }
    ///log out
  Future<void> _handleLogout(BuildContext context) async {
    await SharedPreferences.getInstance().then((prefs) => prefs.clear());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You have been logged out'),duration: Duration(seconds: 1),),
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => WelcomeScreen()),
      (route) => false,
    );
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
      print("Account deleted successfully");
       Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => WelcomeScreen()),
      (route) => false,
    );
    } else {
      print("Failed to delete user: ${response.body}");
    }
  } catch (e) {
    print("Error: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: offwhite, // خلفية التطبيق
      appBar: AppBar(
        backgroundColor: ourPink,
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // قسم الملف الشخصي
              Container(
                width: double.infinity,
                height: 234,
                padding: const EdgeInsets.all(30.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                     Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: iconsBar,
                          radius: 50,
                          backgroundImage: _profileImageUrl != null ? NetworkImage(_profileImageUrl!): null,
                        ),
                        SizedBox(width: 16),
                      
                      ],
                    ),
                  const SizedBox(height: 20),
                    Row(children: [
                      Transform.translate(
                        offset: Offset(-13, 0),
                        child: Icon(Icons.edit_rounded, color: iconsBar)),
                        const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profile',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Click here to edit your information',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          
                        ],
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(10, 0),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, color: iconsBar, size: 20,),
                        onPressed: () {
                           Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilePage(),
                            ),
                          );
                        },
                      ),
                    ),
                    ],)
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // قائمة الإعدادات
              Container(
                 width: double.infinity,
                //0height: 234,
                padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [                  
                    // استخدام ListView.builder أو Column لعرض الخيارات
                    SettingsOption(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      trailing: Switch(
                        value: isNotificationsOn,
                        onChanged: (value) {
                          setState(() {
                            isNotificationsOn = value;
                          });
                        },
                           activeColor: Colors.white, // لون الدائرة عندما يكون مفعّل
                         activeTrackColor: ourPink, // لون المسار عندما يكون مفعّل
                       inactiveThumbColor: Colors.grey, // لون الدائرة عندما يكون غير مفعّل
                       inactiveTrackColor: Colors.white, // لون المسار عندما يكون غير مفعّل

                      ),
                    ),                                  
                   
                  ],
                ),
              ),
              const SizedBox(height: 20),
                Container(
                 width: double.infinity,
                //0height: 234,
                 padding: const EdgeInsets.fromLTRB(15, 8, 8, 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [                  
                    // استخدام ListView.builder أو Column لعرض الخيارات
                
                    GestureDetector(
                      
                      child: SettingsOption(
                        icon: Icons.info,
                        title: 'About App',
                        trailing: const Icon(Icons.arrow_forward_ios, color: ourPink),
                        onTap: () {                           
                     Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AboutAppScreen(),
                            ),
                          );                
                        }
                      ),
                    ),
                   
                  ],
                ),
                              ),

              const SizedBox(height: 20),

                Container(
                 width: double.infinity,
                //0height: 234,
               padding: const EdgeInsets.fromLTRB(15, 8, 8, 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [                  
                    // استخدام ListView.builder أو Column لعرض الخيارات
                  
                    // خيارات تسجيل الخروج وحذف الحساب
                    SettingsOption(
                      icon: Icons.logout,
                      title: 'Logout',
                      trailing: const Icon(Icons.arrow_forward_ios, color: ourPink),
                      onTap: () {
                        _handleLogout(context);
                      },
                    ),
                    const Divider(),
                    SettingsOption(
                      icon: Icons.delete,
                      title: 'Delete account',
                      titleColor: Colors.red,
                      trailing: const Icon(Icons.arrow_forward_ios, color: ourPink),
                       onTap: () async {
                        // عرض مربع حوار التأكيد قبل الحذف
                        bool confirmDelete = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              //backgroundColor: offwhite,
                              title:  Text('Confirm Delete',style: TextStyle(color:Colors.green[300])),
                              content: const Text('Are you sure you want to delete your account?',style: TextStyle(fontSize: 17)),
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
                        ) ?? false; 

                        if (confirmDelete) {   

                          await deleteUser(EMAIL);

                          // إظهار رسالة تأكيد
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Account deleted successfully')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class SettingsOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget trailing;
  final Color? titleColor;
  final VoidCallback? onTap;

  const SettingsOption({
    Key? key,
    required this.icon,
    required this.title,
    required this.trailing,
    this.titleColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Row(
          children: [
            Icon(icon, color: ourBlue, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: titleColor ?? Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
