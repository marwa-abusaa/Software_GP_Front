import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/api.dart';
import 'package:flutter_application_1/config.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
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
  File? _imageFile;
  File? _pdfFile;
  final ImagePicker _picker = ImagePicker();

  // Category values
  String? _selectedCategory;
  final List<String> _categories = [
    'Science',
    'Poetry',
    'History',
    'Psychology',
    'Fiction',
    'Self-help',
    'Novels'
  ];

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
          _pdfFile != null &&
          _selectedCategory != null) {
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
          'category': _selectedCategory,
          'rate': 0,
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
          // Clear all fields after successful submission
          _nameController.clear();
          _authorController.clear();
          _descriptionController.clear();
          _selectedCategory = null;
          _imageFile = null;
          _pdfFile = null;

          // Rebuild the widget to reflect the changes
          setState(() {});
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
      appBar: AppBar(
        title: const Text('Add Book'),
        backgroundColor: ourPink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Card(
            elevation: 10.0,
            shadowColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      labelText: 'Book Name',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _authorController,
                      labelText: 'Author',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _descriptionController,
                      labelText: 'Description',
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryDropdown(),
                    const SizedBox(height: 16),
                    _buildImagePicker(),
                    const SizedBox(height: 16),
                    _buildPdfPicker(),
                    const SizedBox(height: 24),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: ourPink),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$labelText is required';
        }
        return null;
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      hint: const Text('Select Category'),
      onChanged: (String? newValue) {
        setState(() {
          _selectedCategory = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Category is required';
        }
        return null;
      },
      items: _categories.map((String category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return _imageFile == null
        ? ElevatedButton.icon(
            icon: const Icon(Icons.photo),
            label: const Text('Pick Cover Image'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size.fromHeight(50),
              backgroundColor: ourPink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _pickImage,
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              _imageFile!,
              height: 150,
              fit: BoxFit.cover,
            ),
          );
  }

  Widget _buildPdfPicker() {
    return _pdfFile == null
        ? ElevatedButton.icon(
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Pick PDF File'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size.fromHeight(50),
              backgroundColor: ourPink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _pickPdfFile,
          )
        : Text('Selected PDF: ${_pdfFile!.path.split('/').last}');
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitBook,
      style: ElevatedButton.styleFrom(
        minimumSize: Size.fromHeight(50),
        backgroundColor: ourPink,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: const Text(
        'Submit',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
