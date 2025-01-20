import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/api.dart';
import 'package:flutter_application_1/api/info.dart';
import 'package:flutter_application_1/config.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/models/userChat.dart';
import 'package:flutter_application_1/screens/supervisors/super.service.dart';
import 'package:flutter_application_1/screens/users/follow/follow.service.dart';
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
        title: const Text("Chats",style: TextStyle(color: Colors.white),),
        backgroundColor: ourPink,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
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

              // Filter out null emails and currentEmail
              final list = data
                      ?.map((e) => ChatUser.fromJson(e.data()))
                      .where((user) =>
                          user.email != null && user.email != APIS.currentEmail)
                      .toList() ??
                  [];

              // Handle the role-specific logic
// Handle the role-specific logic
              if (ROLE == 'user') {
                return FutureBuilder<List<dynamic>>(
                  future: Future.wait([
                    getFollowersOrFollowing(
                        EMAIL, 'followers'), // Get followers
                    // Get the users for which the current user is a supervisor
                    Future.wait(list.map((user) async {
                      final superEmail = await fetchSuperEmail(EMAIL ?? '');
                      return superEmail;
                    }))
                  ]),
                  builder: (context, snapshots) {
                    if (snapshots.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshots.hasError) {
                      return Text('Error: ${snapshots.error}');
                    }

                    // Unwrap both futures from the snapshots
                    final followersOrFollowing = snapshots.data?[0] ?? [];
                    final supervisorEmails = (snapshots.data?[1] ?? [])
                        .whereType<String>()
                        .toList(); // Extract valid supervisor emails

                    // Filter the list to include either followers or users where the current user is a supervisor
                    final filteredList = list.where((user) {
                      final isFollower = followersOrFollowing
                          .any((f) => f['email'] == user.email);
                      final isSupervised =
                          supervisorEmails.contains(user.email);
                      return isFollower || isSupervised;
                    }).toList();

                    return ListView.builder(
                      itemCount: filteredList.length,
                      padding: EdgeInsets.only(top: mq.width * 0.01),
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return ChatUserCard(user: filteredList[index]);
                      },
                    );
                  },
                );
              } else if (ROLE != 'user') {
                return FutureBuilder<List<dynamic>>(
                  future: getAllMyChildren(EMAIL),
                  builder: (context, childrenSnapshot) {
                    if (childrenSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (childrenSnapshot.hasError) {
                      return Text('Error: ${childrenSnapshot.error}');
                    }

                    final children = childrenSnapshot.data ?? [];
                    print("Fetched children data: $children");

                    // Filter the list based on matching childEmail
                    final filteredList = list.where((user) {
                      // Check if the user's email matches any childEmail in the children data
                      final match = children
                          .any((child) => child['childEmail'] == user.email);
                      if (match) {
                        print("Match found for user: ${user.email}");
                      } else {
                        print("No match for user: ${user.email}");
                      }
                      return match;
                    }).toList();

                    print("Filtered list: $filteredList");

                    // If no matching users found, show message
                    if (filteredList.isEmpty) {
                      return const Center(child: Text('No children found.'));
                    }

                    return ListView.builder(
                      itemCount: filteredList.length,
                      padding: EdgeInsets.only(top: mq.width * 0.01),
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return ChatUserCard(user: filteredList[index]);
                      },
                    );
                  },
                );
              } else {
                return const Text('Role not recognized');
              }
            default:
              return const Text('Error');
          }
        },
      ),
    );
  }
}
