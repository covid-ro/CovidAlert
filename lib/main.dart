import 'package:flutter/material.dart';
import 'package:covid_alert/welcome_screen.dart';
import 'package:covid_alert/mainpage.dart';
import 'package:covid_alert/infoPage.dart';
void main() => runApp(FlashChat());

class FlashChat extends StatelessWidget {
  _decideMainPage()
  {
    if(loggedIn == true)
      return mainPage();
    else
      return decideInfoPage();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _decideMainPage(),
    );
  }
}