import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stability_image_generation/stability_image_generation.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';


class AiTextToImageGenerator extends StatefulWidget {
  const AiTextToImageGenerator({super.key});
  @override
  State<AiTextToImageGenerator> createState() => _AiTextToImageGeneratorState();
}

class _AiTextToImageGeneratorState extends State<AiTextToImageGenerator> {
  final TextEditingController _queryController = TextEditingController();
  final StabilityAI _ai = StabilityAI();
  final String apiKey = 'sk-eqohyEr2ceu19a6SuAA8G8tExuZDS5qNuBQU6A8OyR99z8Wb';
  ImageAIStyle selectedStyle = ImageAIStyle.anime;
  bool isItems = false;

  final List<ImageAIStyle> styles = [
    ImageAIStyle.anime,
    ImageAIStyle.studioPhoto,
    ImageAIStyle.cartoon,
    ImageAIStyle.digitalPainting,
    ImageAIStyle.pencilDrawing,
    ImageAIStyle.medievalStyle,
    ImageAIStyle.render3D,
  ];
  
Future<void> _saveImageWithName(Uint8List image, String name) async {
  try {
    // Request permission to write to storage
    final status = await Permission.storage.request();
    if (status.isGranted) {
      // Get the directory path
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        // Use the provided name for the image
        final imagePath = '${directory.path}/$name.png';

        // Save the image to the device
        final file = File(imagePath);
        await file.writeAsBytes(image);

        // Notify user
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Image saved to storage $imagePath")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to get directory path")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Permission denied")),
      );
    }
  } catch (e) {
    if (kDebugMode) print("Error saving image: $e");
  }
}


Future<void> _showSaveDialog(Uint8List image) async {
  final TextEditingController _nameController = TextEditingController();
  String? imageName;

  return showDialog<void>(
    context: context,
    barrierDismissible: false, // Prevent dismissing by tapping outside
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Save Image'),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'Enter a name for your image',
            border: OutlineInputBorder(),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              // Dismiss the dialog
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Get the entered name and save the image
              imageName = _nameController.text;
              if (imageName != null && imageName!.isNotEmpty) {
                _saveImageWithName(image, imageName!);
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid name')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}


  Future<Uint8List> _generate(String query) async {
    try {
      if (kDebugMode) print("Starting image generation...");
      if (kDebugMode) print("API Key: $apiKey");
      if (kDebugMode) print("Style: $selectedStyle");
      if (kDebugMode) print("Prompt: $query");

      Uint8List image = await _ai.generateImage(
        apiKey: apiKey,
        imageAIStyle: selectedStyle,
        prompt: query,
      );

      if (kDebugMode) print("Image generation successful!");
      return image;
    } catch (e) {
      if (kDebugMode) print("Error during image generation: $e");
      rethrow;
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("AI Image Generator", style: TextStyle(color: Colors.white),),
      backgroundColor: ourPink,
      centerTitle: true, // Center the title
    ),
    backgroundColor: offwhite,
    body: Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 48,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: TextField(
                controller: _queryController,
                decoration: InputDecoration(
                  hintText: 'Enter your prompt',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15), // Rounded corners
                    borderSide: const BorderSide(color: Color.fromARGB(255, 244, 27, 27), width: 2), // Border color and width
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.grey, width: 1), // Default border color
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: ourBlue, width: 1), // Border when focused
                  ),
                  //contentPadding: const EdgeInsets.only(left: 15, top: 5),
                ),
              ),
          
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey, width: 1), // Border color and width
                  color: Colors.white,
                ),
                child: DropdownButton<ImageAIStyle>(
                  isExpanded: true,
                  value: selectedStyle,
                  items: styles.map((style) {
                    return DropdownMenuItem<ImageAIStyle>(
                      value: style,
                      child: Text(style.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (style) {
                    setState(() {
                      selectedStyle = style!;
                    });
                    if (kDebugMode) print("Selected style: $selectedStyle");
                  },
                  dropdownColor: const Color.fromARGB(255, 238, 225, 213), // Dropdown menu background color
                  underline: const SizedBox(),
                ),
              ),
            ),
          Padding(
          padding: const EdgeInsets.all(20),
          child: isItems
        ? FutureBuilder<Uint8List>(
            future: _generate(_queryController.text),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                if (kDebugMode) print("Image is being generated...");
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasData) {
                if (kDebugMode) print("Displaying generated image.");
                return Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(snapshot.data!),
                    ),
                    IconButton(
                          icon: const Icon(Icons.save_alt, size: 35,),
                          onPressed: () {
                            // Display dialog to enter image name
                            _showSaveDialog(snapshot.data!);
                          },
                        ),
          
                  ],
                );
              } else {
                if (kDebugMode) print("No data in snapshot.");
                return const Text(
                  "Error generating image.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                );
              }
            },
          )
        : const Center(
            child: Text(
              'No image generated yet',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          ),
          
            ElevatedButton(
              onPressed: () {
                String query = _queryController.text;
                if (query.isNotEmpty) {
                  setState(() {
                    isItems = true;
                  });
                  if (kDebugMode) print("Query submitted: $query");
                } else {
                  if (kDebugMode) print("Query is empty!!");
                }              
              },
               style: ElevatedButton.styleFrom(
                backgroundColor: ourBlue, // Background color
                foregroundColor: Colors.white, // Text color
                padding: const EdgeInsets.symmetric( horizontal: 20,vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
              ),
              child: const Text("Generate Image", style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Courier' , fontSize: 20), ),
            ),
          ],
        ),
      ),
    ),
  );
}

}
