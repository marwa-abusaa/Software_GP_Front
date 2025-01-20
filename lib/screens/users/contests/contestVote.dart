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

class ContestParticipantsScreen extends StatefulWidget {
  final String contestName;

  const ContestParticipantsScreen({
    super.key,
    required this.contestName,
  });

  @override
  _ContestParticipantsScreenState createState() =>
      _ContestParticipantsScreenState();
}

class _ContestParticipantsScreenState extends State<ContestParticipantsScreen> {
  List<dynamic> participants = [];
  List<dynamic> books = [];
  List<dynamic> selectedBooks = [];

  bool isLoading = true;
  bool votingEnabled = false;
  bool canVote = false;

  @override
  void initState() {
    super.initState();
    fetchParticipantsAndBooks();
    initializeVoteCheck(); // Call the vote-checking function
  }

  Future<void> initializeVoteCheck() async {
    try {
      bool response = await checkVote(
        contestName: widget.contestName,
        email: EMAIL,
      );

      print("API Response for canVote: $response"); // Debugging line

      setState(() {
        canVote = response; // Update `canVote` with the actual response
        print("Updated canVote: $canVote"); // Debugging line
        isLoading = false; // Stop the loading state
      });

      print(canVote ? 'User can vote!' : 'User cannot vote!');
    } catch (e) {
      print('Error during vote check: $e');
      setState(() {
        isLoading = false; // Stop the loading state
      });
    }
  }

  void toggleVote(dynamic book) {
    if (isLoading) {
      // If still loading, prevent voting action
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait, loading data...')),
      );
      return;
    }

    if (!canVote) {
      // If the user can't vote, show a message and return early
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You are not allowed to vote in this contest!')),
      );
      return; // Stop further execution if user can't vote
    }

    setState(() {
      if (selectedBooks.contains(book)) {
        selectedBooks.remove(book);
      } else if (selectedBooks.length < 3) {
        selectedBooks.add(book);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You can vote for up to 3 books only!')),
        );
      }
    });
  }

  Future<void> fetchParticipantsAndBooks() async {
    try {
      // Fetch participants
      final participantsData = await getContestParticipants(widget.contestName);

      // Fetch book details for each participant using fetchBookByName
      final booksData = await Future.wait(
        participantsData.map((participant) async {
          final bookName = participant['bookName'];
          final bookResult = await BookService.fetchBookByName(bookName);

          if (bookResult['success']) {
            return bookResult[
                'data']; // Add book details if fetch was successful
          } else {
            // Handle book not found or other errors
            print('Error fetching book: ${bookResult['message']}');
            return null;
          }
        }).where((book) => book != null), // Exclude null entries
      );

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

  Future<void> saveVotes() async {
    if (selectedBooks.isNotEmpty) {
      print('Selected Books: $selectedBooks');
      final book1 = selectedBooks.length > 0 ? selectedBooks[0]['name'] : '';
      final book2 = selectedBooks.length > 1 ? selectedBooks[1]['name'] : '';
      final book3 = selectedBooks.length > 2 ? selectedBooks[2]['name'] : '';
      await addContestVote(
          contestName: widget.contestName,
          email: EMAIL,
          book1: book1,
          book2: book2,
          book3: book3);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your votes have been submitted!')),
      );
      setState(() {
        votingEnabled = false;
        canVote = false;
        selectedBooks.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to select at least one book.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.contestName} participation',style: TextStyle(color: Colors.white,fontSize: 18)),
        backgroundColor: ourPink,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (!votingEnabled)
            TextButton(
              onPressed: () {
                setState(() {
                  if (!canVote) {
                    // If the user can't vote, show a message and return early
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'You are not allowed to vote in this contest!')),
                    );
                    votingEnabled = false;
                    return; // Stop further execution if user can't vote
                  }
                  votingEnabled = true;
                });
              },
              child: const Text(
                'Vote',
                style: TextStyle(color: Color.fromARGB(255, 122, 224, 226),fontWeight: FontWeight.bold,fontSize: 17),
              ),
            ),
        ],
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
                    final isSelf = bookEmail == EMAIL;
                    final isSelected = selectedBooks.contains(book);

                    return GestureDetector(
                      onTap: () {
                        print("ROLEEEEEE is $ROLE");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PdfViewerScreen(
                              pdfUrl: book['pdfLink'],
                              title: book['name'],
                              author: book['author'],
                            ),
                          ),
                        );
                        final bookEmail =
                            book['email'] ?? 'Unknown'; // Extract book email
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

                                      // Voting Mode
                                      if (votingEnabled && !isSelf)
                                        Row(
                                          children: [
                                            Checkbox(
                                              value: isSelected,
                                              onChanged: (value) {
                                                if (value == true) {
                                                  toggleVote(book);
                                                } else {
                                                  setState(() {
                                                    selectedBooks.remove(book);
                                                  });
                                                }
                                              },
                                              activeColor: ourBlue
                                            ),
                                            const Text('Vote for this book'),
                                          ],
                                        ),
                                      if (isSelf && votingEnabled)
                                        const Text(
                                          'You cannot vote for your own book.',
                                          style: TextStyle(color: Colors.red),
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
      floatingActionButton: votingEnabled
          ? FloatingActionButton.extended(
              onPressed: saveVotes,
              label: const Text('Save Votes',),
              icon: const Icon(Icons.save),
              backgroundColor: ourPink,
            )
            
          : null,
    );
  }
}
