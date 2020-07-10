import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/models/user.dart';
import 'package:flutter_firebase/screens/Authenticate/helperfuncs.dart';
import 'package:flutter_firebase/services/auth.dart';
import 'package:flutter_firebase/services/database.dart';
import 'package:flutter_firebase/shared/constants.dart';
import 'package:flutter_firebase/shared/loading.dart';

class Sign_in extends StatefulWidget {
  final Function toggleview;
  Sign_in({this.toggleview});
  @override
  _Sign_inState createState() => _Sign_inState();
}

class _Sign_inState extends State<Sign_in> {
  final AuthService _auth = AuthService();
  final _formkey = GlobalKey<FormState>();
  DatabaseServices databaseService = new DatabaseServices();
  QuerySnapshot usersnapshot;

  String email = '';
  String password = '';
  String error = '';
  bool loading = false;

  findsignedCurUser(QuerySnapshot val) async {
    String curUser = val.documents[0].data['name'];
    helperFunctions.saveUserEmailSharedPreference(email);
    helperFunctions.saveUserNameSharedPreference(curUser);
    helperFunctions.saveUserLoggedInSharedPreference(true);
    //  Constants.MyName=await helperFunctions.getUserNameSharedPreference();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            // appBar: AppBar(
            //   backgroundColor: Colors.black54,
            //   title: Text('Sign In',),
            //   centerTitle: true,
            // ),
            body: SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height,
                padding: EdgeInsets.only(bottom: 50, top: 100),
                color: Colors.black87,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      child: Form(
                        key: _formkey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(
                                left: 20,
                              ),
                              child: Image.asset(
                                'assets/Logo.png',
                                width: 300,
                                fit: BoxFit.fill,
                              ),
                            ),
                            // SizedBox(height: 20),
                            TextFormField(
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                              decoration: InputDecoration(
                                  icon: Icon(
                                    Icons.email,
                                    color: Colors.grey[600],
                                  ),
                                  alignLabelWithHint: true,
                                  hintText: 'Email',
                                  hintStyle: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                  fillColor: Colors.grey[900],
                                  filled: true,
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 2),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 2),
                                  )),
                              validator: (val) =>
                                  val.isEmpty ? 'invalid email' : null,
                              onChanged: (val) {
                                setState(() => email = val);
                              },
                            ),
                            SizedBox(height: 20),
                            TextFormField(
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                              decoration: InputDecoration(
                                  icon: Icon(
                                    Icons.lock,
                                    color: Colors.grey[600],
                                  ),
                                  alignLabelWithHint: true,
                                  hintText: 'Password',
                                  hintStyle: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                  fillColor: Colors.grey[900],
                                  filled: true,
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 2),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 2),
                                  )),
                              validator: (val) => val.length < 6
                                  ? 'password should be 6+ long'
                                  : null,
                              obscureText: true,
                              onChanged: (val) {
                                setState(() => password = val);
                              },
                            ),
                            SizedBox(height: 20),
                            RaisedButton(
                              elevation: 4,
                              color: Colors.white,
                              onPressed: () async {
                                if (_formkey.currentState.validate()) {
                                  setState(() => loading = true);
                                  print('user');
                                  usersnapshot = await databaseService
                                      .searchUserbyEmail(email);
                                  setState(() {
                                    Constants.MyName =
                                        usersnapshot.documents[0].data['name'];
                                  });
                                  dynamic res = await _auth.signwithEMail(
                                      email, password);

                                  if (res == null) {
                                    setState(() {
                                      error = 'COULD NOT SIGN IN';
                                      loading = false;
                                    });
                                  } else {
                                    Constants.MyProfPic = usersnapshot
                                        .documents[0].data['profpic'];
                                    print(
                                        "user ${usersnapshot.documents[0].data['name']}");
                                    Constants.MyName =
                                        usersnapshot.documents[0].data['name'];
                                    print(Constants.MyName);
                                    findsignedCurUser(usersnapshot);
                                  }
                                }
                              },
                              child: Text(
                                'Sign in',
                                style: (TextStyle(
                                    color: Colors.grey[900],
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600)),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              error,
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                            // SizedBox(height: 220,),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.bottomCenter,
                      child: RaisedButton.icon(
                        color: Colors.white,
                        onPressed: () {
                          widget.toggleview();
                        },
                        label: Text(
                          'Dont have an account? Sign Up',
                          style: TextStyle(
                              fontSize: 18, color: Colors.indigo[700]),
                        ),
                        icon: Icon(
                          Icons.person,
                          color: Colors.indigo[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
