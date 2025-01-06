import 'package:flutter/material.dart';
import 'package:flutter_application_1/config.dart';
import 'package:flutter_application_1/screens/supervisors/super.service.dart';
import 'package:flutter_application_1/api/info.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/screens/supervisors/childProfile.dart';

class SupervisorChildrenPage extends StatefulWidget {
  final String superEmail;

  const SupervisorChildrenPage({Key? key, required this.superEmail})
      : super(key: key);

  @override
  _SupervisorChildrenPageState createState() => _SupervisorChildrenPageState();
}

class _SupervisorChildrenPageState extends State<SupervisorChildrenPage> {
  late Future<List<Map<String, String>>> _childrenFuture;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _childrenFuture = _fetchChildren();
  }

  Future<List<Map<String, String>>> _fetchChildren() async {
    final children = await getAllMyChildren(widget.superEmail);
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
  }

  Future<void> _searchChildren(String searchTerm) async {
    if (searchTerm.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    try {
      final results = await searchUsers(searchTerm, EMAIL);
      final searchResults = await Future.wait(results.map((user) async {
        final email = user['email'] as String;
        final image = await fetchUserImage(email);
        final name = await getUserFullName(email);
        return {
          'email': email,
          'image': image,
          'name': name,
        };
      }));

      setState(() {
        _isSearching = true;
        _searchResults = searchResults;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during search: $e')),
      );
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: logoBar,
      appBar: AppBar(
        title: const Text("My Students"),
        backgroundColor: ourPink,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      if (value.isEmpty) {
                        setState(() {
                          _isSearching = false;
                          _searchResults = [];
                        });
                      }
                    },
                    onSubmitted: _searchChildren,
                    decoration: InputDecoration(
                      hintText: 'Search children...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                ),
                if (_isSearching)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _isSearching = false;
                        _searchController.clear();
                        _searchResults = [];
                      });
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Display search results at the top of the list
          if (_isSearching) _buildSearchResults(),

          // Display the list of children
          Expanded(
            child: FutureBuilder<List<Map<String, String>>>(
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
                return _buildChildrenList(children);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(child: Text("No results found."));
    }

    // Create a horizontal ListView for search results
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Searched Results',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 120, // Adjust the height as needed
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final child = _searchResults[index];
              final imageUrl = child['image'];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChildProfilePage(
                        email: child['email']!,
                      ),
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Selected ${child['name']}"),
                    ),
                  );
                },
                child: Card(
                  color: offwhite,
                  margin: const EdgeInsets.all(8.0),
                  elevation: 4.0, // Add elevation for shadow effect
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10.0), // Rounded corners
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChildProfilePage(
                            email: child['email']!,
                          ),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: 100, // Adjust the width of the card
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: ourPink,
                            backgroundImage:
                                imageUrl != null && imageUrl.isNotEmpty
                                    ? NetworkImage(imageUrl)
                                    : null,
                            child: imageUrl == null || imageUrl.isEmpty
                                ? const Icon(Icons.person,
                                    size: 30, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            child['name']!,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChildrenList(List<Map<String, String>> children) {
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
                ),
              ),
            );
          },
          child: Card(
            color: offwhite,
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: ourPink,
                backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                    ? NetworkImage(imageUrl)
                    : null,
                child: imageUrl == null || imageUrl.isEmpty
                    ? const Icon(Icons.person, size: 30, color: Colors.white)
                    : null,
              ),
              title: Text(child['name']!),
              subtitle: Text(child['email']!),
            ),
          ),
        );
      },
    );
  }
}
