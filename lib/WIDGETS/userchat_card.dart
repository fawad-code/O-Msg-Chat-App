import 'package:cached_network_image/cached_network_image.dart';
import 'package:chattingapp/HELPER/date_utility.dart';
import 'package:chattingapp/MODEL/model_user.dart';
import 'package:chattingapp/MODEL/msgmodel.dart';
import 'package:chattingapp/WIDGETS/profile_dialogs.dart';
import 'package:chattingapp/api/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../SCREENS/chat_screen.dart';
import '../main.dart';

class UserChatCard extends StatefulWidget {
  final ChatUser user;

  const UserChatCard({super.key, required this.user});

  @override
  State<UserChatCard> createState() => _UserChatCardState();
}

class _UserChatCardState extends State<UserChatCard> {
  //last msg info if null --> no msg
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.deepPurple.shade100,
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 4),
      child: InkWell(
        onTap: () {
          //For Navigating to ChatScreen
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(
                      user: widget.user,
                    )),
          );
        },
        child: StreamBuilder(
            //Calling getLastMsg ftn
            stream: APIs.getLastMsg(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
              if (list.isNotEmpty) {
                _message = list[0];
              }

              return ListTile(
                // User Profile pic
                leading: InkWell(
                  onTap: (){
                    showDialog(context: context, builder: (_) => ProfileDialog(user: widget.user,));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .3),
                    child: CachedNetworkImage(
                      width: mq.height * .055,
                      height: mq.height * .055,
                      imageUrl: widget.user.image,
                      // placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const CircleAvatar(
                        child: Icon(CupertinoIcons.person),
                      ),
                    ),
                  ),
                ),

                //user name
                title: Text(widget.user.name),

                //LAST MSG
                subtitle: Text(
                  //if no msg show about
                  _message != null ?
                  _message!.type == Type.image ? 'image' :
                  _message!.msg : widget.user.about,
                  maxLines: 1,
                ),

                //LAST MSG TIME
                trailing: _message == null
                    ? null
                    : _message!.read.isEmpty &&
                            _message!.fromId != APIs.user.uid
                        ?
                        //Show for unread msgs
                        Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                                color: Colors.greenAccent.shade400,
                                borderRadius: BorderRadius.circular(10)),
                          )
                        :
                        //Message Sent Time
                        Text(
                            MyDate.getLastMsgTime(context: context, time: _message!.sent),
                            style: const TextStyle(color: Colors.black54),
                          ),
              );
            }),
      ),
    );
  }
}
