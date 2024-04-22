import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:chattingapp/MODEL/msgmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';
import '../MODEL/model_user.dart';

class APIs {
  //For Authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  //For Accessing Cloud FireStore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  //For Accessing Firebase Storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  //For storing self user Information
  static late ChatUser me;

  //To Return current user
  static User get user => auth.currentUser!;

  //for accessing firebase messaging (Push Notifications)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  //For getting firebase messaging token
  static Future<void> getFirebaseMsgToken() async {
    await fMessaging.requestPermission();
    fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        log('Push Token: $t');
      }
    });

    //Foreground msg handling
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   log('Got a message whilst in the foreground!');
    //   log('Message data: ${message.data}');
    //
    //   if (message.notification != null) {
    //     log('Message also contained a notification: ${message.notification}');
    //   }
    // });
  }

  //FOR SENDING PUSH NOTIFICATIONS
  static Future<void> sendPushNotifications(ChatUser chatUser,
      String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": chatUser.name,
          "body": msg,
          "android_channel_id": "chats",
        },
        "data": {
          "some_data": "User ID: ${me.id}",
        },
      };
      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
            'key=AAAAPy3lqEs:APA91bH57QNDfRe7vjT1t4M-mkIVeggJtJpYjIN0ZXLI51yWWp_Sb74E_10herGAgnukd8vlUmCer7Z2rHL2GLj12SB5OGRltxx73iJCSLILZ3pISC09UPOdk9EoCjmGERoXOjDlLqtN'
          },
          body: jsonEncode(body));
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }

  //For checking if user Exists
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  //For adding chat user to our conversation
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    log('data: ${data.docs}');
    //this will create new user document
    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_Users')
          .doc(data.docs.first.id)
          .set({});
      //userExits
      return true;
    } else {
      //user not exists
      return false;
    }
  }

  //For getting current user info
  static getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        //If User Exists store it in me
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMsgToken();

        //For setting user status to active
        APIs.updateActiveStatus(true);
      } else {
        //If Not Exists then create one & store it in me by calling getSelfInfo ftn again
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  //ftn For Creating New User
  static Future<void> createUser() async {
    final time = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();
    final chatUser = ChatUser(
      id: user.uid,
      name: user.displayName.toString(),
      email: user.email.toString(),
      image: user.photoURL.toString(),
      about: "Hey, I'm using O Msg",
      createdAt: time,
      isOnline: false,
      lastActive: time,
      pushToken: '',
    );

    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  //Getting id of known users from Firestore DB
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_Users')
        .snapshots();
  }

  //Getting all users from Firestore DB
  // (by using Where I have mention that show all users except current login user)
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    log('\nUserIds $userIds');
    return firestore
        .collection('users')
        .where('id', whereIn: userIds.isEmpty ? [''] : userIds)
    // .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  //FTN adding user to my user when first msg is send
  static Future<void> sendFirstMsg(ChatUser chatUser, String msg,
      Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.id).collection('my_Users').doc(user.uid).set({}).then((
        value) => sendMessage(chatUser, msg, type));
  }

  //FTN for updating user information
  //we can also use .set instead of .update but it will create a new document but we already have a document no need to create
  static Future<void> updateUserInfo() async {
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'name': me.name, 'about': me.about});
  }

  //Ftn for updating Profile picture
  static Future<void> updateProfilePicture(File file) async {
    //getting image file extension
    final ext = file.path
        .split('.')
        .last;
    log('Extension: $ext');

    //storage file reference with path
    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext ');
    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //uploading image in firestore db
    me.image = await ref.getDownloadURL();
    await firestore.collection('users').doc(user.uid).update({
      'image': me.image,
    });
  }

  //Getting all users from Firestore DB
  // (by using Where I have mention that show all users except current login user)
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  //Update active status of User
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime
          .now()
          .millisecondsSinceEpoch
          .toString(),
      'push_token': me.pushToken,
    });
  }

  ///************ ChatScreen related APIs ************///

  //chats(collection) --> conversation_id(doc) --> messages(collection --> message(doc))

  //Get Conversation Id ftn
  static String getConversationID(String id) =>
      user.uid.hashCode <= id.hashCode
          ? '${user.uid}_$id'
          : "${id}_${user.uid}";

  //For Getting all msgs of specific convo from firestore DB ftn
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMsgs(ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  //For Sending Msgs
  static Future<void> sendMessage(ChatUser chatUser, String msg,
      Type type) async {
    //Msg sending time (also used as Id)
    final time = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();

    //message to send
    final Message message = Message(
        msg: msg,
        read: '',
        told: chatUser.id,
        type: type,
        sent: time,
        fromId: user.uid);

    final ref = firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotifications(chatUser, type == Type.text ? msg : 'image'));
  }

  //ftn for update Read status of Msg
  static Future<void> msgReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({
      'read': DateTime
          .now()
          .millisecondsSinceEpoch
          .toString(),
    });
  }

  //get only last msg of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMsg(ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  //Send chat Images
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    //getting image file extension
    final ext = file.path
        .split('.')
        .last;

    //storage file reference with path
    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime
            .now()
            .millisecondsSinceEpoch}.$ext ');
    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //uploading image in firestore db
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  //Delete msg
  static Future<void> deleteMsg(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.told)}/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  //Update msg
  static Future<void> updateMsg(Message message, String updatedMsg) async {
    await firestore
        .collection('chats/${getConversationID(message.told)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMsg});
  }
}
