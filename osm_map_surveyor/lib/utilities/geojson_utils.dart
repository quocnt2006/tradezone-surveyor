import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geodesy/geodesy.dart';
import 'package:geojson/geojson.dart';
import 'package:geopoint/geopoint.dart';
import 'package:osm_map_surveyor/models/buiildingpolygon.dart';
import 'package:osm_map_surveyor/models/storepoint.dart';
import 'package:osm_map_surveyor/models/systemzone.dart';
import 'package:osm_map_surveyor/screens/loadingpage/loading_page.dart';
import 'package:pedantic/pedantic.dart';

Future<List<Polygon>> getPolygons(String dataInput) async {
  List<Polygon>  _polygons = <Polygon>[];
  final geojson = GeoJson();
  geojson.processedMultipolygons.listen((GeoJsonMultiPolygon multiPolygon) {
    for (final polygon in multiPolygon.polygons) {
      final geoSerie = GeoSerie(
          type: GeoSerieType.polygon,
          name: polygon.geoSeries[0].name,
          geoPoints: <GeoPoint>[]);
      for (final serie in polygon.geoSeries) {
        geoSerie.geoPoints.addAll(serie.geoPoints);
      }
      final poly = Polygon(
        points: geoSerie.toLatLng(ignoreErrors: true),
        color: Colors.blue.withOpacity(0.2),
        borderColor: Colors.blue,
        borderStrokeWidth: 1,
      );
      _polygons.add(poly);
    }
  });
  geojson.processedPolygons.listen((GeoJsonPolygon geoPolygon) {
    final geoSerie = GeoSerie(
          type: GeoSerieType.polygon,
          name: geoPolygon.geoSeries[0].name,
          geoPoints: <GeoPoint>[]);
    for (final serie in geoPolygon.geoSeries) {
        geoSerie.geoPoints.addAll(serie.geoPoints);
      }
    final poly = Polygon(
      points: geoSerie.toLatLng(ignoreErrors: true),
      color: Colors.blue.withOpacity(0.2),
      borderColor: Colors.blue,
      borderStrokeWidth: 1,
    );
    _polygons.add(poly);
  });
  geojson.endSignal.listen((bool _) => geojson.dispose());
  unawaited(geojson.parse(dataInput, verbose: true));
  return _polygons.toList();
}

Future<void> getInitNeedSurveySystemZonePolygons(String dataInput) async {
  final geojson = GeoJson();
  geojson.processedFeatures.listen((GeoJsonFeature feature) { 
    GeoJsonPolygon geoJsonPolygon = feature.geometry;
    final geoSerie = GeoSerie(
      type: GeoSerieType.polygon,
      name: geoJsonPolygon.geoSeries[0].name,
      geoPoints: <GeoPoint>[]
    );
    for (final serie in geoJsonPolygon.geoSeries) {
        geoSerie.geoPoints.addAll(serie.geoPoints);
      }
    final poly = Polygon(
      points: geoSerie.toLatLng(ignoreErrors: true),
      color: Colors.blue.withOpacity(0.2),
      borderColor: Colors.blue,
      borderStrokeWidth: 1,
    );
    final drawPoly = Polygon(
      points: geoSerie.toLatLng(ignoreErrors: true),
      color: Colors.blue.withOpacity(0.0),
      borderColor: Colors.blue,
      borderStrokeWidth: 1,
    );
    int id = feature.properties['f1'] != null ? int.parse(feature.properties['f1'].toString()) : null;
    String name = feature.properties['f2'] != null ? feature.properties['f2'].toString() : null;
    initListNeedSurveySystemZonePolygons.add(poly);
    initListNeedSurveySystemZone.add(new SystemZone(id: id, name: name));
    initListNeedSurveySystemZoneForDrawPolygons.add(drawPoly);
  });
  await geojson.parse(dataInput, verbose: true);
  geojson.endSignal.listen((bool _) => geojson.dispose());
}

