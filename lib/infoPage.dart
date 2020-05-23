import 'package:flutter/material.dart';
import 'package:covid_alert/main.dart';
import 'package:covid_alert/welcome_screen.dart';
import 'package:covid_alert/mainpage.dart';
class decideInfoPage extends StatefulWidget {
  @override
  _decideInfoPageState createState() => new _decideInfoPageState();
}
var _infoPage = 1;
class _decideInfoPageState extends State<decideInfoPage> {
  @override
  Widget build(BuildContext context) {
    if (_infoPage == 1) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.35,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage('images/PozaOameni1.png'),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(child: Text(
                    'Împreuna putem opri\nrăspandirea COVID-19',
                    maxLines: 2,
                    style: TextStyle(
                        fontSize: 27, fontWeight: FontWeight.bold, fontFamily: 'sfpro'), )),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Row(
                children: <Widget>[
                  Expanded(child: Text(
                      'Aplicația COVIDAlert va înregistra fiecare moment în care dumneavoastra luați contact cu alți utilizatori ai aplicației. Informațiile înregistrate vor fi criptate și securizate astfel încat accesul nepermis să nu fie posibil.\n\nCu ajutorul acestora, în momentul în care un utlilizator cu care ați luat contact este diagnosticat cu COVID-19, veți primi o notificare pentru a lua cunoștina de existența oricărui risc, astfel încat sa puteți lua măsuri de prevenire a înrăutațirii sănătății dumneavoastra, precum și a răspândirii virusului.',
                    style: TextStyle(fontFamily: 'sfpro' , fontWeight: FontWeight.normal, fontSize: 19),
                  )),
                ],
              ),
            ),
            Spacer(),
            ButtonTheme(
              buttonColor: Colors.blue,
              minWidth: MediaQuery
                  .of(context)
                  .size
                  .width * 0.6,
              height: 40,
              child: FlatButton(
                color: Color.fromRGBO(216, 225, 247 , 1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(93.0),
                    side: BorderSide(color: Colors.transparent)
                ),
                child: Text('Vreau să ajut !' , style: TextStyle(fontFamily: 'sfpro' , fontSize: 19 ,color: Colors.black.withOpacity(0.9)), ),
                onPressed: () {
                  setState(() {
                    _infoPage = 2;
                  });
                },
              ),
            ),
            SizedBox(
              height: 30,
            )
          ],
        ),
      );
    }
    else if (_infoPage == 2) {
      return WelcomeScreen();
    }
  }
}