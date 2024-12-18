import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_application_1/api/api.dart';
import 'package:flutter_application_1/config.dart';
import 'package:flutter_application_1/screens/StoryDesign/storyServices/storyService.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

enum ShapeType { freehand, line, circle, rectangle }

class DrawingRoomScreen extends StatefulWidget {
  const DrawingRoomScreen({super.key, required this.onImageUploaded});

  final Future<void> Function() onImageUploaded;
  @override
  State<DrawingRoomScreen> createState() => _DrawingRoomScreenState();
}

class _DrawingRoomScreenState extends State<DrawingRoomScreen> {
  var availableColor = [
    Colors.black,
    Colors.red,
    Colors.amber,
    Colors.blue,
    Colors.green,
    Colors.brown,
  ];

  var drawableElements = <DrawableElement>[];
  var history = <DrawableElement>[];
  var redoHistory = <DrawableElement>[];

  var selectedColor = Colors.black;
  var selectedWidth = 2.0;
  ShapeType selectedShape = ShapeType.freehand;

  final GlobalKey _repaintBoundaryKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Canvas
          GestureDetector(
            onPanStart: (details) {
              setState(() {
                final id = DateTime.now().microsecondsSinceEpoch;
                if (selectedShape == ShapeType.freehand) {
                  final element = DrawableElement(
                    id: id,
                    type: ShapeType.freehand,
                    offsets: [details.localPosition],
                    color: selectedColor,
                    width: selectedWidth,
                  );
                  drawableElements.add(element);
                  history.add(element);
                } else {
                  final element = DrawableElement(
                    id: id,
                    type: selectedShape,
                    startPoint: details.localPosition,
                    endPoint: details.localPosition,
                    color: selectedColor,
                    width: selectedWidth,
                  );
                  drawableElements.add(element);
                  history.add(element);
                }
                redoHistory.clear();
              });
            },
            onPanUpdate: (details) {
              setState(() {
                final lastElement = drawableElements.last;
                final currentOffset = details.localPosition;

                if (lastElement.type == ShapeType.freehand) {
                  drawableElements[drawableElements.length - 1] =
                      lastElement.copyWith(
                    offsets: lastElement.offsets..add(currentOffset),
                  );
                } else {
                  drawableElements[drawableElements.length - 1] =
                      lastElement.copyWith(
                    endPoint: currentOffset,
                  );
                }
              });
            },
            onPanEnd: (_) {},
            child: RepaintBoundary(
              key: _repaintBoundaryKey,
              child: CustomPaint(
                painter: DrawingPainter(drawableElements: drawableElements),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
              ),
            ),
          ),

