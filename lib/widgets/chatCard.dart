import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/api.dart';
import 'package:flutter_application_1/api/info.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/models/message.dart';
import 'package:flutter_application_1/models/userChat.dart';
import 'package:flutter_application_1/screens/chatting/chat_screen.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.04,
        vertical: 8,
      ),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder(
            stream: APIS.getLastMessage(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
              if (list.isNotEmpty) {
                _message = list[0];
              }

              return Row(
                children: [
                  FutureBuilder<String>(
                    future: fetchUserImage(
                        widget.user.email), // استدعاء الدالة غير المتزامنة
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // أثناء تحميل الصورة، عرض مؤشر تحميل
                        return const ClipOval(
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: ourPink,
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        // إذا حدث خطأ أثناء جلب الصورة
                        return const ClipOval(
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: ourPink,
                            child: Icon(Icons.error,
                                size: 30, color: Colors.white),
                          ),
                        );
                      } else if (snapshot.hasData &&
                          snapshot.data != null &&
                          snapshot.data!.isNotEmpty) {
                        // إذا تم تحميل الصورة بنجاح
                        return ClipOval(
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: ourPink,
                            backgroundImage: NetworkImage(snapshot.data!),
                          ),
                        );
                      } else {
                        // إذا لم تكن هناك صورة
                        return const ClipOval(
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: ourPink,
                            child: Icon(Icons.person,
                                size: 30, color: Colors.white),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<String>(
                          future: getUserFullName(widget.user
                              .email), // استدعاء الدالة غير المتزامنة لجلب الاسم
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              // أثناء تحميل الاسم، عرض مؤشر تحميل
                              return const Text(
                                'Loading...',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black87,
                                ),
                              );
                            } else if (snapshot.hasError) {
                              // إذا حدث خطأ أثناء جلب الاسم
                              return const Text(
                                'Error fetching name',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.red,
                                ),
                              );
                            } else if (snapshot.hasData &&
                                snapshot.data != null &&
                                snapshot.data!.isNotEmpty) {
                              // إذا تم جلب الاسم بنجاح
                              return Text(
                                snapshot.data!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black87,
                                ),
                              );
                            } else {
                              // إذا لم يكن هناك بيانات (حالة غير متوقعة)
                              return const Text(
                                'Name not available',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black54,
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 4),
                        Text(
                            _message != null
                                ? _message!.type == Type.image
                                    ? 'image'
                                    : _message!.msg
                                : widget.user.about,
                            maxLines: 1),
                      ],
                    ),
                  ),
                  Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.shade400,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
