import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/api/api.dart';
import 'package:flutter_application_1/api/info.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/helper/myDate.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/models/message.dart';
import 'package:flutter_application_1/models/userChat.dart';
import 'package:flutter_application_1/widgets/message_card.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();
  // showEmoji -- for storing value of showing or hiding emoji
  // isUploading -- for checking if image is uploading or not?
  bool _showEmoji = false, _isUploading = false;
  List<Message> _list = [];

  @override
  void initState() {
    super.initState();
    APIS.getFirebaseMessagingToken();

    APIS.getSelfInfo();

    // for updating user active status according to lifecycle events
    // resume -- active or online
    // pause  -- inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (APIS.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          // APIS.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          // APIS.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            if (_showEmoji) {
              setState(() => _showEmoji = !_showEmoji);
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            backgroundColor: offwhite,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: ourPink,
              flexibleSpace: _appBar(),
            ),
            body: Column(
              children: [
                // chat messages here
                Expanded(
                  child: StreamBuilder(
                    stream: APIS.getAllMessages(widget.user),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        // if data is loading
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const SizedBox();

                        // if some or all data is loaded then show it
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => Message.fromJson(e.data()))
                                  .toList() ??
                              [];

                          if (_list.isNotEmpty) {
                            return ListView.builder(
                              reverse: true,
                              itemCount: _list.length,
                              padding: EdgeInsets.only(top: mq.height * .01),
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return MessageCard(message: _list[index]);
                              },
                            );
                          } else {
                            return const Center(
                              child: Text('Say Hii! 👋',
                                  style: TextStyle(fontSize: 20)),
                            );
                          }
                      }
                    },
                  ),
                ),

                _chatInput(), // Chat input widget
                if (_showEmoji)
                  SizedBox(
                    height: mq.height * 0.35,
                    child: EmojiPicker(
                      textEditingController: _textController,
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
      onTap: () {},
      child: StreamBuilder(
        stream: APIS.getUserInfo(widget.user),
        builder: (context, snapshot) {
          final data = snapshot.data?.docs;
          final list =
              data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

          return Row(
            children: [
              // back button
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),

              // user profile picture
              ClipRRect(
                borderRadius: BorderRadius.circular(mq.width * 0.03),
                // Add user profile picture here
              ),

              // for adding some space
              const SizedBox(width: 10),

              // user name & last seen time
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // user name
                  FutureBuilder<String>(
                    future: getUserFullName(widget
                        .user.email), // استدعاء الدالة غير المتزامنة لجلب الاسم
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
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
                            color: Colors.white,
                          ),
                        );
                      } else {
                        // إذا لم يكن هناك بيانات (حالة غير متوقعة)
                        return const Text(
                          'Name not available',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        );
                      }
                    },
                  ),

                  // for adding some space
                  const SizedBox(height: 2),

                  // last seen time of user
                  Text(
                    list.isNotEmpty
                        ? list[0].isOnline
                            ? 'Online'
                            : MyDateUtil.getLastActiveTime(
                                context: context,
                                lastActive: list[0].lastActive,
                              )
                        : MyDateUtil.getLastActiveTime(
                            context: context,
                            lastActive: widget.user.lastActive,
                          ),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: mq.height * 0.01,
        horizontal: mq.width * 0.025,
      ),
      child: Row(
        children: [
          // input field & buttons
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  // emoji button
                  IconButton(
                    onPressed: () {
                      setState(() {
                        FocusScope.of(context).unfocus();
                        _showEmoji = !_showEmoji;
                      });
                    },
                    icon: const Icon(Icons.emoji_emotions,
                        color: ourBlue, size: 20),
                  ),

                  Expanded(
                    child: TextField(
                      onTap: () {
                        setState(() {
                          _showEmoji = false;
                        });
                      },
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Type ...',
                        hintStyle: TextStyle(color: ourBlue),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  //pick image from gallery button
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Picking multiple images
                        final List<XFile> images =
                            await picker.pickMultiImage(imageQuality: 70);

                        // uploading & sending image one by one
                        for (var i in images) {
                          setState(() => _isUploading = true);
                          await APIS.sendChatImage(widget.user, File(i.path));
                          setState(() => _isUploading = false);
                        }
                      },
                      icon: const Icon(Icons.image,
                          color: Colors.blueAccent, size: 26)),

                  // take image from camera button
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();

                      // Pick an image
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 70,
                      );
                      if (image != null) {
                        setState(() => _isUploading = true);

                        await APIS.sendChatImage(
                          widget.user,
                          File(image.path),
                        );
                        setState(() => _isUploading = false);
                      }
                    },
                    icon: const Icon(Icons.camera_alt_rounded,
                        color: Colors.blueAccent, size: 26),
                  ),

                  // adding some space
                  SizedBox(width: mq.width * .02),
                ],
              ),
            ),
          ),

          // send message button
          MaterialButton(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                APIS.sendMessage(widget.user, _textController.text, Type.text);
                _textController.text = "";
              }
            },
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: const CircleBorder(),
            color: ourBlue,
            child: const Icon(Icons.send, color: Colors.white, size: 25),
          ),
        ],
      ),
    );
  }
}
