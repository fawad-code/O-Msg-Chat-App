import 'dart:developer';
import 'dart:io';

import 'package:chattingapp/api/api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../HELPER/dialogs.dart';
import '../../main.dart';
import '../home_screen.dart';


// ---LOGIN -- SCREEN---//
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false; //initially animate is false

  @override
  void initState() {
    super
        .initState(); //When Screen is build ftn is called & Animate will be True
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  // _ used in order to make the function private
  _handleGoogleButtonClick() {
      //For Showing Progress Indicator
    Dialogs.showProgressIndicator(context);
    _signInWithGoogle().then((user) async {
      //For hiding Progress Indicator
      Navigator.pop(context);
      if(user != null){
        //Printing User Credentials in Terminal
        log('\nUser: ${user.user}');
        log('\nUserAdditionInfo: ${user.additionalUserInfo}');

        //Checking User exists if not Create one by Using APIs class create ftn
        if((await APIs.getSelfInfo()))
        {
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),);}
        else {

          APIs.createUser().then((value) {
            Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
            );
          });
        }

      }
    });
  }

  //Wrapped SignIn Function In Try Catch to handle the problems
  Future<UserCredential?> _signInWithGoogle() async { //? used because it can be null
    try {
      await InternetAddress.lookup('Google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      log('_signInWithGoogle: $e');
      // ignore: use_build_context_synchronously
      Dialogs.showSnackbar(context, 'Something went wrong (Check Internet Connection!)');
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size; //MediaQuery

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Welcome to O Msg'),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
              //Animation added
              top: mq.height * .15,
              right: _isAnimate
                  ? mq.width * .25
                  : -mq.width * .5, //If animate is true, Condition used
              width: mq.width * .5,
              duration: const Duration(seconds: 1),
              child: Image.asset('images/chaticon.png')),
          Positioned(
              bottom: mq.height * .15,
              left: mq.width * .05,
              width: mq.width * .9,
              height: mq.height * .065,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    elevation: 1,
                    backgroundColor: Colors.deepPurple.shade300,
                    shape: const StadiumBorder()),
                onPressed: () {
                  _handleGoogleButtonClick();
                },
                icon:
                    Image.asset('images/google.png', height: mq.height * .045),
                label: RichText(
                    text: const TextSpan(
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                            fontSize: 19),
                        children: [
                      TextSpan(text: 'Log In '),
                      TextSpan(text: 'with '),
                      TextSpan(
                          text: 'Google',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ])),
              )),
        ],
      ),
    );
  }
}
