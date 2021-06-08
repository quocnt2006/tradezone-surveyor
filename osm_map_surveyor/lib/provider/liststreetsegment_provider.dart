import 'package:osm_map_surveyor/models/liststreetsegments.dart';
import 'package:osm_map_surveyor/utilities/base_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong/latlong.dart';
import 'dart:io';

class ListStreetSegmentProvider {
  Future<ListStreetSegments> fetchListStreetSegments(List<LatLng> points) async {
    final prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("JwtToken");
    String coordinateString = "";
    for (final point in points) {
      if (point == points.last) {
        coordinateString = coordinateString +
            point.longitude.toString() +
            " " +
            point.latitude.toString() +
            "," +
            points.first.longitude.toString() +
            " " +
            points.first.latitude.toString();
      } else {
        coordinateString = coordinateString +
            point.longitude.toString() +
            " " +
            point.latitude.toString() +
            ",";
      }
    }
    String jsonString = '{' + '"coordinateString": "' + coordinateString + '"''}';
    final http.Response response = await http.post(
      BaseUrl.liststreetsegment,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwtToken
      },
      body: jsonString
    );
    if (response.statusCode == 200) {
      ListStreetSegments rs = ListStreetSegments.fromJson(jsonDecode(response.body));
      return rs;
    } else {
      throw Exception('Failed to load street segments');
    }
  }

  Future<ListStreetSegments> fetchListStreetSegmentsByPoint(LatLng point) async {
    final prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("JwtToken");
    String jsonString = '{' + '"coordinateString": "' + point.longitude.toString() + ' ' + point.latitude.toString() + '"}';

    final http.Response response = await http.post(
      BaseUrl.liststreetsegmentbypoint,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwtToken
      },
      body: jsonString,
    );

    if (response.statusCode == 200) {
      ListStreetSegments rs = ListStreetSegments.fromJson(jsonDecode(response.body));
      return rs;
    } else {
      throw Exception('Failed to load street segments by point');
    }
  }
}
