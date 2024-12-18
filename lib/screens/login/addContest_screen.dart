import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/screens/supervisors/contestPartipacion.super.dart';
import 'package:flutter_application_1/widgets/custom_home.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/config.dart';
import 'package:velocity_x/velocity_x.dart';

class AddCompetitionsScreen extends StatefulWidget {
  final token;

  const AddCompetitionsScreen({required this.token, Key? key})
      : super(key: key);

  @override
  State<AddCompetitionsScreen> createState() => _AddCompetitionsScreenState();
}

class _AddCompetitionsScreenState extends State<AddCompetitionsScreen> {
  late String supervisorId;
  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController required_score = TextEditingController();
  TextEditingController submit_date = TextEditingController();
  TextEditingController voting_start_date = TextEditingController();
  TextEditingController voting_end_date = TextEditingController();

  ///update
  TextEditingController update_title = TextEditingController();
  TextEditingController update_description = TextEditingController();
  TextEditingController update_required_score = TextEditingController();
  TextEditingController update_submit_date = TextEditingController();
  TextEditingController update_voting_start_date = TextEditingController();
  TextEditingController update_voting_end_date = TextEditingController();
  List? items;
  late String contestId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);

    supervisorId = jwtDecodedToken['_id'];
    getContestsList(supervisorId);
  }

  void addContest() async {
    if (title.text.isNotEmpty &&
        description.text.isNotEmpty &&
        required_score.text.isNotEmpty &&
        submit_date.text.isNotEmpty &&
        voting_start_date.text.isNotEmpty &&
        voting_end_date.text.isNotEmpty) {
      var regBody = {
        "supervisorId": supervisorId,
        "title": title.text,
        "description": description.text,
        "required_score": required_score.text,
        "submit_date": submit_date.text,
        "voting_start_date": voting_start_date.text,
        "voting_end_date": voting_end_date.text
      };

      var response = await http.post(Uri.parse(newContest),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regBody));

      var jsonResponse = jsonDecode(response.body);

      print(jsonResponse['status']);

      if (jsonResponse['status']) {
        submit_date.clear();
        title.clear();
        voting_end_date.clear();
        description.clear();
        required_score.clear();
        voting_start_date.clear();
        Navigator.pop(context);
        getContestsList(supervisorId);
      } else {
        print("SomeThing Went Wrong");
      }
    }
  }

  void getContestsList(supervisorId) async {
    print(supervisorId);
    var regBody = {"supervisorId": supervisorId};

    var response = await http.post(Uri.parse(getSupervisorContests),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody) // This sends the JSON body
        );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      // Initialize each item with isExpanded set to false
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

  void deleteItem(id) async {
    var regBody = {"id": id};

    var response = await http.post(Uri.parse(deleteContest),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody));

    var jsonResponse = jsonDecode(response.body);
    if (jsonResponse['status']) {
      getContestsList(supervisorId);
    }
  }

  void updatedContest(id) async {
    if (update_title.text.isNotEmpty &&
        update_description.text.isNotEmpty &&
        update_required_score.text.isNotEmpty &&
        update_submit_date.text.isNotEmpty &&
        update_voting_start_date.text.isNotEmpty &&
        update_voting_end_date.text.isNotEmpty) {
      var reqBody = {
        "id": id,
        "supervisorId": supervisorId,
        "title": update_title.text,
        "description": update_description.text,
        "required_score": update_required_score.text,
        "submit_date": update_submit_date.text,
        "voting_start_date": update_voting_start_date.text,
        "voting_end_date": update_voting_end_date.text
      };

      var response = await http.patch(
        Uri.parse(updateContest),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody),
      );
      print("Updated code: " + response.statusCode.toString());

      if (response.statusCode == 200) {
        print("Updated successfully");
        showSuccessDialog(); // Show success popup
        //initState();
        getContestsList(supervisorId);
      } else {
        showErrorSnackbar('Something went wrong. Please try again later.');
      }
    }
  }

  void getContestDetails(String contestId) async {
    print(contestId);
    var regBody = {"id": contestId};

    var response = await http.post(
      Uri.parse(getContestDetailss),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(regBody), // This sends the JSON body
    );

    var jsonResponse = jsonDecode(response.body);
    if (jsonResponse['status']) {
      setState(() {
        update_title.text = jsonResponse['success']['title'];
        update_description.text = jsonResponse['success']['description'];
        update_required_score.text =
            jsonResponse['success']['required_score'].toString();
        update_submit_date.text = jsonResponse['success']
            ['submit_date']; // Convert to string if needed
        update_voting_start_date.text =
            jsonResponse['success']['voting_start_date'];
        update_voting_end_date.text =
            jsonResponse['success']['voting_end_date'];
      });
      print("Done!!");
    } else {
      // Handle the case when the response status is false
      print("Failed to fetch course details");
    }
  }

  void showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
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
                size: 80, // Increase the size of the tick icon
              ),
              SizedBox(height: 20),
              Text(
                'Data updated successfully!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center, // Center the text
              ),
            ],
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
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
                    mainAxisAlignment: MainAxisAlignment
                        .spaceBetween, // Distributes space between children
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white), // Arrow icon
                        onPressed: () {
                          Navigator.of(context)
                              .pop(); // Navigate back to the previous page
                        },
                      ),
                      const Text(
                        'My Contests',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle_rounded,
                          color: Colors.white,
                          size: 45,
                        ), // Plus icon
                        onPressed: () {
                          _displayTextInputDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: items == null
                        ? null
                        : ListView.builder(
                            itemCount: items!.length,
                            itemBuilder: (context, index) {
                              return _competitionCard(index);
                            },
                          ),
                  ),
                )
              ],
            )
          ],
        ));
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: offwhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            height: 610,
            width: 700, // Set your desired width here
            child: SingleChildScrollView(
              // Move SingleChildScrollView here
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // Ensure the Column takes minimum height
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Add Contest',
                      style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: ourBlue),
                    ),
                  ),
                  TextField(
                    controller: title,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Title",
                      hintStyle: TextStyle(
                        fontSize: 15.0,
                        color: Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                  ).p4().px8(),
                  TextField(
                    controller: description,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Description",
                      hintStyle: TextStyle(
                        fontSize: 15.0,
                        color: Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                  ).p4().px8(),
                  TextField(
                    controller: required_score,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      prefixIcon: const Icon(Icons.star_rate_rounded),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Required score",
                      hintStyle: TextStyle(
                        fontSize: 15.0,
                        color: Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                  ).p4().px8(),
                  TextFormField(
                    controller: submit_date,
                    readOnly: true,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      prefixIcon: const Icon(Icons.calendar_month),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Submit date",
                      hintStyle: TextStyle(
                        fontSize: 15.0,
                        color: Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          submit_date.text =
                              "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                        });
                      }
                    },
                  ).p4().px8(),
                  TextFormField(
                    controller: voting_start_date,
                    readOnly: true,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      prefixIcon: const Icon(Icons.calendar_month),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Voting starts on:",
                      hintStyle: TextStyle(
                        fontSize: 15.0,
                        color: Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          voting_start_date.text =
                              "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                        });
                      }
                    },
                  ).p4().px8(),
                  TextField(
                    controller: voting_end_date,
                    readOnly: true,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      prefixIcon: const Icon(Icons.calendar_month),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Voting ends on:",
                      hintStyle: TextStyle(
                        fontSize: 15.0,
                        color: Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          voting_end_date.text =
                              "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                        });
                      }
                    },
                  ).p4().px8(),
                  SizedBox(
                    height: 3,
                  ),
                  SizedBox(
                    height: 60,
                    width: 150, // Set the width you want
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ourBlue,
                      ),
                      onPressed: () {
                        addContest();
                      },
                      child: Text("Add"),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _displayTextInputDialogforUpdate(BuildContext context) async {
    getContestDetails(contestId);
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: offwhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            height: 700,
            width: 700,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Update Contest',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 77, 152, 189),
                      ),
                    ),
                  ),
                  // Title Field
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Title',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        TextField(
                          controller: update_title,
                          maxLines: null,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintStyle: TextStyle(
                              fontSize: 15.0,
                              color: Colors.grey,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 16.0),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Description Field
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        TextField(
                          controller: update_description,
                          maxLines: null,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintStyle: TextStyle(
                              fontSize: 15.0,
                              color: Colors.grey,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 16.0),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Required Score Field
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Required Score',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        TextField(
                          controller: update_required_score,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.star_rate_rounded),
                            filled: true,
                            fillColor: Colors.white,
                            hintStyle: TextStyle(
                              fontSize: 15.0,
                              color: Colors.grey,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 16.0),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Submit Date Field
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Submit Date',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        TextFormField(
                          controller: update_submit_date,
                          readOnly: true,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.calendar_month),
                            filled: true,
                            fillColor: Colors.white,
                            hintStyle: TextStyle(
                              fontSize: 15.0,
                              color: Colors.grey,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 16.0),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                            ),
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                update_submit_date.text =
                                    "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  // Voting Start Date Field
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Voting Start Date',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        TextFormField(
                          controller: update_voting_start_date,
                          readOnly: true,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.calendar_month),
                            filled: true,
                            fillColor: Colors.white,
                            hintStyle: TextStyle(
                              fontSize: 15.0,
                              color: Colors.grey,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 16.0),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                            ),
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                update_voting_start_date.text =
                                    "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  // Voting End Date Field
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Voting End Date',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        TextFormField(
                          controller: update_voting_end_date,
                          readOnly: true,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.calendar_month),
                            filled: true,
                            fillColor: Colors.white,
                            hintStyle: TextStyle(
                              fontSize: 15.0,
                              color: Colors.grey,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 16.0),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                            ),
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                update_voting_end_date.text =
                                    "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 6),
                  SizedBox(
                    height: 60,
                    width: 150,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 77, 152, 189),
                      ),
                      onPressed: () {
                        print('id from func:' + contestId);
                        updatedContest(contestId);
                      },
                      child: Text("Update"),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

