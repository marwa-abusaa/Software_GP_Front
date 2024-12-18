import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/api.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/models/userChat.dart';
import 'package:flutter_application_1/widgets/chatCard.dart';

class chat_home_screen extends StatefulWidget {
  late String emaill;

  chat_home_screen({required this.emaill, super.key});

  @override
  State<chat_home_screen> createState() => _chat_home_screenState();
}

class _chat_home_screenState extends State<chat_home_screen> {
  List<ChatUser> list = [];

  @override
  void initState() {
    super.initState();
    APIS.getFirebaseMessagingToken();
    APIS.getSelfInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
        backgroundColor: ourPink,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: APIS.getAllUsers(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const Center(child: CircularProgressIndicator());
            case ConnectionState.active:
            case ConnectionState.done:
              final data = snapshot.data?.docs;
              print(APIS.getAllUsers().toString() +
                  "<<<<<<<<<<<<<<<All users>>>>>>>>>>>");
              final list = data
                      ?.map((e) => ChatUser.fromJson(e.data()))
                      .where((user) =>
                          user.email != null &&
                          user.email !=
                              APIS.currentEmail) // Filter out null emails and currentEmail
                      .toList() ??
                  [];
              return ListView.builder(
                itemCount: list.length,
                padding: EdgeInsets.only(top: mq.width * 0.01),
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return ChatUserCard(user: list[index]);
                },
              );
            default:
              return const Text('Error');
          }
        },
      ),
    );
  }
}
