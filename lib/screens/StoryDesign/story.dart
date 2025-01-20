import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter_application_1/config.dart';
import 'package:flutter_application_1/screens/StoryDesign/drafts.dart';
import 'package:flutter_application_1/screens/StoryDesign/draw.dart';
import 'package:flutter_application_1/screens/StoryDesign/storyServices/storyService.dart';
import 'package:flutter_application_1/screens/StoryDesign/generateImageAI.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart'; // استيراد مكتبة اختيار اللون
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_application_1/api/api.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
/////سلة الزبالة والفويس
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:flutter_sound/flutter_sound.dart';
//speech to text
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_application_1/screens/admin/adminservices.dart';

class PageComponent {
  String type; // 'text' or 'image'
  String data; // Text or image path
  Offset position;
  Matrix4
      transformation; // Transformation matrix for scaling, translation, etc.
  TextStyle? style; // Style for text components, optional for images
  PageComponent({
    required this.type,
    required this.data,
    required this.position,
    this.style, // Optional, only used for text components
    Matrix4? initialMatrix, // تأكد من أن المعامل هنا صحيح
  }) : transformation = initialMatrix ??
            Matrix4
                .identity(); // إذا لم يتم تمرير قيمة للتحويل، سيتم استخدام Matrix4.identity()

// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'data': data,
      'position': {'dx': position.dx, 'dy': position.dy},
      'style': style != null
          ? {
              'color': style!.color?.value,
              'fontSize': style!.fontSize,
              'fontWeight':
                  style!.fontWeight == FontWeight.bold ? 'bold' : 'normal',
              'fontStyle':
                  style!.fontStyle == FontStyle.italic ? 'italic' : 'normal',
              'decoration': style!.decoration == TextDecoration.underline
                  ? 'underline'
                  : 'none',
            }
          : null,
    };
  }

  // تحويل من JSON
  factory PageComponent.fromJson(Map<String, dynamic> json) {
    return PageComponent(
      type: json['type'],
      data: json['data'],
      position: Offset(json['position']['dx'], json['position']['dy']),
      style: json['style'] != null
          ? TextStyle(
              color: json['style']['color'] != null
                  ? Color(json['style']['color'])
                  : null,
              fontSize: json['style']['fontSize']?.toDouble(),
              fontWeight: json['style']['fontWeight'] == 'bold'
                  ? FontWeight.bold
                  : FontWeight.normal,
              fontStyle: json['style']['fontStyle'] == 'italic'
                  ? FontStyle.italic
                  : FontStyle.normal,
              decoration: json['style']['decoration'] == 'underline'
                  ? TextDecoration.underline
                  : TextDecoration.none,
            )
          : null,
    );
  }
  @override
  String toString() {
    return 'PageComponent(type: $type, data: $data, position: $position, style: $style)';
  }
}

class PageData {
  List<PageComponent> components = [];
  bool pageConfirmed = false; // لتحديد إذا كانت الصفحة مؤكد عليها
  PageData({this.pageConfirmed = false});

// Overriding the toString method to display real content
  @override
  String toString() {
    return 'PageData(components: $components)';
  }

  // تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'components': components.map((component) => component.toJson()).toList(),
      'pageConfirmed': pageConfirmed,
    };
  }

  // تحويل من JSON
  factory PageData.fromJson(Map<String, dynamic> json) {
    return PageData(
      pageConfirmed: json['pageConfirmed'] ?? false,
    )..components = List<PageComponent>.from(
        json['components']?.map((x) => PageComponent.fromJson(x)) ?? [],
      );
  }
}

// دالة لتحميل المسودة إذا كانت موجودة
Future<List<PageData>> loadDraft(
  Map<String, dynamic> draft, {
  required Function(String title) onTitleLoaded,
  required Function(String backgroundColor) onColorLoaded,
}) async {
  if (draft.isNotEmpty) {
    // إذا كانت المسودة تحتوي على بيانات
    List<dynamic> pagesData =
        draft['pages']; // هنا نأخذ صفحات المسودة من بيانات المسودة

    // تحويل كل عنصر في pagesData إلى كائن PageData
    List<PageData> loadedPages = pagesData
        .map((item) => PageData.fromJson(Map<String, dynamic>.from(item)))
        .toList();

// Load and assign title and background color
    String title =
        draft['title'] ?? "Untitled"; // Default to "Untitled" if no title
    String backgroundColor =
        draft['backgroundColor'] ?? "#FFFFFF"; // Default to white color
    // Call the provided callbacks to assign values
    onTitleLoaded(title);
    onColorLoaded(backgroundColor);

    // طباعة محتوى الـ pages المحملة
    // print("Loaded Pages: $loadedPages");

    return loadedPages;
  } else {
    print("No draft found.");
    return [];
  }
}

class EditorPage extends StatefulWidget {
  final Map<String, dynamic>? draft; // المسودة يمكن أن تكون فارغة أو موجودة

  EditorPage({this.draft}); // في حال لم يتم تمرير مسودة، يمكن أن تكون null
  @override
  _EditorPageState createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage>
    with SingleTickerProviderStateMixin {
  List<PageData> pages = [PageData()];
  int currentPageIndex = 0;
  List<PageComponent> history = [];
  bool isSidebarOpen = false;
  List<PageComponent> redoHistory = [];
  final List<GlobalKey> _pageKeys = [];
  final PageController _pageController = PageController();
  List<Uint8List> capturedImages = []; // لتخزين الصور الملتقطة
  Color _backgroundColor = Colors.white; // اللون الافتراضي للخلفية
  late TabController _tabController;

  Matrix4 matrix = Matrix4.identity(); // Initial transformation matrix
  /// متغيرات للتحكمم بالنص
  Color selectedColor = Colors.black;
  double fontSize = 16.0;
  String fontFamily = 'Arial';
  bool isBold = false;
  bool isItalic = false;
  bool isUnderlined = false;
  String enteredText = "Write your text";

// error check related
  bool _isLoading = false;
  List<Map<String, dynamic>> _errors = [];
  String _result = '';
  final TextEditingController _controller = TextEditingController();

  /// title related
  bool _isEditing = false;
  TextEditingController _titleController = TextEditingController();
  String _bookTitle = 'Book title';

  ////// سلة الزبالة عقولة اية
  late final VoidCallback onDragStart;
  late final VoidCallback onDragEnd;

  bool _showDeleteButton = false;
  bool _isDeleteButtonActive = false;

  ///الفويس
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  bool isRecording = false;
  bool isPlaying = false;
  String? audioPath;
  bool showSaveButton = false;
  late List<String> bookCategories;
  bool isLoading = true; // Track the loading state

  Future<void> initializeCategories() async {
    try {
      // Fetch categories from the database
      bookCategories = await fetchCategories();
    } catch (e) {
      print('Failed to fetch categories: $e');
    } finally {
      setState(() {
        isLoading = false; // Update loading state
      });
    }
  }

  //speech to text
  stt.SpeechToText _speech = stt.SpeechToText();

  // تهيئة speech_to_text
  Future<void> _initSpeech() async {
    bool available = await _speech.initialize();
    if (!available) {
      // عرض رسالة خطأ إذا لم تتوفر الخدمة
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Speech recognition is not available.')),
      );
    }
  }

