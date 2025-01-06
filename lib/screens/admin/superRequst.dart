import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/screens/admin/CvViewer.dart';
import 'package:flutter_application_1/screens/admin/adminservices.dart';

class SupervisorRequestsPage extends StatefulWidget {
  @override
  _SupervisorRequestsPageState createState() => _SupervisorRequestsPageState();
}

class _SupervisorRequestsPageState extends State<SupervisorRequestsPage> {
  late Future<List<dynamic>> requests;

  @override
  void initState() {
    super.initState();
    requests = getNotActivatedSupervisors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ourPink,
        title: const Text('Supervisor Requests'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: requests,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('No supervisor requests found.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No supervisor requests found.'));
          } else {
            final supervisors = snapshot.data!;
            return ListView.builder(
              itemCount: supervisors.length,
              itemBuilder: (context, index) {
                final supervisor = supervisors[index];

                return Card(
                  child: ListTile(
                    title: Text(supervisor['email']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            showConfirmationDialog(
                              context,
                              email: supervisor['email'],
                              action: 'activate',
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            showConfirmationDialog(
                              context,
                              email: supervisor['email'],
                              action: 'deny',
                            );
                            setState(() {
                              requests = getNotActivatedSupervisors();
                            });
                          },
                        ),
                      ],
                    ),
                    onTap: () {
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
              },
            );
          }
        },
      ),
    );
  }
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
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
