import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/info.dart';

class SupervisorInfoPage extends StatefulWidget {
  final String supervisorEmail;

  const SupervisorInfoPage({Key? key, required this.supervisorEmail})
      : super(key: key);

  @override
  _SupervisorInfoPageState createState() => _SupervisorInfoPageState();
}

class _SupervisorInfoPageState extends State<SupervisorInfoPage> {
  String? supervisorName;
  String? supervisorImageUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSupervisorData();
  }

  Future<void> fetchSupervisorData() async {
    try {
      // Call your function to fetch the supervisor's name
      String name = await getUserFullName(widget.supervisorEmail);

      // Call your function to fetch the supervisor's image URL
      String imageUrl = await fetchUserImage(widget.supervisorEmail);

      setState(() {
        supervisorName = name;
        supervisorImageUrl = imageUrl;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      // Handle error (e.g., show a snackbar)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch supervisor data: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supervisor Information'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Supervisor Image
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: supervisorImageUrl != null
                        ? NetworkImage(supervisorImageUrl!)
                        : null,
                    backgroundColor: Colors.grey.shade200,
                    child: supervisorImageUrl == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  // Supervisor Name
                  Text(
                    supervisorName ?? 'Name not available',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // Supervisor Email
                  Text(
                    widget.supervisorEmail,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  // Optional: Add more details or actions here
                ],
              ),
            ),
    );
  }
}
