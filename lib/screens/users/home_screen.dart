import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/api.dart';
import 'package:flutter_application_1/api/info.dart';
import 'package:flutter_application_1/api/notification_services.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/screens/StoryDesign/story.dart';
import 'package:flutter_application_1/screens/books/bookMainPage.dart';
import 'package:flutter_application_1/screens/users/contests/contests_screen.dart';
import 'package:flutter_application_1/screens/users/courses_screen.dart';
import 'package:flutter_application_1/widgets/custom_home.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_application_1/config.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final token;
  const HomeScreen({@required this.token, Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String emaill;
  List? itemss;
  int currentIndex = 0;
  List? winners;
  int itemssLength=0;
  double carouseHeight=177;
  late ConfettiController _confettiController;
  List<String> emailsList = [];
  bool _hasShownConfetti = false;

  // التحقق إذا كان قد تم عرض الـ Confetti من قبل
  _checkIfConfettiShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasShownConfetti = prefs.getBool('hasShownConfetti') ?? false; // إذا كانت القيمة غير موجودة، ستكون false
    });
  }
  // تخزين الحالة بعد عرض الـ Confetti
  _setConfettiShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('hasShownConfetti', true); // تخزين أن الـ Confetti قد تم عرضه
  }



  
 Future<String?> _fetchUserProfile(String email) async {
  try {
    // استدعاء الدالة لجلب رابط الصورة
    final profileImageUrl = await fetchUserImage(email);
    return profileImageUrl as String?;
  } catch (e) {
    print('Error fetching profile data: $e');
    return null; // في حال حدوث خطأ، يتم إرجاع null
  }
}



  ///get contest images
 void getContests() async {
  var response = await http.get(
    Uri.parse(getAllContests),
    headers: {"Content-Type": "application/json"},
  );

  if (response.statusCode == 200) {
    var jsonResponse = jsonDecode(response.body);
    itemss = jsonResponse['success'].map((item) {
      item['isExpanded'] = false; // Initialize isExpanded
      
      // تحقق من شرط الانضمام
      if (_isJoinActive(item['submit_date'])) {
        item['isJoined'] = true; // أضف خاصية isJoined إذا تحقق الشرط
      } else {
        item['isJoined'] = false; // قيمة افتراضية إذا لم يتحقق الشرط
      }
      return item;
    }).toList();
    setState(() {});

    // عد العناصر التي تحقق شرط isJoined
    int joinedCount = itemss!.where((item) => item['isJoined'] == true).length;
    itemssLength=joinedCount;
   
    print('Number of joined items: $joinedCount');
  } else {
    print('Error: ${response.statusCode}');
    print('Response: ${response.body}');
  }
}

void getAllWinners() async {
  var response = await http.get(
    Uri.parse(getWinnersss),
    headers: {"Content-Type": "application/json"},
  );

  if (response.statusCode == 200) {
    var jsonResponse = jsonDecode(response.body);
    
    winners = jsonResponse.map((item) {
      item['isExpanded'] = false; // Initialize isExpanded
      return item;
    }).toList();

    emailsList = winners!.map<String>((item) => item['email'] as String).toList();
   
    setState(() {
    checkIfUserIsWinner();
    });

  } else {
    print('Error: ${response.statusCode}');
    print('Response: ${response.body}');
  }
}

   bool _isJoinActive(String finalDateStr,) {
    DateTime finalDate =
        DateFormat('yyyy-MM-dd').parse(finalDateStr); // تأكد من صيغة التاريخ
    DateTime now = DateTime.now();
    print('start = ${finalDate}  now=  ${now}');
    bool isBeforeDeadline;
    isBeforeDeadline = now.isBefore(finalDate);
    print(isBeforeDeadline);
    return isBeforeDeadline; // 
  }

bool _isAfterVoteDeadline(String finalDateStr) {
  DateTime finalDate = DateFormat('yyyy-MM-dd').parse(finalDateStr); // تحويل النص إلى تاريخ
  DateTime now = DateTime.now();

  // حساب الفرق بين التاريخ الحالي وتاريخ التصويت النهائي
  Duration difference = now.difference(finalDate);

  print('Final Date: $finalDate');
  print('Today: $now');
  print('Difference: ${difference.inDays} days');

  // التحقق إذا كان اليوم بعد 1/2/3/4 أيام من تاريخ التصويت
  if (difference.inDays >= 1 && difference.inDays <= 3) {
    print("Today is between 1 and 3 days after the voting deadline.");
    return true;
  }

  // إذا لم يكن التاريخ في النطاق المطلوب
  return false;
}



