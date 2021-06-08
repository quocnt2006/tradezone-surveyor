import "package:latlong/latlong.dart";
import 'package:geolocator/geolocator.dart';

getAddressFromLatLng(LatLng point) async {
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  try {
    List<Placemark> p = await geolocator.placemarkFromCoordinates(point.latitude, point.longitude);

    Placemark place = p[0];
    dynamic _address =
        "${place.subThoroughfare}, ${place.thoroughfare}, ${place.subAdministrativeArea}, ${place.administrativeArea}, ${place.country}";
    return _address;
  } catch (e) {
    print(e);
  }
  return null;
}

getCurrentLocation() async {
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  LatLng currentPosition;
  await geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best).then((Position position) {
    currentPosition = LatLng(position.latitude, position.longitude);
  }).catchError((e) {
    print(e);
  });
  return currentPosition;
}

getCenterPolygon(List<LatLng> points) {
  if (points != null) {
    double minLat = 0;
    double minLng = 0;
    double maxLat = 0;
    double maxLng = 0;
    for (final point in points) {
      if (minLat == 0) {
        minLat = point.latitude;
      }
      if (minLng == 0) {
        minLng = point.longitude;
      }
      if (maxLat == 0) {
        maxLat = point.latitude;
      }
      if (maxLng == 0) {
        maxLng = point.longitude;
      }

      if (minLat > point.latitude) {
        minLat = point.latitude;
      }
      if (minLng > point.longitude) {
        minLng = point.longitude;
      }
      if (maxLat < point.latitude) {
        maxLat = point.latitude;
      }
      if (maxLng < point.longitude) {
        maxLng = point.longitude;
      }
    }
    double centerLat = minLat + ((maxLat - minLat) / 2);
    double centerLng = minLng + ((maxLng - minLng) / 2);
    return LatLng(centerLat, centerLng);
  }
}