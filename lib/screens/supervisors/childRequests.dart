import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/api.dart';
import 'package:flutter_application_1/api/info.dart';
import 'package:flutter_application_1/api/notification_services.dart';
import 'package:flutter_application_1/config.dart';
import 'package:flutter_application_1/screens/pdfView.dart';
import 'package:flutter_application_1/screens/supervisors/super.service.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/screens/all_users/profileScreens/chratData.dart';

class BookRequestPage extends StatefulWidget {
  @override
  _BookRequestPageState createState() => _BookRequestPageState();
}

class _BookRequestPageState extends State<BookRequestPage> {
  late Future<List<dynamic>> _books;
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _books = fetchBooksBySuperEmail(EMAIL);
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: logoBar,
      appBar: AppBar(
        title: const Text('Book Requests'),
        backgroundColor: ourPink,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _books,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No book requests found.'));
          } else {
            final books = snapshot.data!;
            return ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return GestureDetector(
                  onTap: () async  {
                     // Fetch the author name asynchronously
                  final authorName = await getUserFullName(book['email']);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PdfViewerScreen(
                          pdfUrl: book['pdfLink'],
                          title: book['name'],
                          author: authorName,
                        ),
                      ),
                    );
                    // Print the card info when pressed
                    print('Card pressed: ${book['name']}');
                    print('Book ID: ${book['_id']}');
                    print('Email: ${book['email']}');
                    print('Description: ${book['Description']}');
                  },
                  child: Card(
                    margin: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Center the image
                        book['image'] != null && book['image'].isNotEmpty
                            ? Image.network(
                                book['image'],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                            : const Icon(
                                Icons.book,
                                size: 100,
                              ),
                        // Title and description under the image
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book['name'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text('Email: ${book['email']}'),
                              const SizedBox(height: 5),
                              Text('Description: ${book['Description']}'),
                            ],
                          ),
                        ),
                        // Action buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check),
                                onPressed: () =>
                                    _showCommentDialog(context, 'accept', book),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () =>
                                    _showCommentDialog(context, 'deny', book),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  void _showCommentDialog(BuildContext context, String action, dynamic book) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Provide a comment for $action'),
          content: TextField(
            controller: _commentController,
            decoration: const InputDecoration(hintText: 'Enter your comment'),
            maxLines: 4,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _handleAction(action, book);
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleAction(String action, dynamic book) async {
    final comment = _commentController.text;
    _commentController.clear();

    String? pushToken = await APIS.getPushTokenByEmail(book['email']);
    if (pushToken != null) {
      print('Push Token: $pushToken');
    } else {
      print('Push token not found for email: ');
    }
    if (action == 'deny') {
      if (pushToken != null) {
        NotificationService.sendNotification(pushToken, "Book denied",
            " Your ${book['name']} has been denied by the supervisor open app to get more details");
      }
      print("the book is denied");
      await updateBookStatus(book['name'], book['email'], "denied", comment);
      // Instead of calling initState(), use setState to refresh the UI
      setState(() {
        _books = fetchBooksBySuperEmail(EMAIL);
      });
    } else {
      if (pushToken != null) {
        NotificationService.sendNotification(pushToken, "Book Accepted",
            " Your ${book['name']} has been accepted by the supervisor and published to all users");
      }
      print("the book is accepted");
      await registerBookToPublish(
          book['name'],
          await getUserFullName(book['email']),
          book['Description'],
          book['category'],
          0,
          book['image'],
          book['pdfLink'],
          book['email']);
      await updateBookStatus(book['name'], book['email'], "accepted", comment);
      // Instead of calling initState(), use setState to refresh the UI
      await incrementCreatedStory(book['email']);
      await incrementProgress(book['email'], "creating");

      setState(() {
        _books = fetchBooksBySuperEmail(EMAIL);
      });
    }
    print('Action: $action');
    print('Book Name: ${book['name']}');
    print('Comment: $comment');
  }
}
