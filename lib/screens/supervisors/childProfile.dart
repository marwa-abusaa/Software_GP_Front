import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/info.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/screens/books/BookService%20.dart';
import 'package:flutter_application_1/widgets/bookCard.dart';

class ChildProfilePage extends StatefulWidget {
  final String email;

  const ChildProfilePage({super.key, required this.email});

  @override
  _ChildProfilePageState createState() => _ChildProfilePageState();
}

class _ChildProfilePageState extends State<ChildProfilePage> {
  List<dynamic> publishedBooks = [];
  @override
  void initState() {
    super.initState();
    _fetchMypublishedBooks();
  }

  Future<void> _fetchMypublishedBooks() async {
    List? books = await BookService.getMyPublishedBooks(widget.email);
    setState(() {
      publishedBooks = books!;
    });
  }

  // Method to fetch user image and full name together
  Future<Map<String, String>> fetchUserData(String email) async {
    try {
      String userImage = await fetchUserImage(email);
      String fullName = await getUserFullName(email);

      return {
        'image': userImage,
        'name': fullName,
      };
    } catch (e) {
      print("Error fetching user data: $e");
      throw e; // Re-throw to allow upper layers to catch
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: logoBar,
      appBar: AppBar(
        backgroundColor: ourPink,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getUserProgress(widget.email), // Fetching user progress
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print("Error fetching user progress: ${snapshot.error}");
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.hasData) {
            final userProgress = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  // First Part: User Info (Image, Name, Email)
                  FutureBuilder<Map<String, String>>(
                    future: fetchUserData(
                        widget.email), // Fetching user image and full name
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (userSnapshot.hasError) {
                        print(
                            "Error fetching user image and full name: ${userSnapshot.error}");
                        return Center(
                            child: Text("Error: ${userSnapshot.error}"));
                      }

                      if (userSnapshot.hasData) {
                        final userImage = userSnapshot.data!['image']!;
                        final fullName = userSnapshot.data!['name']!;

                        return Column(
                          children: [
                            const SizedBox(height: 10),
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: ourPink,
                              backgroundImage:
                                  userImage != null && userImage.isNotEmpty
                                      ? NetworkImage(userImage)
                                      : null,
                              child: userImage == null || userImage.isEmpty
                                  ? const Icon(Icons.person,
                                      size: 30, color: Colors.white)
                                  : null,
                            ),
                            Text(fullName,
                                style: const TextStyle(fontSize: 24)),
                            Text(widget.email,
                                style: const TextStyle(fontSize: 18)),
                          ],
                        );
                      } else {
                        return const Text("No user data available.");
                      }
                    },
                  ),

                  // Second Part: User Progress
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      color: offwhite,
                      child: ListTile(
                        title: const Text("User Progress"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "Created Stories: ${userProgress['createdStroryNum']}"),
                            Text("Contests: ${userProgress['contestsNum']}"),
                            Text("Courses: ${userProgress['coursesNum']}"),
                            Text("Points: ${userProgress['points']}"),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Third Part: Published Books (this is your part to implement)
                  // Add your code to display the published books here
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      color: offwhite,
                      child: ListTile(
                        title: const Text("Published Books"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 220,
                              child: publishedBooks.isEmpty
                                  ? Center(
                                      child: Text(
                                          "No published books available")) // Placeholder message
                                  : ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: publishedBooks
                                          .length, // Use the length of the fetched books
                                      itemBuilder: (context, index) {
                                        final book = publishedBooks[index];
                                        return BookCard(
                                          title: book[
                                              'name'], // Display the book name
                                          imagePath: book[
                                              'image'], // Pass the image URL if available
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text("No user data available."));
        },
      ),
    );
  }
}
