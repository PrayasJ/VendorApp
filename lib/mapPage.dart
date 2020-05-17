import 'dart:async';
import 'dart:core';
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'databaseClass.dart';
import 'homePage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapPage extends StatefulWidget {
  MapPageState createState() => MapPageState();
}

 int index;

class MapPageState extends State<MapPage> {
  double lat;
  double long;
  GoogleMapController mapController;
  BitmapDescriptor pinLocationIcon;
  bool mapCreated = false;
  DatabaseClass dataBase = new DatabaseClass();
  String vendorData;

  Geolocator locator = Geolocator();

  static StreamSubscription<Position> streamSub;

  bool helpNeeded = false;

  static StreamSubscription vendorStream;
  //Set<Marker> vendorMarkerSet = new Set<Marker>();
  MarkerId markerId = new MarkerId("Vendor");
  Marker vendorMarker;
  Map<MarkerId, Marker> vendorMarkerMap = <MarkerId, Marker>{};
  List<Marker> allMarkers = [];
  DatabaseReference vic;
  String uid;

  //Auth auth = new Auth();


  @override
  void initState() {
    //vendorMarkerSet.add(vendorMarker);
    BitmapDescriptor.fromAssetImage(
         ImageConfiguration(devicePixelRatio: 2.5),
         'images/marker.png').then((onValue) {
            pinLocationIcon = onValue;
         });
    lat = 100.0;
    long = 50.0;
    vendorMarker = new Marker(markerId: markerId);
    vendorMarkerMap[markerId] = vendorMarker;
    locator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((pos) {
      setState(() {
        lat = pos.latitude;
        long = pos.longitude;
        addMarkers();
      });
    });

    dataBase.reqAlert().then((stream) {
      stream.listen((event) async {
        vendorData = await HomePageState.connectFlutterToBackend();
        if (vendorData != "" && helpNeeded == false) {
          vic =
              FirebaseDatabase.instance.reference().child("Users/$vendorData");

          vic.once().then((snap) {
            setState(() {
              helpNeeded = true;
              vendorMarker = new Marker(
                  markerId: markerId,
                  position:
                      LatLng(snap.value["Latitude"], snap.value["Longitude"]));
              vendorMarkerMap[markerId] = vendorMarker;
            });
          });
        }
      });
    });


    streamSub = locator
        .getPositionStream(LocationOptions(
            accuracy: LocationAccuracy.best, distanceFilter: 10))
        .listen((Position position) {
      if (mapCreated) {
        print("Lat: ${position.latitude}, Long: ${position.longitude}");
        mapController.moveCamera(CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude)));
      }
    });
    super.initState();
  }

  @override
void addMarkers(){
  var random = new Random();
  for (int i=1;i<=5;i++){
            allMarkers.add(Marker(
            markerId: MarkerId('Vendor$i'),
            icon: pinLocationIcon,
            draggable: false,
            onTap: () {
              print('Marker Tapped');
              index=i-1;
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => display_items()));
            },
            position: LatLng(lat + (random.nextDouble() - 0.5) / 100,
                long + (random.nextDouble() - 0.5) / 100)));
  }
}

  @override
  Widget build(BuildContext context) {
    if (helpNeeded) {
      vendorStream =
          dataBase.getVendorsLocation(vendorData).listen((event) async {
        DataSnapshot snaps = await vic.once();
        if (mapCreated) {
          //vendorMarkerSet.remove(vendorMarker);
          if (event.snapshot.key == "Latitude") {
            vendorMarker = new Marker(
              markerId: markerId,
              position: LatLng(event.snapshot.value, snaps.value["Longitude"]),
            );
          } else if (event.snapshot.key == "Longitude") {
            vendorMarker = new Marker(
              markerId: markerId,
              position: LatLng(snaps.value["Latitude"], event.snapshot.value),
            );
          }
          //vendorMarkerSet.add(vendorMarker);
        }
        setState(() {
          vendorMarkerMap[markerId] = vendorMarker;
        });
      });
      Timer(Duration(minutes: 1), () {
        vendorStream.cancel();
        setState(() {
          vendorMarker = new Marker(markerId: markerId);
          vendorMarkerMap[markerId] = vendorMarker;
        });
      });
      helpNeeded = false;
    }
    return Container(
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(lat, long),
          zoom: 15,
        ),
        buildingsEnabled: false,
        myLocationEnabled: true,
        onMapCreated: (controller) {
          mapController = controller;
          mapCreated = true;
        },
        markers: Set.from(allMarkers),
      ),
    );
  }
}

List<int> count;

int countInit(DocumentSnapshot document){
  count = [];
  for(int i=0;i<document.data.length;i++){
    count.add(0);
  }
  return document.data.length;
}

class display_items extends StatefulWidget {
  @override
  _display_itemsState createState() => _display_itemsState();
}


class _display_itemsState extends State<display_items> {
  // int i=0;
  TextEditingController _controller = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List'),
        backgroundColor: Colors.red,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: Icon(Icons.shopping_cart),
        onPressed: () {},
      ),
      body: StreamBuilder(
          stream: Firestore.instance.collection('Vendors').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Text('Loading..');
            return ListView.builder(
              itemCount: countInit(snapshot.data.documents[index]),
              itemBuilder: (BuildContext context, int i) {
                return Card(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      //leading: Icon(Icons.album),
                      title: Text(snapshot.data.documents[index]['Product${i+1}']['name']),
                      subtitle: Text("Rs. "+snapshot.data.documents[index]['Product${i+1}']['cost']
                          .toString()),
                    ),
                    Row(
                      mainAxisAlignment:MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        FloatingActionButton(
                          child: Icon(Icons.add_circle_outline),
                          backgroundColor: Colors.black,
                          
                          onPressed: () {
                            setState(() {
                              count[i]++;
                            });
                            },
                        ),
                        FloatingActionButton(
                          child: Icon(Icons.remove_circle_outline),
                          backgroundColor: Colors.black,
                          onPressed: () {
                            setState(() {
                              count[i]-=count[i]>0?1:0;
                            });
                            },
                        ),
                        Text('${count[i]}'),
                        SizedBox(width: 20),
                      ],
                    ),
                  ],
                ));
              },
            );
          }),
    );
  }
}
