import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String title;

  PdfViewerScreen({required this.pdfUrl, required this.title});

  @override
  _PdfViewerScreenState createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  File? _localFile;
  bool _isDownloading = true; // لعرض مؤشر التحميل أثناء التنزيل

  @override
  void initState() {
    super.initState();
    print(">>>>>>>>>>>>>>>" + widget.pdfUrl);
    _downloadAndSavePdf();
  }

  // دالة لتحميل الملف وحفظه مؤقتًا
  Future<void> _downloadAndSavePdf() async {
    try {
      // الحصول على المسار المؤقت على الجهاز
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/temp.pdf';

      // تحميل الملف باستخدام Dio
      final response = await Dio().download(widget.pdfUrl, filePath);

      if (response.statusCode == 200) {
        setState(() {
          _localFile = File(filePath);
          _isDownloading = false; // عند اكتمال التحميل
        });
      }
    } catch (e) {
      print("Error downloading PDF: $e");
      setState(() {
        _isDownloading = false; // إيقاف التحميل في حال حدوث خطأ
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _isDownloading
          ? const Center(
              child:
                  CircularProgressIndicator()) // عرض مؤشر تحميل أثناء التنزيل
          : _localFile != null
              ? SfPdfViewer.file(_localFile!) // عرض الـ PDF بعد تحميله
              : const Center(child: Text("فشل تحميل الملف")),
    );
  }
}
