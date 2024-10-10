import 'package:flutter/material.dart';

class MyStoriesScreen extends StatefulWidget {
  late String emaill;
   MyStoriesScreen({required this.emaill,Key? key}) : super(key: key);

  @override
  State<MyStoriesScreen> createState() => _MyStoriesScreenState();
}

class _MyStoriesScreenState extends State<MyStoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(

      body: 
      
      Center(
        child: Text("stories screen"),
      ),
    );
  }
}
