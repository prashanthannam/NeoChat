import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_firebase/shared/constants.dart';

class DatabaseServices {
  seachUser(String name) {
    return Firestore.instance
        .collection('user')
        .where("name", isEqualTo: name)
        .getDocuments();
  }

  searchUserbyEmail(String email) {
    return Firestore.instance
        .collection('user')
        .where("email", isEqualTo: email)
        .getDocuments()
        .catchError((e) {
      print(e.toString());
    });
  }

  getProfPic(String name) {
    return Firestore.instance
        .collection('user')
        .where("name", isEqualTo: name)
        .getDocuments();
  }

  getAllProfPics() async {
    var shot = await Firestore.instance.collection('user').getDocuments();
    return shot;
  }

  uploadUserInfo(String name, String email) {
    Firestore.instance
        .collection('user')
        .document(name)
        .setData({'name': name, 'email': email, 'profpic': ""});
  }

  uploadUserProfilePic(String name, String imageUrl) {
    Firestore.instance
        .collection('user')
        .document(name)
        .updateData({'profpic': imageUrl});
  }

  createChatRoom(String chatRoomID, chatRoomMap) {
    Firestore.instance
        .collection('chatRooms')
        .document(chatRoomID)
        .setData(chatRoomMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  sendMessagetoFirestore(String chatRoomID, chatMap, time) {
    Firestore.instance
        .collection('chatRooms')
        .document(chatRoomID)
        .collection('chats')
        .document(time)
        .setData(chatMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  updateLastMessage(String chatRoomID, String mess) {
    Firestore.instance.collection('chatRooms').document(chatRoomID).updateData({
      'lastMessage': mess,
      'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
      "hour": DateTime.now().hour,
      "minute": DateTime.now().minute,
      'lastmessBy': Constants.MyName,
    });
  }

  getMessagesFromFirestore(String chatRoomID) {
    return Firestore.instance
        .collection('chatRooms')
        .document(chatRoomID)
        .collection('chats')
        .orderBy("time", descending: true)
        .snapshots();
  }

  getChatRooms(String userName) async {
    return Firestore.instance
        .collection('chatRooms')
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  getSingleChatRoom(String chatRoomID) async {
    var d = await Firestore.instance
        .collection('chatRooms')
        .document(chatRoomID)
        .get();

    return d.data;
  }

  updateSeenInfoWhenMessSent(String chatRoomID, String user) {
    Firestore.instance
        .collection('chatRooms')
        .document(chatRoomID)
        .updateData({'seenby$user': false});
  }

  updateSeenInfoWhenMessReceived(String chatRoomID) {
    Firestore.instance
        .collection('chatRooms')
        .document(chatRoomID)
        .updateData({'seenby${Constants.MyName}': true});
  }

  updateseenInfoOfText(String chatRoomID, time) {
    Firestore.instance
        .collection('chatRooms')
        .document(chatRoomID)
        .collection('chats')
        .document(time)
        .updateData({'seenby': true});
  }
}
