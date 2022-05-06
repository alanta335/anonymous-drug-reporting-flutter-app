import 'dart:convert';
import 'expendable_fab.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart';
import 'package:report/models/basicJson.dart';

class Map extends StatefulWidget {
  const Map({Key? key}) : super(key: key);

  @override
  State<Map> createState() => _MapState();
}

double lat = 0.0;
double long = 0.0;
CameraPosition _initialCameraPosition = const CameraPosition(
  target: LatLng(37.3861, 122.0839),
  zoom: 0,
);

Future<Position> _getGeoLocationPosition() async {
  bool serviceEnabled;
  LocationPermission permission;
  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    await Geolocator.openLocationSettings();
    return Future.error('Location services are disabled.');
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }
  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
}

class _MapState extends State<Map> {
  var ls = [];
  var dio = Dio();
  Set<Circle> circles = Set.from([
    Circle(
      circleId: CircleId("s"),
      center: LatLng(lat, long),
      radius: 0,
    )
  ]);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    mapLocset();
  }

  final Set<Marker> markers = {};

  void mapLocset() async {
    Position pos = await _getGeoLocationPosition();

    setState(() {
      markers.add(
        Marker(
          markerId: const MarkerId('mylocation'),
          infoWindow: const InfoWindow(title: 'current location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          position: LatLng(pos.latitude, pos.longitude),
        ),
      );
    });

    _initialCameraPosition = CameraPosition(
      target: LatLng(pos.latitude, pos.longitude),
      zoom: 18,
    );
  }

  late GoogleMapController _googleMapController;

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              child: GoogleMap(
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                initialCameraPosition: _initialCameraPosition,
                onMapCreated: (controller) {
                  _googleMapController = controller;
                },
                markers: markers.toSet(),
                onLongPress: _addMarker,
                circles: circles,
                onTap: (coordinates) {
                  _googleMapController
                      .animateCamera(CameraUpdate.newLatLng(coordinates));
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ExpendableFab(distance: 100, children: [
        ActionButton(
            icon: Icon(Icons.center_focus_strong_rounded,
                color: Colors.yellowAccent),
            onPressed: () {
              _googleMapController.animateCamera(
                  CameraUpdate.newCameraPosition(_initialCameraPosition));
            }),
        ActionButton(
          icon: Icon(Icons.done, color: Colors.yellowAccent),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ]),
    );
  }

  void _addMarker(LatLng pos) {
    setState(() {
      markers.add(
        Marker(
          markerId: const MarkerId('reportArea'),
          infoWindow: const InfoWindow(title: 'report area'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          position: pos,
        ),
      );
      lat = pos.latitude;
      long = pos.longitude;
    });
  }

  void addMarkerOfReportedArea(
    String id,
    double lat,
    double long,
    double radius,
  ) {
    setState(() {
      ls.add({"lat": lat, "long": long});
      if (id == "MAX") {
        circles.add(Circle(
            strokeColor: Colors.red,
            fillColor: Color.fromARGB(150, 175, 217, 237),
            strokeWidth: 0,
            circleId: CircleId("2"),
            radius: radius * 115550,
            center: LatLng(lat, long)));
        markers.add(Marker(
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          position: LatLng(lat, long),
          markerId: MarkerId('$id'),
        ));
      } else {
        markers.add(Marker(
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          position: LatLng(lat, long),
          markerId: MarkerId('$id'),
        ));
      }
    });
  }

  reportLocationGet() async {
    markers.clear();
    Stream<QuerySnapshot> snap =
        FirebaseFirestore.instance.collection("R_AREA").snapshots();
    snap.forEach(
      (field) {
        field.docs.asMap().forEach(
          (index, data) async {
            //print('${data.id}-----------');
            DocumentSnapshot user = await FirebaseFirestore.instance
                .collection('R_AREA')
                .doc('${data.id}')
                .get();
            double lati = user['lat'];
            double longi = user['long'];
            addMarkerOfReportedArea(data.id, lati, longi, 0.0);
          },
        );
      },
    );
  }
}
