import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/books/BookDetailsPage.dart';

class BookCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final String? publishDate; // Mark publishDate as nullable

  const BookCard({
    Key? key,
    required this.title,
    required this.imagePath,
    this.publishDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Default current date for comparison
    final currentDate = DateTime.now();
    // Initialize difference variable to null if publishDate is invalid
    int difference = 0;

    // If publishDate is not null, parse it and calculate the difference
    if (publishDate != null && publishDate!.isNotEmpty) {
      try {
        DateTime parsedDate = DateTime.parse(publishDate!);
        difference = currentDate.difference(parsedDate).inDays;
      } catch (e) {
        // Handle invalid date format
        print("Invalid date format: $e");
      }
    }

    return InkWell(
      onTap: () {
        // Navigate to the book details page on tap
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => BookDetailsPage(bookName: title)),
        );

        print('Tapped on $title');
      },
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        width: 120,
        margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
        child: Column(
          children: [
            // Show "NEW BOOK" if the book was published less than 5 days ago
            if (difference < 5)
              Container(
                padding: const EdgeInsets.all(4.0),
                color: Colors.green,
                child: const Text(
                  'NEW BOOK',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 5),

            // Book cover image
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  image: DecorationImage(
                    image: NetworkImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 5),

            // Book title at the bottom
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