Future<void> getInitNeedSurveyBuildingPolygons(String dataInput) async {
  initListNeedSurveyBuildingPolygons.clear();
  final geojson = GeoJson();
  geojson.processedFeatures.listen((GeoJsonFeature feature) {
    BuildingPolygon buildingPolygon = new BuildingPolygon();
    int id = feature.properties['f4'] != null ? int.parse(feature.properties['f4'].toString()) : null;
    String name = feature.properties['f2'] != null ? feature.properties['f2'].toString() : null;
    String centerPointString = feature.properties['f5'] != null ? feature.properties['f5'].toString() : null;
    int status = feature.properties['f3'] != null ? feature.properties['f3'] : null;
    double centerPointLongitude = 0;
    double centerPointLatitude = 0;
    Color polygonColor = Colors.grey;
    if (status != null) {
      if (status == 1) {
        polygonColor = Colors.green;
      } else if (status == 2) {
        polygonColor = Colors.orange;
      } else if (status == 3 || status == 4) {
        polygonColor = Colors.yellow;
      }
    }
    if (centerPointString != null) {
      centerPointString =  centerPointString.substring(centerPointString.indexOf(' '), centerPointString.length).toString();
      centerPointString = centerPointString.replaceAll('(', '').toString();
      centerPointString = centerPointString.replaceAll(')', '').toString();
      centerPointLongitude = double.parse(centerPointString.split(' ')[1]);
      centerPointLatitude = double.parse(centerPointString.split(' ')[2]);
    }
    GeoJsonMultiPolygon multiPolygon = feature.geometry;
    GeoJsonPolygon geoPolygon = multiPolygon.polygons[0];
    final geoSerie = GeoSerie(
      type: GeoSerieType.polygon,
      name: geoPolygon.geoSeries[0].name,
      geoPoints: <GeoPoint>[]
    );
    for (final serie in geoPolygon.geoSeries) {
      geoSerie.geoPoints.addAll(serie.geoPoints);
    }
    final poly = Polygon(
      points: geoSerie.toLatLng(ignoreErrors: true),
      color: polygonColor.withOpacity(0.2),
      borderColor: polygonColor,
      borderStrokeWidth: 1,
    );
    buildingPolygon = new BuildingPolygon(id: id, name: name, polygon: poly, status: status);
    if (centerPointString != null) buildingPolygon.centerPoint = new LatLng(centerPointLatitude, centerPointLongitude);
    initListNeedSurveyBuildingPolygons.add(buildingPolygon);
  });
  await geojson.parse(dataInput, verbose: true);
  geojson.endSignal.listen((bool _) => geojson.dispose());
}

Future<void> getInitListCampusPolygons(String dataInput) async {
  initListCampusPolygons.clear();
  final geojson = GeoJson();
  geojson.processedFeatures.listen((GeoJsonFeature feature) {
    GeoJsonPolygon geoPolygon = feature.geometry;
   // GeoJsonPolygon geoPolygon = multiPolygon.polygons[0];
    final geoSerie = GeoSerie(
      type: GeoSerieType.polygon,
      name: geoPolygon.geoSeries[0].name,
      geoPoints: <GeoPoint>[]
    );
    for (final serie in geoPolygon.geoSeries) {
      geoSerie.geoPoints.addAll(serie.geoPoints);
    }
    final poly = Polygon(
      points: geoSerie.toLatLng(ignoreErrors: true),
      color: Colors.green.withOpacity(0),
      borderColor: Colors.green,
      borderStrokeWidth: 1,
    );
    initListCampusPolygons.add(poly);
  });
  await geojson.parse(dataInput, verbose: true);
  geojson.endSignal.listen((bool _) => geojson.dispose());
}

Future<void> getInitStoreOnMapPoints(String dataInput) async {
  initListStorePointsOnMap.clear();
  final geojson = GeoJson();
    geojson.processedFeatures.listen((GeoJsonFeature feature) {
      int id = feature.properties['f4'] != null ? int.parse(feature.properties['f4'].toString()) : null;
      String name = feature.properties['f2'] != null ? feature.properties['f2'] : null;
      String type = feature.properties['f1'] != null ? feature.properties['f1'] : null;
      int status = feature.properties['f3'] != null ? int.parse(feature.properties['f3'].toString()) : null;
      GeoJsonPoint geoJsonPoint = feature.geometry;
      LatLng point = LatLng(geoJsonPoint.geoPoint.latitude, geoJsonPoint.geoPoint.longitude);
      initListStorePointsOnMap.add(
        new StorePoint(id: id, name: name, type: type, status: status, point: point)
      );
    });
    await geojson.parse(dataInput, verbose: true);
    geojson.endSignal.listen((bool _) => geojson.dispose());
}