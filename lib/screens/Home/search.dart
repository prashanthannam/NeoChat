import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/screens/Home/conversation.dart';
import 'package:flutter_firebase/services/database.dart';
import 'package:flutter_firebase/shared/constants.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchcontroller = new TextEditingController();
  DatabaseServices databaseService = new DatabaseServices();
  QuerySnapshot searchsnapshot;
  Map<String, String> searchresult = {};

  createChatRoomandStartConv(String userName, String userProfpic) async {
    String curUserProfpic = Constants.MyProfPic;
    List<String> users = [userName, Constants.MyName];
    String chatRoomID = getChatRoomID(userName, Constants.MyName);
    var len = await databaseService.getSingleChatRoom(chatRoomID);
    if (len == null) {
      print('create');
      Map<String, dynamic> chatRoomMap = {
        "users": users,
        "chatRoomID": chatRoomID,
        'lastMessage': "",
        'lastMessageTime': 0,
        "hour": 0,
        "minute": 0,
        "lastmessBy": "",
        "seenby$userName": true,
        "seenby${Constants.MyName}": true,
      };
      databaseService.createChatRoom(chatRoomID, chatRoomMap);
    }
    print(chatRoomID);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ConversationScreen(chatRoomID, userName, userProfpic)));
  }

  Widget SearchTile({String userName, String userEmail, String userProfpic}) {
    return Container(
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.indigo[500],
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 30,
              backgroundImage: userProfpic == ""
                  ? AssetImage("assets/profPic.jpg")
                  : NetworkImage(userProfpic),
            ),
            SizedBox(
              width: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 23,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    // fontStyle: FontStyle.italic,
                  ),
                ),
                Text(
                  userEmail,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Spacer(),
            GestureDetector(
              onTap: () {
                createChatRoomandStartConv(userName, userProfpic);
              },
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30)),
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Text(
                    'Message',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  )),
            )
          ],
        ),
      ),
    );
  }

  Widget searchResultList() {
    return searchsnapshot == null
        ? Container()
        : ListView.builder(
            itemCount: searchsnapshot.documents.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              if (searchsnapshot.documents[index].data["name"] !=
                  Constants.MyName) {
                return SearchTile(
                  userName: searchsnapshot.documents[index].data["name"],
                  userEmail: searchsnapshot.documents[index].data["email"],
                  userProfpic: searchsnapshot.documents[index].data["profpic"],
                );
              }
            });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[],
        backgroundColor: Colors.black54,
      ),
      body: Container(
        color: Colors.grey[900],
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            TextField(
              style: TextStyle(color: Colors.white, fontSize: 18),
              controller: searchcontroller,
              onChanged: (value) async {
                await databaseService
                    .seachUser(searchcontroller.text)
                    .then((val) {
                  setState(() {
                    searchsnapshot = val;
                  });
                });
              },
              decoration: InputDecoration(
                  alignLabelWithHint: true,
                  hintText: 'Search',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                  ),
                  fillColor: Colors.grey[800],
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.indigo[700], width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  )),
            ),
            SizedBox(
              height: 10,
            ),
            searchResultList(),
          ],
        ),
      ),
    );
  }
}

getChatRoomID(String a, String b) {
  if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
    return "$b\_$a";
  } else {
    return "$a\_$b";
  }
}
