import 'package:cached_network_image/cached_network_image.dart';
import 'package:chattingapp/HELPER/date_utility.dart';
import 'package:chattingapp/MODEL/model_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context)
          .unfocus(), //To hide keyboard by tapping anywhere
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.user.name),
        ),

        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Joined on:  ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.deepPurple),),
            Text(
              MyDate.getLastMsgTime(context: context, time: widget.user.createdAt, showYear: true),
              style: TextStyle(color: Colors.deepPurple.shade300, fontSize: 16),
            ),
          ],
        ),

        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: mq.width * .05,
          ),
          child: SingleChildScrollView(
            //SCSV used to fix Render flow while opening keyboard
            child: Column(
              children: [
                //For adding space to set Profile Pic
                SizedBox(
                  width: mq.width,
                  height: mq.height * .03,
                ),

                //Profile Pic + Edit Button Added through Stack
                ClipRRect(
                    borderRadius:
                        BorderRadius.circular(mq.height * .1),
                    child: CachedNetworkImage(
                      width: mq.height * .2,
                      height: mq.height * .2,
                      fit: BoxFit.cover,
                      imageUrl: widget.user.image,
                      errorWidget: (context, url, error) =>
                          const CircleAvatar(
                        child: Icon(CupertinoIcons.person),
                      ),
                    ),
                  ),
                SizedBox(
                  height: mq.height * .03,
                ),
                Text(
                  widget.user.email,
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                ),
                SizedBox(
                  height: mq.height * .02,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('About:  ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),),
                    Text(
                      widget.user.about,
                      style: const TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                  ],
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
