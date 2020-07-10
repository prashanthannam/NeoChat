import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/screens/Authenticate/helperfuncs.dart';
import 'package:flutter_firebase/screens/Authenticate/sign_in.dart';
import 'package:flutter_firebase/screens/Home/conversation.dart';
import 'package:flutter_firebase/screens/Home/search.dart';
import 'package:flutter_firebase/screens/Home/settings.dart';
import 'package:flutter_firebase/services/auth.dart';
import 'package:flutter_firebase/services/database.dart';
import 'package:flutter_firebase/shared/constants.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();
  DatabaseServices databaseService = new DatabaseServices();
  Stream chatRoomStream;
  QuerySnapshot profpicsnapshot;

  Widget chatRoomList() {
    return StreamBuilder(
      stream: chatRoomStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  List usArray = snapshot.data.documents[index].data['users'];
                  if (usArray.contains(Constants.MyName)) {
                    if (snapshot.data.documents[index].data['lastMessage'] !=
                        "") {
                      String uname = snapshot
                          .data.documents[index].data['chatRoomID']
                          .toString()
                          .replaceAll('_', '')
                          .replaceAll(Constants.MyName, '');
                      return profpicsnapshot == null
                          ? Container()
                          : ChatRoomTile(
                              uname,
                              snapshot.data.documents[index].data['chatRoomID'],
                              profpicsnapshot,
                              snapshot.data.documents[index].data['hour'],
                              snapshot.data.documents[index].data['minute'],
                              snapshot.data.documents[index].data['lastmessBy'],
                              snapshot
                                  .data.documents[index].data['lastMessage'],
                              snapshot.data.documents[index]
                                  .data['seenby${Constants.MyName}'],
                            );
                    }
                  }
                })
            : Container();
      },
    );
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  getUserInfo() async {
    if (Constants.MyName == '') {
      Constants.MyName = await helperFunctions.getUserNameSharedPreference();
    }
    databaseService.getChatRooms(Constants.MyName).then((value) {
      setState(() {
        chatRoomStream = value;
      });
    });
    databaseService.getAllProfPics().then((value) async {
      setState(() {
        profpicsnapshot = value;
      });
    });
  }

  Widget popUpMemu() {
    return PopupMenuButton<int>(
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 1,
          child: Row(
            children: <Widget>[
              Icon(
                Icons.exit_to_app,
                color: Colors.black,
              ),
              Text('Logout')
            ],
          ),
        ),
        PopupMenuItem(
          value: 2,
          child: Row(
            children: <Widget>[
              Icon(
                Icons.settings,
                color: Colors.black,
              ),
              Text('Settings')
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 1) {
          _auth.signOut();
          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Sign_in()));
        } else {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Settings()));
        }
      },
      icon: Icon(
        Icons.list,
        size: 30,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black54,
        elevation: 1,
        title: Container(
          child: Image.asset('assets/Logo.png'),
        ),
        actions: <Widget>[
          // dropMenu()
          popUpMemu()
        ],
      ),
      body: Container(
        color: Colors.black87,
        child: chatRoomList(),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.search),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Search(),
                ));
          }),
    );
  }
}

class ChatRoomTile extends StatelessWidget {
  final String userName;
  final String chatRoomID;
  QuerySnapshot url;
  final int hour;
  final int minute;
  final String sentby;
  final String lastmess;
  final bool seenbyme;
  // final Querysnapshot prof;
  ChatRoomTile(this.userName, this.chatRoomID, this.url, this.hour, this.minute,
      this.sentby, this.lastmess, this.seenbyme);
  @override
  Widget build(BuildContext context) {
    final List arr = url.documents.toList();
    String p;
    for (int i = 0; i < arr.length; i++) {
      if (arr[i].data['name'] == userName) {
        p = arr[i].data['profpic'];
      }
    }
    return GestureDetector(
      onTap: () {
        print(chatRoomID);
        DatabaseServices databaseService = new DatabaseServices();
        databaseService.updateSeenInfoWhenMessReceived(chatRoomID);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ConversationScreen(chatRoomID, userName, p)));
      },
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          // decoration: BoxDecoration(border: ),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                  radius: 30,
                  backgroundImage: (p == "" || p == null)
                      ? AssetImage("assets/profPic.jpg")
                      : NetworkImage(p)),
              SizedBox(
                width: 20,
              ),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 20,
                        letterSpacing: 1,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        sentby == Constants.MyName
                            ? Padding(
                                padding: const EdgeInsets.only(right: 6.0),
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white60,
                                ),
                              )
                            : Container(),
                        Container(
                          constraints:
                              BoxConstraints(maxWidth: 200, maxHeight: 42),
                          child: lastmess == null
                              ? Row(
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 5.0),
                                      child: Icon(
                                        Icons.camera_alt,
                                        color: Colors.white60,
                                      ),
                                    ),
                                    Text(
                                      'Image',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white60,
                                      ),
                                    )
                                  ],
                                )
                              : Text(
                                  lastmess,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white60,
                                  ),
                                ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Spacer(),
              Column(
                children: <Widget>[
                  Text(
                    "$hour:$minute",
                    style: TextStyle(
                      fontSize: 18,
                      color: seenbyme == true ? Colors.white : Colors.blue,
                    ),
                  ),
                  seenbyme == true
                      ? Container()
                      : Icon(
                          Icons.notifications_active,
                          color: Colors.blue,
                        )
                ],
              )
            ],
          )),
    );
  }
}
