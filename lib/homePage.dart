import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:VendorApp/login.dart';

import 'profilePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:geolocator/geolocator.dart';
import 'authentication.dart';
import 'main.dart';
import 'getUserData.dart';
import 'mapPage.dart';
import 'databaseClass.dart';

class HomePage extends StatefulWidget {
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  double _start = 1;
  int _selectedIndex = 0;
  bool run = true;
  static bool maps = false;
  bool reqSending = false;

  static Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  GeolocationStatus permissionStatus = GeolocationStatus.granted;
  static var locationOptions =
      LocationOptions(accuracy: LocationAccuracy.best, distanceFilter: 5);

  static Auth auth = new Auth();
  static GetUserData getData = new GetUserData();

  static Future<String> connectFlutterToBackend() async {
    if (Platform.isAndroid) {
      var channel = MethodChannel("com.example.sukhmay.messages");
      String data = await channel.invokeMethod("startService");
      print(data);
      return data;
    }
    return null;
  }

  String vendorData;

  Future<void> locationPermission() async {
    GeolocationStatus stat =
        await Geolocator().checkGeolocationPermissionStatus();
    if (stat != GeolocationStatus.granted) {
      try {
        await geolocator.getCurrentPosition();
        permissionStatus =
            await Geolocator().checkGeolocationPermissionStatus();
      } catch (e) {
        permissionStatus =
            await Geolocator().checkGeolocationPermissionStatus();
      }
    } else {
      permissionStatus = stat;
    }
  }

  static Future<StreamSubscription<Position>> streamPositon(String path) async {
    String uid = await auth.returnUid();
    return geolocator
        .getPositionStream(locationOptions)
        .listen((Position position) {
      //MapPageState.lat = position.latitude;
      //MapPageState.long = position.longitude;
      dataBase.pushDataWithoutKey(path + "/$uid/Latitude", position.latitude);
      dataBase.pushDataWithoutKey(path + "/$uid/Longitude", position.longitude);
    });
  }

  static DatabaseClass dataBase = new DatabaseClass();

  static StreamSubscription<Position> alwaysPositionStream;
  static StreamSubscription<Position> reqPositionStream;

  Widget req;
  List<Widget> itemWidgets = new List<Widget>();

  @override
  void initState() {
    locationPermission().then((_) async {
      setState(() {});
      if (permissionStatus == GeolocationStatus.granted) {
        connectFlutterToBackend();      }
    });

    itemWidgets = <Widget>[
      MapPage(),
      FutureBuilder(
          future: getData.fetchData(),
          builder: (BuildContext c, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              List<dynamic> dataLis = snapshot.data;
              return ProfilePage(
                  dataLis[0], dataLis[1], dataLis[2], dataLis[3], dataLis[4]);
            } else {
              return Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          }),
      Icon(Icons.reorder)
    ];

    super.initState();
  }

Widget transition(double val){
  return Builder(
      builder: (BuildContext c) {
        return Center(
          child: Container(
            child: InkWell(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: new BorderRadius.all(Radius.circular(1000*_start)),
                    color: Color(0x0350b3ab),
                    border: Border.all(
                      color: Color(0x0350b3ab),
                      width: 0,
                    ),
                  ),
                  alignment: Alignment(0, 0),
                ),
              ),
            ),
            color: Colors.grey[850],
            width: MediaQuery.of(c).size.width*(1-_start),
            height: MediaQuery.of(c).size.height*(1-_start),
          ),
        );
      },
    );
}

  Widget build(BuildContext context) {
    return permissionStatus == GeolocationStatus.granted
        ? Scaffold(
            backgroundColor: Colors.grey[850],
            body: itemWidgets[_selectedIndex],
            bottomNavigationBar: BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: Icon(Icons.home,color:_selectedIndex==0?Colors.blue:Colors.white), title: Text("Home",style:TextStyle(color:_selectedIndex==0?Colors.blue:Colors.white))),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person_pin,color:_selectedIndex==1?Colors.blue:Colors.white), title: Text("Profile",style:TextStyle(color:_selectedIndex==1?Colors.blue:Colors.white))),
              ],
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              selectedItemColor: Colors.blue,
              backgroundColor: Color(0x33333333),
            ),
            floatingActionButton: Row(
              children: <Widget>[
                FloatingActionButton(
                  child: Icon(Icons.exit_to_app),
                  onPressed: () {
                    OpeningScreenState.authStatus = AuthStatus.NOT_LOGGED_IN;
                    auth.logOut();
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (BuildContext c) {
                      return LoginPage();
                    }), (Route<dynamic> route) => false);
                  },
                  backgroundColor: Colors.blueAccent,
                  heroTag: 1,
                ),
                SizedBox(width: 20),
              ],
              mainAxisAlignment: MainAxisAlignment.end,
            ))
        : Scaffold(
            body: Container(
              child: Center(
                child: Column(
                  children: <Widget>[
                    Text(
                        "You cannot use the app without giving permission.(Choose 'Allow all the time')"),
                    RaisedButton(
                      child: Text("OK"),
                      onPressed: () {
                        locationPermission().then((_) async {
                          setState(() {});

                          if (permissionStatus == GeolocationStatus.granted) {
                            alwaysPositionStream = await streamPositon("Users");
                          }
                        });
                      },
                    )
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
              ),
            ),
          );
  }
}
