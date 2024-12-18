// BookCard Widget with Press Effect
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/books/BookDetailsPage.dart';

class BookCard extends StatelessWidget {
  final String title;
  final String imagePath;

  const BookCard({
    Key? key,
    required this.title,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Add any action you want to perform when the book card is tapped.
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
            // Book Cover Image
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  image: DecorationImage(
                    image: NetworkImage(
                        imagePath), // Use NetworkImage instead of AssetImage
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 5),

            // Book Title at the bottom
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
