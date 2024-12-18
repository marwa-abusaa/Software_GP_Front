import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:page_flip/page_flip.dart';

class PDFPageFlip extends StatefulWidget {
  final String pdfPath;

  const PDFPageFlip({Key? key, required this.pdfPath}) : super(key: key);

  @override
  State<PDFPageFlip> createState() => _PDFPageFlipState();
}

class _PDFPageFlipState extends State<PDFPageFlip> {
  late PdfDocument pdfDocument;
  List<PdfPageImage?> pdfPages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPdfPages();
  }

  Future<void> _loadPdfPages() async {
    try {
      pdfDocument = await PdfDocument.openFile(widget.pdfPath);
      final List<PdfPageImage?> pages = [];

      // تحميل الصفحات بشكل تدريجي
      for (int i = 1; i <= pdfDocument.pagesCount; i++) {
        final page = await pdfDocument.getPage(i);
        final pageImage = await page.render(
          width: page.width,
          height: page.height,
        );
        pages.add(pageImage);
        await page.close();
      }

      // التأكد من أن الصفحات تم تحميلها بشكل صحيح
      setState(() {
        pdfPages = pages;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading PDF: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Flipbook'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pdfPages.isEmpty
              ? const Center(child: Text('No Pages Available'))
              : PageFlipWidget(
                  backgroundColor: Colors.white,
                  children: pdfPages
                      .map((pageImage) =>
                          Image.memory(pageImage!.bytes, fit: BoxFit.contain))
                      .toList(),
                ),
    );
  }
}