// Private helper method for creating a competition card
  Widget _competitionCard(int index) {
    final List<Color> cardColors = [
      const Color.fromARGB(255, 103, 194, 196),
      iconsBar,
    ];
    final Color cardColor = cardColors[index % cardColors.length];

    return GestureDetector(
      onTap: () {
        print('Card pressed! Contest ID: ${items![index]['_id']}');
        // Add your desired functionality here
        //navigateToContestDetails(items![index]['_id']); // Example navigation
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContestParticipantsSuperScreen(
              contestName: items![index]['title'],
            ),
          ),
        );
      },
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
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                      });
                    },
                  ),
                ],
              ),
              subtitle: Container(
                height: 150,
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: AssetImage(index % 2 == 0
                        ? 'assets/images/contest.png'
                        : 'assets/images/contest2.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            if (items![index]['isExpanded'])
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.info, color: Colors.black54),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${items![index]['description']}',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_month_rounded,
                            color: Colors.black54),
                        const SizedBox(width: 8),
                        Text(
                          'Submit date: ${items![index]['submit_date']}',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_month_rounded,
                            color: Colors.black54),
                        const SizedBox(width: 8),
                        Text(
                          'Voting starts on: ${items![index]['voting_start_date']}',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_month_rounded,
                            color: Colors.black54),
                        const SizedBox(width: 8),
                        Text(
                          'Voting ends on: ${items![index]['voting_end_date']}',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star_rate_rounded, color: Colors.black54),
                        const SizedBox(width: 8),
                        Text(
                          'Required score: ${items![index]['required_score']}',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            print('Update action pressed');
                            contestId = '${items![index]['_id']}';
                            print('contestId: ' + contestId);
                            _displayTextInputDialogforUpdate(context);
                          },
                          icon: Icon(Icons.edit, color: Colors.white),
                          label: Text('Update'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                                255, 77, 152, 189), // لون الخلفية
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 7), // طول وعرض الزر
                            textStyle: TextStyle(fontSize: 14), // حجم النص
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12), // حواف دائرية
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            deleteItem('${items![index]['_id']}');
                            // If the delete was successful, then remove the item locally and refresh the list
                            if (items!.isNotEmpty) {
                              items!.removeAt(index);
                            }
                            // Refresh the contests list
                            getContestsList(supervisorId);
                          },
                          icon: Icon(Icons.delete, color: Colors.white),
                          label: Text('Delete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                                255, 230, 74, 63), // لون الخلفية
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 7), // طول وعرض الزر
                            textStyle: TextStyle(fontSize: 14), // حجم النص
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12), // حواف دائرية
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}//class



  

