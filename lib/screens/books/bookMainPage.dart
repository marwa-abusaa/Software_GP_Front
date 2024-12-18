import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/books/BookService%20.dart';
import 'package:flutter_application_1/widgets/bookCard.dart';

class BookHomePage extends StatefulWidget {
  @override
  _BookHomePageState createState() => _BookHomePageState();
}

class _BookHomePageState extends State<BookHomePage> {
  List<dynamic> _topRatedBooks = [];
  List<dynamic> _categoryBooks =
      []; // List to hold books for the selected category
  String selectedCategory = '';
  String filterCategory = 'All Categories';
  String filterTitle = '';
  String filterAuthor = '';
  double filterRating = 0.0;

  // This will hold books categorized by their categories
  Map<String, List<dynamic>> booksByCategory = {
    'All Categories': [],
    'Science': [],
    'Poetry': [],
    'History': [],
    'Psychology': [],
    'Fiction': [],
    'self-help': [],
    'novels': [],
  };

  @override
  void initState() {
    super.initState();
    _fetchTopRatedBooks();
  }

  Future<void> _fetchTopRatedBooks() async {
    List<dynamic> books = await BookService.searchBooksRating(4.0);
    setState(() {
      _topRatedBooks = books;

      // Populate the booksByCategory map
      for (var book in books) {
        String category =
            book['category']; // Assuming the book object has a 'category' field
        if (booksByCategory.containsKey(category)) {
          booksByCategory[category]!.add(book);
        } else {
          booksByCategory[category] = [book];
        }
      }
      booksByCategory['All Categories'] =
          books; // Keep track of all books under 'All Categories'
    });
  }

  Future<void> _fetchBooksByCategory(String category) async {
    List<dynamic> books;

    if (category == 'All Categories') {
      books = await BookService.getAllBooks();
    } else {
      books = await BookService.searchCategory(category);
    }

    setState(() {
      _categoryBooks = books;
    });
  }

  final List<String> categories = [
    'All Categories',
    'Science',
    'Poetry',
    'History',
    'Psychology',
    'Fiction',
    'self-help',
    'novels',
  ];

  List<String> searchResults = []; // New list for search results

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: GestureDetector(
                  onTap: _showFilterDialog, // Show filter dialog on tap
                  child: TextField(
                    enabled: false, // Disable typing; tap to open dialog
                    decoration: InputDecoration(
                      hintText: 'Search books...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Display Search Results if any
              if (searchResults.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Search Results:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          searchResults.clear(); // Clear search results
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 220,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: searchResults.map((title) {
                      return BookCard(
                        title: title,
                        imagePath: 'assets/images/howNotToDie.jpg',
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Book List (Scrollable Horizontally) - Most Popular
              const Text(
                'Top Rated:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _topRatedBooks
                      .length, // Use the length of the fetched books
                  itemBuilder: (context, index) {
                    final book = _topRatedBooks[index];

                    return BookCard(
                      title: book['name'], // Display the book name
                      imagePath:
                          book['image'], // Pass the image URL if available
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Categories List with Expandable Books
              ...categories
                  .map((category) => categoryWithBooks(category))
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }

  // Show filter dialog
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Search'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Filter
                DropdownButtonFormField(
                  value: filterCategory,
                  decoration:
                      const InputDecoration(labelText: 'Select Category'),
                  items: categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      filterCategory = value.toString();
                    });
                  },
                ),
                const SizedBox(height: 10),

                // Title Filter
                TextField(
                  decoration: const InputDecoration(labelText: 'Book Title'),
                  onChanged: (value) {
                    setState(() {
                      filterTitle = value;
                    });
                  },
                ),
                const SizedBox(height: 10),

                // Author Filter
                TextField(
                  decoration: const InputDecoration(labelText: 'Author Name'),
                  onChanged: (value) {
                    setState(() {
                      filterAuthor = value;
                    });
                  },
                ),
                const SizedBox(height: 10),

                // Rating Filter
                TextField(
                  decoration:
                      const InputDecoration(labelText: 'Minimum Rating (0-5)'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      filterRating = double.tryParse(value) ?? 0.0;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Apply'),
              onPressed: () {
                _applyFilter(); // Apply filter logic
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Apply filter logic and update search results
  void _applyFilter() async {
    searchResults.clear(); // Clear previous results
    try {
      final books = await BookService.searchBooks(
        name: filterTitle.isNotEmpty ? filterTitle : null,
        author: filterAuthor.isNotEmpty ? filterAuthor : null,
        category: filterCategory != 'All Categories' ? filterCategory : null,
        minRating: filterRating > 0 ? filterRating : null,
      );

      // Log the fetched books to confirm they match the expected structure
      log('Fetched books: ${books.toString()}');

      setState(() {
        // Map each book to its 'name' and cast to List<String>
        searchResults = books.map((book) => book['name'] as String).toList();
        log('Search results after filter: ${searchResults.toString()}');
      });
    } catch (error) {
      print('Error applying filter: $error');
    }
  }

  // Category Card with expand/collapse functionality and books below it
  Widget categoryWithBooks(String category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () async {
            setState(() {
              selectedCategory = selectedCategory == category ? '' : category;
              _categoryBooks.clear(); // Clear previous category books
            });
            if (selectedCategory == category) {
              // Fetch books for the selected category
              await _fetchBooksByCategory(category);
            }
          },
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    category,
                    style: const TextStyle(fontSize: 16),
                  ),
                  Icon(
                    selectedCategory == category
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Display books in a horizontally scrollable grid if the category is selected
        if (selectedCategory == category) ...[
          if (_categoryBooks.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'No books available in this category.',
                style: TextStyle(color: Colors.red),
              ),
            )
          else
            SizedBox(
              height: 240, // Height to accommodate two rows
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _categoryBooks.map((book) {
                  return BookCard(
                    title: book['name'], // Display the book name
                    imagePath: book['image'],
                  );
                }).toList(),
              ),
            ),
        ],
      ],
    );
  }
}
