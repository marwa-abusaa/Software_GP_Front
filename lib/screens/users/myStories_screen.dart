import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/custom_home.dart';

class MyStoriesScreen extends StatefulWidget {
  late String emaill;
   MyStoriesScreen({required this.emaill,Key? key}) : super(key: key);

  @override
  State<MyStoriesScreen> createState() => _MyStoriesScreenState();
}

class _MyStoriesScreenState extends State<MyStoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return  CustomHomePage(
      emaill: widget.emaill,
      body: 
      
      Center(
        child: Text("stories screen"),
      ),
    );
  }
}
