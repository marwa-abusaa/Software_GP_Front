import 'package:flutter/material.dart';

class TutorialPage extends StatefulWidget {
  @override
  _TutorialPageState createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  bool _tutorialCompleted = false;
  int _currentStep = 0; // لتمثيل الخطوات الحالية في التتوريال
  List<String> tutorialTexts = [
    'اضغط هنا لفتح الشريط الجانبي',
    'استخدم هذا الزر للتراجع عن آخر عملية',
    'استخدم هذا الزر لإعادة العملية التي تم التراجع عنها',
    'احذف الصفحة الحالية باستخدام هذا الزر',
    'أضف صفحة جديدة باستخدام هذا الزر',
  ];

  // دالة لتخطي التتوريال
  void _skipTutorial() {
    setState(() {
      _tutorialCompleted = true;
    });
  }

  // دالة للانتقال للخطوة التالية
  void _nextStepTutorial() {
    setState(() {
      if (_currentStep < tutorialTexts.length - 1) {
        _currentStep++;
      } else {
        _tutorialCompleted = true;
      }
    });
  }

  // دالة لبدء التتوريال
  void _startTutorial() {
    setState(() {
      _tutorialCompleted = false;
      _currentStep = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tutorial Example')),
      body: Stack(
        children: [
          // محتوى الصفحة الأصلية
          Column(
            children: [
              // زر فتح الشريط الجانبي
              Positioned(
                left: 10,
                top: 10,
                child: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {},
                ),
              ),
              // باقي أزرار الصفحة (تراجع، إعادة، حذف، إضافة صفحة)
            ],
          ),

          // إضافة التتوريال إذا لم يكتمل
          if (!_tutorialCompleted)
            Positioned(
              top: 50,
              left: 20,
              child: Container(
                color: Colors.black.withOpacity(0.7),
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tutorialTexts[_currentStep],
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _skipTutorial,
                          child: Text('تخطي'),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _nextStepTutorial,
                          child: Text('التالي'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 100, // حدد العرض الذي تريده هنا
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.undo),
                  onPressed: () {
                    // التراجع عن آخر عملية
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.redo),
                  onPressed: () {
                    // إعادة العملية
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    // دالة التأكيد للحذف
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    // حذف الصفحة
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    // إضافة صفحة جديدة
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
