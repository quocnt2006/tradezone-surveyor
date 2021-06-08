import 'package:flutter_map/flutter_map.dart';
import 'package:geodesy/geodesy.dart';

class BuildingPolygon {
  int id;
  String name;
  Polygon polygon;
  LatLng centerPoint;
  int status;

  BuildingPolygon(
    {
      this.id,
      this.name,
      this.polygon,
      this.status,
    }
  );
}