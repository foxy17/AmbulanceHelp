import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class Loc extends StatefulWidget {
  FirebaseUser user;
  Loc({Key key, this.user}) : super(key: key);
  @override
  _LocState createState() => _LocState();
}

class _LocState extends State<Loc> {
  @override
  void initState() {

    super.initState();
  }

  var location = new Location();


  Geoflutterfire geo = Geoflutterfire();
  LocationData userLocation;
  Future<LocationData> getLocation() async {
    print(widget.user.uid);
    LocationData currentLocation;
    try {
      currentLocation = await location.getLocation();
      GeoFirePoint myLocation = geo.point(
          latitude: currentLocation.latitude,
          longitude: currentLocation.longitude);
      var point =
          new GeoPoint(currentLocation.latitude, currentLocation.longitude);
      Firestore.instance
          .collection('vehicle')
          .document(widget.user.uid)
          .updateData({'location': myLocation.data, 'point': point});
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.exit_to_app),
        onPressed: () => FirebaseAuth.instance.signOut(),
      ),
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            userLocation == null
                ? CircularProgressIndicator()
                : Text("Location:" +
                    userLocation.latitude.toString() +
                    " " +
                    userLocation.longitude.toString()),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RaisedButton(
                onPressed: () {
                  getLocation().then((value) {
                    setState(() {
                      userLocation = value;
                    });
                  });
                },
                color: Colors.blue,
                child: Text(
                  "Get Location",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