  void _startListening() {
    _speech.listen(
      onResult: (result) {
        setState(() {
          enteredText = result.recognizedWords;
          _controller.text = result.recognizedWords; // تحديث النص في TextField
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        });
      },
      listenMode: stt.ListenMode.dictation, // ضبط الوضع للاستماع المستمر
    );
    setState(() {
      //_isListening = true;
    });
  }

  //voice for fierbase
  String pdfID = '';

  Future<String> uploadCoverImage(Uint8List image) async {
    try {
      // Define the file path in Firebase Storage
      String fileName =
          'book_covers/${DateTime.now().millisecondsSinceEpoch}.png';

      // Upload the image
      Reference storageRef = APIS.storage.ref(fileName);
      UploadTask uploadTask = storageRef.putData(image);

      // Wait for the upload to complete and get the download URL
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print("Error uploading cover image: $e");
      throw Exception("Failed to upload cover image");
    }
  }

  ///فنكنشات الفويس
  Future<void> _startRecording() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      //final path = 'audio_${DateTime.now().millisecondsSinceEpoch}.aac';
      final directory = await getExternalStorageDirectory();
      final filePath =
          '${directory!.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';
      setState(() {
        audioPath = filePath;
      });

      await _recorder!.startRecorder(toFile: filePath);
      setState(() {
        isRecording = true;
      });

      //   // Upload to Firebase Storage
      // if (audioPath != null) {
      //   final audioUrl = await _uploadAudioToFirebase(audioPath!);
      //   if (audioUrl != null) {
      //     //String pdfId = await _savePdf();
      //     await _saveAudioUrlToMongoDB(audioUrl, pdfID); // Replace "12345" with actual pdfId
      //   }
      // }
    } else {
      // Handle permission denial
    }
  }

  Future<String?> _uploadAudioToFirebase(String filePath) async {
    try {
      final fileName = filePath.split('/').last;
      final ref =
          FirebaseStorage.instance.ref().child('audioRecords/$fileName');
      final uploadTask = ref.putFile(File(filePath));
      final snapshot = await uploadTask;
      final url = await snapshot.ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Error uploading audio: $e');
      return null;
    }
  }

  Future<void> _saveAudioUrlToMongoDB(String audioUrl, String pdfId) async {
    try {
      final response = await http.post(
        Uri.parse(addRecorde), // Replace with your backend URL
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "pdfId": pdfId,
          "url": audioUrl,
        }),
      );

      if (response.statusCode == 201) {
        print('Audio URL saved to MongoDB');
      } else {
        print('Error saving URL to MongoDB: ${response.body}');
      }
    } catch (e) {
      print('Error saving URL to MongoDB: $e');
    }
  }

// Future<void> _stopRecording() async {
//   await _recorder!.stopRecorder();
//   setState(() {
//     isRecording = false;
//   });
// }

  Future<void> _stopRecording() async {
    if (isRecording) {
      try {
        await _recorder!.stopRecorder();
        setState(() {
          isRecording = false;
        });

        if (audioPath != null) {
          print('Recording saved at: $audioPath');
          final audioUrl = await _uploadAudioToFirebase(audioPath!);
          if (audioUrl != null) {
            print('Audio uploaded to Firebase: $audioUrl');
            await _saveAudioUrlToMongoDB(audioUrl, pdfID);
          } else {
            print('Failed to upload audio');
          }
        } else {
          print('Audio path is null');
        }
      } catch (e) {
        print('Error stopping recorder: $e');
      }
    }
  }

  Future<void> _playRecording() async {
    if (audioPath != null) {
      await _player!.startPlayer(fromURI: audioPath);
      setState(() {
        isPlaying = true;
        showSaveButton = true; // إخفاء زر الحفظ أثناء التشغيل
      });
      _player!.onProgress!.listen((e) {
        if (e.position.inMilliseconds >= e.duration.inMilliseconds) {
          setState(() {
            isPlaying = false;
            showSaveButton = true; // إظهار زر الحفظ عند انتهاء التشغيل
          });
        }
      });
    }
  }

  Future<void> _stopPlayback() async {
    await _player!.stopPlayer();
    setState(() {
      isPlaying = false;
      showSaveButton = false;
    });
  }

  ///خلصت فنكشنات الفويس

  ///upload my image to firbase
  //
