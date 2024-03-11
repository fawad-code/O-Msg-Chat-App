import 'dart:developer';
import 'package:chattingapp/SCREENS/AUTH/login_screen.dart';
import 'package:chattingapp/SCREENS/home_screen.dart';
import 'package:chattingapp/api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';


//---SPLASH--SCREEN---//

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  //Splashing
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      //EXIT FULL SCREEN
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(systemNavigationBarColor: Colors.white, statusBarColor: Colors.deepPurple.shade300),
      );

      if(APIs.auth.currentUser != null){
        //Printing User Credentials
        log('\nUser: ${APIs.auth.currentUser}');
        //Navigate to HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
        );

      }else
        {
          //Navigate to HomeScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const LoginScreen(),
            ),
          );
        }

    });
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
          Positioned(
              top: mq.height * .15,
              right: mq.width * .25,
              width: mq.width * .5,
              child: Image.asset('images/chaticon.png')),
          Positioned(
            bottom: mq.height * .15,
            width: mq.width,
            child: const Text(
              'O-Msg',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                  letterSpacing: .5),
            ),
          ),
        ],
      ),
    );
  }
}
