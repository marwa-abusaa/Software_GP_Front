import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_application_1/config.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdf/pdf.dart'; // الحزمة لمعالجة PDF

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String title;
  final String author;

  PdfViewerScreen({required this.pdfUrl, required this.title, required this.author});

  @override
  _PdfViewerScreenState createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  File? _localFile;
  bool _isDownloading = true;
  bool isAudio=true;
  late String author=widget.author;

  /// قائمة مسارات الملفات الصوتية
  // final List<String> audioPaths = [
  //   "/storage/emulated/0/Android/data/com.example.flutter_application_1/files/audio_1735233394040.aac",
  //   "/storage/emulated/0/Android/data/com.example.flutter_application_1/files/audio_1735232711900.aac",
  // ];

  int currentAudioIndex = 0; // لتتبع التسجيل الصوتي الحالي
  FlutterSoundPlayer? _player;
  bool isPlaying = false;


  //return recordes
 Future<List<String>> getAudioRecords(String pdfId) async {
  final response = await http.post(
    Uri.parse(getRecords), // رابط الـ API الخاص بك
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"pdfId": pdfId}), // إرسال pdfId في الـ body
  );

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    if (jsonResponse['status']) {
      final List records = jsonResponse['data'];
      return records.map<String>((record) => record['url'] as String).toList();
    }
  }
  else{
     setState(() {
       isAudio=false;
     });
  }
  throw Exception('Failed to load audio records');
}


List<String> audioPaths = [];



Future<void> fetchAudioRecords() async {
  try {
    final records = await getAudioRecords(widget.pdfUrl); // Pass the desired pdfId
    setState(() {
      audioPaths = records;
    });
  } catch (e) {
    print('Error fetching audio records: $e');
  }
}



  // للتحكم في عرض ملف PDF
  final PdfViewerController _pdfViewerController = PdfViewerController();

Future<void> _playRecording() async {
  if(!isAudio){    
   ScaffoldMessenger.of(context).showSnackBar(
     const SnackBar(content: Text('No audio for this story!'),backgroundColor: Colors.red,),
    ); 
  }
  // إذا انتهت جميع التسجيلات وأيقونة التشغيل ظاهرة
  if (currentAudioIndex >= audioPaths.length && !isPlaying) {
    setState(() {
      currentAudioIndex = 0; // إعادة تعيين الفهرس إلى أول تسجيل
    });
  }

  if (currentAudioIndex < audioPaths.length) {
    final audioPath = audioPaths[currentAudioIndex];
    await _player!.startPlayer(
      fromURI: audioPath,
      whenFinished: () {
        if (currentAudioIndex + 1 < audioPaths.length) {
          setState(() {
            currentAudioIndex++;
            _pdfViewerController.jumpToPage(currentAudioIndex + 1); // الانتقال للصفحة التالية
          });
          _playRecording(); // تشغيل التسجيل التالي
        } else {
          setState(() {
            isPlaying = false; // تحويل الأيقونة إلى Play عند الانتهاء من آخر تسجيل
            currentAudioIndex = 0; 
          });
        }
      },
    );

    setState(() {
      isPlaying = true; // الأيقونة تبقى Pause أثناء التشغيل
    });
  }
}



  Future<void> _stopPlayback() async {
    await _player!.stopPlayer();
    setState(() {
      isPlaying = false;
    });
  }

  @override
  void dispose() {
    _player!.closePlayer();
    _pdfViewerController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    print(">>>>>>>>>>>>>>>" + widget.pdfUrl);
    _downloadAndProcessPdf();
    _player = FlutterSoundPlayer();
    _player!.openPlayer();
    fetchAudioRecords();
  
  }

  // دالة لتحميل الملف وحفظه مؤقتًا
  Future<void> _downloadAndProcessPdf() async {
    try {
      // تحميل الملف
      final tempDir = await getTemporaryDirectory();
      final originalFilePath = '${tempDir.path}/original.pdf';
      final processedFilePath = '${tempDir.path}/watermarked.pdf';

      // تنزيل الملف
      await Dio().download(widget.pdfUrl, originalFilePath);

      // إضافة العلامة المائية
      await _addWatermarkToPdf(originalFilePath, processedFilePath);

      setState(() {
        _localFile = File(processedFilePath);
        _isDownloading = false;
      });
    } catch (e) {
      print("Error processing PDF: $e");
      setState(() {
        _isDownloading = false;
      });
    }
  }

    Future<void> _addWatermarkToPdf(String inputPath, String outputPath) async {
    // تحميل ملف PDF
    final fileBytes = File(inputPath).readAsBytesSync();
    final PdfDocument document = PdfDocument(inputBytes: fileBytes);

    // إضافة العلامة المائية لكل صفحة
    for (int i = 0; i < document.pages.count; i++) {
      final PdfPage page = document.pages[i];
      final Size pageSize = page.getClientSize();

      // إعداد نص العلامة المائية
      final PdfGraphics graphics = page.graphics;
      graphics.save();
      graphics.drawString(
        'TinyTales - $author', // Watermark text
        PdfStandardFont(PdfFontFamily.helvetica, 14), // Adjusted font size
        bounds: Rect.fromLTWH(
            0,
            pageSize.height - 38, // Positioned near the bottom
            pageSize.width,
            50),
        brush:
            PdfSolidBrush(PdfColor(128, 128, 128, 50)), // Gray with low opacity
        format: PdfStringFormat(
          alignment: PdfTextAlignment.center, // Centered horizontally
          lineAlignment: PdfVerticalAlignment.middle, // Vertically aligned
        ),
      );

      graphics.restore();
    }

    // حفظ الملف مع العلامة المائية
    final List<int> bytes = document.saveSync();
    File(outputPath).writeAsBytesSync(bytes);
    document.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Text(widget.title),
  actions: [
    Row(
      children: [
           Transform.translate(
            offset: Offset(9, 0),
             child: const Text(
                       'Listen to story',
                       style: TextStyle(
              color: Colors.black, // تغيير اللون إذا كنت بحاجة لذلك
                       ),
                     ),
           ),
        IconButton(
          icon: Icon(isPlaying ? Icons.pause : Icons.volume_up),
          onPressed: isPlaying ? _stopPlayback : _playRecording,
        ),     
      ],
    ),
  ],
),

      body: _isDownloading
          ? const Center(
              child: CircularProgressIndicator(),
            ) // عرض مؤشر تحميل أثناء التنزيل
          : _localFile != null
              ? SfPdfViewer.file(
                  _localFile!,
                  controller: _pdfViewerController,
                ) // عرض الـ PDF بعد تحميله
              : const Center(child: Text("فشل تحميل الملف")),
    );
  }
}