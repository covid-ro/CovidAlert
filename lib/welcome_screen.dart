import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:covid_alert/login_screen.dart';
import 'package:covid_alert/registration_screen.dart';
class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Spacer(),
            Row(
              children: <Widget>[
                Spacer(),
                Hero(
                  tag: 'logo',
                  child: Container(

                    alignment: Alignment.center,
                    child: Icon(Icons.check_circle,
                      color: Colors.red,
                      size: 80,
                    ),
                    width: 80,
                    height: 80.0,
                  ),
                ),
                Text(
                  'CovidAlert',
                  style: TextStyle(
                      fontFamily: 'sfpro',
                      fontSize: 45,
                    fontWeight: FontWeight.bold
                  ),
                ),
                Spacer(),

              ],
            ),
            SizedBox(height: MediaQuery
                .of(context)
                .size
                .height * 0.1,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 40,
                  width: MediaQuery.of(context).size.width*0.6,
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                        ),
                        color:Color.fromRGBO(234, 240, 255 , 1) ,
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                        },
                        child: Text(
                          'Autentificare',
                          style: TextStyle(
                              fontFamily: 'sfpro',
                              fontSize: 18
                          ),
                        ),
                      ),

              ),
            ),
            SizedBox(height: 15,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                    width: MediaQuery.of(context).size.width*0.6,
                    height: 40,
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),

                      ),
                      color:Color.fromRGBO(216, 225, 247 , 1) ,
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => RegistrationScreen()));
                      },
                      child: Text(
                        'Înregistrare',
                        style: TextStyle(
                          fontFamily: 'sfpro',
                          fontSize: 18
                        ),
                      ),
                    ),
              ),
            ),
           SizedBox(height: MediaQuery
               .of(context)
               .size
               .height * 0.15,),
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
                    .height * 0.3,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('images/BOTTOMSPHERES.png'),
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