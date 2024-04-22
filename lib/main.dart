import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'SCREENS/splash_screen.dart';
import 'firebase_options.dart';

late Size mq; //Initializing MediaQuery globally now we can import it in any screen

void main() {


  WidgetsFlutterBinding.ensureInitialized(); //Rid Of Fullscreen Errors

  //ENTER FULL SCREEN
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // DEVICE ORIENTATION SETTINGS
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) {
    _initializeFirebase(); //calling firebase ftn
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OMsg',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.deepPurple.shade300,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle:
              const TextStyle(fontWeight: FontWeight.normal, fontSize: 19),
          centerTitle: true,
          elevation: 1,
        ),
        useMaterial3: false,
      ),
      home: const SplashScreen(),
    );
  }
}

_initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  var result = await FlutterNotificationChannel().registerNotificationChannel(
    description: 'For Showing Msg Notifications',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats',
  );
  log('notification channel result: $result');
}
