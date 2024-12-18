import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/info.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/screens/supervisors/childProfile.dart';
import 'package:flutter_application_1/screens/supervisors/super.service.dart';

class SupervisorChildrenPage extends StatefulWidget {
  final String superEmail;

  const SupervisorChildrenPage({Key? key, required this.superEmail})
      : super(key: key);

  @override
  _SupervisorChildrenPageState createState() => _SupervisorChildrenPageState();
}

class _SupervisorChildrenPageState extends State<SupervisorChildrenPage> {
  late Future<List<Map<String, String>>> _childrenFuture;

  @override
  void initState() {
    super.initState();
    _childrenFuture =
        getAllMyChildren(widget.superEmail).then((children) async {
      return await Future.wait(children.map((child) async {
        final childEmail = child['childEmail'];
        final userImage = await fetchUserImage(childEmail);
        final fullName = await getUserFullName(childEmail);
        return {
          'email': childEmail,
          'image': userImage,
          'name': fullName,
        };
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: logoBar,
      appBar: AppBar(
        title: const Text("My students"),
        backgroundColor: ourPink,
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _childrenFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No children found."));
          }

          final children = snapshot.data!;
          return ListView.builder(
            itemCount: children.length,
            itemBuilder: (context, index) {
              final child = children[index];
              final imageUrl = child['image'];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChildProfilePage(
                              email: child['email']!,
                            )),
                  );
                  // Perform action on tap (e.g., navigate or show details)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Selected ${child['name']}"),
                    ),
                  );
                },
                child: Card(
                  color: offwhite,
                  //color: Colors.lightBlueAccent,
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: ourPink,
                      backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                          ? NetworkImage(imageUrl)
                          : null,
                      child: imageUrl == null || imageUrl.isEmpty
                          ? const Icon(Icons.person,
                              size: 30, color: Colors.white)
                          : null,
                    ),
                    title: Text(child['name']!),
                    subtitle: Text(child['email']!),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
