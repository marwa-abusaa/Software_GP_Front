import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/api.dart';
import 'package:flutter_application_1/screens/StoryDesign/story.dart';

class DraftsPage extends StatefulWidget {
  @override
  _DraftsPageState createState() => _DraftsPageState();
}

class _DraftsPageState extends State<DraftsPage> {
  List<Map<String, dynamic>> drafts = [];

  @override
  void initState() {
    super.initState();
    loadUserDrafts();
  }

  // Load user drafts from Firebase
  void loadUserDrafts() async {
    String userId = APIS.user!.uid; // Get the current user's ID
    CollectionReference draftsCollection =
        FirebaseFirestore.instance.collection('drafts');

    // Fetch user's drafts
    QuerySnapshot snapshot =
        await draftsCollection.where('userId', isEqualTo: userId).get();

    setState(() {
      drafts = snapshot.docs
          .map((doc) => {
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id, // Include the document ID for deletion
              })
          .toList();
    });
  }

  // Delete a draft from Firebase
  void deleteDraft(String draftId) async {
    try {
      CollectionReference draftsCollection =
          FirebaseFirestore.instance.collection('drafts');
      await draftsCollection.doc(draftId).delete();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Drafts')),
      body: drafts.isEmpty
          ? const Center(child: Text('No drafts available'))
          : ListView.builder(
              itemCount: drafts.length,
              itemBuilder: (context, index) {
                var draft = drafts[index];
                return Card(
                  child: ListTile(
                    title: Text('Draft ${index + 1}'),
                    subtitle: Text(
                        'Last modified: ${draft['lastModified'].toDate()}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        // Confirm deletion
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Delete Draft'),
                              content: const Text(
                                  'Are you sure you want to delete this draft?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    deleteDraft(draft['id']);
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    onTap: () {
                      // Navigate to the editor page with the selected draft
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditorPage(draft: draft),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
