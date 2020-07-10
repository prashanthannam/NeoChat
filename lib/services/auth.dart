import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase/models/user.dart';
import 'package:flutter_firebase/screens/Authenticate/helperfuncs.dart';

class AuthService{

  final FirebaseAuth _auth= FirebaseAuth.instance;
  User _userfromfirebaseUser(FirebaseUser user){
    return user!=null? User(uid: user.uid): null;
  }

  Stream<User> get user{
    return _auth.onAuthStateChanged
    .map(_userfromfirebaseUser);
  }

  Future signwithEMail(String email, String password)async{
    try{
      AuthResult res=await _auth.signInWithEmailAndPassword(email: email, password: password);
      FirebaseUser user=res.user;
      return _userfromfirebaseUser(user);
    }
    catch(e){
      print(e.toString());
      return null;
    }
  }
  
  Future regwithEmail(String email,String password) async{
    try{
      AuthResult res=await _auth.createUserWithEmailAndPassword(email: email, password: password);
      FirebaseUser user=res.user;
      return _userfromfirebaseUser(user);

    }catch(e){
      print(e.toString());
      return null;

    }

  }

  Future signOut() async{
    try{
      return _auth.signOut();
      await helperFunctions.saveUserNameSharedPreference('');
      await helperFunctions.saveUserEmailSharedPreference('');
      await helperFunctions.saveUserLoggedInSharedPreference(false);
    }
    catch(e){
      print(e.toString());
      return null;
    }
  }
}