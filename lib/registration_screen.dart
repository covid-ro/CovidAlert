import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:covid_alert/mainpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}
TextStyle normal = new TextStyle(
  color: Colors.black,
);
TextStyle normalhint = new TextStyle(
  color: Colors.grey,
);
class _RegistrationScreenState extends State<RegistrationScreen> {
  String email;
  final key1 = new GlobalKey<ScaffoldState>();
  String password;
  final _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      key: key1,
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.0),
        child: Column(
          children: <Widget>[
            Hero(
              tag: 'reallogo',
              child: Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                height: MediaQuery
                    .of(context)
                    .size
                    .height * 0.25,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('images/SPHERESTOP.png'),
                  ),
                ),
              ),
            ),

            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: Row(
                children: <Widget>[
                  Text(
                    'Înregistrare',
                    style: TextStyle(
                      fontFamily: 'sfpro',
                      fontWeight: FontWeight.bold,
                      fontSize: 35,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: Row(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: TextField(
                      keyboardType: TextInputType.emailAddress,
                      style:normal,
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        email = value;
                      },
                      decoration: InputDecoration(
                        hintStyle: TextStyle(
                          fontFamily: 'sfpro',
                          fontSize: 17,
                          color: Colors.black.withOpacity(0.4)
                        ),
                        hintText: 'e-mail',
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color:  Color.fromRGBO(234, 240, 255, 1), width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color:  Color.fromRGBO(234, 240, 255, 1), width: 2.0),
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: Row(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: TextField(
                      obscureText: true,
                      textAlign: TextAlign.center,
                      style: normal,
                      onChanged: (value) {
                        password = value;
                      },
                      decoration: InputDecoration(
                        hintText: 'parola',
                        hintStyle: TextStyle(
                          fontFamily: 'sfpro',
                          fontSize: 17,
                          color: Colors.black.withOpacity(0.4)
                      ),
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color:  Color.fromRGBO(234, 240, 255, 1), width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color:  Color.fromRGBO(234, 240, 255, 1), width: 2.0),
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 60.0,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Material(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                elevation: 5.0,
                child: MaterialButton(
                  onPressed: () async {
                    try {
                      final newuser = await _auth
                          .createUserWithEmailAndPassword(
                          email: email, password: password);
                      await newuser.user.sendEmailVerification();
                      if(newuser != null && newuser.user.isEmailVerified == true) {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => mainPage()));
                        key1.currentState.showSnackBar(new SnackBar(
                          content: new Text(
                              "V-am trimis un email de confirmare!"),
                        ));
                      }
                      else
                        {
                          key1.currentState.showSnackBar(new SnackBar(
                            content: new Text(
                                "Sunteti deja inregistrat in aplicatie!"),
                          ));
                        }

                    }
                    catch(e)
                    {

                      key1.currentState.showSnackBar(new SnackBar(
                        content: new Text(
                            "Sunteti deja inregistrat in aplicatie!"),
                      ));
                    }
                  },
                  minWidth: 160.0,
                  height: 42.0,
                  child: Text(
                    'Înregistrare',
                    style: TextStyle(color: Colors.white , fontFamily: 'sfpro' , fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}