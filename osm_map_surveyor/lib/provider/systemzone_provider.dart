import 'dart:convert';
import 'dart:io';
import 'package:osm_map_surveyor/models/listbuildings.dart';
import 'package:osm_map_surveyor/models/liststores.dart';
import 'package:osm_map_surveyor/models/listsystemzone.dart';
import 'package:osm_map_surveyor/utilities/base_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SystemzoneProvider {
  Future<String> fetchNeedSurveySystemZoneMap() async {
    final prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("JwtToken");
    final http.Response response = await http.get(
      BaseUrl.needsurveysystemzonemap,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwtToken
      },
    );
    if (response.statusCode == 200) {
      return response.body.toString();
    } else {
      return null;
    }
  }

  Future<ListSystemZone> getListSystemZone(int districtId, int page, int pageSize, bool isMe) async {
    final prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("JwtToken");
    final http.Response response = await http.get(
      BaseUrl.pagingsystemzones(districtId ,page, pageSize, isMe),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwtToken
      },
    );
    if (response.statusCode == 200) {
      ListSystemZone rs = new ListSystemZone.fromJson(jsonDecode(response.body));
      return rs;
    } else {
      return null;
    }
  }

  Future<ListBuildings> getListSystemZoneBuilding(int id, int page, int pageSize) async {
    final prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("JwtToken");
    final http.Response response = await http.get(
      BaseUrl.systemzonebuildings(id, page, pageSize),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwtToken
      },
    );
    if (response.statusCode == 200) {
      ListBuildings rs = new ListBuildings.fromJson(jsonDecode(response.body));
      return rs;
    } else {
      return null;
    }
  }  

  Future<ListStores> getListSystemZoneStores(int id, int page, int pageSize) async {
    final prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("JwtToken");
    final http.Response response = await http.get(
      BaseUrl.systemzonestores(id ,page, pageSize),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwtToken
      },
    );
    if (response.statusCode == 200) {
      ListStores rs = new ListStores.fromJson(jsonDecode(response.body));
      return rs;
    } else {
      return null;
    }
  }  
}