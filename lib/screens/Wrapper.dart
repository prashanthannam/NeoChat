import 'package:flutter/material.dart';
import 'package:flutter_firebase/screens/Authenticate/Authenticate.dart';
import 'package:flutter_firebase/screens/Home/Home.dart';
import 'package:provider/provider.dart';
import 'package:flutter_firebase/models/user.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    if (user == null) {
    } else {}
    // user.uid.;

    if (user == null) {
      return Authenticate();
    } else {
      return Home();
    }
  }
}
