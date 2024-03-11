// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chattingapp/MODEL/model_user.dart';
import 'package:chattingapp/SCREENS/AUTH/login_screen.dart';
import 'package:chattingapp/api/api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import '../HELPER/dialogs.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  //FormKey
  final _formKey = GlobalKey<FormState>();

  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context)
          .unfocus(), //To hide keyboard by tapping anywhere
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile Screen'),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),

          //Logout Button
          // Extended is used to add Text with Icon in button
          child: FloatingActionButton.extended(
            backgroundColor: Colors.red,
            onPressed: () async {
              //for showing progress dialog
              Dialogs.showProgressIndicator(context);

              await APIs.updateActiveStatus(false);

              //Sign out from App
              await APIs.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  //For Hiding Progress Dialog
                  Navigator.pop(context);
                  //ForMoving to HomeScreen
                  Navigator.pop(context);

                  APIs.auth = FirebaseAuth.instance;

                  //Replacing HomeScreen with LoginScreen
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()));
                });
              });
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
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
                  Stack(
                    children: [
                      //Profile Picture
                      _image != null
                          ?

                          //Local Image
                          ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * .1),
                              child: Image.file(
                                File(_image!),
                                width: mq.height * .2,
                                height: mq.height * .2,
                                fit: BoxFit.cover,
                              ),
                            )
                          :

                          //Image From Server
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

                      //Edit Button
                      Positioned(
                        bottom: 0,
                        right: 3,
                        child: MaterialButton(
                          onPressed: () {
                            _showBottomSheet(); //Calling Below bottom sheet ftn
                          },
                          shape: const CircleBorder(),
                          color: Colors.white,
                          elevation: 2,
                          child: const Icon(
                            Icons.edit,
                            size: 20,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: mq.height * .03,
                  ),
                  Text(
                    widget.user.email,
                    style: const TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                  SizedBox(
                    height: mq.height * .05,
                  ),
                  TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (val) => APIs.me.name =
                        val ?? '', //?? used so if null return empty string
                    validator: (val) => val != null && val.isNotEmpty //if
                        ? null //Return null
                        : 'Required Field', // Otherwise Return this
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        CupertinoIcons.person,
                        color: Colors.deepPurple,
                      ),
                      hintText: 'eg. John Wick',
                      label: const Text('Name'),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(
                    height: mq.height * .02,
                  ),
                  TextFormField(
                    initialValue: widget.user.about,
                    onSaved: (val) => APIs.me.about =
                        val ?? '', //?? used so if null return empty string
                    validator: (val) => val != null && val.isNotEmpty //if
                        ? null //Return null
                        : 'Required Field', // Otherwise Return this
                    decoration: InputDecoration(
                      prefixIcon: const Icon(CupertinoIcons.info,
                          color: Colors.deepPurple),
                      hintText: 'eg. I am feeling Awesome',
                      label: const Text('About'),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(
                    height: mq.height * .02,
                  ),

                  //Update Profile Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        backgroundColor: Colors.deepPurple.shade300,
                        minimumSize: Size(mq.width * .4, mq.height * .06)),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!
                            .save(); //For Saving Name & About by tapping Update
                        APIs.updateUserInfo().then((value) {
                          Dialogs.showSnackbar(context, 'Profile Updated');
                        });
                      }
                    },
                    icon: const Icon(
                      Icons.edit,
                      size: 20,
                    ),
                    label: const Text(
                      'Update',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //Ftn for picking a profile pic for user
  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            //Bottom Sheet
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20), topLeft: Radius.circular(20))),
        builder: (_) {
          return Padding(
            padding:
                EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .05),
            child: ListView(
              //list view because we need icons here
              shrinkWrap: true, //it will only take widgets size
              children: [
                const Text(
                  'Change Profile Picture',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: mq.height * .02,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceEvenly, //Row to represent Image Icons in row form
                  children: [
                    ElevatedButton(
                        //Button to make images clickable
                        style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            backgroundColor: Colors.white,
                            fixedSize: Size(mq.width * .3, mq.height * .15)),
                        onPressed: () async {
                          //(Image Picker plugin Code)
                          final ImagePicker picker = ImagePicker();
                          // Pick an image.
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery, imageQuality: 80);
                          if (image != null) {
                            log('Image Path: ${image.path} -- Mime Type ${image.mimeType}');
                            setState(() {
                              _image = image.path;
                            });

                            APIs.updateProfilePicture(File(_image!));
                            //For hiding bottom sheet after uploading
                            Navigator.pop(context);
                          }
                        },
                        child: Image.asset('images/gallery.png')),
                    ElevatedButton(
                        //Button to make images clickable
                        style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            backgroundColor: Colors.white,
                            fixedSize: Size(mq.width * .3, mq.height * .15)),
                        onPressed: () async {
                          //Camera Image Picker
                          final ImagePicker picker = ImagePicker();
                          // Pick an image.
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.camera, imageQuality: 80);
                          if (image != null) {
                            log('Image Path: ${image.path}');
                            setState(() {
                              _image = image.path;
                            });
                            APIs.updateProfilePicture(File(_image!));
                            //For hiding bottom sheet after uploading
                            Navigator.pop(context);
                          }
                        },
                        child: Image.asset('images/camera.png')),
                  ],
                )
              ],
            ),
          );
        });
  }
}
