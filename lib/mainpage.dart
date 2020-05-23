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
TextStyle stilTitlu = new TextStyle(color: Colors.redAccent , fontSize: 20 , fontWeight: FontWeight.bold);
TextStyle stilSubtitlu = new TextStyle(color: Colors.black , fontSize: 15 , fontWeight: FontWeight.bold);
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
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
        ),
        color: Colors.white,
        elevation: 10,

        child: Padding(
          padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
              Text('Data si ora la care v-ati intersectat:', textAlign: TextAlign.center,style: stilTitlu,),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0 , 2, 0 , 10),
                  child: Text( date.toString(), textAlign: TextAlign.center, style: stilSubtitlu,),
                ),
                Text('Distanta la care v-ati aflat: ' ,textAlign: TextAlign.center,style: stilTitlu,),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0 , 2, 0 , 10),
                  child: Text(distance.toString() , textAlign: TextAlign.center,style: stilSubtitlu,),
                ),
                Text('Locul in care v-ati intersectat: ' , textAlign: TextAlign.center,style: stilTitlu,),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0 , 2, 0 , 10),
                  child: Text(location, textAlign: TextAlign.center,style: stilSubtitlu,),
                ),
              ],
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
      appBar: AppBar(title : Text('Ultimele intersectii'),
        backgroundColor: Colors.redAccent,
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
      return ListView.builder(
        itemCount: projectSnap.data.length,
        itemBuilder: (context, index) {
          IntersectionCard project = projectSnap.data[index];
          return Column(
            children: <Widget>[project],
          );
        },
      );
    },
    future: getParticipans(),
  );
}
FirebaseUser loggedInUser;
var newList = new List<dynamic>();
double DistantaPuncte;
class _mainPageState extends State<mainPage> {
  Icon alerta;


  Color buttonColor = Colors.redAccent;
  String mesaj_rosu = 'Apasati butonul rosu pentru a porni aplicatia';
  String mesaj_verde = 'Apasati butonul verde pentru a opri aplicatia';
  String Str = '1';
  Color culoare_pers = Colors.green;
  var iconita = Icon(
    Icons.location_off,
    size: 50,
  );
  final _firestore = Firestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    alerta = Icon(
      Icons.check,
      color: Colors.black,
    );
    Str = mesaj_rosu;
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
      final user = await _auth.currentUser();
      loggedInUser = user;
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
    await _firestore.collection('users').document(loggedInUser.uid).updateData({
      'location': GeoPoint(userPosition.latitude, userPosition.longitude) , 'altitude': userPosition.altitude,
    });
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

              SizedBox(height: 40,),

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
                      buttonStatus = true;
                      iconita = Icon(Icons.location_on, size: 50);
                      buttonColor = Colors.greenAccent[700];
                      _firestore.collection('users').document(loggedInUser.uid).updateData({'active' : 1});
                      imagineScut = AssetImage('images/SCUT_VERDE.png');
                      print('DID IT');
                    } else if (buttonStatus == true) {
                      Str = mesaj_rosu;
                      iconita = Icon(Icons.location_off, size: 50);
                      _firestore.collection('users').document(loggedInUser.uid).updateData({'active' : 0});
                      buttonStatus = false;
                      buttonColor = Colors.redAccent;
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
              Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 800),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide(color: Colors.grey.withOpacity(0.2))
                    ),
                    child: Container(
                      height: 100,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          Str,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 40,),
              SizedBox(
                  height: 200,
                  width: 300,
                  child: Center(
                    child: ButtonTheme(
                      minWidth: 400,
                      height: 50,
                      child: FlatButton(
                          color: culoare_pers,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              side: BorderSide(color: culoare_pers, width: 5)
                          ),
                          child :Text('Vedeti ultimele intersectii' , style: TextStyle(color: Colors.white ,fontSize: 20),),
                          onPressed:() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => intersectionPage()),
                            );
                          }
                      ),
                    ),
                  )),

            ],
          ),
        ),
      ),
    );
  }
}
