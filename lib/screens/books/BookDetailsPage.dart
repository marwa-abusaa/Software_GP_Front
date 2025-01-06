import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/api.dart';
import 'package:flutter_application_1/config.dart';
import 'package:flutter_application_1/screens/books/BookService%20.dart';
import 'package:flutter_application_1/screens/pdfView.dart';
import 'package:flutter_application_1/widgets/comment.dart';
import 'package:http/http.dart' as http;

class BookDetailsPage extends StatefulWidget {
  final String bookName;

  BookDetailsPage({required this.bookName});

  @override
  _BookDetailsPageState createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  bool isFavorite = false; // لتتبع حالة المفضلة

  Map<String, dynamic>? bookDetails;
  List<String> _categories = [];
  List<dynamic> _comments = []; // To store comments
  bool isLoading = true; // Loading state
  double _userRating = 0.0;
  String _userComment = '';
  String errorMessage = ''; // Error message state
  String pdfUrl = "";
  late double oldRate;
  late double review;
  late double newRate;
  String author='';

  @override
  void initState() {
    super.initState();
    _fetchBookDetails();
  }

  Future<void> _initializeFavoriteState() async {
    try {
      final favoriteStatus =
          await BookService.isBookInFavorites(EMAIL, bookDetails?['id']);

      setState(() {
        isFavorite = favoriteStatus;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load favorite status';
      });
      print(e); // Optional: Log the error for debugging
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      if (isFavorite) {
        await BookService.removeBookFromFavorites(EMAIL, bookDetails?['id']);
        // Show success dialog for removal
        _showFavoriteStatusDialog("Book removed from favorites successfully!");
      } else {
        await BookService.addBookToFavorites(EMAIL, bookDetails?['id']);
        // Show success dialog for addition
        _showFavoriteStatusDialog("Book added to favorites successfully!");
      }
      setState(() {
        isFavorite = !isFavorite; // Update favorite status
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update favorite status: $e'),
        ),
      );
    }
  }

// Function to show the popup dialog
  void _showFavoriteStatusDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Favorite Status"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchBookDetails() async {
    try {
      final response = await http.get(
        Uri.parse('$getBook?name=${widget.bookName}'),
      );

      if (response.statusCode == 200) {
        log("Response body: ${response.body}"); // Log response for debugging
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['data'] != null) {
          setState(() {
            bookDetails = jsonResponse['data'];
            oldRate = bookDetails?['rate'].toDouble() ?? 0.0;
            review = bookDetails?['review'].toDouble() ?? 0.0;
            author=bookDetails?['author'];
            // Extract PDF URL if available
            pdfUrl = bookDetails?['pdfLink']; // Store PDF URL
            log("LINK >>>>>>>>>>>>>>>>>>>>>>" + pdfUrl);
            // Split the category string by commas into a list of strings
            if (bookDetails!['category'] is String) {
              _categories = (bookDetails!['category'] as String)
                  .split(',')
                  .map((e) => e.trim()) // Trim spaces around category names
                  .toList();
            } else {
              _categories = [];
            }

            isLoading = false; // Stop loading when data is ready
          });
          _fetchComments();
          _initializeFavoriteState();
        } else {
          setState(() {
            errorMessage = 'No book data found.';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load book details.';
          isLoading = false;
        });
      }
    } catch (e) {
      log('Error fetching book details: $e');
      setState(() {
        errorMessage = 'An error occurred: $e';
        isLoading = false;
      });
    }
  }

  void _openPdfViewer() {
    if (pdfUrl != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerScreen(
            pdfUrl: pdfUrl!,
            title: widget.bookName,
            author: author,
          ),
        ),
      );
    } else {
      // Show a message if PDF is not available
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF not available for this book.')),
      );
    }
  }

  Future<void> _fetchComments() async {
    try {
      final response = await http.get(
        Uri.parse('$getComments?bookName=${widget.bookName}'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // Assume the comments array has the correct structure
        setState(() {
          _comments = jsonResponse['data'] ?? [];
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load comments.';
        });
      }
    } catch (e) {
      log('Error fetching comments: $e');
      setState(() {
        errorMessage = 'An error occurred while fetching comments: $e';
      });
    }
  }

  void _submitReview() async {
    try {
      // Construct the body of the request
      final body = json.encode({
        'email': APIS.currentEmail,
        'commentText': _userComment,
        'rate': _userRating,
        'bookName': widget.bookName, // The name of the current book
      });

      // Send the POST request to your backend
      final response = await http.post(
        Uri.parse('$addComment'), // Add your backend URL here
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 201) {
        // Success response
        setState(() {
          newRate = oldRate + _userRating;
          _userRating = 0.0;

          // Refetch comments and book details
          _fetchComments();
          updateBookRate();
        });

        await _fetchBookDetails(); // Ensure this also refetches in case of UI-bound data
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => BookDetailsPage(bookName: widget.bookName)),
        );
      } else if (response.statusCode == 410) {
        // Handle the case where the user has already added a comment (status 410)
        print('You already added a comment.');
        showDialog(
          context: context,
          builder: (context) => const AlertDialog(
            title: Text('Comment Already Exists'),
            content: Text(
                'You have already added a comment for this book. You can edit your existing comment.'),
          ),
        );
      } else if (response.statusCode == 400) {
        // Handle the case where the user has already added a comment (status 410)
        print('');
        showDialog(
          context: context,
          builder: (context) => const AlertDialog(
            title: Text('Adding comment faild because of comment content'),
            content: Text(
                'We appreciate your feedback! However, we encourage you to provide constructive criticism to help improve the content.'),
          ),
        );
      } else {
        // Handle the error case
        print('Failed to add comment: ${response.body}');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(
                'Failed to add comment: ${json.decode(response.body)['error']}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error submitting comment: $e');
      // Handle the error, maybe show an error message dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('An error occurred while submitting your comment: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  void _showReviewDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0), // Rounded corners
          ),
          title: const Text(
            "Add Review",
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Star rating selection
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return Flexible(
                      // Use Flexible to adjust each star's size
                      child: IconButton(
                        icon: Icon(
                          index < _userRating ? Icons.star : Icons.star_border,
                          color: Colors.orange,
                          size: 30, // Increase the size slightly if needed
                        ),
                        onPressed: () {
                          setState(() {
                            _userRating = index + 1.0; // Update the rating
                          });
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                // TextField for comment
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Your Comment",
                    border: OutlineInputBorder(),
                    hintText: "Write your review...",
                  ),
                  maxLines: 3, // Multi-line for longer comments
                  onChanged: (value) {
                    _userComment = value; // Update the comment
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Submit action
                print("Rating: $_userRating");
                print("Comment: $_userComment");
                _submitReview();
                _fetchBookDetails();
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text("Submit"),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Book Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
        actions: ROLE == 'user'
            ? [
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: _toggleFavorite, // عند الضغط على القلب
                ),
              ]
            : null,
      ),
      body: isLoading // Check if data is loading
          ? const Center(
              child: CircularProgressIndicator()) // Loading indicator
          : bookDetails == null // Check if book details are available
              ? Center(child: Text(errorMessage)) // Show error message
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Book image, title, author, rating (Centered)
                        Container(
                          alignment:
                              Alignment.center, // Center the entire container
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Book Cover
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 3,
                                      blurRadius: 7,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: Image.network(
                                    bookDetails!['image'],
                                    height: 250,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.error),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Title (Centered)
                              Text(
                                bookDetails!['name'] ??
                                    'Unknown Title', // Use the fetched book name
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal[700],
                                ),
                                textAlign: TextAlign.center, // Center the title
                              ),
                              const SizedBox(height: 5),
                              // Author (Centered)
                              Text(
                                "by ${bookDetails!['author'] ?? 'Unknown Author'}", // Use the fetched author
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey),
                                textAlign:
                                    TextAlign.center, // Center the author
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        // Ratings Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ...List.generate(5, (index) {
                              return Icon(
                                index <
                                        (bookDetails!['review'] > 0
                                            ? (bookDetails!['rate'] /
                                                    bookDetails!['review'])
                                                .round()
                                            : 0)
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.orange,
                                size: 20,
                              );
                            }),
                            const SizedBox(
                                width:
                                    8), // Add SizedBox here directly in the list
                            Text(
                              bookDetails!['review'] > 0
                                  ? "${(bookDetails!['rate'] / bookDetails!['review']).toStringAsFixed(1)}" // Display average rating with one decimal
                                  : "0", // Display '0' if there are no reviews
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "(${bookDetails!['review'] ?? 0} Reviews)", // Use the fetched reviews count
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          bookDetails!['Description'] ??
                              'No description available', // Use the fetched description
                          style: const TextStyle(fontSize: 16, height: 1.5),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: _openPdfViewer, // Opens the PDF viewer
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                backgroundColor: Colors.teal,
                              ),
                              child: const Text(
                                "Read Now",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            OutlinedButton(
                              onPressed: _canComment,
                              // Show review dialog
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                side: const BorderSide(color: Colors.teal),
                              ),
                              child: const Text(
                                "Add Review",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Categories",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        // Categories List
                        Wrap(
                          spacing: 10,
                          children: _categories
                              .map((category) => Chip(
                                    label: Text(category),
                                    backgroundColor: Colors.teal[100],
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Comments",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal),
                        ),
                        const SizedBox(height: 10),
                        // Displaying comments
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _comments.length,
                          itemBuilder: (context, index) {
                            final commentData = _comments[index];
                            return CommentWidget(
                              username: commentData['email'] ?? 'Anonymous',
                              comment: commentData['commentText'] ??
                                  'No comment provided',
                              rating: commentData['rate']?.toDouble() ?? 0.0,
                              id: commentData['_id'],
                              bookName: widget.bookName,
                              bookRate: oldRate,
                              bookReview: review,
                              onCommentUpdated: _fetchBookDetails,
                            ); // Use your CommentWidget
                          },
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Future<void> updateBookRate() async {
    final url = Uri.parse(getBook); // Replace with your actual API URL

    // Construct request body with optional fields
    final Map<String, dynamic> data = {
      'name': widget.bookName,
      'rate': newRate,
      'review': review + 1
    };

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        print('Book updated successfully');
      } else if (response.statusCode == 404) {
        print('Book not found');
      } else {
        print('Failed to update book: ${response.body}');
      }
    } catch (e) {
      print('Error updating book: $e');
    }
  }

  Future<void> _canComment() async {
    try {
      // Construct the body of the request
      final body = json.encode({
        'email': APIS.currentEmail,
        'bookName': widget.bookName, // The name of the current book
      });

      // Send the POST request to your backend
      final response = await http.post(
        Uri.parse('$canComment'), // Add your backend URL here
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
// can comment show dialog
        _showReviewDialog();

        print('can comment show dialog!');
      } else if (response.statusCode == 410) {
        // Handle the case where the user has already added a comment (status 410)
        print('You already added a comment.');
        showDialog(
          context: context,
          builder: (context) => const AlertDialog(
            title: Text('Comment Already Exists'),
            content: Text(
                'You have already added a comment for this book. You can edit your existing comment.'),
          ),
        );
      } else {
        // Handle the error case
        print('Failed to add comment: ${response.body}');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(
                'Failed to add comment: ${json.decode(response.body)['error']}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error submitting comment: $e');
      // Handle the error, maybe show an error message dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('An error occurred while submitting your comment: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }
}