          // Color Palette and Shape Selector
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 16,
            right: 16,
            child: Column(
              children: [
                // Color Palette + Color Picker
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 80,
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: availableColor.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedColor = availableColor[index];
                                  });
                                },
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: availableColor[index],
                                    shape: BoxShape.circle,
                                  ),
                                  foregroundDecoration: BoxDecoration(
                                    border:
                                        selectedColor == availableColor[index]
                                            ? Border.all(
                                                color: Colors.grey, width: 4)
                                            : null,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        final newColor = await showColorPicker(context);
                        if (newColor != null) {
                          setState(() {
                            availableColor.add(newColor);
                            selectedColor = newColor;
                          });
                        }
                      },
                      icon: const Icon(Icons.palette, color: Colors.black),
                    ),
                  ],
                ),

                // Shape Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var shape in ShapeType.values)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            selectedShape = shape;
                          });
                        },
                        icon: Icon(
                          _getShapeIcon(shape),
                          color: selectedShape == shape
                              ? Colors.blue
                              : Colors.black,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Pencil Size Slider
          Positioned(
            top: MediaQuery.of(context).padding.top + 160,
            right: 0,
            bottom: 150,
            child: RotatedBox(
              quarterTurns: 3,
              child: Slider(
                value: selectedWidth,
                min: 1,
                max: 20,
                onChanged: (value) {
                  setState(() {
                    selectedWidth = value;
                  });
                },
              ),
            ),
          ),

          // Floating Action Buttons
          Positioned(
            bottom: 16,
            left: 16,
            child: Row(
              children: [
                // Clear Canvas Button
                FloatingActionButton(
                  heroTag: "Clear",
                  onPressed: () {
                    setState(() {
                      drawableElements.clear();
                      history.clear();
                      redoHistory.clear();
                    });
                  },
                  child: const Icon(Icons.delete, color: Colors.red),
                ),
                const SizedBox(width: 16),
                // Undo Button
                FloatingActionButton(
                  heroTag: "Undo",
                  onPressed: () {
                    if (drawableElements.isNotEmpty) {
                      setState(() {
                        final lastElement = drawableElements.removeLast();
                        redoHistory.add(lastElement);
                      });
                    }
                  },
                  child: const Icon(Icons.undo),
                ),
                const SizedBox(width: 16),
                // Redo Button
                FloatingActionButton(
                  heroTag: "Redo",
                  onPressed: () {
                    if (redoHistory.isNotEmpty) {
                      setState(() {
                        final lastRedo = redoHistory.removeLast();
                        drawableElements.add(lastRedo);
                      });
                    }
                  },
                  child: const Icon(Icons.redo),
                ),
                const SizedBox(width: 16),
                // Save Button
                FloatingActionButton(
                  heroTag: "Save Image",
                  onPressed: saveImage,
                  child: const Icon(Icons.save_alt),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // باقي الكود كما هو...

  Future<Color?> showColorPicker(BuildContext context) async {
    Color selectedColor = this.selectedColor;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick a color!'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (color) {
                selectedColor = color;
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
              enableAlpha: true,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancel
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(selectedColor); // Select color
              },
              child: const Text('Select'),
            ),
          ],
        );
      },
    );

    return selectedColor;
  }

  Future<void> saveImage() async {
    await Permission.storage.request();
    if (await Permission.storage.isGranted) {
      final boundary = _repaintBoundaryKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage();
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      // Save image locally
      final directory = await getExternalStorageDirectory();
      final filePath =
          '${directory!.path}/drawing_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(buffer);

      // Show local save success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image saved to $filePath')),
      );

      // Upload image to Firebase
      final downloadUrl = await uploadImage(file);
      if (downloadUrl != null) {
        await addImage(downloadUrl, EMAIL, "", "");
        await widget.onImageUploaded();
        print("After upload image im here");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload image')),
        );
      }

      if (downloadUrl != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image uploaded to Firebase')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload image to Firebase.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission to write to storage denied.')),
      );
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

  IconData _getShapeIcon(ShapeType shape) {
    switch (shape) {
      case ShapeType.freehand:
        return Icons.brush;
      case ShapeType.line:
        return Icons.remove;
      case ShapeType.circle:
        return Icons.circle_outlined;
      case ShapeType.rectangle:
        return Icons.rectangle_outlined;
      default:
        return Icons.help_outline;
    }
  }
}

class DrawableElement {
  final int id;
  final ShapeType type;
  final List<Offset> offsets;
  final Offset? startPoint;
  final Offset? endPoint;
  final Color color;
  final double width;

  DrawableElement({
    required this.id,
    required this.type,
    this.offsets = const [],
    this.startPoint,
    this.endPoint,
    required this.color,
    required this.width,
  });

  DrawableElement copyWith({
    List<Offset>? offsets,
    Offset? startPoint,
    Offset? endPoint,
  }) {
    return DrawableElement(
      id: id,
      type: type,
      offsets: offsets ?? this.offsets,
      startPoint: startPoint ?? this.startPoint,
      endPoint: endPoint ?? this.endPoint,
      color: this.color,
      width: this.width,
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawableElement> drawableElements;

  DrawingPainter({required this.drawableElements});

  @override
  void paint(Canvas canvas, Size size) {
    final paint2 = Paint()..style = PaintingStyle.stroke;

    for (var element in drawableElements) {
      final paint = Paint()
        ..color = element.color
        ..isAntiAlias = true
        ..strokeWidth = element.width
        ..strokeCap = StrokeCap.round;
      paint2.color = element.color;
      paint2.strokeWidth = element.width;

      if (element.type == ShapeType.freehand) {
        for (var i = 0; i < element.offsets.length - 1; i++) {
          //canvas.drawLine(element.offsets[i], element.offsets[i + 1], paint);
          if ((element.offsets[i + 1] - element.offsets[i]).distance > 1) {
            canvas.drawLine(element.offsets[i], element.offsets[i + 1], paint);
          }
        }
      } else {
        switch (element.type) {
          case ShapeType.line:
            canvas.drawLine(element.startPoint!, element.endPoint!, paint2);
            break;
          case ShapeType.circle:
            final rect =
                Rect.fromPoints(element.startPoint!, element.endPoint!);
            canvas.drawOval(rect, paint2);
            break;
          case ShapeType.rectangle:
            canvas.drawRect(
                Rect.fromPoints(element.startPoint!, element.endPoint!),
                paint2);
            break;
          default:
            break;
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class LastOperation {
  final String type;
  final DrawableElement element;

  LastOperation({required this.type, required this.element});
}
