import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chattingapp/HELPER/date_utility.dart';
import 'package:chattingapp/MODEL/model_user.dart';
import 'package:chattingapp/SCREENS/view_profile_screen.dart';
import 'package:chattingapp/WIDGETS/msg_card.dart';
import 'package:chattingapp/api/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../MODEL/msgmodel.dart';
import '../main.dart';


class ChatScreen extends StatefulWidget {
  final ChatUser user; //Declaring user expected

  const ChatScreen({
    super.key,
    required this.user,
  }); //user parameter added

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //For Storing All Messages
  List<Message> _list = [];

  //For handling msg text changes
  final _textController = TextEditingController();

  //checking if image is Uploading or not
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: _appBar(), //Calling app Bar ftn
        ),
        body: Column(
          children: [
            //Wrapped in expanded to get text field to the bottom
            Expanded(
              //Stream builder used because of real time updates here
              child: StreamBuilder(
                stream: APIs.getAllMsgs(widget.user), //Calling msgs from APIs
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    //IF Data is Loading
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return const SizedBox();

                    //Some or All data is loaded then show it
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
                            padding: EdgeInsets.only(top: mq.height * .01),
                            physics: const BouncingScrollPhysics(),
                            itemCount: _list.length,
                            itemBuilder: (context, index) {
                              //MsgCard Widget
                              return MsgCard(
                                message: _list[index],
                              );
                            });
                      } else {
                        return const Center(
                            child: Text(
                          'Say Hi! 👋',
                          style:
                              TextStyle(fontSize: 24, color: Colors.deepPurple),
                        ));
                      }
                  }
                },
              ),
            ),

            //Progress indicator for showing uploading
            if (_isUploading)
              const Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.deepPurple,
                    ),
                  )),
            _chatInput(), //Calling chat input ftn
          ],
        ),
      ),
    );
  }

  //App Bar Function return type widget
  Widget _appBar() {
    return InkWell(
      //Making AppBar widget area clickable
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context)=> ViewProfileScreen(user: widget.user)));
      },
      child: StreamBuilder(
          stream: APIs.getUserInfo(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

            return Row(
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context); //Back Screen
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    )),

                //User profile pic
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .03),
                    child: CachedNetworkImage(
                      width: mq.height * .05,
                      height: mq.height * .05,
                      fit: BoxFit.cover,
                      imageUrl:
                          list.isNotEmpty ? list[0].image : widget.user.image,
                      errorWidget: (context, url, error) => const CircleAvatar(
                        child: Icon(CupertinoIcons.person),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  //Appbar Name & status alignment settings
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //UserName
                    Text(
                      list.isNotEmpty ? list[0].name : widget.user.name,
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 2,
                    ),

                    //LastSeen of user
                    Text(
                      list.isNotEmpty
                          ? list[0].isOnline
                              ? 'Online'
                              : MyDate.getLastActiveTime(
                                  context: context, lastActive: list[0].lastActive)
                          : MyDate.getLastActiveTime(
                              context: context, lastActive: widget.user.lastActive),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
    );
  }

  //Function ChatInput
  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * .01, horizontal: mq.width * .025),
      child: Row(
        children: [
          //Input fields & buttons
          Expanded(
            //expanded to avoid flex error
            child: Card(
              color: Colors.deepPurple.shade100,
              //Wrap with card to get background
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  IconButton(
                      //Emoji Button
                      onPressed: () {},
                      icon: const Icon(
                        Icons.emoji_emotions,
                        size: 25,
                        color: Colors.deepPurple,
                      )),
                  Expanded(
                      child: TextField(
                        cursorColor: Colors.deepPurple,
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(
                        hintText: 'Type Something..',
                        hintStyle: TextStyle(color: Colors.deepPurple),
                        border: InputBorder.none),
                  )),
                  //Expanded cover all space available to its Parent widget
                  IconButton(
                      onPressed: () async {
                        //(Image Picker plugin Code)
                        final ImagePicker picker = ImagePicker();
                        // Picking Multiple images.
                        final List<XFile> images =
                            await picker.pickMultiImage(imageQuality: 70);
                        //uploading & sending image one by one
                        for (var i in images) {
                          log('Image Path ${i.path}');
                          setState(() => _isUploading = true);
                          await APIs.sendChatImage(widget.user, File(i.path));
                          setState(() => _isUploading = false);
                        }
                      },
                      icon: const Icon(
                        //Gallery
                        Icons.photo,
                        size: 26,
                        color: Colors.deepPurple,
                      )),
                  IconButton(
                      onPressed: () async {
                        //(Image Picker plugin Code)
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 70);
                        if (image != null) {
                          log('Image Path: ${image.path} -- Mime Type ${image.mimeType}');
                          setState(() => _isUploading = true);
                          await APIs.sendChatImage(
                              widget.user, File(image.path));
                          setState(() => _isUploading = false);
                        }
                      },
                      icon: const Icon(
                        Icons.camera_alt,
                        size: 26,
                        color: Colors.deepPurple,
                      )),
                  SizedBox(
                    width: mq.width * .02,
                  ),
                ],
              ),
            ),
          ),

          //Send Message Button
          MaterialButton(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                if(_list.isEmpty){
                  //on first msg add user to my_user collections of chat user
                  APIs.sendFirstMsg(widget.user, _textController.text, Type.text);
                }else {
                  //simply send msg
                  APIs.sendMessage(widget.user, _textController.text, Type.text);
                }
                _textController.text = '';
              }
            },
            minWidth: 0,
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: const CircleBorder(),
            color: Colors.deepPurple.shade100,
            elevation: 2,
            child: const Icon(
              Icons.send,
              color: Colors.deepPurple,
              size: 28,
            ),
          )
        ],
      ),
    );
  }
}
