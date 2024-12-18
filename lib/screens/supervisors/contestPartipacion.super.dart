import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/api.dart';
import 'package:flutter_application_1/api/info.dart';
import 'package:flutter_application_1/config.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/screens/books/BookService%20.dart';
import 'package:flutter_application_1/screens/pdfView.dart';
import 'package:flutter_application_1/screens/users/contests/contestService.dart';
import 'package:http/http.dart' as http;

class ContestParticipantsSuperScreen extends StatefulWidget {
  final String contestName;

  const ContestParticipantsSuperScreen({
    super.key,
    required this.contestName,
  });

  @override
  _ContestParticipantsSuperScreenState createState() =>
      _ContestParticipantsSuperScreenState();
}

class _ContestParticipantsSuperScreenState
    extends State<ContestParticipantsSuperScreen> {
  List<dynamic> participants = [];
  List<dynamic> books = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchParticipantsAndBooks();
  }

  Future<void> fetchParticipantsAndBooks() async {
    try {
      // Fetch participants
      final participantsData = await getContestParticipants(widget.contestName);

      // Fetch book details and associate votes
      final booksData = await Future.wait(
        participantsData.map((participant) async {
          final bookName = participant['bookName'];
          final votes =
              participant['vote'] ?? 0; // Extract votes from participant
          final bookResult = await BookService.fetchBookByName(bookName);

          if (bookResult['success']) {
            final book = bookResult['data'];
            book['votes'] = votes; // Attach votes to the book object
            return book;
          } else {
            // Handle book not found or other errors
            print('Error fetching book: ${bookResult['message']}');
            return null;
          }
        }).where((book) => book != null), // Exclude null entries
      );

      // Sort books by votes in descending order
      booksData.sort((a, b) => (b['votes'] ?? 0).compareTo(a['votes'] ?? 0));

      setState(() {
        participants = participantsData;
        books = booksData;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.contestName} participation'),
        backgroundColor: ourPink,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : books.isEmpty
              ? const Center(child: Text('No books found.'))
              : ListView.builder(
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    final bookEmail =
                        book['email'] ?? 'Unknown'; // Extract book email
                    final votes = book['votes'] ?? 0; // Extract votes count

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PdfViewerScreen(
                              pdfUrl: book['pdfLink'],
                              title: book['name'],
                            ),
                          ),
                        );
                        print('Book Name: ${book['name'] ?? 'Unknown'}');
                        print('Book email: $bookEmail');
                        print('Logged email: $EMAIL');
                      },
                      child: Container(
                        color: ourBlue, // Set the desired background color
                        child: Card(
                          color:
                              logoBar, // Set your desired background color here
                          margin: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              // Leading Image
                              Container(
                                width: 100,
                                height: 150,
                                margin: const EdgeInsets.all(8.0),
                                child: book['image'] != null
                                    ? Image.network(
                                        book['image'],
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        color: Colors.grey[300],
                                        child: const Center(
                                            child: Text('No Image')),
                                      ),
                              ),
                              // Book Details
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        book['name'] ?? 'Unknown Book',
                                        style: const TextStyle(
                                            color: ourBlue,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const Text(
                                        'Author:',
                                      ),
                                      FutureBuilder<String>(
                                        future: getUserFullName(book[
                                            'email']), // Call your function here
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Text(
                                                'Loading...'); // Show a loading indicator
                                          } else if (snapshot.hasError) {
                                            return Text(
                                                'Error: ${snapshot.error}'); // Handle errors
                                          } else if (!snapshot.hasData ||
                                              snapshot.data == null) {
                                            return const Text(
                                                'Unknown'); // Handle the case where no data is returned
                                          } else {
                                            return Text(snapshot
                                                .data!); // Display the fetched name
                                          }
                                        },
                                      ),
                                      Text(
                                          'Description: ${book['Description'] ?? ''}'),
                                      Text('Note: ${book['note'] ?? ''}'),
                                      Text(
                                        'Votes: $votes',
                                        style: const TextStyle(
                                            color: ourBlue,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
