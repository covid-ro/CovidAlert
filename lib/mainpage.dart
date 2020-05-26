import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'dart:core';
import 'package:geocoder/geocoder.dart';
bool loggedIn = false;

class mainPage extends StatefulWidget {
  @override
  _mainPageState createState() => new _mainPageState();
}

class User {
  String uID;
  GeoPoint loc;
  double altitude;
  int status;
  User(String this.uID, GeoPoint this.loc , double this.altitude , int this.status);
}
class Intersectie {
  String uID;
  DateTime timp;

  Intersectie(String name, DateTime time) {
    this.uID = name;
    this.timp = time;
  }
}
TextStyle stilTitlu = new TextStyle(color: Colors.black , fontSize: 18 , fontFamily: 'sfpro');
TextStyle stilSubtitlu = new TextStyle(color: Colors.black , fontSize: 15 , fontFamily: 'sfpro');
List<User> Helper = new List<User>();
class IntersectionCard extends StatelessWidget {
  DateTime date;
  double distance;
  String location;
  IntersectionCard({this.date , this.distance , this.location});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15 , horizontal: 3),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,

        child: Card(

          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
          ),
          color: Colors.white,
          elevation: 6.5,

          child: Padding(
            padding: const EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: Text('Cand ati luat contact?', textAlign: TextAlign.left,style: stilTitlu,),
                    ),
                  ],
                ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 35),
                        child: Text( 'Pe data de ' + date.day.toString()  + '.' + date.month.toString() +', la ora ' + date.hour.toString() + ':' + date.minute.toString(), textAlign: TextAlign.center, style: stilSubtitlu,),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 35),
                        child: Text('La ce distanta v-ati aflat ' ,textAlign: TextAlign.left,style: stilTitlu,),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 35),
                        child: Text(distance.toStringAsFixed(1) + 'm', textAlign: TextAlign.center,style: stilSubtitlu,),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 35),
                        child: Text('Unde? ' , textAlign: TextAlign.left,style: stilTitlu,),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(35 , 0 , 0 , 0),
                        child: Text(location, textAlign: TextAlign.center,style: stilSubtitlu,),
                      ),
                    ],
                  ),
                ],
              ),
          ),
        ),
      ),
    );
  }
}

class intersectionPage extends StatefulWidget {
  @override
  _intersectionPageState createState() => _intersectionPageState();
}
var widgetList = new List<Widget>();
class _intersectionPageState extends State<intersectionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title : Text('Intersectii' , style: TextStyle(color: Colors.black , fontFamily: 'sfpro' , fontSize: 24),),
        backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,),
      body: FutureParticipants(),
    );
  }
}


List<User> Lista = new List();
Position userPosition;
var buttonStatus = false;
var geolocator = Geolocator();
var locationOptions =
    LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 3);
StreamSubscription<Position> positionStream =
    geolocator.getPositionStream(locationOptions).listen((Position position) {
  userPosition = position;
});
Future<List> getParticipans() async {
  final _firestore = Firestore.instance;
  widgetList.clear();
  var qs = await _firestore
      .collection('intersections')
      .document(loggedInUser.uid)
      .get();
  if(qs.data['Users'] != null)
    newList = qs.data['Users'].toList();
  print('-------------------------------DEBUG-------------------------------------------');
  for(int i = 0 ; i < newList.length ; i ++)
  {
    var  a = newList[i].values;
    print('newlist');
    Timestamp timp;
    double distanta;
    String locatie;
    String uid;
    for(var helper in a) {
      print('1');
      print(helper.runtimeType);
      if (helper.runtimeType == double)
        distanta = helper;
      else if (helper.runtimeType == String) {
        if (helper.contains(',') == true)
          locatie = helper;
        else
          uid = helper;
        print('1');
      }
      else
        timp = helper;
      print('1');
    }
    print(timp);
    var poz = Lista.indexWhere((element) => element.status == 2 && element.uID == uid);
    if(poz != -1 && uid != loggedInUser.uid)
    {
      print('A intrat');
      widgetList.add(IntersectionCard(date: timp.toDate() , location: locatie, distance: distanta,));
    }

  }
  print('Ok end');
  return widgetList;
}

