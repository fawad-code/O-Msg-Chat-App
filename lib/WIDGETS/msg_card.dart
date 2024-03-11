import 'package:cached_network_image/cached_network_image.dart';
import 'package:chattingapp/HELPER/date_utility.dart';
import 'package:chattingapp/MODEL/msgmodel.dart';
import 'package:chattingapp/api/api.dart';
import 'package:flutter/material.dart';

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
    //Condition if user id and from id are same show green msg otherwise show blue msg
    return APIs.user.uid == widget.message.fromId
        ? _greenMessage()
        : _blueMessage();
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
            padding: EdgeInsets.all(widget.message.type == Type.image ? mq.width * .02 : mq.width * .04),
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
            padding: EdgeInsets.all(widget.message.type == Type.image ? mq.width *.02 :  mq.width * .04),
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
}
