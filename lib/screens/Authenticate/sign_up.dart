import 'package:flutter/material.dart';
import 'package:flutter_firebase/screens/Authenticate/sign_in.dart';
import 'package:flutter_firebase/services/auth.dart';
import 'package:flutter_firebase/services/database.dart';
import 'package:flutter_firebase/shared/constants.dart';
import 'package:flutter_firebase/shared/loading.dart';
import 'package:flutter_firebase/screens/Authenticate/helperfuncs.dart';

class signUp extends StatefulWidget {
  final Function toggleview;
  signUp({ this.toggleview });
  @override
  _signUpState createState() => _signUpState();
}

class _signUpState extends State<signUp> {
  final AuthService _auth=AuthService();
  final _formkey=GlobalKey<FormState>();
  DatabaseServices databaseService=new DatabaseServices();
  String name='';
  String email='';
  String password='';
  String error='';
  bool loading=false;

  findCurUser(String email, String name)async{
    helperFunctions.saveUserEmailSharedPreference(email);
    helperFunctions.saveUserNameSharedPreference(name);
    helperFunctions.saveUserLoggedInSharedPreference(true);
  }

  @override
  Widget build(BuildContext context) {
    return loading?Loading(): Scaffold(
      
      body: SingleChildScrollView(
        
          child: Container(
            height: MediaQuery.of(context).size.height,
                        padding: EdgeInsets.only(top:100,bottom: 50),

                      color: Colors.black87,

                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
              padding: EdgeInsets.symmetric(vertical:10,horizontal: 20),
              child: Form(
      key: _formkey,
      child: Column(
        children: <Widget>[
            SizedBox(height: 20),
            TextFormField(
              style: TextStyle(color: Colors.white,
              fontSize: 18),
              decoration: InputDecoration(
                icon: Icon(Icons.person,
                color: Colors.grey[600],),
                alignLabelWithHint:true,
                hintText: 'name',
                hintStyle: TextStyle(color: Colors.white,
              fontSize: 18),
                fillColor: Colors.grey[900],
                filled: true,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white,width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white,width: 2),
                  )
                ),
                validator: (val) => val.isEmpty?'invalid name':null,
              onChanged: (val){
                setState(()=>name=val);
              },
              ),
            SizedBox(height: 20),
            TextFormField(
              style: TextStyle(color: Colors.white,
              fontSize: 18),
              decoration: InputDecoration(
                icon: Icon(Icons.email,
                color: Colors.grey[600],),
                alignLabelWithHint:true,
                hintText: 'email',
                hintStyle: TextStyle(color: Colors.white,
              fontSize: 18),
                fillColor: Colors.grey[900],
                filled: true,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white,width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white,width: 2),
                  )
                ),
                validator: (val) => val.isEmpty?'invalid email':null,
              onChanged: (val){
                setState(()=>email=val);
              },
              ),
            SizedBox(height: 20),
            TextFormField(
              style: TextStyle(color: Colors.white,
              fontSize: 18),
              decoration: InputDecoration(
                icon: Icon(Icons.lock,
                color: Colors.grey[600],),
                alignLabelWithHint:true,
                hintText: 'password',
                hintStyle: TextStyle(color: Colors.white,
              fontSize: 18),
                fillColor: Colors.grey[900],
                filled: true,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white,width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white,width: 2),
                  )
                ),
                validator: (val) => val.length<6?'password should be 6+ long':null,
              obscureText: true,
              onChanged: (val){
                setState(()=>password=val);
              },
              ),
            SizedBox(height: 20),
              RaisedButton(
                // shape: BeveledRectangleBorder (
                // side: BorderSide(color: Colors.indigo, width: 1.5)),
                color: Colors.white,

                elevation: 4,
                onPressed: ()async{
                  if(_formkey.currentState.validate()){
                    setState(()=>loading=true);
                  dynamic res=await _auth.regwithEmail(email, password);
                  Constants.MyName=name;
                  findCurUser(email, name);
                  if(res==null){
                    setState(() {
                          error='please supply valid email';
                          loading=false;});
                  }
                  else{
                    Constants.MyName=name;
                    await databaseService.uploadUserInfo(name, email);

                  }
                  
                  }
                },
                child: Text('Sign Up',style: (TextStyle(             
                   color: Colors.grey[900],
                   fontSize: 20,
                   fontWeight: FontWeight.w700,
)),),
                ),
                SizedBox(height: 10,),
                Text(
                  error,
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
        ],
        ),
      ),
            ),
            Container(
                  alignment: Alignment.bottomCenter,
                  child: RaisedButton.icon(
                    
                    color: Colors.white,
                    
        onPressed: (){
          widget.toggleview();
        },
        
        label: Text('Dont have an account? Sign Up',style: TextStyle(fontSize: 18,
        color: Colors.indigo[700]),),
        icon: Icon(Icons.person,color: Colors.indigo[700],),
        ),
                ),
                        ],
                      ),
          ),
        ),
    );
  }
}