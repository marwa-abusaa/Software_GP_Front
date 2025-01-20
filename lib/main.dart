import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/api/api.dart';
import 'package:flutter_application_1/api/notification_services.dart';
import 'package:flutter_application_1/screens/admin/homePage.dart';
import 'package:flutter_application_1/screens/books/addBookPage.dart';
import 'package:flutter_application_1/screens/books/BookDetailsPage.dart';
import 'package:flutter_application_1/screens/login/loading_page.dart';
import 'package:flutter_application_1/screens/login/temp--retrieveCV.dart';
import 'package:flutter_application_1/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

//global object for accessing device screen size
late Size mq;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
// إعدادات إشعارات محلية
var androidInitialize = const AndroidInitializationSettings('app_icon');
var initializationSettings = InitializationSettings(android: androidInitialize);

// تحديث الإشعار ليظهر مباشرة داخل التطبيق عند تلقي رسالة جديدة
void _showNotification(RemoteMessage message) async {
  AndroidNotificationDetails androidPlatformChannelSpecifics =
      const AndroidNotificationDetails(
    'com.yourapp.notifications', // Unique channel ID
    'General Notifications', // Channel name
    channelDescription:
        'Notifications for general updates', // Channel description
    importance: Importance.high,
    priority: Priority.high,
  );
  NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    message.notification?.title,
    message.notification?.body,
    platformChannelSpecifics,
    payload: 'item x', // يمكنك تمرير بيانات إضافية هنا إذا أردت
  );
}

Future<void> setupLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> _firebaseBackgroundMessageHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  if (message.notification != null) {
    // Show local notification for background message
    flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'default_channel',
          'Default Channel',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure binding is initialized
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await _initializeFirebase(); // Initialize Firebase
  APIS.firestore.settings = const Settings(persistenceEnabled: true);
  await setupLocalNotifications();
  // Register the background message handler
  flutterLocalNotificationsPlugin.initialize(initializationSettings);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("Received message in foreground: ${message.notification?.title}");

    // إظهار الإشعار داخل واجهة المستخدم
    if (message.notification != null) {
      // عرض إشعار محلي عند تلقي الرسالة
      _showNotification(message);
    }
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessageHandler);
  String deviceToken =
      "fo0_UbmvQBeTpi6J7rxGac:APA91bELUZqVpqwTtipKZCAu9w_OVmqW6kFxZVpV_ympp2NlD0jyo5qaZLAWKRwWS_ZiAFHrVhk55nqaI5QNV-qFS_gLXcos0v8p_GrvzXcHd8QYKJdYO60MhvWwsSMK2rILiDQmDSbQ";

  try {
    NotificationService.sendNotification(
      deviceToken,
      "Test Notification",
      "This is a test notification from Tiny Tales!",
    );
    print("Notification test completed");
  } catch (e) {
    print("Error while sending notification: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final token;
  const MyApp({
    @required this.token,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size; // Capture screen size
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: lightMode,
      home:
           Loading(), // PdfPageView(pdfPath: 'story_1732381054269.pdf'), // Loading(), //UserProfilePage( email: 'sis@gmail.com',) , //AddBookPage(), //
    );
  }
}

Future<void> _initializeFirebase() async {
  // Change to Future<void>
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
