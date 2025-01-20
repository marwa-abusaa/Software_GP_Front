import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/screens/admin/CvViewer.dart';
import 'package:flutter_application_1/screens/admin/adminservices.dart';
import 'package:flutter_application_1/api/info.dart';

class SupervisorRequestsPage extends StatefulWidget {
  @override
  _SupervisorRequestsPageState createState() => _SupervisorRequestsPageState();
}

class _SupervisorRequestsPageState extends State<SupervisorRequestsPage> {
  late Future<List<dynamic>> requests;
  List<dynamic> _filteredRequests = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    requests = getNotActivatedSupervisors();
    final supervisors = await requests;
    setState(() {
      _filteredRequests = supervisors;
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      // Reset the filtered list if the query is empty
      final supervisors = await requests;
      setState(() {
        _filteredRequests = supervisors;
        _isSearching = false;
      });
    } else {
      final supervisors = await searchNonActivatedUsers(query);
      setState(() {
        _filteredRequests = supervisors;
        _isSearching = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: logoBar,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
         centerTitle: true,
        backgroundColor: ourPink,
        title: const Text('Supervisor Requests', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56.0),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _performSearch,
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: const Icon(Icons.search, color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 20.0,
                ),
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: requests,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError ||
              !_isSearching && (!snapshot.hasData || snapshot.data!.isEmpty)) {
            return const Center(child: Text('No supervisor requests found.'));
          } else {
            final supervisors = _filteredRequests;
            return ListView.builder(
              itemCount: supervisors.length,
              itemBuilder: (context, index) {
                final supervisor = supervisors[index];

                // Use FutureBuilder to get the full name asynchronously
                return FutureBuilder<String>(
                  future: getUserFullName(supervisor['email']),
                  builder: (context, nameSnapshot) {
                    if (nameSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (nameSnapshot.hasError || !nameSnapshot.hasData) {
                      return const Center(child: Text('Error loading name'));
                    } else {
                      String name = nameSnapshot.data!;

                      return Card(
                        color: offwhite,
                        child: ListTile(
                          title: Text(name),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check,
                                    color: Colors.green),
                                onPressed: () {
                                  showConfirmationDialog(
                                    context,
                                    email: supervisor['email'],
                                    action: 'activate',
                                  );
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  showConfirmationDialog(
                                    context,
                                    email: supervisor['email'],
                                    action: 'deny',
                                  );
                                },
                              ),
                            ],
                          ),
                          onTap: () {

                            print(supervisor['cv'] + "hello");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PdfViewerScreen(
                                  pdfUrl: supervisor['cv'],
                                  title: 'CV Viewer',
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  void showConfirmationDialog(BuildContext context,
      {required String email, required String action}) {
    final TextEditingController noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              action == 'activate' ? 'Confirm Activation' : 'Confirm Denial'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  hintText: 'Enter a note for the user',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel',style: TextStyle(color: Colors.red,)),
            ),
            ElevatedButton(  
                style: ElevatedButton.styleFrom(
                 backgroundColor: const Color.fromARGB( 255, 63, 160, 161),
                 fixedSize: Size(
                 MediaQuery.of(context).size.width * 0.2, 44, ),
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), ),
                  padding: EdgeInsets.zero,
                  ),                               
              onPressed: () async {
                final note = noteController.text.trim();
                if (note.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please provide a note.'),
                    ),
                  );
                  return;
                }

                try {
                  await updateActivation(
                    email: email,
                    note: note,
                    activated: action == 'activate' ? 'activated' : 'not',
                  );
                  setState(() {
                    _loadRequests();
                  });

                  Navigator.of(context).pop(); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'User successfully ${action == 'activate' ? 'activated' : 'denied'}'),
                    ),
                  );
                } catch (error) {
                  Navigator.of(context).pop(); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $error'),
                    ),
                  );
                }
              },
              child: Text(action == 'activate' ? 'Activate' : 'Deny'),
            ),
          ],
        );
      },
    );
  }
}