// Function to pick an image
  File? _selectedImage;
  final picker = ImagePicker();

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      await handleAddImage();
      await fillImageCategories();
      _showSuccessDialog(context);
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
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in all fields and select an image')),
      );
      return;
    }

    final imageUrl = await uploadImage(_selectedImage!);
    if (imageUrl != null) {
      await addImage(imageUrl, EMAIL, "", "");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image')),
      );
    }
  }

  // دالة لإنشاء TextSpan مع الخط تحت الكلمات الخطأ
  List<TextSpan> _buildTextWithErrors(String text) {
    List<TextSpan> textSpans = [];
    int start = 0;

    for (var error in _errors) {
      String word = error['word'];
      int index = text.indexOf(word, start);

      if (index > start) {
        // إضافة النص السليم قبل الكلمة الخطأ
        textSpans.add(TextSpan(
          text: text.substring(start, index),
          style: const TextStyle(color: Colors.black),
        ));
      }

      // إضافة الكلمة الخطأ مع خط تحتها
      textSpans.add(TextSpan(
        text: word,
        style: const TextStyle(
          color: Colors.red,
          decoration: TextDecoration.underline,
        ),
      ));

      start = index + word.length;
    }

    // إضافة النص المتبقي بعد آخر كلمة خطأ
    if (start < text.length) {
      textSpans.add(TextSpan(
        text: text.substring(start),
        style: const TextStyle(color: Colors.black),
      ));
    }

    return textSpans;
  }

  // دالة لاختبار التدقيق الإملائي
  Future<void> _checkForErrors1(String text) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await checkSpelling(text);

      if (response['errors'].isEmpty) {
        setState(() {
          _result = '';
          _errors = [];
        });
      } else {
        setState(() {
          _result = '';
          _errors = List<Map<String, dynamic>>.from(response['errors']);
        });
      }
    } catch (error) {
      setState(() {
        _result = ' ';
        _errors = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // الماب الذي يحتوي على الصور بناءً على الفئات
  final Map<String, List<String>> imageCategories = {
    'My images': [],
    'Characters': [],
    'Professions': [],
    'Nature': [],
    'Animals': [],
    'Actions': [],
    'Religious Images': [],
  };

// دالة لملء الماب من خلال الصور التي تأتي من الـ API
  Future<void> fillImageCategories() async {
    String? email = APIS.currentEmail;
    // استرجاع صور الفئة "صوري" باستخدام البريد الإلكتروني
    List<dynamic>? myImages = await getImagesByEmail(email!);
    if (myImages != null) {
      setState(() {
        imageCategories['My images'] = myImages
            .map((image) => image['url'] as String)
            .toList(); // تأكد أن الصورة تحتوي على الرابط بالاسم المناسب
      });
    } else {
      print('No images found for your category (صوري)');
    }

    // استرجاع الصور لبقية الفئات باستخدام دالة getImagesByCategory
    List<String> categories = [
      'Characters',
      'Professions',
      'Nature',
      'Animals',
      'Actions',
      'Religious Images',
    ];

    for (String category in categories) {
      List<dynamic>? categoryImages = await getImagesByCategory(category);
      if (categoryImages != null) {
        setState(() {
          imageCategories[category] = categoryImages
              .map((image) => image['url'] as String)
              .toList(); // تأكد أن الصورة تحتوي على الرابط بالاسم المناسب
        });
      } else {
        print('No images found for category: $category');
      }
    }

    //printImageCategories(imageCategories);

    print('Image categories populated successfully');
  }

  void printImageCategories(Map<String, List<String>> imageCategories) {
    imageCategories.forEach((category, images) {
      print('Category: $category');
      if (images.isNotEmpty) {
        images.forEach((image) {
          print(' - $image');
        });
      } else {
        print(' - No images available');
      }
      print(''); // Add an empty line for better readability
    });
  }

  Future<String> saveDraft(String userId, List<PageData> pages, String title,
      String backgroundColor) async {
    CollectionReference drafts =
        FirebaseFirestore.instance.collection('drafts');

    // تحويل قائمة الصفحات إلى JSON
    List<Map<String, dynamic>> draftData =
        pages.map((page) => page.toJson()).toList();

    await drafts.add({
      'userId': userId, // إضافة userId للمسودة
      'pages': draftData, // حفظ جميع الصفحات
      'lastModified': Timestamp.now(), // وقت التعديل الأخير
      'backgroundColor': backgroundColor,
      'title': title,
    }).then((value) {
      print("Draft Saved Successfully with ID: ${value.id}");

      _showSuccessDialog(context);
      return value.id;
    }).catchError((error) {
      print("Failed to save draft: $error");
      return " ";
    });
    return " ";
  }

////// send to supervisor
  ///
  Future<void> sendToSuper(BuildContext context) async {
    TextEditingController descriptionController = TextEditingController();

    // Show the dialog to input the description
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal by tapping outside
      builder: (BuildContext context) {
        String selectedCategory =
            bookCategories[0]; // Default category is 'All Categories'

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Sending Story to Supervisor'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Be aware that when you send to supervisor, it will also be saved as a draft and downloaded as a PDF.',
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration:
                          const InputDecoration(hintText: 'Enter description'),
                      maxLines: null,
                    ),
                    const SizedBox(height: 20),
                    const Text('Select Category',
                        style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      value: selectedCategory,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedCategory =
                                newValue; // Update the selected value
                          });
                        }
                      },
                      items: bookCategories
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    String description = descriptionController.text;

                    // Close the dialog
                    Navigator.of(context).pop();

                    // Proceed with sending the story
                    if (description.isNotEmpty) {
                      String draftId = await saveDraft(APIS.user!.uid, pages,
                          _bookTitle, _backgroundColor.toString());

                      String pdfId = await _savePdf();

                      Uint8List coverImage = capturedImages.first;

                      // Upload the cover image to Firebase Storage
                      String coverImageUrl = await uploadCoverImage(coverImage);

                      // Send the book with the description, draftId, and selected category
                      await registerBook(_bookTitle, description, coverImageUrl,
                          pdfId, draftId, APIS.mySuperEmail, selectedCategory);

                      pdfID = pdfId;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Story sent to supervisor!')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Description cannot be empty')),
                      );
                    }
                  },
                  child: const Text('Send'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    /////الفويس
    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();
    _recorder!.openRecorder();
    _player!.openPlayer();

    //speech to text
    _initSpeech();

    fillImageCategories();
    initializeCategories();
    // أضف مفتاحًا للصفحة الأولى عند بدء التطبيق
    if (widget.draft != null) {
      _tabController = TabController(length: 2, vsync: this); // لإنشاء الترويسة
      _titleController.text = _bookTitle;
      _pageKeys.add(GlobalKey());
      loadDraft(
        widget.draft!,
        onTitleLoaded: (title) {
          print("Assigned Title: $title");
          setState(() {
            this._bookTitle = title;
          });
        },
        onColorLoaded: (backgroundColor) {
          print("Assigned Background Color: $backgroundColor");
          // Convert the String to a Color object
          setState(() {
            final colorString =
                backgroundColor.substring(6, backgroundColor.length - 1);
            this._backgroundColor = Color(int.parse(colorString));
          });
        },
      ).then((loadedPages) {
        setState(() {
          pages = loadedPages;
          // إضافة المفاتيح بعد تحميل الصفحات
          if (_pageKeys.length < pages.length) {
            _pageKeys.addAll(List.generate(
                pages.length - _pageKeys.length, (index) => GlobalKey()));
          }
          print("Loaded Pages: $pages");
        });
      });
    } else {
      _pageKeys.add(GlobalKey());
      _tabController = TabController(length: 2, vsync: this); // لإنشاء الترويسة
      _titleController.text = _bookTitle;
    }
  }

  void _changeTextColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Text Color'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: selectedColor,
            onColorChanged: (color) {
              setState(() {
                selectedColor = color;
              });
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }

  TextStyle getTextStyle() {
    return TextStyle(
      color: selectedColor,
      fontSize: fontSize,
      fontFamily: fontFamily,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
      decoration: isUnderlined ? TextDecoration.underline : TextDecoration.none,
    );
  }

  void _changeBackgroundColor() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color tempColor =
            _backgroundColor; // لون مؤقت لتحديث المعاينة داخل نافذة الاختيار
        return AlertDialog(
          title: const Text(" Background Color"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                ColorPicker(
                  pickerColor: _backgroundColor, // اللون الحالي
                  onColorChanged: (color) {
                    tempColor = color; // تحديث اللون المؤقت عند التغيير
                  },
                  showLabel: true,
                  enableAlpha: false, // تعطيل الشفافية
                  pickerAreaHeightPercent: 0.8, // نسبة ارتفاع منطقة الألوان
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _backgroundColor = tempColor; // تحديث اللون الفعلي للخلفية
                });
                Navigator.of(context).pop(); // إغلاق نافذة اختيار اللون
                _toggleSidebar();
              },
              child: const Text("Confirm"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق نافذة اختيار اللون دون حفظ
                _toggleSidebar();
              },
              child: const Text("Cancle"),
            ),
          ],
        );
      },
    );
  }

  // التقاط السكرين شوت للصفحة المؤكدة فقط
  Future<void> _capturePage(int index) async {
    try {
      if (pages.every((page) => !page.pageConfirmed)) {
        // عرض رسالة أو الخروج مباشرة
        print('All pages are not confirmed. Exiting function.');
        return;
      }
      final key = _pageKeys[index];
      final page = pages[index];

      if (!page.pageConfirmed) {
        return; // تخطي الصفحة إذا لم يتم تأكيدها
      }

      if (key.currentContext == null) {
        print('Key at index $index has no context.');
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        RenderRepaintBoundary? boundary =
            key.currentContext!.findRenderObject() as RenderRepaintBoundary?;
        if (boundary == null) {
          print('Render object not found for page at index $index.');
          return;
        }

        var image = await boundary.toImage();
        ByteData? byteData =
            await image.toByteData(format: ImageByteFormat.png);
        if (byteData == null) {
          print(
              'Failed to convert image to ByteData for page at index $index.');
          return;
        }

        Uint8List pngBytes = byteData.buffer.asUint8List();
        setState(() {
          capturedImages.add(pngBytes); // إضافة الصورة الملتقطة
        });
      });
    } catch (e) {
      print('Error capturing page: $e');
    }
  }

  Future<String> _savePdf() async {
    try {
      // التحقق إذا كانت قائمة الصور فارغة
      if (capturedImages.isEmpty) {
        // إظهار نافذة تنبيهية
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Warning'),
              content:
                  const Text('Be sure to confirm pages before saving as PDF.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // إغلاق النافذة
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        return ""; // الخروج من الدالة
      }

      final document = pw.Document();

      // إضافة الصور إلى PDF
      for (var pngBytes in capturedImages) {
        final image = pw.MemoryImage(pngBytes);
        final decodedImage = await decodeImageFromList(pngBytes);

        final imageWidth = decodedImage.width.toDouble();
        final imageHeight = decodedImage.height.toDouble();

        document.addPage(
          pw.Page(
            pageFormat: PdfPageFormat(imageWidth, imageHeight),
            build: (pw.Context context) {
              return pw.Image(image, fit: pw.BoxFit.fill);
            },
          ),
        );
      }

      // حفظ الملف
      final pdfBytes = await document.save();

// Define the Firebase path
      final firebasePath =
          'storybooks/story_${DateTime.now().millisecondsSinceEpoch}.pdf';
      // رفع الـ PDF إلى Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child(firebasePath);
      await storageRef.putData(pdfBytes);

      // الحصول على الرابط المباشر للـ PDF
      final downloadUrl = await storageRef.getDownloadURL();

      // تنزيل الـ PDF إلى جهاز المستخدم
      await _downloadPdf(downloadUrl);

      // عرض نافذة منبثقة بعد حفظ ورفع الـ PDF بنجاح

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Storybook saved, uploaded, and downloaded!')),
      );
      return downloadUrl;
    } catch (e) {
      print('Error saving PDF: $e');
      return "";
    }
  }

  Future<void> _downloadPdf(String url) async {
    try {
      // التحقق من صلاحيات الوصول للمجلدات
      await _requestPermissions();

      // عرض نافذة تحميل
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // تنزيل الملف من الرابط
      final response = await http.get(Uri.parse(url));

      // التحقق إذا كان التحميل ناجحًا
      if (response.statusCode == 200) {
        // الحصول على مسار مجلد التنزيلات
        final directory = Directory('/storage/emulated/0/Download');
        final filePath =
            '${directory.path}/storybook_${DateTime.now().millisecondsSinceEpoch}.pdf';

        // حفظ الملف في مجلد التنزيلات
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // إغلاق نافذة التحميل
        Navigator.of(context).pop();

        // عرض رسالة تأكيد بتنزيل الملف
        Fluttertoast.showToast(
          msg: 'saved successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        // عرض رسالة خطأ إذا فشل التحميل
        Navigator.of(context).pop();
        Fluttertoast.showToast(
          msg: 'error while downloading',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      // معالجة أي أخطاء
      Navigator.of(context).pop();
      Fluttertoast.showToast(
        msg: ' $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

// طلب صلاحيات الوصول إلى الذاكرة
  Future<void> _requestPermissions() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      Fluttertoast.showToast(
        msg: 'يرجى منح التطبيق صلاحية الوصول إلى الذاكرة.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content:
              const Text('The storybook was successfully saved and uploaded!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق النافذة المنبثقة
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // إضافة صفحة جديدة والانتقال إليها
  void _addPage() {
    setState(() {
      pages.insert(currentPageIndex + 1, PageData());
      _pageKeys.insert(currentPageIndex + 1, GlobalKey());
      currentPageIndex = pages.length - 1; // الانتقال مباشرة إلى الصفحة الجديدة
    });
    _pageController.jumpToPage(currentPageIndex);
  }

  void _confirmClearPageContent(BuildContext context) {
    // عرض نافذة تأكيد قبل مسح المحتوى
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
              'Are you sure you want to delete the content of the page?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // إغلاق النافذة بدون مسح المحتوى
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                // مسح المحتوى إذا تم الضغط على "نعم"
                setState(() {
                  pages[currentPageIndex].components.clear();
                  history.clear();
                  redoHistory.clear(); // تنظيف redoHistory عند مسح الصفحة
                });
                Navigator.of(context).pop(); // إغلاق نافذة التأكيد بعد المسح
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  // فتح أو إغلاق الشريط الجانبي
  void _toggleSidebar() {
    setState(() {
      _controller.text = "";
      enteredText = "";
      _result = '';
      _errors = [];
      isSidebarOpen = !isSidebarOpen;
    });
  }

  @override
  void dispose() {
    _tabController.dispose(); // تحرير الموارد
    _pageController.dispose();
    ////الفويس
    _recorder!.closeRecorder();
    _player!.closePlayer();

    super.dispose();
  }

  // الدالة لحفظ العنوان المعدل
  void _saveTitle() {
    setState(() {
      _bookTitle = _titleController.text;
      _isEditing = false; // إيقاف وضع التحرير بعد الحفظ
    });
  }

  // الدالة لتفعيل أو إيقاف وضع التحرير
  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _saveTitle(); // حفظ العنوان عند إيقاف التحرير
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: _isEditing
            ? Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        hintText: 'Title',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.black),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.edit,
                      size: 18, // حجم صغير للأيقونة
                    ),
                    onPressed:
                        _toggleEdit, // الضغط على القلم للتحويل بين التحرير والحفظ
                  ),
                ],
              )
            : Row(
                children: [
                  Text(
                    _bookTitle,
                    style: const TextStyle(color: Colors.black),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.edit,
                      size: 18, // حجم صغير للأيقونة
                    ),
                    onPressed:
                        _toggleEdit, // الضغط على القلم للتحويل بين التحرير والحفظ
                  ),
                ],
              ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) async {
              // يمكنك إضافة الدالة المناسبة بناءً على الخيار المحدد
              if (value == 'savePdf') {
                _savePdf(); // تنفيذ حفظ كـ PDF
              } else if (value == 'saveDraft') {
                saveDraft(
                    APIS.user!.uid,
                    pages,
                    _bookTitle,
                    _backgroundColor
                        .toString()); // حيث أن pages هي قائمة الصفحات في التطبيق

                // _saveDraft(); // تنفيذ حفظ كـ Draft
              } else if (value == 'sendToSupervisor') {
                // _sendToSupervisor(); // تنفيذ إرسال للمشرف
                await sendToSuper(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'savePdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf),
                    SizedBox(width: 8),
                    Text('Save as PDF'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'saveDraft',
                child: Row(
                  children: [
                    Icon(Icons.save_alt),
                    SizedBox(width: 8),
                    Text('Save as Draft'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'sendToSupervisor',
                child: Row(
                  children: [
                    Icon(Icons.send),
                    SizedBox(width: 8),
                    Text('Send to Supervisor'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 20,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      currentPageIndex = index;
                    });
                  },
                  itemCount: pages.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    if (index >= _pageKeys.length) {
                      return const Center(
                          child: Text("Error: Page data not ready"));
                    }
                    return RepaintBoundary(
                      key: _pageKeys[index],
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.73,
                        decoration: BoxDecoration(
                          color:
                              _backgroundColor, // استخدام اللون الذي يتم اختياره
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DragTarget<String>(
                          onAcceptWithDetails: (details) {
                            setState(() {
                              final newComponent = PageComponent(
                                type: details.data.endsWith('.png') ||
                                        details.data.startsWith('https')
                                    ? 'image'
                                    : 'text',
                                data: details.data,
                                style: details.data.endsWith('.png')
                                    ? null
                                    : getTextStyle(),
                                position: Offset(details.offset.dx - 20,
                                    details.offset.dy - kToolbarHeight - 20),
                              );
                              pages[currentPageIndex]
                                  .components
                                  .add(newComponent);
                              history.add(newComponent);
                            });
                          },
                          builder: (context, candidateData, rejectedData) {
                            return Listener(
                              onPointerMove: (event) {
                                //سلة الزبالة

                                if (event.position.dy >
                                    (MediaQuery.of(context).size.height *
                                        0.73)) {
                                  if (!_isDeleteButtonActive) {
                                    setState(() {
                                      _isDeleteButtonActive = true;
                                    });
                                  }
                                } else {
                                  //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('false')));
                                  if (_isDeleteButtonActive) {
                                    setState(() {
                                      _isDeleteButtonActive = false;
                                    });
                                  }
                                }
                              },
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  for (var component
                                      in pages[currentPageIndex].components)
                                    Positioned(
                                      child: MatrixGestureDetector(
                                        onMatrixUpdate: (Matrix4 updatedMatrix,
                                            tm, translation, ___) {
                                          setState(() {
                                            // Update only this component's transformation matrix
                                            component.transformation =
                                                updatedMatrix;
                                          });
                                        },
                                        ////سلة الزبالة
                                        onScaleStart: () {
                                          //onDragStart();
                                          if (!_showDeleteButton) {
                                            setState(() {
                                              _showDeleteButton = true;
                                            });
                                          }
                                        },

                                        onScaleEnd: () {
                                          //onDragEnd();
                                          if (_showDeleteButton) {
                                            setState(() {
                                              _showDeleteButton = false;
                                              if (_isDeleteButtonActive) {
                                                pages[currentPageIndex]
                                                    .components
                                                    .remove(component);
                                                _isDeleteButtonActive = false;
                                                _showDeleteButton = false;
                                              }
                                            });
                                          }
                                        },
                                        child: Transform(
                                          transform: component.transformation,
                                          child: component.type == 'text'
                                              ? Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  height: MediaQuery.of(context)
                                                      .size
                                                      .height,
                                                  child: Align(
                                                    child: Text(
                                                      component.data,
                                                      style: component.style,
                                                    ),
                                                  ),
                                                )
                                              : Image.network(
                                                  component.data,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      1.2,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.73,
                                                  // لضبط كيفية ملء الصورة في المساحة
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                    if (loadingProgress ==
                                                        null) {
                                                      return child; // عرض الصورة إذا انتهى تحميلها
                                                    } else {
                                                      return const Center(
                                                        child:
                                                            CircularProgressIndicator(), // عرض مؤشر تحميل أثناء تحميل الصورة
                                                      );
                                                    }
                                                  },
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return const Icon(
                                                        Icons.broken_image,
                                                        size:
                                                            90); // عرض أيقونة عند حدوث خطأ
                                                  },
                                                ),
                                        ),
                                      ),
                                    ),

                                  ///سلة الزبالة
                                  if (_showDeleteButton)
                                    Positioned(
                                        top: 540,
                                        left: 170,
                                        child: Center(
                                          child: Container(
                                            height: 50,
                                            width: 50,
                                            // decoration: BoxDecoration(
                                            //   color:  Colors.grey,// لون السلة
                                            //   borderRadius: BorderRadius.circular(10),
                                            // ),
                                            child: Center(
                                              child: Icon(
                                                Icons.delete,
                                                color: _isDeleteButtonActive
                                                    ? Colors.red
                                                    : Colors.grey,
                                                size: _isDeleteButtonActive
                                                    ? 45
                                                    : 30,
                                              ),
                                            ),
                                          ),
                                        ))
                                  ////
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          pages[currentPageIndex].pageConfirmed =
                              !pages[currentPageIndex].pageConfirmed;
                        });
                        _capturePage(currentPageIndex); // التقاط السكرين شوت
                      },
                      child: Icon(
                        pages[currentPageIndex].pageConfirmed
                            ? Icons.check_circle
                            : Icons.check_circle_outline,
                        color: pages[currentPageIndex].pageConfirmed
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ),

                    // Left Arrow Button
                    SizedBox(
                      width: 80, // عرض الزر
                      height: 80, // ارتفاع الزر
                      child: IconButton(
                        icon: const Icon(Icons.arrow_left),
                        onPressed: () {
                          if (currentPageIndex > 0) {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      ),
                    ),
                    // Text displaying the current page
                    Text(
                      'Page ${currentPageIndex + 1}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    // Right Arrow Button
                    SizedBox(
                      width: 80, // عرض الزر
                      height: 80, // ارتفاع الزر
                      child: IconButton(
                        icon: const Icon(Icons.arrow_right),
                        onPressed: () {
                          if (currentPageIndex < pages.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // الشريط الجانبي
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus(); // إخفاء لوحة المفاتيح
            },
            child: Stack(
              children: [
                // الشريط الجانبي
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  left: isSidebarOpen
                      ? 0
                      : -MediaQuery.of(context).size.width * 0.75,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    color: Colors.grey[300],
                    child: Column(
                      children: [
                        // الترويسة مع أيقونة تغيير اللون
                        Row(
                          children: [
                            Expanded(
                              child: TabBar(
                                controller: _tabController,
                                labelColor: Colors.black,
                                indicatorColor: Colors.blue,
                                tabs: const [
                                  Tab(text: 'Text'),
                                  Tab(text: 'Images'),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const FaIcon(FontAwesomeIcons.paintRoller),
                              onPressed: _changeBackgroundColor,
                            ),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // محتوى النصوص
                              SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      // إعدادات النص: Bold, Italic, Underline
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ToggleButtons(
                                            isSelected: [
                                              isBold,
                                              isItalic,
                                              isUnderlined
                                            ],
                                            onPressed: (index) {
                                              setState(() {
                                                if (index == 0) {
                                                  isBold = !isBold;
                                                }
                                                if (index == 1) {
                                                  isItalic = !isItalic;
                                                }
                                                if (index == 2) {
                                                  isUnderlined = !isUnderlined;
                                                }
                                              });
                                            },
                                            children: const [
                                              Icon(Icons.format_bold),
                                              Icon(Icons.format_italic),
                                              Icon(Icons.format_underline),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      // إعدادات النص: اللون ونوع الخط
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.color_lens),
                                            onPressed: _changeTextColor,
                                          ),
                                          DropdownButton<String>(
                                            value: fontFamily,
                                            items: [
                                              'Arial',
                                              'Roboto',
                                              'Times New Roman',
                                              'Lato', // مثال لخط من Google Fonts
                                              'Montserrat', //
                                              'Cairo', // خط عربي من Google Fonts

                                              'Droid Arabic Kufi',
                                            ]
                                                .map((font) => DropdownMenuItem(
                                                      value: font,
                                                      child: Text(font),
                                                    ))
                                                .toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                fontFamily = value!;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      // إعدادات النص: حجم النص
                                      Slider(
                                        value: fontSize,
                                        min: 8,
                                        max: 48,
                                        divisions: 8,
                                        label: fontSize.toString(),
                                        onChanged: (value) {
                                          setState(() {
                                            fontSize = value;
                                          });
                                        },
                                      ),
                                      const SizedBox(height: 30),
                                      // حقل النصوص
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Transform.translate(
                                            offset: Offset(240, 0),
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.volume_up,
                                                size: 25,
                                              ),
                                              onPressed: _startListening,
                                            ),
                                          ),
                                          TextField(
                                            controller: _controller,
                                            onChanged: (value) async {
                                              setState(() {
                                                enteredText = _controller.text;
                                                _result =
                                                    ''; // مسح النتيجة السابقة عند التعديل
                                              });
                                              await _checkForErrors1(value);
                                            },
                                            decoration: const InputDecoration(
                                              hintText:
                                                  "Write your text or speak it",
                                              border: OutlineInputBorder(),
                                            ),
                                            style: getTextStyle(),
                                            maxLines: 3,
                                            scrollPhysics:
                                                const BouncingScrollPhysics(),
                                            keyboardType:
                                                TextInputType.multiline,
                                          ),
                                          const SizedBox(height: 16),
                                          // عرض النص مع الخط تحت الكلمات الخطأ
                                          if (_errors.isNotEmpty)
                                            RichText(
                                              text: TextSpan(
                                                children: _buildTextWithErrors(
                                                    _controller.text),
                                              ),
                                            ),
                                          const SizedBox(height: 16),
                                          // عرض الاقتراحات تحت TextField
                                          if (_errors.isNotEmpty)
                                            ..._errors.map((error) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4.0),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      'instead "${error['word']}": ',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      error['suggestions']
                                                          .take(
                                                              2) // عرض أول اقتراحين فقط
                                                          .join(', '),
                                                      style: const TextStyle(
                                                          color: Colors.blue),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                          // إذا لم توجد أخطاء إملائية
                                          if (_result.isNotEmpty)
                                            Text(
                                              _result,
                                              style: const TextStyle(
                                                  color: Colors.green),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),

                                      const SizedBox(height: 20),
                                      // النص الذي يتم سحبه
                                      Draggable(
                                        data: enteredText,
                                        feedback: Material(
                                          child: Text(enteredText,
                                              style: getTextStyle()),
                                        ),
                                        onDragStarted: _toggleSidebar,
                                        child: Text(enteredText,
                                            style: getTextStyle()),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // محتوى الصور
                              SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // أزرار رفع الصور والرسم
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.upload,
                                                size: 30),
                                            onPressed: () {
                                              pickImage();
                                              // منطق رفع الصورة
                                            },
                                          ),
                                          const SizedBox(width: 10),
                                          IconButton(
                                            icon: const Icon(Icons.brush,
                                                size: 30),
                                            onPressed: () {
                                              // منطق الرسم
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        DrawingRoomScreen(
                                                          onImageUploaded:
                                                              fillImageCategories,
                                                        ) // Pass the function reference)
                                                    ),
                                              );
                                            },
                                          ),
                                          const SizedBox(width: 10),
                                          IconButton(
                                            icon: const Icon(Icons.psychology,
                                                size: 30),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        AiTextToImageGenerator(
                                                          onImageUploaded:
                                                              fillImageCategories,
                                                        ) // Pass the function reference)
                                                    ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      // عرض الفئات باستخدام ExpansionTile
                                      ...imageCategories.keys.map((category) {
                                        return ExpansionTile(
                                          title: Text(
                                            category,
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          trailing: const Icon(Icons
                                              .arrow_forward_ios), // السهم بجانب العنوان
                                          children: [
                                            SizedBox(
                                              height:
                                                  300, // صفين من الصور (190 لكل صف)
                                              child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Row(
                                                  children: [
                                                    Column(
                                                      children: [
                                                        // الصف الأول من الصور
                                                        Row(
                                                          children: imageCategories[
                                                                  category]!
                                                              .take(imageCategories[
                                                                          category]!
                                                                      .length ~/
                                                                  2)
                                                              .map((imagePath) {
                                                            bool isMyImage =
                                                                imageCategories[
                                                                            'My images']
                                                                        ?.contains(
                                                                            imagePath) ??
                                                                    false;

                                                            return Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child:
                                                                  GestureDetector(
                                                                onLongPress:
                                                                    isMyImage
                                                                        ? () {
                                                                            // منطق الحذف عند الضغط المطوّل
                                                                            showDialog(
                                                                              context: context,
                                                                              builder: (context) => AlertDialog(
                                                                                title: const Text('Deleting Image'),
                                                                                content: const Text('Are you sure you wnat to delete this image?'),
                                                                                actions: [
                                                                                  TextButton(
                                                                                    onPressed: () async {
                                                                                      await deleteImage(imagePath);
                                                                                      setState(() async {
                                                                                        await fillImageCategories();
                                                                                      });

                                                                                      Navigator.of(context).pop();
                                                                                    },
                                                                                    child: const Text('delete'),
                                                                                  ),
                                                                                  TextButton(
                                                                                    onPressed: () {
                                                                                      Navigator.of(context).pop();
                                                                                    },
                                                                                    child: const Text('cancle'),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            );
                                                                          }
                                                                        : null,
                                                                child:
                                                                    Draggable(
                                                                  onDragStarted:
                                                                      _toggleSidebar,
                                                                  data:
                                                                      imagePath,
                                                                  feedback:
                                                                      Material(
                                                                    child: Image
                                                                        .network(
                                                                      imagePath,
                                                                      width: 90,
                                                                      height:
                                                                          90,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      loadingBuilder: (context,
                                                                          child,
                                                                          loadingProgress) {
                                                                        if (loadingProgress ==
                                                                            null) {
                                                                          return child;
                                                                        } else {
                                                                          return const Center(
                                                                            child:
                                                                                CircularProgressIndicator(),
                                                                          );
                                                                        }
                                                                      },
                                                                      errorBuilder: (context,
                                                                          error,
                                                                          stackTrace) {
                                                                        return const Icon(
                                                                            Icons
                                                                                .broken_image,
                                                                            size:
                                                                                90);
                                                                      },
                                                                    ),
                                                                  ),
                                                                  child: Stack(
                                                                    children: [
                                                                      Image
                                                                          .network(
                                                                        imagePath,
                                                                        width:
                                                                            90,
                                                                        height:
                                                                            90,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        loadingBuilder: (context,
                                                                            child,
                                                                            loadingProgress) {
                                                                          if (loadingProgress ==
                                                                              null) {
                                                                            return child;
                                                                          } else {
                                                                            return const Center(
                                                                              child: CircularProgressIndicator(),
                                                                            );
                                                                          }
                                                                        },
                                                                        errorBuilder: (context,
                                                                            error,
                                                                            stackTrace) {
                                                                          return const Icon(
                                                                              Icons.broken_image,
                                                                              size: 90);
                                                                        },
                                                                      ),
                                                                      // if (isMyImage)
                                                                      //   const Positioned(
                                                                      //     top:
                                                                      //         5,
                                                                      //     right:
                                                                      //         5,
                                                                      //     child: Icon(
                                                                      //         Icons.delete,
                                                                      //         color: Colors.red),
                                                                      //   ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          }).toList(),
                                                        ),
                                                        // الصف الثاني من الصور
                                                        Row(
                                                          children: imageCategories[
                                                                  category]!
                                                              .skip(imageCategories[
                                                                          category]!
                                                                      .length ~/
                                                                  2)
                                                              .map((imagePath) {
                                                            bool isMyImage =
                                                                imageCategories[
                                                                            'My images']
                                                                        ?.contains(
                                                                            imagePath) ??
                                                                    false;

                                                            return Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child:
                                                                  GestureDetector(
                                                                onLongPress:
                                                                    isMyImage
                                                                        ? () {
                                                                            // منطق الحذف عند الضغط المطوّل
                                                                            showDialog(
                                                                              context: context,
                                                                              builder: (context) => AlertDialog(
                                                                                title: const Text('Deleting Image'),
                                                                                content: const Text('Are you sure you wnat to delete this image?'),
                                                                                actions: [
                                                                                  TextButton(
                                                                                    onPressed: () {
                                                                                      deleteImage(imagePath);
                                                                                      setState(() {
                                                                                        fillImageCategories();
                                                                                      });

                                                                                      Navigator.of(context).pop();
                                                                                    },
                                                                                    child: const Text('delete'),
                                                                                  ),
                                                                                  TextButton(
                                                                                    onPressed: () {
                                                                                      Navigator.of(context).pop();
                                                                                    },
                                                                                    child: const Text('cancle'),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            );
                                                                          }
                                                                        : null,
                                                                child:
                                                                    Draggable(
                                                                  onDragStarted:
                                                                      _toggleSidebar,
                                                                  data:
                                                                      imagePath,
                                                                  feedback:
                                                                      Material(
                                                                    child: Image
                                                                        .network(
                                                                      imagePath,
                                                                      width: 90,
                                                                      height:
                                                                          90,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      loadingBuilder: (context,
                                                                          child,
                                                                          loadingProgress) {
                                                                        if (loadingProgress ==
                                                                            null) {
                                                                          return child;
                                                                        } else {
                                                                          return const Center(
                                                                            child:
                                                                                CircularProgressIndicator(),
                                                                          );
                                                                        }
                                                                      },
                                                                      errorBuilder: (context,
                                                                          error,
                                                                          stackTrace) {
                                                                        return const Icon(
                                                                            Icons
                                                                                .broken_image,
                                                                            size:
                                                                                90);
                                                                      },
                                                                    ),
                                                                  ),
                                                                  child: Stack(
                                                                    children: [
                                                                      Image
                                                                          .network(
                                                                        imagePath,
                                                                        width:
                                                                            90,
                                                                        height:
                                                                            90,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        loadingBuilder: (context,
                                                                            child,
                                                                            loadingProgress) {
                                                                          if (loadingProgress ==
                                                                              null) {
                                                                            return child;
                                                                          } else {
                                                                            return const Center(
                                                                              child: CircularProgressIndicator(),
                                                                            );
                                                                          }
                                                                        },
                                                                        errorBuilder: (context,
                                                                            error,
                                                                            stackTrace) {
                                                                          return const Icon(
                                                                              Icons.broken_image,
                                                                              size: 90);
                                                                        },
                                                                      ),
                                                                      // if (isMyImage)
                                                                      //   const Positioned(
                                                                      //     top:
                                                                      //         5,
                                                                      //     right:
                                                                      //         5,
                                                                      //     child: Icon(
                                                                      //         Icons.delete,
                                                                      //         color: Colors.red),
                                                                      //   ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          }).toList(),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // زر فتح الشريط الجانبي
                Positioned(
                  left: -4,
                  top: 10,
                  child: IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: _toggleSidebar,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Container(
            width: 100, // تحديد العرض المطلوب
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Transform.translate(
                  offset: Offset(-10, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: Icon(isRecording ? Icons.stop : Icons.mic),
                        tooltip:
                            isRecording ? 'Stop Recording' : 'Start Recording',
                        onPressed:
                            isRecording ? _stopRecording : _startRecording,
                      ),
                      Transform.translate(
                        offset: Offset(-8, 0),
                        child: IconButton(
                          icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
                          tooltip:
                              isPlaying ? 'Stop Playback' : 'Play Recording',
                          onPressed: isPlaying ? _stopPlayback : _playRecording,
                        ),
                      ),
                      SizedBox(
                        width: 24, // حجز مساحة ثابتة لزر الحفظ
                        child: Visibility(
                          visible: showSaveButton, // التحكم في ظهور الزر
                          child: Transform.translate(
                            offset: Offset(-13, 0),
                            child: IconButton(
                              icon: Icon(Icons.save),
                              tooltip: 'Save Recording',
                              onPressed: () {
                                // Function to save the audio
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Recording saved!')),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.undo),
                  onPressed: () {
                    if (history.isNotEmpty) {
                      setState(() {
                        final lastComponent = history.removeLast();
                        redoHistory
                            .add(lastComponent); // إضافة العنصر إلى redoHistory
                        pages[currentPageIndex]
                            .components
                            .remove(lastComponent);
                      });
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.redo),
                  onPressed: () {
                    if (redoHistory.isNotEmpty) {
                      setState(() {
                        final redoComponent = redoHistory.removeLast();
                        history.add(redoComponent); // إعادة العنصر إلى history
                        pages[currentPageIndex].components.add(redoComponent);
                      });
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _confirmClearPageContent(context); // استدعاء دالة التأكيد
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    if (pages.length > 1) {
                      // عرض نافذة تأكيد قبل الحذف
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text(
                                'Are you sure you want to delete this page?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  // إغلاق النافذة بدون حذف الصفحة
                                  Navigator.of(context).pop();
                                },
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: () {
                                  // حذف الصفحة إذا تم الضغط على "نعم"
                                  setState(() {
                                    pages.removeAt(currentPageIndex);
                                    _pageKeys.removeAt(currentPageIndex);
                                    currentPageIndex = currentPageIndex > 0
                                        ? currentPageIndex - 1
                                        : 0;
                                    redoHistory
                                        .clear(); // تنظيف redoHistory عند حذف صفحة
                                  });
                                  _pageController.jumpToPage(currentPageIndex);
                                  Navigator.of(context)
                                      .pop(); // إغلاق نافذة التأكيد بعد الحذف
                                },
                                child: const Text('Yes'),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Cannot delete the last page!')),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addPage,
                ),
                // داخل كود EditorPage
              ],
            ),
          ),
        ),
      ),
    );
  }
}
