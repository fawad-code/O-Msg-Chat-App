import 'dart:developer';
import 'package:chattingapp/HELPER/dialogs.dart';
import 'package:chattingapp/MODEL/model_user.dart';
import 'package:chattingapp/SCREENS/profile_screen.dart';
import 'package:chattingapp/api/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../WIDGETS/userchat_card.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //For Storing all users
  List<ChatUser> _list = [];

  //For Storing all searchedItems
  final List<ChatUser> _searchList = [];

  //For storing Search Status
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();

    //For setting user active status  according to lifecycle events
    //Resume -- active or online
    //pause -- inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');

      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      //Hiding keyboard with a tap

      child: PopScope(
        // PopScope widget to handle the system's back button press from Search Icon.
        canPop: ModalRoute
            .of(context)
            ?.canPop ?? false,
        onPopInvoked: (didPop) async {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
          } else {
            return SystemNavigator.pop();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: const Icon(CupertinoIcons.home),
            title: _isSearching
                ? TextField(
              decoration: const InputDecoration(
                  border: InputBorder.none, hintText: 'Name, Email, ...'),
              autofocus: true,
              style: const TextStyle(fontSize: 17, letterSpacing: 0.5),
              onChanged: (val) {
                //Search Logic
                _searchList.clear();
                for (var i in _list) {
                  if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                      i.email.toLowerCase().contains(val.toLowerCase())) {
                    _searchList.add(i);
                  }
                }
                setState(() {
                  _searchList;
                });
              },
            )
                : const Text('O Msg'),
            actions: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching =
                      !_isSearching; //Whatever value is set opposite value of it
                    });
                  },
                  icon: Icon(_isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : Icons.search)),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ProfileScreen(user: APIs.me)));
                  },
                  icon: const Icon(Icons.person))
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
              backgroundColor: Colors.deepPurple.shade300,
              onPressed: () {
                _addChatUserDialog();
              },
              child: const Icon(Icons.chat),
            ),
          ),
          body: StreamBuilder(builder: (context, snapshot) {
            switch (snapshot.connectionState) {
            //IF Data is Loading
              case ConnectionState.waiting:
              case ConnectionState.none:
                return const Center(child: CircularProgressIndicator());

            //Some or All data is loaded then show it
              case ConnectionState.active:
              case ConnectionState.done:
              return StreamBuilder(
                stream: APIs.getAllUsers(
                    snapshot.data?.docs.map((e) => e.id).toList() ?? []
                ),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                  //IF Data is Loading
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      // return const Center(child: CircularProgressIndicator());

                  //Some or All data is loaded then show it
                    case ConnectionState.active:
                    case ConnectionState.done:
                      final data = snapshot.data?.docs;
                      _list =
                          data?.map((e) => ChatUser.fromJson(e.data()))
                              .toList() ?? [];

                      if (_list.isNotEmpty) {
                        return ListView.builder(
                            padding: EdgeInsets.only(top: mq.height * .01),
                            physics: const BouncingScrollPhysics(),
                            itemCount: _isSearching ? _searchList.length : _list
                                .length,
                            itemBuilder: (context, index) {
                              return UserChatCard(user: _isSearching
                                  ? _searchList[index]
                                  : _list[index]);
                              // return Text('Name: ${list[index]}');
                            });
                      } else {
                        return const Center(
                            child: Text(
                              'No Connection Found',
                              style: TextStyle(fontSize: 20),
                            ));
                      }
                  }
                },
              );
            }
          }, stream: APIs.getMyUsersId(),),
        ),
      ),
    );
  }

  void _addChatUserDialog() {
    String email = '';
    showDialog(
        context: context,
        builder: (_) =>
            AlertDialog(
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
                    Icons.person_add_alt_1,
                    color: Colors.deepPurple,
                  ),
                  Text(
                    '  Add User',
                    style: TextStyle(color: Colors.deepPurple),
                  )
                ],
              ),
              content: TextFormField(
                maxLines: null,
                onChanged: (value) => email = value,
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email),
                    hintText: 'Email Id',
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
                    style: TextStyle(color: Colors.red, fontSize: 18),
                  ),
                ),
                MaterialButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    if (email.isNotEmpty) {
                      await APIs.addChatUser(email).then((value) {
                        if (!value) {
                          Dialogs.showSnackbar(context, 'User not available!');
                        }
                      });
                    }
                  },
                  child: const Text(
                    'Add',
                    style: TextStyle(color: Colors.deepPurple, fontSize: 18),
                  ),
                ),
              ],
            ));
  }
}
