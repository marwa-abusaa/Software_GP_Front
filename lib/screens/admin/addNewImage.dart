import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/api.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/screens/StoryDesign/storyServices/storyService.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddImagePage extends StatefulWidget {
  @override
  _AddImagePageState createState() => _AddImagePageState();
}

class _AddImagePageState extends State<AddImagePage> {
  TextEditingController descriptionController = TextEditingController();
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

      // Clear all fields
      setState(() {
        _selectedImage = null;
        _category = null;
        _description = '';
        descriptionController.clear();
      });

      // Show success dialog
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image')),
      );
    }
  }

  // Function to show the success dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Image added successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ourPink,
        title: const Text('Add New Image',
            style: TextStyle(fontWeight: FontWeight.bold, color:Colors.white)),
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
         centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image picker
              GestureDetector(
                onTap: pickImage,
                child: _selectedImage == null
                    ? Container(
                        height: 180,
                        width: 180,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            const BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 4))
                          ],
                        ),
                        child: const Icon(Icons.add_a_photo,
                            size: 60, color: Colors.grey),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImage!,
                          height: 180,
                          width: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
              const SizedBox(height: 20),

              // Category dropdown
              const Text(
                'Select Category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _category,
                hint: const Text('Select Category'),
                onChanged: (value) {
                  setState(() {
                    _category = value;
                  });
                },
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Description text field
              const Text(
                'Description',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Enter a description',
                  border: const OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                onChanged: (value) {
                  _description = value;
                },
              ),
              const SizedBox(height: 20),

              // Add Image button
              Center(
                child: ElevatedButton(
                  onPressed: handleAddImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ourPink,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Add Image'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
