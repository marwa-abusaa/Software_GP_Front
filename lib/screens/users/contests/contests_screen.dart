import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/api.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/screens/users/contests/contestService.dart';
import 'package:flutter_application_1/screens/users/contests/contestVote.dart';
import 'package:flutter_application_1/screens/users/home_screen.dart';
import 'package:flutter_application_1/widgets/custom_home.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/config.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/screens/books/BookService%20.dart';

class ContestsScreen extends StatefulWidget {
  final String token;

  const ContestsScreen({required this.token, Key? key}) : super(key: key);

  @override
  State<ContestsScreen> createState() => _ContestsScreenState();
}

class _ContestsScreenState extends State<ContestsScreen> {
  late String supervisorId;
  List? items;
  late String contestId;
  int? selectedCardIndex; //card index indecator
  bool isVoteButtonEnabled = false;
  bool isJoinButtonEnabled = false;

  List<dynamic> publishedBooks = [];
  String? selectedBook; // To store the selected book name
  final TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    supervisorId = jwtDecodedToken['_id'];
    getContests();

    _fetchMypublishedBooks();
  }

  Future<void> _fetchMypublishedBooks() async {
    List? books = await BookService.getMyPublishedBooks(EMAIL);
    setState(() {
      publishedBooks = books!;
    });
  }

  void showJoinPopup(BuildContext context, String contestName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Join $contestName',style: TextStyle(color: ourBlue),),
          content: SingleChildScrollView(
            // Wrap content in SingleChildScrollView
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dropdown menu for book names
                DropdownButtonFormField<String>(
                  value: selectedBook,
                  items: publishedBooks.map((dynamic book) {
                    return DropdownMenuItem<String>(
                      value: book['name'], // Use the name as the value
                      child: Text(book['name'] ??
                          'Unknown'), // Display the name in the dropdown
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedBook = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Select your book',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // Note field
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: 'Write a note (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3, // Allow multiple lines
                  keyboardType:
                      TextInputType.multiline, // Allow multiline input
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel',style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                 backgroundColor: ourBlue,
                 fixedSize: Size(
                 MediaQuery.of(context).size.width * 0.2, 25, ),
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), ),
                  padding: EdgeInsets.zero,
                  ),

              onPressed: () async {
                // Handle "Join" logic here
                print('Selected Book: $selectedBook');
                print('Note: ${noteController.text}');

                await joinContest(context, contestName, EMAIL, selectedBook!,
                    noteController.text);
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Join'),
            ),
          ],
        );
      },
    );
  }

  void getContests() async {
    var response = await http.get(
      Uri.parse(getAllContests),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      items = jsonResponse['success'].map((item) {
        item['isExpanded'] = false; // Initialize isExpanded
        return item;
      }).toList();
      setState(() {});
    } else {
      print('Error: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  }

  void showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating, // Makes it float above the bottom
        margin: const EdgeInsets.only(top: 50.0),
      ),
    );
  }

  void showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                color: ourPink,
                size: 80,
              ),
              SizedBox(height: 20),
              Text(
                'Data updated successfully!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'OK',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomHomePage(
      emaill: EMAIL,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                color: ourPink,
                padding: const EdgeInsets.only(top: 8.0, bottom: 15.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(width: 100.0),
                    const Text(
                      'Contests',
                      style: TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: items == null
                        ? null
                        : CarouselSlider.builder(
                            itemCount: items!.length,
                            itemBuilder: (BuildContext context, int index,
                                int realIndex) {
                              return SingleChildScrollView(child: _competitionCard(index));
                            },
                            options: CarouselOptions(
                              enlargeCenterPage: true,
                              viewportFraction: 0.85,
                              autoPlay:
                                  selectedCardIndex != null ? false : true,
                              height: selectedCardIndex != null
                                  ? 600 // Height for the expanded card
                                  : 370, // Default height for other cards
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _competitionCard(int index) {
    final List<Color> cardColors = [
      const Color.fromARGB(255, 103, 194, 196),
      iconsBar,
    ];
    final Color cardColor = cardColors[index % cardColors.length];

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 6, offset: Offset(0, 9)),
          ],
        ),
        child: Column(
          children: [
            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${items![index]['title']}',
                      maxLines: null,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Georgia',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      items![index]['isExpanded']
                          ? Icons.expand_less
                          : Icons.expand_more,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        items![index]['isExpanded'] =
                            !items![index]['isExpanded'];
                        selectedCardIndex =
                            items![index]['isExpanded'] ? index : null;
                      });
                    },
                  ),
                ],
              ),
              subtitle: Container(
                height: 180,
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage(items![index]['imageUrl']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            if (items![index]['isExpanded'])
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.info, color: Colors.black54),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${items![index]['description']}',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.black54),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Submit date: ${items![index]['submit_date']}',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                      // Add other details here
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.black54),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Voting starts on: ${items![index]['voting_start_date']}',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.black54),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Voting ends on: ${items![index]['voting_end_date']}',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star_rate_rounded,
                              color: Colors.black54),
                          const SizedBox(width: 8),
                          Text(
                            'Required score: ${items![index]['required_score']}',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              contestId = '${items![index]['_id']}';
                              print('contestId: ' + contestId);
                              if (_isJoinActive(items![index]['submit_date'])) {
                                // If voting is active, navigate to the HomeScreen
                                showJoinPopup(
                                    context, '${items![index]['title']}');
                              } else {
                                // If voting is not active, show the error snackbar
                                showErrorSnackbar('You can\'t join, time is out');
                              }
                            },
                            icon: const Icon(Icons.group, color: Colors.white),
                            label: const Text('Join contest'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _isJoinActive(items![index]['submit_date'])
                                      ? const Color.fromARGB(255, 77, 152, 189)
                                      : const Color.fromARGB(255, 40, 84, 106)
                                          .withOpacity(0.5),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              textStyle: const TextStyle(fontSize: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                              onPressed: () {
                                if (_isVotingActive(
                                    items![index]['voting_start_date'],
                                    items![index]['voting_end_date'])) {
                                  //If voting is active, navigate to the HomeScreen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ContestParticipantsScreen(
                                        contestName: items![index]['title'],
                                      ),
                                    ),
                                  );
                                } else {
                                  // If voting is not active, show the error snackbar
                                  showErrorSnackbar(
                                      'You can\'t vote, pay attention to the time');
                                }
                              },
                              icon: const Icon(Icons.ballot, color: Colors.white),
                              label: const Text('Vote'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isVotingActive(
                                        items![index]['voting_start_date'],
                                        items![index]['voting_end_date'])
                                    ? const Color.fromARGB(255, 230, 74, 63)
                                    : const Color.fromARGB(255, 230, 74, 63)
                                        .withOpacity(0.5),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 17, vertical: 7),
                                textStyle: const TextStyle(fontSize: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _isVotingActive(String startDateStr, String endDateStr) {
    DateTime startDate =
        DateFormat('yyyy-MM-dd').parse(startDateStr); // تأكد من صيغة التاريخ
    DateTime endDate = DateFormat('yyyy-MM-dd').parse(endDateStr);
    DateTime now = DateTime.now();
    print('start = ${startDate} end = ${endDate}' 'now=  ${now}');
    isVoteButtonEnabled = now.isAfter(startDate) && now.isBefore(endDate);
    print(isVoteButtonEnabled);
    return isVoteButtonEnabled; // تحقق إذا كان التاريخ الحالي بين التاريخين
  }

  bool _isJoinActive(
    String finalDateStr,
  ) {
    DateTime finalDate =
        DateFormat('yyyy-MM-dd').parse(finalDateStr); // تأكد من صيغة التاريخ
    DateTime now = DateTime.now();
    print('start = ${finalDate}  now=  ${now}');
    isJoinButtonEnabled = now.isBefore(finalDate);
    print(isJoinButtonEnabled);
    return isJoinButtonEnabled; // 
  }
}//class


