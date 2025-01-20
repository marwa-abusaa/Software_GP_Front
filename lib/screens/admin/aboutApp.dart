import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/app_colors.dart';

class AboutAppScreen extends StatefulWidget {
  @override
  _AboutAppScreenState createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: offwhite,
      appBar: AppBar(
        backgroundColor: ourPink,
        title: const Text(
          'About App',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo Section
               Transform.translate(
                  offset: Offset(0, -60),
                  child: Image.asset(
                    'assets/images/logo2.png', // المسار إلى صورة الشعار
                    width: 300,
                    height: 300,
                  ),
                ),
        
              // About Section
             Transform.translate(
                offset: Offset(0, -140),
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: offwhite, // إضافة لون الخلفية
                    border: Border.all(color: ourBlue),
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5), // لون الظل مع الشفافية
                        spreadRadius: 2, // مدى انتشار الظل
                        blurRadius: 5, // مدى تمويه الظل
                        offset: Offset(3, 3), // إزاحة الظل (يمين وأسفل)
                      ),
                    ],
                  ),
                  child: const Text(
                    'An interactive platform designed to empower creativity and learning. The app allows users to create their own stories by dragging characters and illustrations into a customizable book format. It also offers a variety of competitions, courses, and quizzes to engage users and enhance their skills. With Tiny Tales, users can transform their imagination into shareable stories and contribute to a vibrant community of creators.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Times New Roman',
                    ),
                  ),
                ),
              ),

              //const SizedBox(height: 20),
        
              // Developers Section
              Transform.translate(
                offset: Offset(0, -90),
                child: const Text(
                  'Developers:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ourPink,fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 10),
        
              // Developer Profiles
              Transform.translate(
                offset: Offset(0, -80),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        CircleAvatar(
                          backgroundImage: AssetImage('assets/images/aya.jpeg'), // صورة المطور الأول
                          radius: 40,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'ِAya Ba\'ara', // اسم المطور الأول
                          style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold, color: Color.fromARGB(255, 67, 65, 65)),
                        ),
                      ],
                    ),
                    SizedBox(width: 20),
                    Column(
                      children: [
                        CircleAvatar(
                          backgroundImage: AssetImage('assets/images/marwa.jpeg'), // صورة المطور الثاني
                          radius: 40,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Marwa AbuSaa', // اسم المطور الثاني
                          style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold, color: Color.fromARGB(255, 67, 65, 65)),
                        ),
                      ],
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
