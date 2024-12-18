import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;

class NotificationService {
  static Future<void> subscribeToTopic() async {
    await FirebaseMessaging.instance.subscribeToTopic('all');
    print("User subscribed to topic: all");
  }

  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "tiny-tales-1dc40",
      "private_key_id": "371ecc45ecb001fe1bea8716af919116f68087fc",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCpLz5gfOoP3nZR\nVyfahrBzzZcpFLLVZHvXElicFH6YXoYc2O1uyDMVvbSuLGqeHm2bu+vytS75ZpgQ\nk0wXWEG9S7SxC82yte9OzldNmwKgGrKtshMR22CoSsqgUXzfSW+f3c7R+7E72nnN\ngqJAl95y9brCSuShY/P+YWbweQOxvXl6CumeS+WvllHnsAqVnAqNFIC7XHjat/9D\n9WG0SYe+asPwL9IMdS1NLisfi8XewKParJMw9uzcsNz0NZBHLZgvHHuqlpqme+Gn\nViYi5zh5XA18CD91jiVOor/3pXmzQ5CFkMOkdPtlSi1PPUE6i3LLq5rjfqCV6uI5\n4hthid+VAgMBAAECggEAJ0H4bCzIJkcFdvHtpEJJOxHbb9Om/Ke8qccOyybhSkty\nvMpka+amHfcfcCQL2GVwoyi7wx2iSQpyojP/vdIDrSBeTQ/TWxLm9Qch0Hb16L9R\nM0dlL+lTGDIEqydFfc19SqAOQADymxQi29pienETE+Nrwu5cd4upQB+LYqT+A7W2\nWZpVmvqEKzQ1kgmAfencftf+8KfOcFFExeviT3ptEdLmdIo9iLf9sYh9MOISl1vI\n8yR9dHOkM4vwY6fEJDYzC40qE5OGA/QX1faaubwyP/jcDH0b811SsSyH/7VG7KXN\nqQDfFwCAFAMBy3HINykga6XMqqOkwtYPKFohYkGPwQKBgQDUqiwbHrW3xPKsZ+Kq\nGX+0pPZ8nvnvpEUMt5eh/I8u5YXIaBpZQ5cWCnez/ZbVTXE4Tv5UF5pdHT3yWmql\nzhKX1B45hvlZeE1YBCPBreV6RzrfurJ9Z+SQzqkZtv0jK3fquv+X5kEnyELaU0E8\nK16jNlfNlgpi/E4u0zfJEigvwQKBgQDLqORjSQm4xd8YedzhbljbCRl8tBS+f7Yt\nUSu1vMYvUDkrVTu2oBQB9w/CCKeq42l/0tBln/Tw5OXsdqps5CfyWXdX/WqD4bCs\nPS3cYapv/pcZ4HETmAebGVJKYXq4OnBn7NLqL08gPNmSiKT9NhtDof/s000Ah9Ni\n6iOJGCMk1QKBgQC+Y1r5LJUi4H8hOiACiLF71/OTvf+kOzxWFkb6DlFhero6oHh2\nUbyBTv27ddwDOkGSV6X5Qug/VF6RCcFQjxy2MICen+e74afclFgunLBEuGBMy6ff\n/ZLy0REypFAbnF7PFnqcUtch9ndjXgWZCHrBQ3V36EuEMr0Lzqyypj60AQKBgDjX\nG18GfHsgZqKbKGWWeaAwSve9/ugoFr1RIUToudtspXgNosvWo57kyHYcGkecjs5J\nFTa3zRIKoI09lVUs3GVMSP260aabL8bykEEo1PvK73seZBDW5pCIIap2yFxwmvy2\nYStRJuFVelfmYT32gud+aEI9uwkB36KEvIQ/w1c9AoGAfLX/DTKzX2kepvXDSGm/\nesFoCZ5Jg0YmUHMAHPu4E+g9EkqrrcJqFr36aSpjQ7x09V7dJvp8tXFt0zkzlSuS\nzZ/ZH/BMLAShgP3oZJI2cT9/evS97V0q1vxqfNb6eCZtN4iZr7Fh/5C5ZXFNzsQH\nrJNV/47edz6LfnhKH7Sx5U4=\n-----END PRIVATE KEY-----\n",
      "client_email": "testing@tiny-tales-1dc40.iam.gserviceaccount.com",
      "client_id": "104415038964717414665",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/testing%40tiny-tales-1dc40.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };
    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];
    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );
    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client);
    client.close();
    return credentials.accessToken.data;
  }

  static Future<void> sendNotification(
      String deviceToken, String title, String body) async {
    final String accessToken = await getAccessToken();
    String endpointFCM =
        'https://fcm.googleapis.com/v1/projects/tiny-tales-1dc40/messages:send';
    final Map<String, dynamic> message = {
      "message": {
        "token": deviceToken,
        "notification": {"title": title, "body": body},
        "data": {
          "route": "serviceScreen",
        }
      }
    };

    final http.Response response = await http.post(
      Uri.parse(endpointFCM),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully blabla');
    } else {
      print('Failed to send notification');
    }
  }

// دالة إرسال إشعار إلى جميع المستخدمين
  static Future<void> sendNotificationToAll(String title, String body) async {
    final String accessToken = await getAccessToken();
    final String endpointFCM =
        'https://fcm.googleapis.com/v1/projects/tiny-tales-1dc40/messages:send';

    // رسالة FCM إلى الموضوع "/topics/all"
    final Map<String, dynamic> message = {
      "message": {
        "topic": "all", // إرسال لجميع المستخدمين المشتركين
        "notification": {
          "title": title,
          "body": body,
        },
        "data": {
          "route": "serviceScreen",
        },
      }
    };

    // إرسال الطلب إلى Firebase
    final http.Response response = await http.post(
      Uri.parse(endpointFCM),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(message),
    );

    // التحقق من الاستجابة
    if (response.statusCode == 200) {
      print('Notification sent successfully to all ✅');
    } else {
      print('Failed to send notification ❌: ${response.body}');
    }
  }
}
