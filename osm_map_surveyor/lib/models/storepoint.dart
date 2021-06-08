import 'package:geodesy/geodesy.dart';

class StorePoint {
  int id;
  String name;
  String type;
  int status;
  LatLng point;

  StorePoint({
    this.id,
    this.name,
    this.type,
    this.status,
    this.point
  });
}