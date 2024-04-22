import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chattingapp/HELPER/date_utility.dart';
import 'package:chattingapp/HELPER/dialogs.dart';
import 'package:chattingapp/MODEL/msgmodel.dart';
import 'package:chattingapp/api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';

//FOR SHOWING MSG CARDS

class MsgCard extends StatefulWidget {
  const MsgCard({super.key, required this.message});

  final Message message;

  @override
  State<MsgCard> createState() => _MsgCardState();
}

class _MsgCardState extends State<MsgCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;
    return InkWell(
      onLongPress: () {
        _showBottomSheet(isMe);
      },
      child: isMe ? _greenMessage() : _blueMessage(),
    );
    //Condition if user id and from id are same show green msg otherwise show blue msg
  }

  //Sender or another user msg (BLUE MSG)
  Widget _blueMessage() {
    //Update last read msg status if sender & receiver are different

    if (widget.message.read.isEmpty) {
      APIs.msgReadStatus(widget.message);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //Wrapped with Flexible for long msgs instead of Expandable because Flexible cover space which it needs
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * .02
                : mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
                color: Colors.deepPurple.shade100,
                border: Border.all(color: Colors.deepPurple),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            child: widget.message.type == Type.text
                ?
                //Show Text
                Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  )
                :
                //OTHERWISE Show Image
                ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.image,
                        size: 70,
                      ),
                    ),
                  ),
          ),
        ),

        //Time of sender
        Padding(
          padding: EdgeInsets.only(right: mq.width * .04),
          child: Text(
            MyDate.getFormattedTime(
                context: context, time: widget.message.sent),
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        )
      ],
    );
  }

  //USER SELF MESSAGE (GREEN MSG)
  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //Msg Time
        Row(
          children: [
            SizedBox(
              width: mq.width * .04,
            ),

            //double tick blue icon for msg read
            if (widget.message.read.isNotEmpty)
              const Icon(
                Icons.done_all_rounded,
                color: Colors.deepPurple,
                size: 18,
              ),
            const SizedBox(
              width: 2,
            ),

            //Sent Time
            Text(
              //calling date class & calling getFormattedTime ftn in it
              MyDate.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),

        //Wrapped with Flexible for long msgs instead of Expandable because Flexible cover space which it needs
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * .02
                : mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
                color: Colors.lightGreenAccent.shade100,
                border: Border.all(color: Colors.lightGreenAccent),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30))),
            child: widget.message.type == Type.text
                ?
                //Show Text
                Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  )
                :
                //OTHERWISE Show Image
                ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.image,
                        size: 70,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  //BOTTOM SHEET FOR MSGS
  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            //Bottom Sheet
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20), topLeft: Radius.circular(20))),
        builder: (_) {
          return ListView(
            //list view because we need icons here
            shrinkWrap: true, //it will only take widgets size
            children: [
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: mq.height * .015, horizontal: mq.width * .4),
                decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(8)),
              ),
              widget.message.type == Type.text
                  ? _OptionItem(
                      icon: const Icon(
                        Icons.copy_all_rounded,
                        color: Colors.deepPurple,
                        size: 26,
                      ),
                      name: 'Copy Text',
                      onTap: () async {
                        await Clipboard.setData(
                                ClipboardData(text: widget.message.msg))
                            .then((value) {
                          Navigator.of(context).pop(mounted);
                          Dialogs.showSnackbar(context, 'Text Copied');
                        });
                      },
                    )
                  : _OptionItem(
                      icon: const Icon(
                        Icons.file_download_outlined,
                        color: Colors.deepPurple,
                        size: 26,
                      ),
                      name: 'Save Image',
                      onTap: () {},
                    ),
              if (isMe)
                Divider(
                  indent: mq.width * .04,
                  endIndent: mq.width * .04,
                  color: Colors.deepPurple.shade100,
                ),
              if (widget.message.type == Type.text && isMe)
                _OptionItem(
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.deepPurple,
                    size: 26,
                  ),
                  name: 'Edit Message',
                  onTap: () {
                    //hide bottom sheet
                    Navigator.pop(context);
                    _showMsgUpdateDialog();
                  },
                ),

              //delete msg
              if (isMe)
                _OptionItem(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                    size: 26,
                  ),
                  name: 'Delete Message',
                  onTap: () async {
                    log('hello');
                    await APIs.deleteMsg(widget.message).then((value) {
                      Navigator.pop(context);
                    });
                  },
                ),
              Divider(
                indent: mq.width * .04,
                endIndent: mq.width * .04,
                color: Colors.deepPurple.shade100,
              ),

              //Sent time
              _OptionItem(
                icon: const Icon(
                  Icons.remove_red_eye,
                  color: Colors.blue,
                  size: 26,
                ),
                name: 'Sent At ${MyDate.getMsgTime(
                  context: context,
                  time: widget.message.sent,
                )}',
                onTap: () {},
              ),

              //Read time
              _OptionItem(
                icon: const Icon(
                  Icons.remove_red_eye,
                  color: Colors.green,
                  size: 26,
                ),
                name: widget.message.read.isEmpty
                    ? 'Read At: Not seen yet'
                    : 'Read At ${MyDate.getMsgTime(
                        context: context,
                        time: widget.message.read,
                      )}',
                onTap: () {},
              ),
            ],
          );
        });
  }

  void _showMsgUpdateDialog() {
    String updateMsg = widget.message.msg;
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                top: 20,
                bottom: 10,
                left: 24,
                right: 24,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              title: const Row(
                children: [
                  Icon(
                    Icons.message,
                    color: Colors.deepPurple,
                  ),
                  Text(' Update Message')
                ],
              ),
              content: TextFormField(
                initialValue: updateMsg,
                maxLines: null,
                onChanged: (value) => updateMsg = value,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.deepPurple, fontSize: 18),
                  ),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    APIs.updateMsg(widget.message, updateMsg);
                  },
                  child: const Text(
                    'Update',
                    style: TextStyle(color: Colors.red, fontSize: 18),
                  ),
                ),
              ],
            ));
  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: EdgeInsets.only(
          left: mq.width * .05,
          top: mq.height * .015,
          bottom: mq.height * .015,
        ),
        child: Row(
          children: [
            icon,
            Flexible(
              child: Text(
                '   $name',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  color: Colors.deepPurple.shade200,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
