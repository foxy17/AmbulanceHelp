import 'package:amb_loc/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_map_polyline/google_map_polyline.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:location/location.dart';

const double CAMERA_ZOOM = 13;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 30;
LatLng SOURCE_LOCATION = LatLng(28.4507681,77.569137);
LatLng DEST_LOCATION = LatLng(28.4507681, 77.5845697);

class MapPath extends StatefulWidget {
  @override
  _MapPathState createState() => _MapPathState();
}

class _MapPathState extends State<MapPath> {
  Loc obj=Loc();


  String googleAPIKey = "AIzaSyA57cKmNTKd6g6lQR9uAOO0IV12nQD4OtA";

  @override
  void initState() {
    super.initState();
  }

  int _polylineCount = 1;
  Map<PolylineId, Polyline> _polylines = <PolylineId, Polyline>{};
  GoogleMapController _controller;


  GoogleMapPolyline _googleMapPolyline =
  new GoogleMapPolyline(apiKey: "AIzaSyAZQl0TRenJIoCbKNjDKmT2LN9Y94um9qs");

  //Polyline patterns
  List<List<PatternItem>> patterns = <List<PatternItem>>[
    <PatternItem>[], //line
    <PatternItem>[PatternItem.dash(30.0), PatternItem.gap(20.0)], //dash
    <PatternItem>[PatternItem.dot, PatternItem.gap(10.0)], //dot
    <PatternItem>[
      //dash-dot
      PatternItem.dash(30.0),
      PatternItem.gap(20.0),
      PatternItem.dot,
      PatternItem.gap(20.0)
    ],
  ];

  LatLng _mapInitLocation = SOURCE_LOCATION;

  LatLng _originLocation = SOURCE_LOCATION;
  LatLng _destinationLocation = DEST_LOCATION;

  bool _loading = false;

  _onMapCreated(GoogleMapController controller) {
    setState(() {
      _controller = controller;
    });
  }

  Future<void> _goToMyLocation() async {

    var location = new Location();
    LocationData currentLocation ;
    try {
      _setLoadingMenu(true);
      currentLocation = await location.getLocation();
      SOURCE_LOCATION=LatLng(currentLocation.latitude, currentLocation.longitude);
    } catch (e) {
      currentLocation = null;
    }
    _originLocation=SOURCE_LOCATION;
    final GoogleMapController controller = await _controller;
    print(SOURCE_LOCATION);
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        bearing: 192.8334901395799,
        target: SOURCE_LOCATION,
        tilt: 20,
        zoom: 15)));
    _setLoadingMenu(false);
  }

  //Get polyline with Location (latitude and longitude)
  _getPolylinesWithLocation() async {
    _setLoadingMenu(true);
    List<LatLng> _coordinates =
    await _googleMapPolyline.getCoordinatesWithLocation(
        origin: _originLocation,
        destination: _destinationLocation,
        mode: RouteMode.walking);
    print(_coordinates.length);
    setState(() {
      _polylines.clear();
    });
    _addPolyline(_coordinates);
    _setLoadingMenu(false);
  }


  _addPolyline(List<LatLng> _coordinates) {
    if(_coordinates==null)print("HELL NOO");
    PolylineId id = PolylineId("poly$_polylineCount");
    Polyline polyline = Polyline(
        polylineId: id,
        patterns: patterns[0],
        color: Colors.blueAccent,
        points: _coordinates,
        width: 10,
        onTap: () {});

    setState(() {
      _polylines[id] = polyline;
      _polylineCount++;
    });
  }

  _setLoadingMenu(bool _status) {
    setState(() {
      _loading = _status;
    });
  }
  Future<LocationData> setLoc() async {
    var location = new Location();
    LocationData currentLocation ;
    try {
      currentLocation = await location.getLocation();
      SOURCE_LOCATION=LatLng(currentLocation.latitude, currentLocation.longitude);
      var point=new GeoPoint(currentLocation.latitude, currentLocation.longitude) ;
      Firestore.instance.collection('amb').document("ug6AKnr3En4OMBjk40s7").updateData({'location':point});
    } catch (e) {
      currentLocation = null;
    }

  }
  Set<Marker> markers = Set();
  _handleTap(LatLng point) {
    setState(() {
      markers.clear();
      markers.add(Marker(
        markerId: MarkerId(point.toString()),
        position: point,
        infoWindow: InfoWindow(
          title: 'I am a marker',
        ),

      ));
      _destinationLocation=point;
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: ThemeData(brightness: Brightness.dark),
      home: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
            leading: IconButton(icon:Icon(Icons.arrow_back),
              //onPressed:() => Navigator.pop(context, false),
              onPressed:() {Navigator.pop(context);}
            ),
          title: Text('Map Polyline'),
        ),
        body: Container(
          child: LayoutBuilder(
            builder: (context, cont) {
              return Stack(
                children: <Widget>[

                  Column(
                    children: <Widget>[
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height - 175,
                        child: GoogleMap(
                          onTap: _handleTap,
                          markers: markers,
                          onMapCreated: _onMapCreated,
                          polylines: Set<Polyline>.of(_polylines.values),
                          initialCameraPosition: CameraPosition(
                            target: _mapInitLocation,
                            zoom: 15,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Align(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                RaisedButton(
                                  child: Text('Set Destination Location'),
                                  onPressed: _getPolylinesWithLocation,
                                ),
                                RaisedButton(
                                  child: Text('Start Drive'),
                                  onPressed: setLoc,
                                ),
                              ],
                            )),
                      ),
                    ],
                  ),
                  Positioned(
                    right: MediaQuery.of(context).size.width*0.05,
                    bottom:MediaQuery.of(context).size.height*0.12,
                    child: FloatingActionButton(
                      child: Icon(Icons.my_location),
                      onPressed:  _goToMyLocation,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: _loading
            ? Container(
          color: Colors.black.withOpacity(0.75),
          child: Center(
            child: Text(
              'Loading Location...',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        )
            : Container(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

  class Utils {
    static String mapStyles = '''[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dadada"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#c9c9c9"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  }
]''';

  }

