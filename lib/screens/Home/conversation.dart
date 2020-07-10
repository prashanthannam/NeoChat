import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/services/database.dart';
import 'package:flutter_firebase/shared/constants.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class ConversationScreen extends StatefulWidget {
  final String chatRoomID;
  String userName;
  String Profpic;
  ConversationScreen(this.chatRoomID, this.userName, this.Profpic);

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  TextEditingController chatController = new TextEditingController();
  DatabaseServices databaseService = new DatabaseServices();

  File _image;
  final picker = ImagePicker();
  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      try {
        _image = File(pickedFile.path);
      } catch (e) {
        print(e.toString());
      }
    });
    uploadPic();
  }

  String imgurl = "";
  Future uploadPic() async {
    String fileName = basename(_image.path);
    StorageReference firebasestorageRef =
        FirebaseStorage.instance.ref().child('${widget.chatRoomID}/"$fileName');
    StorageUploadTask uploadTask = firebasestorageRef.putFile(_image);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    sendimage(downloadUrl, widget.userName);
    // print("after upload $imgurl");
  }

  Stream messagesStream;

  Widget chatList() {
    return Expanded(
      child: StreamBuilder(
          stream: messagesStream,
          builder: (context, snapshot) {
            return snapshot.hasData
                ? ListView.builder(
                    reverse: true,
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      if (snapshot.data.documents[index].data['sendBy'] !=
                          Constants.MyName) {
                        databaseService.updateseenInfoOfText(
                            widget.chatRoomID,
                            snapshot.data.documents[index].data['time']
                                .toString());
                      }
                      return messageTile(
                        snapshot.data.documents[index].data['message'],
                        snapshot.data.documents[index].data['sendBy'] ==
                            Constants.MyName,
                        snapshot.data.documents[index].data['hour'],
                        snapshot.data.documents[index].data['minute'],
                        snapshot.data.documents[index].data['imgeurl'],
                        snapshot.data.documents[index].data['sendBy'] ==
                                Constants.MyName
                            ? snapshot.data.documents[index].data['seenby']
                            : false,
                      );
                    })
                : Container();
          }),
    );
  }

  sendMessage(String message, String userName) {
    if (message.isNotEmpty) {
      var tim = DateTime.now().millisecondsSinceEpoch;
      Map<String, dynamic> chatMap = {
        "message": message,
        "sendBy": Constants.MyName,
        "time": tim,
        "hour": DateTime.now().hour,
        "minute": DateTime.now().minute,
        "imageurl": "",
        "seenby": false,
      };
      databaseService.sendMessagetoFirestore(
          widget.chatRoomID, chatMap, tim.toString());
      chatController.text = "";
      databaseService.updateLastMessage(widget.chatRoomID, message);
      databaseService.updateSeenInfoWhenMessSent(
          widget.chatRoomID,
          widget.chatRoomID
              .replaceAll('_', '')
              .replaceAll(Constants.MyName, ''));
    }
  }

  sendimage(String url, String userName) {
    if (url != "") {
      var tim = DateTime.now().millisecondsSinceEpoch;

      Map<String, dynamic> chatMap = {
        "message": "",
        "sendBy": Constants.MyName,
        "time": tim,
        "hour": DateTime.now().hour,
        "minute": DateTime.now().minute,
        "imgeurl": url,
        "seenby": false,
      };
      databaseService.sendMessagetoFirestore(widget.chatRoomID, chatMap, tim);
      databaseService.updateLastMessage(widget.chatRoomID, null);
    }
  }

  @override
  void initState() {
    dynamic value = databaseService.getMessagesFromFirestore(widget.chatRoomID);
    setState(() {
      messagesStream = value;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black54,
        title: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 20,
              backgroundImage: url == null
                  ? AssetImage("assets/profPic.jpg")
                  : (widget.Profpic == ""
                      ? AssetImage("assets/profPic.jpg")
                      : NetworkImage(widget.Profpic)),
            ),
            SizedBox(
              width: 15,
            ),
            Text(widget.userName),
          ],
        ),
      ),
      body: Container(
        color: Colors.black87,
        child: Column(
          children: [
            Container(child: chatList()),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.grey[800],
                padding: EdgeInsets.all(7),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.blue[700],
                          size: 30,
                        ),
                        onTap: () {
                          getImage();
                        },
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        style: TextStyle(fontSize: 17),
                        controller: chatController,
                        decoration: InputDecoration(
                            alignLabelWithHint: true,
                            hintText: 'Message...',
                            fillColor: Colors.white,
                            filled: true,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.red[300], width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.blue, width: 2),
                            )),
                      ),
                    ),
                    GestureDetector(
                        onTap: () {
                          sendMessage(chatController.text, widget.userName);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15, right: 8),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                color: Colors.blue[700]),
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            height: 40,
                            width: 40,
                            child: Icon(
                              Icons.send,
                              size: 25,
                              color: Colors.white,
                            ),
                          ),
                        ))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class messageTile extends StatelessWidget {
  final String message;
  final int hour;
  final int minute;
  final bool isitsentbyme;
  final String imageurl;
  final bool seen;

  messageTile(this.message, this.isitsentbyme, this.hour, this.minute,
      this.imageurl, this.seen);

  @override
  Widget build(BuildContext context) {
    // print("tile $imageurl");
    return Container(
      padding: EdgeInsets.all(8),
      width: MediaQuery.of(context).size.width,
      alignment: isitsentbyme ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        children: <Widget>[
          Container(
            // width: MediaQuery.of(context).size.width,
            constraints: BoxConstraints(minWidth: 50, maxWidth: 250),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
                color: isitsentbyme ? Colors.indigo[400] : Colors.blueGrey[500],
                borderRadius: isitsentbyme
                    ? BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(23),
                        bottomLeft: Radius.circular(23),
                      )
                    : BorderRadius.only(
                        topLeft: Radius.circular(23),
                        topRight: Radius.circular(23),
                        bottomRight: Radius.circular(23),
                      )),
            child: Column(
              crossAxisAlignment: isitsentbyme
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: <Widget>[
                message == ""
                    ? Image.network(
                        imageurl,
                        height: 150,
                      )
                    : Text(
                        message,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                SizedBox(
                  height: 5,
                ),
                UnconstrainedBox(
                    child: Row(
                  mainAxisAlignment: isitsentbyme
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      hour.toString() + ":" + minute.toString(),
                      style: TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.w500),
                      // textAlign: TextAlign.right,
                    ),
                    isitsentbyme == true
                        ? Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Icon(
                              Icons.check_circle,
                              size: 20,
                              color: seen == true
                                  ? Colors.blue[300]
                                  : Colors.white,
                            ),
                          )
                        : Container()
                  ],
                ))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
