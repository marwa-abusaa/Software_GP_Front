import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/api.dart';
import 'package:flutter_application_1/config.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class AddBookPage extends StatefulWidget {
  @override
  _AddBookPageState createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _rateController = TextEditingController();
  File? _imageFile;
  File? _pdfFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickPdfFile() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _pdfFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _submitBook() async {
    try {
      if (_formKey.currentState!.validate() &&
          _imageFile != null &&
          _pdfFile != null) {
        // Upload image to Firebase Storage
        String imageFileName =
            DateTime.now().millisecondsSinceEpoch.toString() + "_cover.jpg";
        Reference imageStorageRef =
            APIS.storage.ref().child("book_covers/$imageFileName");
        await imageStorageRef.putFile(_imageFile!);
        String imageUrl = await imageStorageRef.getDownloadURL();

        // Upload PDF to Firebase Storage
        String pdfFileName =
            DateTime.now().millisecondsSinceEpoch.toString() + "_book.pdf";
        Reference pdfStorageRef =
            APIS.storage.ref().child("book_pdfs/$pdfFileName");
        await pdfStorageRef.putFile(_pdfFile!);
        String pdfUrl = await pdfStorageRef.getDownloadURL();

        // Construct request body for MongoDB
        final body = json.encode({
          'name': _nameController.text,
          'author': _authorController.text,
          'Description': _descriptionController.text,
          'category': _categoryController.text,
          'rate': int.parse(_rateController.text),
          'review': 0, // default review value
          'image': imageUrl, // URL of the uploaded image
          'pdfLink': pdfUrl, // URL of the uploaded PDF
        });

        // Send POST request to MongoDB backend
        final response = await http.post(
          Uri.parse(
              '$getBook'), // Replace with your actual MongoDB API endpoint
          headers: {"Content-Type": "application/json"},
          body: body,
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Book added successfully!'),
            backgroundColor: Colors.green,
          ));
        } else if (response.statusCode == 409) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Duplicate Book'),
              content: const Text('A book with this name already exists.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: Text(
                  'Failed to add book: ${json.decode(response.body)['error']}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Please complete all fields and select an image and PDF.'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('An error occurred while adding the book: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Book')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Book Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: 'Author'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Author name is required';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Category is required';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _rateController,
                decoration: const InputDecoration(labelText: 'Rate'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Rate is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _imageFile == null
                  ? TextButton.icon(
                      icon: const Icon(Icons.photo),
                      label: const Text('Pick Cover Image'),
                      onPressed: _pickImage,
                    )
                  : Image.file(
                      _imageFile!,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
              const SizedBox(height: 16),
              _pdfFile == null
                  ? TextButton.icon(
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Pick PDF File'),
                      onPressed: _pickPdfFile,
                    )
                  : Text('Selected PDF: ${_pdfFile!.path.split('/').last}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitBook,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
