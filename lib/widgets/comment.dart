import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/api.dart';
import 'package:flutter_application_1/config.dart';
import 'package:flutter_application_1/screens/books/BookDetailsPage.dart';
import 'package:http/http.dart' as http;

class CommentWidget extends StatefulWidget {
  final String username;
  final String comment;
  final double rating;
  final String id;
  final String bookName;
  final double bookRate;
  final double bookReview;
  final VoidCallback onCommentUpdated;

  const CommentWidget({
    Key? key,
    required this.username,
    required this.comment,
    required this.rating,
    required this.id,
    required this.bookName,
    required this.bookRate,
    required this.bookReview,
    required this.onCommentUpdated,
  }) : super(key: key);

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  late double _userRating;
  late String _userComment;
  late double bookRate;
  late double bookReview;
  late double rating;

  @override
  void initState() {
    super.initState();
    _userRating = 0;
    _userComment = widget.comment;
    print("inside the comment widget rate is " +
        widget.bookRate.toString() +
        "review is " +
        widget.bookReview.toString() +
        "comment rating " +
        widget.rating.toString());

    bookRate = widget.bookRate.toDouble();
    bookReview = widget.bookReview.toDouble();
    rating = widget.rating.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    String displayUsername = widget.username.split('@')[0];
    bool isCurrentUserComment = widget.username == APIS.currentEmail;

    return isCurrentUserComment
        ? Dismissible(
            key: Key(widget.comment),
            background: slideLeftBackground(), // For delete
            secondaryBackground: slideRightBackground(), // For edit
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.endToStart) {
                await deleteComment(widget.id);
                return true;
              } else if (direction == DismissDirection.startToEnd) {
                _showReviewDialog();
                return false;
              }
              return false;
            },
            child: buildCommentCard(displayUsername),
          )
        : buildCommentCard(displayUsername);
  }

  // Build comment card
  Widget buildCommentCard(String displayUsername) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.teal,
            child: Text(
              displayUsername.isNotEmpty ? displayUsername[0] : '?',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(widget.comment),
          subtitle: Text("By $displayUsername"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              5,
              (index) => Icon(
                index < widget.rating.toInt() ? Icons.star : Icons.star_border,
                color: Colors.orange,
                size: 10,
              ),
            ),
          ),
        ),
        Divider(color: Colors.grey[300]),
      ],
    );
  }

  // Delete comment method
  Future<void> deleteComment(String commentId) async {
    try {
      final url = Uri.parse('$getComments?id=$commentId');
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        print('Comment deleted successfully');
        await updateBookRatAfterDelete();
        widget.onCommentUpdated();
        _showDeleteSuccessPopup(); // Show success popup after delete
      } else {
        print('Failed to delete comment. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while deleting comment: $e');
    }
  }

  // Show delete success popup
  void _showDeleteSuccessPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Success"),
          content: const Text("Comment deleted successfully!"),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  // Show edit review dialog
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
              onPressed: () async {
                // Submit action
                print("Rating: $_userRating");
                print("Comment: $_userComment");
                // Submit the edited review
                _submitReview();
                await updateBookRatAfterUpdate();
                initState();
                Navigator.of(context).pop();
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

  void _submitReview() async {
    // Create the request body with the updated comment and rating
    Map<String, dynamic> requestBody = {
      'rate': _userRating,
      'commentText': _userComment,
      'bookName':
          widget.bookName, // You may need to pass the actual book name here
      'email':
          APIS.currentEmail, // Assume this contains the current user's email
      '_id': widget.id, // Assuming the ID of the comment is passed as widget.id
    };

    // API URL
    final url =
        Uri.parse('$getComments'); // Replace with your actual API endpoint

    try {
      // Send a PATCH request to update the comment
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody), // Convert the request body to JSON
      );

      // Check the response status code
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == true) {
          print("Comment updated successfully");
          // Optionally, you can show a success message to the user
          Navigator.of(context).pop();
          widget.onCommentUpdated();
        } else {
          print("Failed to update comment: ${responseData['error']}");
        }
      } else {
        print('Failed to update comment. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while updating comment: $e');
    }
  }

  // Background for swipe left (edit)
  Widget slideLeftBackground() {
    return Container(
      color: Colors.blue,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.centerRight,
      child: const Icon(Icons.edit, color: Colors.white),
    );
  }

  // Background for swipe right (delete)
  Widget slideRightBackground() {
    return Container(
      color: Colors.red,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.centerLeft,
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }

  Future<void> updateBookRatAfterDelete() async {
    final url = Uri.parse(getBook); // Replace with your actual API URL

    // Construct request body with required fields
    final Map<String, dynamic> data = {
      'name': widget.bookName,
      'rate': bookRate - rating,
      'review': bookReview - 1,
    };

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print('Book updated after comment deletion');
      } else {
        print('Failed to update book. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating book: $e');
    }
  }

  Future<void> updateBookRatAfterUpdate() async {
    final url = Uri.parse(getBook); // Replace with your actual API URL

    // Construct request body with required fields
    final Map<String, dynamic> data = {
      'name': widget.bookName,
      'rate': _userRating,
    };

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print('Book updated after comment update');
      } else {
        print('Failed to update book. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating book: $e');
    }
  }
}
