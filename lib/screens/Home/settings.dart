import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/screens/Home/Home.dart';
import 'package:flutter_firebase/services/database.dart';
import 'package:flutter_firebase/shared/constants.dart';
import 'package:flutter_firebase/screens/Authenticate/helperfuncs.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

// import 'package:image_crop/image_crop.dart';
import 'dart:io';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  DatabaseServices databaseService = new DatabaseServices();
  QuerySnapshot imagesnapshot;
  bool up = false;

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  getUserInfo() async {
    imagesnapshot = await databaseService.getProfPic(Constants.MyName);
    Constants.MyProfPic = imagesnapshot.documents[0].data['profpic'];
    print("pic ${Constants.MyProfPic}");
  }

  initialValue(val) {
    return TextEditingController(text: val);
  }

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
  }

  Future uploadPic(BuildContext context) async {
    String fileName = basename(_image.path);
    StorageReference firebasestorageRef =
        FirebaseStorage.instance.ref().child('Profilepics/$fileName');
    StorageUploadTask uploadTask = firebasestorageRef.putFile(_image);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    databaseService.uploadUserProfilePic(Constants.MyName, downloadUrl);

    setState(() {
      Constants.MyProfPic = downloadUrl;
      print("prof pic uploaded");
      print(Constants.MyProfPic);
      up = true;
      final snackBar = SnackBar(
          content: Text('Yay! A SnackBar!'),
          action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                // Some code to undo the change.
              }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black54,
          title: Text('Settings'),
        ),
        body: Container(
            padding: EdgeInsets.only(top: 70),
            width: MediaQuery.of(context).size.width,
            color: Colors.black87,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 70.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: (_image == null)
                            ? (Constants.MyProfPic != ""
                                ? NetworkImage(Constants.MyProfPic)
                                : AssetImage("assets/profPic.jpg"))
                            : FileImage(
                                _image,
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: GestureDetector(
                          child: Icon(
                            Icons.edit,
                            color: Colors.grey,
                            size: 35,
                          ),
                          onTap: () {
                            getImage();
                          },
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 60),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'User Name:',
                        style: TextStyle(color: Colors.white, fontSize: 25),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Container(
                          width: 150,
                          child: TextField(
                            autocorrect: false,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                letterSpacing: 1,
                                wordSpacing: 3),
                            decoration: InputDecoration(
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                            controller: initialValue(Constants.MyName),
                          )),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 100.0),
                  child: Row(
                    children: <Widget>[
                      RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.indigo, width: 2)),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.indigo,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1,
                          ),
                        ),
                        color: Colors.grey[900],
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.indigo, width: 2)),
                        child: Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.indigo,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1,
                          ),
                        ),
                        color: Colors.grey[900],
                        onPressed: () {
                          uploadPic(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
              // Scaffold.of(context).showSnackBar(snackBar);
            )));
  }
}
