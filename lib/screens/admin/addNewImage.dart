import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/api.dart';
import 'package:flutter_application_1/screens/StoryDesign/storyServices/storyService.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddImagePage extends StatefulWidget {
  @override
  _AddImagePageState createState() => _AddImagePageState();
}

class _AddImagePageState extends State<AddImagePage> {
  File? _selectedImage;
  String? _category;
  String _description = '';
  final String _email = 'public'; // Replace with the actual email
  final List<String> _categories = [
    'Characters',
    'Professions',
    'Nature',
    'Animals',
    'Actions',
    'Religious Images',
  ];

  final picker = ImagePicker();

  // Function to pick an image
  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Function to upload image to Firebase Storage and get the download URL
  Future<String?> uploadImage(File image) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef = APIS.storage.ref().child('storyImages/$fileName');
      await storageRef.putFile(image);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Function to handle the "Add Image" button click
  Future<void> handleAddImage() async {
    if (_selectedImage == null || _category == null || _description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in all fields and select an image')),
      );
      return;
    }

    final imageUrl = await uploadImage(_selectedImage!);
    if (imageUrl != null) {
      await addImage(imageUrl, _email, _description, _category!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Image'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Image picker
            GestureDetector(
              onTap: pickImage,
              child: _selectedImage == null
                  ? Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add_a_photo, size: 50),
                    )
                  : Image.file(
                      _selectedImage!,
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(height: 16),

            // Dropdown menu for category
            DropdownButtonFormField<String>(
              value: _category,
              hint: const Text('Select Category'),
              onChanged: (value) {
                setState(() {
                  _category = value;
                });
              },
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Text field for description
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _description = value;
              },
            ),
            const SizedBox(height: 16),

            // Add Image button
            ElevatedButton(
              onPressed: handleAddImage,
              child: const Text('Add Image'),
            ),
          ],
        ),
      ),
    );
  }
}