Widget FutureParticipants() {
  return FutureBuilder(
    builder: (context, projectSnap) {
      if (projectSnap.hasData == false) {
        //print('project snapshot data is: ${projectSnap.data}');
        return Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.redAccent),));
      }
      if(projectSnap.data.length == 0)
        return Scaffold(
          backgroundColor: Colors.white,
            body :Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      width: MediaQuery.of(context).size.width * 0.95,
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(25.0),
                          child: Text('Momentan nu exista date care sa sugereze ca ati intrat in contact cu o persoana diagnosticata cu COVID-19.' , textAlign: TextAlign.center, style: TextStyle(fontFamily: 'sfpro' , fontSize: 17),),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ));
      return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Text('Uh oh, se pare ca ati intrat in contact cu o persoana diagnosticata cu COVID-19. Mai jos puteti analiza informatii suplimentare.' , textAlign: TextAlign.center, style: TextStyle(fontFamily: 'sfpro' , fontSize: 17),),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              height: 400,
              child: ListView.builder(
                itemCount: projectSnap.data.length,
                itemBuilder: (context, index) {
                  IntersectionCard project = projectSnap.data[index];
                  return Column(
                    children: <Widget>[project],
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
    future: getParticipans(),
  );
}

FirebaseUser loggedInUser;
var newList = new List<dynamic>();
double DistantaPuncte;
GeoPoint lastLocation = new GeoPoint(0, 0);
class _mainPageState extends State<mainPage> {
  Icon alerta;


  Color buttonColor = Colors.redAccent;
  String mesaj_rosu = ' Înainte sa va părasiți locuința, apăsați pe butonul de mai sus pentru a activa aplicatța. Puteți opri CovidAlert cât timp vă aflați într-un loc sigur.';
  String mesaj_verde = ' Tot ce trebuie să faceți este să vă asigurați că aplicația rămane activă pe perioada în care doriți să fiți protejat!';
  String mesaj_bold_rosu = 'CovidAlert este inactivă!';
  String mesaj_bold_verde = 'CovidAlert este activă!';
  String mesaj_safe = 'În cazul în care luați contact cu o persoana diagnosticată cu COVID-19, puteți accesa informații suplimentare';
  String mesaj_unsafe = 'Apăsați pentru informații suplimentare';
  String intersectionTitle;
  String titlu_safe = 'Sunteți in siguranță !';
  String titlu_unsafe = 'Ați luat contact cu o persoana diagnosticata cu COVID-19!';
  String firstText = '1';
  String Str = '1';
  Color culoare_pers = Colors.green;
  var iconita = Icon(
    Icons.location_off,
    size: 50,
  );
  final _firestore = Firestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  Future getProjectDetails() async {
    await getCurrentUser();
    DocumentSnapshot ds =
    await _firestore.collection('users').document(loggedInUser.uid).get();
    intersectionTitle = '';
    if(ds.data['status'] > 1){
      intersectionTitle = titlu_unsafe;
    }
    else{
      intersectionTitle = titlu_safe;
    }
    print(intersectionTitle);
    return intersectionTitle;
  }
  Widget projectWidget() {
    return FutureBuilder(
      builder: (context, projectSnap) {
        String project;
        if (projectSnap.hasData == false) {
          //print('project snapshot data is: ${projectSnap.data}');
          return Card(child: Text('Se incarca...'));
        }
        String mesaj;
        project = projectSnap.data;
        Color backgroundColor;
        Color textColor;
        if(project == titlu_unsafe) {
          mesaj = mesaj_unsafe;
          backgroundColor = Colors.redAccent;
          textColor = Colors.white;
        }
        else {
          mesaj = mesaj_safe;
          backgroundColor = Colors.white;
          textColor = Colors.black;
        }
        return  Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Card(
            color: backgroundColor,
            elevation: 6.5,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
            ),
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                ),
                height: 650,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 300,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              project,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontFamily: 'sfpro' , fontWeight: FontWeight.normal , fontSize: 23 , color: textColor),
                              maxLines: 3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 300,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              mesaj,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontFamily: 'sfpro' , fontWeight: FontWeight.normal , fontSize: 17,color: textColor),
                              maxLines: 3,
                            ),
                          ),
                        ),
                      ],
                    ),

                    FlatButton(
                          color: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              side: BorderSide(color: Colors.transparent, width: 5)
                          ),
                          child :Icon(Icons.navigate_next , color:textColor,),
                          onPressed:() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => intersectionPage()),
                            );
                          }
                      ),
                    Expanded(
                      child: Container(

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          image: DecorationImage(
                            fit: BoxFit.scaleDown,
                            image: AssetImage('images/OMULETII.png'),
                          ),
                        ),
                      ),
                    ),


                  ],
                )
            ),
          ),
        );
      },
      future: getProjectDetails(),
    );
  }
  void initState ()  {

    alerta = Icon(
      Icons.check,
      color: Colors.black,
    );
    Str = mesaj_rosu;
    firstText = mesaj_bold_rosu;

    if (_auth.currentUser() == null)
      loggedIn = false;
    else
      loggedIn = true;
    super.initState();
    getCurrentUser();
    getpoz();
    init();
  }


  void getCurrentUser() async {
    try {
      loggedInUser = await _auth.currentUser();;
    } catch (e) {
      print(e);
    }
  }

  void getpoz() async {
    final position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    userPosition = position;
  }

  Timer timer;

  void init() async {

    alerta = Icon(
      Icons.person,
      size: 100,
      color: Colors.green,
    );
    DocumentSnapshot ds =
        await _firestore.collection('users').document(loggedInUser.uid).get();
    if (ds.exists == false)
      _firestore.collection('users').document(loggedInUser.uid).setData({
        'uID': loggedInUser.uid,
        'location': GeoPoint(userPosition.latitude, userPosition.longitude),
      });
  }

  void updateLocation() async {
    getpoz();
    Lista.clear();
    print(lastLocation.toString());
    if(lastLocation != GeoPoint(userPosition.latitude, userPosition.longitude)) {
      print('ok');
      await _firestore.collection('users')
          .document(loggedInUser.uid)
          .updateData({
        'location': GeoPoint(userPosition.latitude, userPosition.longitude),
        'altitude': userPosition.altitude,
      });
      lastLocation = GeoPoint(userPosition.latitude, userPosition.longitude);
    }
    getDocs();
    for (DocumentSnapshot a in list) {
      if(a.data['active'] == 0)
        continue;
      Lista.add(User(a.data['uID'], a.data['location'] , a.data['altitude'] , a.data['status']));
      if (a.data['uID'] == loggedInUser.uid) {
        if (a.data['status'] == 0) {
          culoare_pers = Colors.greenAccent[700];
          print('green');
          setState(() {
            culoare_pers;
          });
        }
        if (a.data['status'] == 1) {
          culoare_pers = Colors.yellowAccent;
          print('yellow');
          setState(() {
            culoare_pers;
          });
        }
        if (a.data['status'] == 2) {
          culoare_pers = Colors.redAccent;
          setState(() {
            culoare_pers;
          });
          print('red');
        }
      }
    }

    var list2;
    Intersectie newIntersection = new Intersectie('', DateTime.now());
    var qs = await _firestore
        .collection('intersections')
        .document(loggedInUser.uid)
        .get();
    if (qs.exists == false)
      _firestore
          .collection('intersections')
          .document(loggedInUser.uid)
          .setData({});
    else if(qs.data['Users'] != null)
      newList = qs.data['Users'].toList();
    print('-------------------------------DEBUG-------------------------------------------');


    List<Placemark> newPlace = await Geolocator().placemarkFromCoordinates(
        userPosition.latitude, userPosition.longitude);

    // this is all you need
    Placemark placeMark = newPlace[0];
    String name = placeMark.name;
    String subLocality = placeMark.subLocality;
    String locality = placeMark.locality;
    String administrativeArea = placeMark.administrativeArea;
    String postalCode = placeMark.postalCode;
    String country = placeMark.country;
    String address =
        "${name}, ${subLocality}, ${locality}, ${administrativeArea} ${postalCode}, ${country}";
    for (int i = 0; i < Lista.length; i++) {
      print('-------------------------------DEBUG-------------------------------------------');
      DistantaPuncte = await Geolocator().distanceBetween(Lista[i].loc.latitude, Lista[i].loc.longitude,
          userPosition.latitude, userPosition.longitude);
      print(DistantaPuncte);
      if (Lista[i].uID != loggedInUser.uid) {
        print(loggedInUser.uid);
        print(Lista[i].uID);
        newIntersection = Intersectie(Lista[i].uID, DateTime.now());
        if (DistantaPuncte <
            10 && (userPosition.altitude - Lista[i].altitude).abs() < 10) {
          if (
          newList.indexWhere((value) =>
          (value.values.contains(Lista[i].uID) == true)) == -1) {
            print('DEBUG');
            newList.add({
              'uID': Lista[i].uID,
              'date': DateTime.now(),
              'location': address,
              'distance': DistantaPuncte
            }
            );
          }
          else
            newList[newList.indexWhere(
                    (value) =>
                (value.values.contains(Lista[i].uID) == true))] = {
              'uID': Lista[i].uID,
              'date': DateTime.now(),
              'location': address,
              'distance': DistantaPuncte
            };
        }
      }
    }

    _firestore
        .collection('intersections')
        .document(loggedInUser.uid)
        .updateData({'Users': newList});
    print('doing it');
  }

  void alertIntersections() async {
    var qs = await _firestore
        .collection('intersections')
        .document(loggedInUser.uid)
        .get();
    _firestore
        .collection('users')
        .document(loggedInUser.uid)
        .updateData({'status': 2});
    print('Schimbat status');
    var Lista2 = qs.data['Users'];
    for (int i = 0; i < Lista2.length; i++) {
      _firestore
          .collection('users')
          .document(Lista2[i])
          .updateData({'status': 1});
    }
  }

  Future<bool> _onBackPressed() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            elevation: 10,
            title: Padding(
              padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 20),
              child: new Text('Sunteti Sigur?'),
            ),
            content: Padding(
              padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 20),
              child: new Text('Ca vreti sa iesiti din aplicatie'),
            ),
            actions: <Widget>[
              new GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("NO",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ),
              SizedBox(height: 16),
              new GestureDetector(
                  onTap: () => Navigator.of(context).pop(true),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("YES",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        )),
                  )),
            ],
          ),
        ) ??
        false;
  }

  Color getColor(button) {
    if (button == true)
      return Colors.green;
    else
      return Colors.red;
  }

  void timerStart() {
    timer =
        Timer.periodic(Duration(seconds: 10), (Timer t) => updateLocation());
  }

  void timerStop() {
    timer?.cancel();
  }

  var list;
  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Diagnostic COVID-19"),
          content: new Text("Ati fost diagnosticat cu COVID-19"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Nu"),
              textColor: Colors.red,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              textColor: Colors.green,
              child: new Text("Da"),
              onPressed: () {
                alertIntersections();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void getDocs() async {
    QuerySnapshot qs = await _firestore.collection('users').getDocuments();
    list = qs.documents;
  }

  void getDocs2() async {
    QuerySnapshot qs =
        await _firestore.collection('intersections').getDocuments();
    list = qs.documents;
  }
  AssetImage imagineScut = AssetImage('images/SCUT_ROSU.png');
  Widget build(BuildContext context) {
    init();
    return new WillPopScope(
      onWillPop: _onBackPressed,
      child: new Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text('CovidAlert' ,style: TextStyle(fontWeight: FontWeight.bold , fontSize: 25, color: Colors.black),),
        ),
        body: Center(
          child: Column(
            children: <Widget>[

              SizedBox(height: 10,),

              Container(
                width: 150,
                height: 150,
                child: FloatingActionButton(
                  focusColor: Colors.white,
                  splashColor: Colors.white,
                  foregroundColor: Colors.white,
                  hoverColor: Colors.white,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  onPressed: () {
                    init();
                    if (buttonStatus == false) {
                      Str = mesaj_verde;
                      firstText = mesaj_bold_verde;
                      buttonStatus = true;
                      iconita = Icon(Icons.location_on, size: 50);
                      buttonColor = Colors.greenAccent[700];
                      _firestore.collection('users').document(loggedInUser.uid).updateData({'active' : 1});
                      imagineScut = AssetImage('images/SCUT_VERDE.png');
                      print('DID IT');
                    } else if (buttonStatus == true) {
                      firstText = mesaj_bold_rosu;
                      Str = mesaj_rosu;
                      iconita = Icon(Icons.location_off, size: 50);
                      _firestore.collection('users').document(loggedInUser.uid).updateData({'active' : 0});
                      buttonStatus = false;
                      buttonColor = Color.fromRGBO(202, 42, 42, 1);
                      imagineScut = AssetImage('images/SCUT_ROSU.png');
                    }
                    setState(() {
                      buttonColor;
                      alerta;
                    });
                    if (buttonStatus == true) {
                      timerStart();
                    } else
                      timerStop();
                  },
                  child: AnimatedContainer(
                    width: 150,
                    height: 150,
                    child: Image(image: imagineScut),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    duration: Duration(milliseconds: 300),
                  ),
                ),
              ),
              SizedBox(
                height: 15 ,
              ),
              Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 800),
                  child: Card(
                    elevation: 6.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    child: Container(
                      height: 100,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: firstText,
                            style: TextStyle(fontSize: 18, color: buttonColor, fontWeight: FontWeight.bold , fontFamily: 'sfpro'),
                            children: <TextSpan>[
                            TextSpan(text: Str, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400, color: Colors.black)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                  width:500,
                  height: 300,
                  child: projectWidget()),
            ],
          ),
        ),
      ),
    );
  }
}
