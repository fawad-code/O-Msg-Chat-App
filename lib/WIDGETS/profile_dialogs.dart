import 'package:cached_network_image/cached_network_image.dart';
import 'package:chattingapp/MODEL/model_user.dart';
import 'package:chattingapp/SCREENS/view_profile_screen.dart';
import 'package:chattingapp/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.user});

  final ChatUser user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(0),
      backgroundColor: Colors.deepPurple.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      content: SizedBox(
        width: mq.width * .6,
        height: mq.height * .35,
        child: Stack(
          children: [
            //Profile Pic
            Positioned(
              top: mq.height * .076,
              left: mq.width * .1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .25),
                child: CachedNetworkImage(
                  width: mq.width * .5,
                  fit: BoxFit.cover,
                  imageUrl: user.image,
                  errorWidget: (context, url, error) => const CircleAvatar(
                    child: Icon(CupertinoIcons.person),
                  ),
                ),
              ),
            ),

            //User name
            Positioned(
              left: mq.width * .04,
              top: mq.height * .018,
              //width used for long names
              width: mq.width * .55,
              child: Text(
                user.name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),

            //Info Button
            Positioned(
              right: 6,
              top: 6,
              child: MaterialButton(
                minWidth: 0,
                padding: const EdgeInsets.all(0),
                shape: const CircleBorder(),
                onPressed: () {
                  //For dismissing dialog
                  Navigator.pop(context);

                  //Moving to other screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ViewProfileScreen(user: user),
                    ),
                  );
                },
                child: const Icon(
                  Icons.info_outline,
                  size: 30,
                  color: Colors.deepPurpleAccent,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
