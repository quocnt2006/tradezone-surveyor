import 'dart:convert';
import 'dart:io';
import "package:latlong/latlong.dart" as latLng;
import 'package:http/http.dart' as http;
import 'package:osm_map_surveyor/models/building.dart';
import 'package:osm_map_surveyor/models/buildinganalysis.dart';
import 'package:osm_map_surveyor/models/buildingpost.dart';
import 'package:osm_map_surveyor/models/buildingtypes.dart';
import 'package:osm_map_surveyor/models/campus.dart';
import 'package:osm_map_surveyor/models/listbuildings.dart';
import 'package:osm_map_surveyor/models/liststreetsegments.dart';
import 'package:osm_map_surveyor/utilities/base_url.dart';
import 'package:osm_map_surveyor/utilities/config_base.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BuildingProvider {
  Future<String> fetchBuildingByFourBounds(
      latLng.LatLng northWest,
      latLng.LatLng northEast,
      latLng.LatLng southEast,
      latLng.LatLng southWest) async {
    final prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("JwtToken");
    String jsonString = '{' +
        '"coordinateString": "' +
        northWest.longitude.toString() +
        ' ' +
        northWest.latitude.toString() +
        ',' +
        northEast.longitude.toString() +
        ' ' +
        northEast.latitude.toString() +
        ',' +
        southEast.longitude.toString() +
        ' ' +
        southEast.latitude.toString() +
        ',' +
        southWest.longitude.toString() +
        ' ' +
        southWest.latitude.toString() +
        ',' +
        northWest.longitude.toString() +
        ' ' +
        northWest.latitude.toString() +
        '"''}';
    final http.Response response = await http.post(BaseUrl.mapbuildings,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwtToken
      },
      body: jsonString
    );
    print(response.body);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load building on four bound');
    }
  }

  Future<String> fetchNeedSurveyBuildingsMap() async {
    final prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("JwtToken");
    final http.Response response = await http.get(
      BaseUrl.needsurveybuildingmap,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwtToken
      },
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  }

  Future<Building> fetchBuildingById(int id) async {
    final prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("JwtToken");
    final http.Response response = await http.get(
      BaseUrl.buildingbyid(id),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwtToken
      }
    );
    if (response.statusCode == 200) {
      Building rs = Building.fromJson(jsonDecode(response.body));
      return rs;
    } else {
      throw Exception('Fail to load building details by id');
    }
  }

  Future<bool> addBuilding(BuildingPost building) async {
    final prefs = await SharedPreferences.getInstance();
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    String jwtToken = prefs.getString("JwtToken");
    dynamic jsonString = encoder.convert(building);
    final http.Response response = await http.post(
      BaseUrl.buildings,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwtToken
      },
      body: jsonString,
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Fail to add building');
    }
  }

  Future<Building> fetchUpdateBuilding(BuildingPost building) async {
    final prefs = await SharedPreferences.getInstance();
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    String jwtToken = prefs.getString("JwtToken");
    int id = building.id;
    building.id = null;
    dynamic jsonString = encoder.convert(building);
    final http.Response response = await http.put(
      BaseUrl.buildingbyid(id),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwtToken
      },
      body: jsonString,
    );
    if (response.statusCode == 200) {
      Building rs = new Building.fromJson(jsonDecode(response.body));
      return rs;
    } else {
      throw Exception('Fail to update building');
    }
  }

  Future<List<BuildingType>> fetchListBuildingTypes() async {
    final prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("JwtToken");
    final http.Response response = await http.get(
      BaseUrl.listbuildingtypes,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwtToken
      },
    );
    if (response.statusCode == 200) {
      List<BuildingType> rs = new List<BuildingType>();
      jsonDecode(response.body).forEach((buildingType) {
        rs.add(new BuildingType.fromJson(buildingType));
      });
      return rs;
    } else {
      return null;
    }
  }

  Future<Campus> fetchCampus(String geomBuilding) async {
    final prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("JwtToken");
    String jsonString = '{"coordinateString": "' + geomBuilding + '"}';
    final http.Response response = await http.post(
      BaseUrl.getbuildingcampus,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwtToken
      },
      body: jsonString,
    );
    if (response.statusCode == 200) {
      Campus rs;
      rs = Campus.fromJson(jsonDecode(response.body));
      return rs;
    } else if (response.statusCode == 204) {
      Campus rs = new Campus(id: -2);
      return rs;
    } 
    else {
      throw Exception('Fail to get campus');
    }
  }

  Future<ListBuildings> fetchNeedSurveyBuildings() async {
    final prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("JwtToken");
    final http.Response response = await http.get(
      BaseUrl.buildingsneedsurveyor,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwtToken
      },
    );
    if (response.statusCode == 200) {
      ListBuildings rs = ListBuildings.fromJson(jsonDecode(response.body));
      return rs;
    } else if (response.statusCode == 204) {
      ListBuildings rs = ListBuildings();
      rs.results = new List<Building>();
      return rs;
    } else {
      return null;
    }
  }

  Future<ListStreetSegments> fetchListStreetSegmentsByBuildingId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("JwtToken");
    final http.Response response = await http.get(
      BaseUrl.liststreetsegmentbybuildingid(id),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwtToken
      },
    );
    if (response.statusCode == 200) {
      ListStreetSegments rs = ListStreetSegments.fromJson(jsonDecode(response.body));
      return rs;
    } else {
      throw Exception('Fail to get list street segments by building id');
    }
  }

  Future<bool> deleteBuildingById(int id) async {
    final prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("JwtToken");
    final http.Response response = await http.delete(
      BaseUrl.buildingbyid(id), 
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwtToken
      }
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<BuildingAnalysis> saveBuildingAnalysis(BuildingAnalysis buildingAnalysis) async {
    final prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("JwtToken");
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    dynamic jsonString = encoder.convert(buildingAnalysis);
    final http.Response response = await http.post(
      BaseUrl.analysisbuilding, 
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwtToken
      },
      body: jsonString,
    );
    if (response.statusCode == 200) {
      BuildingAnalysis rs;
      rs = new BuildingAnalysis.fromJson(jsonDecode(response.body));
      return rs;
    } else {
      throw Exception('Fail to save building analysis');
    }
  }

  Future<List<BuildingAnalysis>> fetchListBuildingAnalysis(int id) async {
    final prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("JwtToken");
    final http.Response response = await http.get(
      BaseUrl.listBuildingAnalysis(id), 
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwtToken
      },
    );
    if (response.statusCode == 200) {
      List<BuildingAnalysis> rs = new List<BuildingAnalysis>();
      dynamic json = jsonDecode(response.body);
      json.forEach((buildingAnalysis) {
        rs.add(new BuildingAnalysis.fromJson(buildingAnalysis));
      });
      return rs;
    } else if (response.statusCode == 204) {
      List<BuildingAnalysis> rs = new List<BuildingAnalysis>();
      return rs;
    } else {
      throw Exception('Fail to get list building analysis');
    }
  }

  Future<BuildingAnalysis> deleteBuildingAnalysis(int buildingId, int categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("JwtToken");
    final http.Response response = await http.delete(
      BaseUrl.buildingAnalysisById(buildingId, categoryId), 
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwtToken
      },
    );
    if (response.statusCode == 200) {
      BuildingAnalysis rs = new BuildingAnalysis.fromJson(jsonDecode(response.body));
      return rs;
    } else {
      throw Exception('Fail to delete building analysis');
    }
  }
  Future<BuildingAnalysis> updateBuildingAnalysis(BuildingAnalysis buildingAnalysis) async {
    final prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("JwtToken");
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    dynamic jsonString = encoder.convert(buildingAnalysis);
    final http.Response response = await http.put(
      BaseUrl.buildingAnalysisById(buildingAnalysis.buildingId, buildingAnalysis.segmentId), 
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwtToken
      },
      body: jsonString,
    );
    if (response.statusCode == 200) {
      BuildingAnalysis rs;
      rs = new BuildingAnalysis.fromJson(jsonDecode(response.body));
      return rs;
    } else {
      throw Exception('Fail to save building analysis');
    }
  }

  Future<String> fetchCampusMap() async {
    final prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("JwtToken");
    String jsonString = '{' +
        '"coordinateString": "' + Config.jsonStringCampus + '"''}';
    final http.Response response = await http.post(BaseUrl.mapcampus,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwtToken
      },
      body: jsonString
    );
    print(response.body);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load campus');
    }
  }
}
