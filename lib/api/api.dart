import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_application_1/models/message.dart';
import 'package:flutter_application_1/models/userChat.dart';
import 'dart:developer';

class APIS {
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // for accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  // to return current user
  static User? get user => auth.currentUser;

  // Global variable to store the email
  static String? currentEmail;

  // Global variable to store the email
  static String mySuperEmail = "";

  // for getting firebase messaging token
  static Future<String> getFirebaseMessagingToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request notification permission from the user
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Check the permission status
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');

      // If permission is granted, get the FCM token
      await messaging.getToken().then((t) {
        if (t != null) {
          me.pushToken = t;
          print('Push Token: $t');
          //for setting user status to active
          return t;
        }
        return "";
      });
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
      return "";
    } else {
      print('User declined or has not accepted permission');
      return "";
    }
    return "";
  }

// for creating a new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    // Extract the part of the email before '@'
    String email = currentEmail.toString();
    final nameFromEmail = email.split('@')[0];

    // Check if displayName is null and use the name from the email before '@'
    final displayName = user?.displayName ?? nameFromEmail;

    final chatUser = ChatUser(
      id: user!.uid,
      name: displayName,
      email: currentEmail.toString(),
      about: "Hey, I'm using We Chat!",
      image: user?.photoURL ?? "", // Handle null photoURL
      createdAt: time,
      isOnline: false,
      lastActive: time,
      pushToken: '',
    );

    return await firestore
        .collection('users')
        .doc(currentEmail)
        .set(chatUser.toJson());
  }

  // Method to set the current email globally
  static void initializeEmail(String email) {
    currentEmail = email;
  }

  static void initializeSuperEmail(String superEmail) {
    mySuperEmail = superEmail;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection('users')
        .where('email', isNotEqualTo: null) // Exclude documents with null email
        .snapshots();
  }

////خليطة بليطة
  ///
//

  // for storing self information
  static ChatUser me = ChatUser(
      id: user!.uid,
      name: "user.displayName.toString()",
      email: currentEmail.toString(),
      about: "Hey, I'm using We Chat!",
      image: "user.photoURL.toString()",
      createdAt: '',
      isOnline: false,
      lastActive: '',
      pushToken: '');
  // for checking if user exists or not?
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user!.uid).get()).exists;
  }

  // for adding an chat user for our conversation
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    log('data: ${data.docs}');

    if (data.docs.isNotEmpty && data.docs.first.id != currentEmail) {
      //user exists

      log('user exists: ${data.docs.first.data()}');

      firestore
          .collection('users')
          .doc(user!.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});

      return true;
    } else {
      //user doesn't exists

      return false;
    }
  }

  // for getting current user info
  static Future<void> getSelfInfo() async {
    print("User Id " + user!.uid);
    await firestore
        .collection('users')
        .doc(user!.email)
        .get()
        .then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);

        await getFirebaseMessagingToken();

        print('My Data: ${user.data()}');
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  // for getting id's of known users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection('users')
        .doc(user!.uid)
        .collection('my_users')
        .snapshots();
  }

  // for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  // update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    print("I am in the update function ");
    try {
      await firestore.collection('users').doc(user!.email).update({
        'is_online': isOnline,
        'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
        'push_token': me.pushToken,
      });
      print('User info updated successfully');
    } catch (e) {
      print('Failed to update user info: $e');
      if (e.toString().contains('RESOURCE_EXHAUSTED')) {
        print('Firestore quota exceeded. Retrying...');
        // Retry logic
        Future.delayed(
            Duration(seconds: 5), () => updateActiveStatus(isOnline));
      }
    }
  }

  // chat related

  static String getConversationID(String id) =>
      user!.email.hashCode <= id.hashCode
          ? '${user!.uid}_$id'
          : '${id}_${user!.uid}';

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // for sending message
  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    //message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //message to send
    final Message message = Message(
        toId: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        fromId: user!.uid,
        sent: time);

    final ref = firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages/');

    await ref.doc(time).set(message.toJson());
    //await ref.doc(time).set(message.toJson()).then((value) =>
    //   sendPushNotification(chatUser, type == Type.text ? msg : 'image'));
  }

// for adding an user to my user when first message is send
  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user!.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }

  //update read status of message
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  //get only last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

//send chat image
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {});

    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }
}
