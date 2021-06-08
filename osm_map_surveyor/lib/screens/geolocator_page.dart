import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class GeolocatorsPage extends StatefulWidget {
  @override
  _GeolocatorsPageState createState() => _GeolocatorsPageState();
}

class _GeolocatorsPageState extends State<GeolocatorsPage> {
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

  Position _currentPosition;
  String _currentAddress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Location"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_currentPosition != null) Text(_currentAddress),
            FlatButton(
              child: Text("Get location"),
              onPressed: () {
                _getCurrentLocation();
                print("LAT: " + 
                  _currentPosition.latitude.toString() + " " + "LNG: " + 
                  _currentPosition.longitude.toString());
              },
            ),
          ],
        ),
      ),
    );
  }

  _getCurrentLocation() {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best).then((Position position) {
      setState(() {
        _currentPosition = position;
      });
      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
        _currentPosition.latitude, 
        _currentPosition.longitude
      );

      Placemark place = p[0];

      setState(() {
        _currentAddress =
            "${place.subThoroughfare}, ${place.thoroughfare}, ${place.subAdministrativeArea}, ${place.administrativeArea}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }
}
