import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/api/api.dart';
import 'package:flutter_application_1/config.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/screens/StoryDesign/story.dart';
import 'package:flutter_application_1/screens/StoryDesign/storyServices/storyService.dart';
import 'package:flutter_application_1/screens/books/BookService%20.dart';
import 'package:flutter_application_1/screens/pdfView.dart';
import 'package:flutter_application_1/widgets/bookCard.dart';
import 'package:intl/intl.dart';

class MyBooksPage extends StatefulWidget {
  @override
  _BooksPageState createState() => _BooksPageState();
}

class _BooksPageState extends State<MyBooksPage> {
  List<Map<String, dynamic>> onlyMeBooks = [];
  List<Map<String, dynamic>> drafts = [];
  List<dynamic> publishedBooks = [];
  List<dynamic> onRequest = [];
  List<dynamic> denied = [];

  String selectedTab = "on request";

  Future<void> _fetchMyBooks() async {
    // استدعاء الـ API للحصول على الكتب حسب الحالة
    List? booksOnReq = await getBooksByEmailAndStatus(EMAIL, "on request");
    List? booksDenied = await getBooksByEmailAndStatus(EMAIL, "denied");
    setState(() {
      onRequest = booksOnReq ?? [];
      denied = booksDenied ?? [];
    });
  }

  void _deleteBookLogic(String name) async {
    try {
      // تنفيذ عملية الحذف (يمكن تعديلها حسب الـ API الخاص بك)
      await deleteDeniedBook(name);
      setState(() {
        _fetchMyBooks();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting book: $e')),
      );
    }
  }

  void _deleteBook(String bookName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Book'),
          content: Text('Are you sure you want to delete this book?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                // Call the deleteBook function here
                _deleteBookLogic(bookName);
              },
              child: Text('Delete'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red, // Set the text color to red
              ),
            ),
          ],
        );
      },
    );
  }

  void _openPdf(String pdfLink) {
    // فتح ملف PDF (يمكنك استخدام مكتبة مثل `url_launcher` أو مكتبة مخصصة لعرض PDF)
    print("Open PDF: $pdfLink");
  }

  @override
  void initState() {
    super.initState();
    loadUserDraftData();
    _fetchMypublishedBooks();
    _fetchMyBooks();
  }

  Future<void> _fetchMypublishedBooks() async {
    List? books = await BookService.getMyPublishedBooks(EMAIL);
    setState(() {
      publishedBooks = books!;
    });
  }

  void loadUserDraftData() async {
    String userId = APIS.user!.uid;

    CollectionReference draftsCollection =
        FirebaseFirestore.instance.collection('drafts');

    // Load drafts
    QuerySnapshot draftsSnapshot =
        await draftsCollection.where('userId', isEqualTo: userId).get();
    setState(() {
      drafts = draftsSnapshot.docs
          .map((doc) => {
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              })
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> currentBooks =
        selectedTab == "on request" ? onRequest : denied;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Books'),
        backgroundColor: ourPink,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: offwhite, // Set the background color here

          child: Column(
            children: [
              // Published Books Section
              Container(
                padding: const EdgeInsets.all(8.0),
                color: offwhite,
                width: double.infinity,
                child: const Text("My published books",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: publishedBooks
                      .length, // Use the length of the fetched books
                  itemBuilder: (context, index) {
                    final book = publishedBooks[index];
                    return BookCard(
                      title: book['name'], // Display the book name
                      imagePath:
                          book['image'], // Pass the image URL if available
                    );
                  },
                ),
              ),

              // Only Me Books Section
              Container(
                padding: const EdgeInsets.all(8.0),
                color: offwhite,
                width: double.infinity,
                child: const Text(
                  "Only Me Books",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: MediaQuery.of(context).size.height *
                    1 /
                    3, // Take 1/3 of the screen height
                child: Column(
                  children: [
                    // Tab Bar
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedTab = "on request";
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12.0),
                              color: selectedTab == "on request"
                                  ? Colors.blue.shade100
                                  : Colors.grey.shade300,
                              child: const Text(
                                "On Request",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedTab = "denied";
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12.0),
                              color: selectedTab == "denied"
                                  ? Colors.blue.shade100
                                  : Colors.grey.shade300,
                              child: const Text(
                                "Denied",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Books List
                    Expanded(
                      child: currentBooks.isEmpty
                          ? Center(
                              child: Text(
                                selectedTab == "on request"
                                    ? "No books on request"
                                    : "No denied books",
                              ),
                            )
                          : ListView.builder(
                              itemCount: currentBooks.length,
                              itemBuilder: (context, index) {
                                final book = currentBooks[index];
                                return Card(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      radius: 25, // Adjust the radius as needed
                                      backgroundImage: book['image'] != null
                                          ? NetworkImage(book['image'])
                                          : null,
                                      backgroundColor: Colors
                                          .grey.shade300, // Fallback color
                                      child: book['image'] == null
                                          ? Icon(Icons.book,
                                              color: Colors.grey.shade700)
                                          : null,
                                    ),
                                    title: Text(book['name']),
                                    subtitle: Text(
                                      selectedTab == "denied"
                                          ? "Status: ${book['status']}\nComment: ${book['superComment']}"
                                          : "Status: ${book['status']}",
                                    ),
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
                                    },
                                    onLongPress: () =>
                                        _deleteBook(book['name']),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),

              // Drafts Section
              SizedBox(
                height: MediaQuery.of(context).size.height *
                    1 /
                    3, // Take 2/3 of the screen height
                child: _buildSection(
                  title: 'My Drafts',
                  items: drafts,
                  emptyMessage: 'No drafts available',
                  isDraft: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Map<String, dynamic>> items,
    required String emptyMessage,
    bool isDraft = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            color: offwhite,
            width: double.infinity,
            child: Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: items.isEmpty
                ? Center(child: Text(emptyMessage))
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      var item = items[index];
                      return ListTile(
                        title: Text(' ${item['title']}'),
                        subtitle: Text(
                          isDraft
                              ? 'Last modified: ${DateFormat('MM-dd HH:mm:ss').format(item['lastModified'].toDate())}'
                              : 'Author: ${item['author']}',
                        ),
                        trailing: isDraft
                            ? IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteDraft(item['id']),
                              )
                            : null,
                        onTap: isDraft
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditorPage(draft: item),
                                  ),
                                );
                              }
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _deleteDraft(String draftId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Draft'),
          content: Text('Are you sure you want to delete this book?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                // Call the deleteBook function here
                try {
                  await FirebaseFirestore.instance
                      .collection('drafts')
                      .doc(draftId)
                      .delete();
                  setState(() {
                    drafts.removeWhere((draft) => draft['id'] == draftId);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Draft deleted successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting draft: $e')),
                  );
                }
              },
              child: Text('Delete'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red, // Set the text color to red
              ),
            ),
          ],
        );
      },
    );
  }
}
