import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
bool loggedIn = false;
class mainPage extends StatefulWidget {
  @override
  _mainPageState createState() => new _mainPageState();
}
class User
{
  String uID;
  GeoPoint loc;
  User(String this.uID, GeoPoint this.loc);
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
class _mainPageState extends State<mainPage> {
  Icon alerta ;
  Color buttonColor = Colors.red;
  String mesaj_rosu = 'Apasati butonul rosu pentru a porni aplicatia';
  String mesaj_verde = 'Apasati butonul verde pentru a opri aplicatia';
  String Str = '1';
  Color culoare_pers = Colors.green;
  var iconita = Icon(Icons.location_off , size: 50,);
  final _firestore = Firestore.instance;
  final _auth = FirebaseAuth.instance;
  FirebaseUser loggedInUser;
  @override
  void initState() {
    alerta = Icon(Icons.check , color: Colors.black,);
    Str = mesaj_rosu;
    if(_auth.currentUser() == null)
      loggedIn = false;
    else
      loggedIn = true;
    super.initState();
    getCurrentUser();
    getpoz();
    init();
  }

  double computeDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }
  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      loggedInUser = user;
      print(user.uid);
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
    alerta = Icon(Icons.person, size: 100, color: Colors.green,);
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
      'location': GeoPoint(userPosition.latitude, userPosition.longitude),
    });
    getDocs();
    for(DocumentSnapshot a in list)
    {
      Lista.add(User(a.data['uID'] ,a.data['location']));
      if(a.data['uID'] == loggedInUser.uid)
        {
          if(a.data['status'] == 0) {
            culoare_pers = Colors.green;
            print('green');
            setState(() {
              culoare_pers;
            });
          }
          if(a.data['status'] == 1) {
            culoare_pers = Colors.yellow;
            print('yellow');
            setState(() {
              culoare_pers;
            });
          }
          if(a.data['status'] == 2) {
            culoare_pers = Colors.red;
            setState(() {
              culoare_pers;
            });
            print('red');
          }
        }
    }

    var list2;
    var newList = List<dynamic>();
    var qs = await _firestore.collection('intersections').document(loggedInUser.uid).get();
    if(qs.exists == false)
      _firestore.collection('intersections').document(loggedInUser.uid).setData({});
    newList = qs.data['Users'];
    for(int i = 0 ; i < Lista.length ; i ++)
      if(Lista[i].uID != loggedInUser.uid)
      {
        if(computeDistance(Lista[i].loc.latitude , Lista[i].loc.longitude , userPosition.latitude , userPosition.longitude) < 5.0)
          if(newList.indexOf(Lista[i].uID) == -1)
          newList.add(Lista[i].uID);
     }
    _firestore.collection('intersections').document(loggedInUser.uid).updateData({'Users' : newList});
    print('doing it');
  }
  void alertIntersections() async
  {
    var qs = await _firestore.collection('intersections').document(loggedInUser.uid).get();
    var Lista2 = qs.data['Users'];
    _firestore.collection('users').document(loggedInUser.uid).updateData({'status' : 2});
    for(int i = 0 ; i < Lista2.length ; i ++)
      {
        _firestore.collection('users').document(Lista2[i]).updateData({'status' : 1});
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
          padding: const EdgeInsets.symmetric(vertical: 1 , horizontal: 20),
          child: new Text('Sunteti Sigur?'),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 1 , horizontal: 20),
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
                  )
              ),
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
                    )
                ),
              )

          ),
        ],
      ),
    ) ??
        false;
  }
  Color getColor(button)
  {
    if(button == true)
      return Colors.green;
    else
      return Colors.red;
  }
  void timerStart() {
    timer = Timer.periodic(
        Duration(seconds: 5), (Timer t) => updateLocation());
  }
  void timerStop()
  {
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
  void getDocs() async
  {
    QuerySnapshot qs = await _firestore.collection('users').getDocuments();
    list = qs.documents;
  }
  void getDocs2() async
  {
    QuerySnapshot qs = await _firestore.collection('intersections').getDocuments();
    list = qs.documents;
  }
  Widget build(BuildContext context) {
    init();
    return new WillPopScope(
      onWillPop: _onBackPressed,
      child: new Scaffold(
        appBar: AppBar(
          title: Text('CovidAlert'),
        ),
        body: Center(
            child: Column(
              children: <Widget>[
                SizedBox(height: 200,child: Icon(Icons.person, size: 100 ,color: culoare_pers,)),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15 , horizontal: 5),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 800),
                    child: Text(Str,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),),
                  ),
                ),

                Container(
                  width: 100,
                  height: 100,
                  child: FloatingActionButton(

                    onPressed: () {
                      init();
                      if (buttonStatus == false) {
                        Str = mesaj_verde;
                        buttonStatus = true;
                        iconita = Icon(Icons.location_on,size : 50);
                        buttonColor = Colors.green;
                        print('DID IT');
                      }
                      else if (buttonStatus == true) {
                        Str = mesaj_rosu;
                        iconita = Icon(Icons.location_off , size : 50);

                        buttonStatus = false;
                        buttonColor = Colors.red;
                      }
                      setState(() {
                        buttonColor ;
                        alerta ;
                      });
                      if(buttonStatus == true) {
                        timerStart();
                        }
                      else
                        timerStop();

                    },
                      child: AnimatedContainer(
                        width: 100,
                        height: 100,
                        child: iconita,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: buttonColor,

                        ),
                          duration: Duration(milliseconds:300),
                      ),
                  ),
                ),
                SizedBox(height: 300,),

                Align(
                  alignment: Alignment.bottomCenter,
                  child:RaisedButton(
                    elevation: 15,
                    color: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.red)
                    ),
                    onPressed: () {
                      _showDialog();
                    },
                    child: const Text('Am fost diagnosticat', style: TextStyle(fontSize: 20 , color: Colors.white)),
                ),
                ),
              ],
            ),
          ),
      ),
    );
  }
}
