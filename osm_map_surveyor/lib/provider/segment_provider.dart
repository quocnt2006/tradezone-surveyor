import 'dart:convert';
import 'dart:io';
import 'package:osm_map_surveyor/models/segment.dart';
import 'package:osm_map_surveyor/utilities/base_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SegmentProvider {
  Future<List<Segment>> fetchListSegments() async {
    final prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("JwtToken");
    final http.Response response = await http.get(
      BaseUrl.segment,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwtToken
      },
    );
    if (response.statusCode == 200) {
      List<Segment> rs = new List<Segment>();
      dynamic json = jsonDecode(response.body);
      json.forEach((segment) {
        rs.add(new Segment.fromJson(segment));
      });
      return rs;
    } else if (response.statusCode == 204) {
      List<Segment> rs = new List<Segment>();
      return rs;
    } else {
      return null;
    }
  }
}