// دالة للتحقق إذا كان الايميل موجودًا في القائمة
void checkIfUserIsWinner() {
  // فحص إذا كان EMAIL موجود في emailsList
 if (!_hasShownConfetti && emailsList.contains(EMAIL)) {
      _confettiController.play();
      _setConfettiShown(); // تخزين الحالة بعد عرض الـ Confetti
      showTopSnackBar(context, 'Congratulations! You have won! 🎉🎊🏆');

    }
}


   @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

void showTopSnackBar(BuildContext context, String message) {
  OverlayEntry overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: 95.0, // المسافة من أعلى الشاشة
      left: 5.0,
      right: 5.0,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 205, 89), // لون الخلفية
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Center(
            child: Text(
              message,
              style:  GoogleFonts.convergence(
                color: Colors.white, // لون النص
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    ),
  );

  // إضافة الـ Overlay إلى التطبيق
  Overlay.of(context)?.insert(overlayEntry);

  // إزالة الـ Overlay بعد مدة معينة
  Future.delayed(const Duration(seconds: 12), () {
    overlayEntry.remove();
  });
}

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllWinners();
    getContests();
    APIS.getSelfInfo();
    _confettiController = ConfettiController(duration: const Duration(seconds: 10));
    _checkIfConfettiShown();

//    WidgetsBinding.instance.addPostFrameCallback((_) {
//   ScaffoldMessenger.of(context).showSnackBar(
// SnackBar(
//         content: Text('Congratulations! You have won!🎉🎊🏆',style: TextStyle(color: Colors.black),),
//         backgroundColor: orangee,
//         behavior: SnackBarBehavior.floating, // Makes it float above the bottom
//         margin: const EdgeInsets.only(top: 50.0),
//         duration: const Duration(seconds: 10),
//       ),  );
// });

    //APIS.getFirebaseMessagingToken();
    // String deviceToken =
    //     "fo0_UbmvQBeTpi6J7rxGac:APA91bELUZqVpqwTtipKZCAu9w_OVmqW6kFxZVpV_ympp2NlD0jyo5qaZLAWKRwWS_ZiAFHrVhk55nqaI5QNV-qFS_gLXcos0v8p_GrvzXcHd8QYKJdYO60MhvWwsSMK2rILiDQmDSbQ";

    // try {
    //   NotificationService.sendNotification(
    //     deviceToken,
    //     "Test Notification",
    //     "This is a test notification from Tiny Tales!",
    //   );
    //   print("Notification test completed");
    // } catch (e) {
    //   print("Error while sending notification: $e");
    // }
    // NotificationService.sendNotificationToAll("all notification", "test test");
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    emaill = jwtDecodedToken['email'];
    EMAIL = emaill;
    // Fetch the superEmail asynchronously
    fetchSuperEmail(emaill).then((superEmail) {
      if (superEmail != null) {
        APIS.initializeSuperEmail(superEmail);
        print("Super email is<<<< $superEmail >>>>");
      } else {
        print("Failed to fetch superEmail.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomHomePage(
      emaill: emaill,
      //backgroundColor: offwhite,
      body: Column(children: [
        //const SizedBox(height: 1,),
            ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive, // يحدد الاتجاه
            emissionFrequency: 0.05, // تكرار الانفجارات
            numberOfParticles: 30, // عدد الجسيمات
            gravity: 0.1, // تأثير الجاذبية
          ),
        Expanded(
          flex: 0,
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  // Navigate to another screen when the image is tapped
                  print("tapppped");
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: ourPink, // Set the border color
                      width: 2, // Set the border width
                    ),
                    borderRadius: BorderRadius.circular(
                        12), // Optional: Set rounded corners
                  ),
                  

              child: Stack(
                children: [
                  Column(
                    children: [                    
                      Opacity(
                        opacity: 0.6, // Set the opacity value here (0.0 to 1.0)
                        child: Image.asset(
                          'assets/images/advert.png', // Replace with the path to your image
                          width: double.infinity,
                          height: 210,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 185,
                    right: 0,
                    child: SizedBox(
                      width: 150, // Set the desired width
                      height: 25, // Set the desired height
                      child: ElevatedButton(
                        onPressed: () {             
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ContestsScreen(
                                token: TOKEN,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: orangee, // Background color
                          textStyle: const TextStyle(
                            fontSize: 10, // Set font size
                            fontWeight: FontWeight.bold, // Set font weight
                            fontStyle: FontStyle.italic, // Set font style
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12), // Set border radius
                          ),
                          padding: EdgeInsets.zero, // Remove padding
                        ),
                        child:  Row(
                          mainAxisAlignment: MainAxisAlignment.center, // Center the contents
                          children: [
                             const Text(
                              'Go to contests',
                              style: TextStyle(color: ourPink,fontSize: 13),
                            ),
                            Transform.translate(
                              offset: Offset(7, 0),
                              child: const Icon(
                                Icons.arrow_forward, // Change this to your desired arrow icon
                                color: ourPink, // Icon color
                                size: 18, // Adjust the size as needed
                              ),
                            ),
                           
                          ],
                        ),
                      ),
                    ),
                  ),
                   Positioned(
                    top: 188,
                    left: 3,
                    child: SizedBox(
                      width: 120, // Set the desired width
                      height: 20, // Set the desired height
                      child: ElevatedButton(
                        onPressed: () { },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: orangee, // Background color
                          textStyle: const TextStyle(
                            fontSize: 10, // Set font size
                            fontWeight: FontWeight.bold, // Set font weight
                            fontStyle: FontStyle.italic, // Set font style
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12), // Set border radius
                          ),
                          padding: EdgeInsets.zero, // Remove padding
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center, // Center the contents
                          children: [
                            Transform.translate(
                              offset: Offset(-3, 0),
                              child: const Icon(
                                Icons.event, // Change this to your desired arrow icon
                                color: ourPink, // Icon color
                                size: 18, // Adjust the size as needed
                              ),
                            ),
                            
                              Text(
                          itemss != null && itemss!.isNotEmpty && itemssLength!=0
                              ? itemss!
                                  .where((item) => _isJoinActive(item['submit_date'])) // تصفية العناصر
                                  .toList()[currentIndex]['submit_date'] // الحصول على العنصر الحالي بعد التصفية
                              : 'Loading...',
                          style: const TextStyle(color: ourPink, fontSize: 13),
                        ),

                         
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                 Transform.translate(
  offset: Offset(0, 5),
  child: CarouselSlider(
    options: CarouselOptions(
      height:  carouseHeight, // طول الكاروسيل
      autoPlay: false, // تشغيل تلقائي
      enlargeCenterPage: true, // تأثير تكبير العنصر النشط
      viewportFraction: 1, // لعرض صورة واحدة فقط
      onPageChanged: (index, reason) {
     
         if (itemss != null && index < itemssLength) {
        setState(() {
          currentIndex = index; // تحديث currentIndex بناءً على itemss فقط
          carouseHeight=177;
        });
       }
       else{
        setState(() {
          currentIndex = 0; // تحديث currentIndex بناءً على itemss فقط  
           carouseHeight=203;       
        });
       }
      },
    ),
    items: [
      if (itemss != null)
        ...itemss!
            .where((item) => _isJoinActive(item['submit_date'])) // تصفية العناصر
            .map((item) {
              return Builder(
                builder: (BuildContext context) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12), // زوايا دائرية
                    child: item['imageUrl'] != null
                        ? Image.network(item['imageUrl'], width: 420, fit: BoxFit.cover)
                        : Image.asset('assets/images/contest2.png'),
                  );
                },
              );
            }).toList(),

      if (winners != null && winners!.isNotEmpty )      
  ...winners!.where((winner) => _isAfterVoteDeadline(winner['voting_end_date'])).map((winner) {
    return Builder(
      builder: (BuildContext context) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12), // 
child: Stack(
  children: [
    Center(
      child: SizedBox(
        width: 420, // العرض المطلوب
        height: 440, // الارتفاع المطلوب
        child: Image.asset(
          'assets/images/adv_winner.png',
          fit: BoxFit.cover, // لضبط الصورة مع الحاوية
        ),
      ),
    ),

Transform.translate(
  offset: Offset(242, 125),
  child: Container(
    width: 120, // عرض الحاوية
    height: 60, // ارتفاع الحاوية
    decoration: BoxDecoration(
      color: Colors.transparent, // لون الخلفية
      borderRadius: BorderRadius.circular(8), // زوايا دائرية
    ),
    padding: EdgeInsets.all(3), // مسافة داخلية للنص
    child: AutoSizeText(
     winner['_id'] ?? 'Unknown Winner',
      style:  GoogleFonts.castoro(
        fontSize: 23, // الحجم الافتراضي
        fontWeight: FontWeight.bold,
        color: ourPink,
      ),
      textAlign: TextAlign.center, // توسيط النص
      maxLines: 2, // الحد الأقصى لعدد الأسطر
      overflow: TextOverflow.ellipsis, // لإضافة ... عند تجاوز النص
      minFontSize: 20, // الحد الأدنى لحجم الخط
    ),
  ),
),



    Transform.translate(
  offset: Offset(161, 96),
  child: FutureBuilder<String?>(
    future: fetchUserImage(winner['email']), // استدعاء دالة جلب الصورة
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        // عرض مؤشر انتظار أثناء تحميل الصورة
        return CircleAvatar(
          radius: 34,
          backgroundColor: ourPink,
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        );
      } else if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
        // عرض أيقونة افتراضية إذا حدث خطأ أو لم يتم العثور على الصورة
        return CircleAvatar(
          radius: 33,
          backgroundColor: ourPink,
          child: Icon(Icons.person, size: 34, color: Colors.white),
        );
      } else {
        // عرض الصورة إذا تم تحميلها بنجاح
        return CircleAvatar(
          radius: 34,
          backgroundImage: NetworkImage(snapshot.data!),
          backgroundColor: ourPink, 
        );
      }
    },
  ),
),




   Transform.translate(
  offset: Offset(20, 181),
  child: Container(
    width: 120, // العرض الثابت للحاوية
    height: 20, // الارتفاع الثابت للحاوية
    decoration: BoxDecoration(
      //color: Colors.blue, // لون الخلفية
      borderRadius: BorderRadius.circular(8), // زوايا دائرية
    ),
    alignment: Alignment.center, // توسيط النص داخل الحاوية
    child: Text(
      winner['userName'] ?? 'Unknown User',
      style:  GoogleFonts.montserrat(fontSize: 14, // حجم النص
        fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 231, 170, 48),
          shadows: [
    Shadow(
      offset: Offset(2, 2), // إزاحة الظل أفقيًا وعموديًا
      blurRadius: 4, // مستوى التمويه
      color: const Color(0xFFfff079).withOpacity(0.9), // لون الظل (ذهبي شفاف)
    ),
  ],),     
      textAlign: TextAlign.center, // توسيط النص أفقيًا
    ),
  ),
),


  ],
),


        );
      },
    );
  }).toList(),

    ],
  ),
),


                ],
              ),

                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 15,
        ),

        // Second part - Grid of 4 square buttons
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 20.0,
              mainAxisSpacing: 20.0,
              children: [
                // First Button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BookHomePage()),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFffe4cc),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book, color: ourPink, size: 50),
                        Text('All stories', style: TextStyle(color: ourPink)),
                      ],
                    ),
                  ),
                ),
                // Second Button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CoursesScreen()),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: orangee,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.school, color: ourPink, size: 50),
                        Text('Courses', style: TextStyle(color: ourPink)),
                      ],
                    ),
                  ),
                ),
                // Third Button
                GestureDetector(
                  onTap: () {
                    print("compppp tapped!");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ContestsScreen(
                                token: TOKEN,
                              )),
                    );
                    print(emaill);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: orangee,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.emoji_events, color: ourPink, size: 50),
                        Text('Contests', style: TextStyle(color: ourPink)),
                      ],
                    ),
                  ),
                ),
                // Fourth Button
                GestureDetector(
                  onTap: () {
                    print("Create stroy tapped!");
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditorPage()),
                    );
                    print(emaill);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFffe4cc),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.create, color: ourPink, size: 50),
                        Text('Create story', style: TextStyle(color: ourPink)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        //SizedBox(height: 50,)
      ]),
    );
  }
}
