import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Map extends StatefulWidget {
  const Map({Key? key}) : super(key: key);

  @override
  State<Map> createState() => _MapState();
}

late double lat;
late double long;
CameraPosition _initialCameraPosition = const CameraPosition(
  target: LatLng(37.3861, 122.0839),
  zoom: 11.5,
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
      appBar: AppBar(
        title: Row(
          children: [
            Text("Map"),
            Expanded(
              child: ElevatedButton(
                  onPressed: () {
                    reportLocationGet();
                  },
                  child: Text("see report area")),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              initialCameraPosition: _initialCameraPosition,
              onMapCreated: (controller) {
                _googleMapController = controller;
              },
              markers: markers.toSet(),
              onLongPress: _addMarker,
              onTap: (coordinates) {
                _googleMapController
                    .animateCamera(CameraUpdate.newLatLng(coordinates));
              },
            ),
          ),
          ElevatedButton(
            child: Text("Select"),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(_initialCameraPosition),
        ),
        child: const Icon(Icons.center_focus_strong),
      ),
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
      String id, double lat, double long, String name, String loc) {
    setState(() {
      markers.add(
        Marker(
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
          position: LatLng(lat, long),
          markerId: MarkerId('$id'),
          infoWindow: InfoWindow(title: '$name', snippet: '$loc'),
        ),
      );
    });
  }

  reportLocationGet() async {
    Stream<QuerySnapshot> snap =
        FirebaseFirestore.instance.collection("R_AREA").snapshots();
    snap.forEach(
      (field) {
        field.docs.asMap().forEach(
          (index, data) async {
            print('${data.id}-----------');
            if (data.id.toString() != 'NO_OF_FRIENDS') {
              DocumentSnapshot user = await FirebaseFirestore.instance
                  .collection('USERS')
                  .doc('${data.id}')
                  .get();
              double lati = double.parse(user['lat']);
              double longi = double.parse(user['long']);
              addMarkerOfReportedArea(data.id, lati, longi,
                  user['name'].toString(), user['location'].toString());
            }
          },
        );
      },
    );
  }
}
