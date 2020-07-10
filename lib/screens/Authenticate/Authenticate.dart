import 'package:flutter/material.dart';
import 'package:flutter_firebase/screens/Authenticate/sign_in.dart';
import 'package:flutter_firebase/screens/Authenticate/sign_up.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  @override
  bool showSignin=true;
  void toggleview(){
    setState(() =>showSignin=!showSignin);
  }

  Widget build(BuildContext context) {
    if(showSignin==true){
    return Sign_in(toggleview: toggleview);
  }
  else{
    return signUp(toggleview: toggleview);
  }
}
}