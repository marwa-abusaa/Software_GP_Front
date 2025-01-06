import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/api.dart';
import 'package:flutter_application_1/api/info.dart';
import 'package:flutter_application_1/api/notification_services.dart';
import 'package:flutter_application_1/config.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/screens/supervisors/childProfile.dart';
import 'package:flutter_application_1/screens/users/follow/follow.service.dart';
import 'package:flutter_application_1/constants/app_colors.dart';

class UsersPage extends StatefulWidget {
  final String currentUserEmail;

  const UsersPage({Key? key, required this.currentUserEmail}) : super(key: key);

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  int followingCount = 0;
  int followersCount = 0;
  String searchQuery = "";
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    fetchCounts();
  }

  Future<void> fetchCounts() async {
    followingCount =
        (await getFollowersOrFollowing(widget.currentUserEmail, 'following'))
            .length;
    followersCount =
        (await getFollowersOrFollowing(widget.currentUserEmail, 'followers'))
            .length;
    setState(() {});
  }

  Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    return await fetchUsersWithRoleUser();
  }

  Future<List<Map<String, dynamic>>> fetchFollowings() async {
    return await getFollowersOrFollowing(widget.currentUserEmail, 'following');
  }

  Future<List<Map<String, dynamic>>> fetchFollowers() async {
    return await getFollowersOrFollowing(widget.currentUserEmail, 'followers');
  }

  Widget buildUserCard(Map<String, dynamic> user) {
    return FutureBuilder<bool>(
      future: isFollowing(widget.currentUserEmail, user['email']),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        bool isFollowed = snapshot.data!;

        return GestureDetector(
          onTap: () {
            print(user['email']); // Print the email when the card is tapped
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChildProfilePage(
                  email: user['email']!,
                ),
              ),
            );
          },
          child: Card(
            color: offwhite,
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FutureBuilder<String>(
                    future: fetchUserImage(user['email']),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        // If image data is not available or is empty, show the default CircleAvatar with an icon
                        return const CircleAvatar(
                          radius: 25,
                          backgroundColor:
                              ourPink, // Use your desired color (e.g., `ourPink`)
                          child: Icon(Icons.person,
                              size: 30,
                              color: Colors.white), // Icon for missing image
                        );
                      }
                      // If image data exists, show the CircleAvatar with the image
                      return CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(snapshot.data!),
                      );
                    },
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: FutureBuilder<String>(
                      future: getUserFullName(user['email']),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Text("Loading...",
                              style: TextStyle(fontSize: 16));
                        }
                        return Text(snapshot.data!,
                            style: const TextStyle(fontSize: 16));
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (isFollowed) {
                        await unfollowUser(
                            widget.currentUserEmail, user['email']);
                      } else {
                        await followUser(
                            widget.currentUserEmail, user['email']);
                        String? pushToken =
                            await APIS.getPushTokenByEmail(user['email']);
                        if (pushToken != null) {
                          print('Push Token: $pushToken');
                          NotificationService.sendNotification(
                              pushToken,
                              "Follow",
                              "${widget.currentUserEmail} started following you");
                        } else {
                          print('Push token not found for email: ');
                        }
                      }
                      setState(() {});
                      fetchCounts();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFollowed ? Colors.red : ourPink,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // Adjusts to content size
                      children: [
                        Icon(
                          isFollowed ? Icons.person_remove : Icons.person_add,
                          color: Colors.white,
                        ),
                        const SizedBox(
                            width: 8), // Spacing between icon and text
                        Text(
                          isFollowed ? 'Unfollow' : 'Follow',
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildTabContent(
      Future<List<Map<String, dynamic>>> Function() fetchFunction,
      String type) {
    return Column(
      children: [
        if (type != 'all')
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Following: $followingCount',
                    style: const TextStyle(fontSize: 16)),
                Text('Followers: $followersCount',
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search...",
              hintStyle: TextStyle(color: Colors.grey.shade600),
              labelText: "Search",
              labelStyle: TextStyle(color: ourPink),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
              suffixIcon: isSearching
                  ? IconButton(
                      icon: Icon(Icons.close, color: Colors.grey.shade600),
                      onPressed: () {
                        setState(() {
                          searchQuery = "";
                          isSearching = false;
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: ourPink, width: 2),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
                isSearching = value.isNotEmpty;
              });
            },
            style: TextStyle(color: Colors.black87),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: isSearching
                ? (type == 'all'
                    ? searchUsersByName(searchQuery)
                    : searchFollowersOrFollowing(
                        userEmail: widget.currentUserEmail,
                        searchQuery: searchQuery,
                        type: type,
                      ).then((result) =>
                        result.cast<Map<String, dynamic>>())) // Cast the result
                : fetchFunction(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              List<Map<String, dynamic>> users = snapshot.data!;
              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  // Skip building the card if the email matches "EMAIL"
                  if (users[index]['email'] == EMAIL) {
                    return const SizedBox
                        .shrink(); // Returns an empty widget (skips the card)
                  }
                  return buildUserCard(users[index]);
                },
              );
            },
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: logoBar,
        appBar: AppBar(
          backgroundColor: ourPink,
          title: const Text("Users"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "All Users"),
              Tab(text: "Followings"),
              Tab(text: "Followers"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildTabContent(fetchAllUsers, 'all'),
            buildTabContent(fetchFollowings, 'following'),
            buildTabContent(fetchFollowers, 'followers'),
          ],
        ),
      ),
    );
  }
}
