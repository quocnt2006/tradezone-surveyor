import 'dart:convert';
import 'dart:io';
import 'package:geodesy/geodesy.dart';
import "package:latlong/latlong.dart" as latLng;
import 'package:http/http.dart' as http;
import 'package:osm_map_surveyor/models/building.dart';
import 'package:osm_map_surveyor/models/liststores.dart';
import 'package:osm_map_surveyor/models/liststreetsegments.dart';
import 'package:osm_map_surveyor/models/store.dart';
import 'package:osm_map_surveyor/models/storepost.dart';
import 'package:osm_map_surveyor/utilities/base_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoreProvider {
  Future<String> fetchStoresByFourBounds(
    latLng.LatLng northWest,
    latLng.LatLng northEast,
    latLng.LatLng southEast,
    latLng.LatLng southWest) async {
    final prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("JwtToken");
    String jsonString = '{' +
        '"coordinateString": "' +
        northWest.longitude.toString() + ' ' + northWest.latitude.toString() + ',' +
        northEast.longitude.toString() + ' ' + northEast.latitude.toString() + ',' +
        southEast.longitude.toString() + ' ' + southEast.latitude.toString() + ',' + 
        southWest.longitude.toString() + ' ' + southWest.latitude.toString() + ',' + 
        northWest.longitude.toString() + ' ' + northWest.latitude.toString() +
        '"''}';

    final http.Response response = await http.post(
      BaseUrl.mapstore,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json', 
        HttpHeaders.authorizationHeader: 'Bearer ' + jwtToken
      },
      body: jsonString
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load stores');
    }
  }

  Future<List<Building>> fetchListBuildings(LatLng point) async {
    final prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("JwtToken");
    String jsonString = '{' + '"coordinateString": "' + point.longitude.toString() + ' ' + point.latitude.toString() + '"}';
    final http.Response response = await http.post(
      BaseUrl.liststorebuildings,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwtToken
      },
      body: jsonString,
    ); 
    if (response.statusCode == 200) {
      List<Building> rs = <Building>[];
      dynamic json = jsonDecode(response.body);
      json.forEach((building) {
        rs.add(new Building.fromJson(building));
      });
      return rs;
    } else {
      throw Exception('Fail to get list buildings');
    }
  }

  Future<bool> addStore(StorePost store) async {
    final prefs = await SharedPreferences.getInstance();
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    String jwtToken = prefs.getString("JwtToken");
    dynamic jsonString = encoder.convert(store);
    final http.Response response = await http.post(
      BaseUrl.stores,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwtToken
      },
      body: jsonString,
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Fail to add store');
    }
  }

  Future<bool> updateStore(StorePost store) async {
    final prefs = await SharedPreferences.getInstance();
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    String jwtToken = prefs.getString("JwtToken");
    dynamic jsonString = encoder.convert(store);
    final http.Response response = await http.put(
      BaseUrl.storebyid(store.id),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwtToken
      },
      body: jsonString,
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Fail to update store');
    }
  }

  Future<ListStores> fetchNeedSurveyStores() async {
    final prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("JwtToken");
    final http.Response response = await http.get(
      BaseUrl.storesneedsurveyor,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwtToken
      },
    );
    if (response.statusCode == 200) {
      ListStores rs = ListStores.fromJson(jsonDecode(response.body));
      return rs;
    } else if (response.statusCode == 204) {
      ListStores rs = ListStores();
      rs.results = new List<Store>();
      return rs;
    } else {
      return null;
    }
  }

  Future<ListStreetSegments> fetchListStreetSegmentsByStoreId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("JwtToken");
    final http.Response response = await http.get(
      BaseUrl.liststreetsegmentbystoreid(id),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwtToken
      },
    );
    if (response.statusCode == 200) {
      ListStreetSegments rs = ListStreetSegments.fromJson(jsonDecode(response.body));
      return rs;
    } else {
      throw Exception('Fail to get list street segments by store id');
    }
  }

  Future<bool> deleteStoreById(int id) async {
    final prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("JwtToken");
    final http.Response response = await http.delete(
      BaseUrl.storebyid(id), 
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

  Future<Store> fetchStoreById(int id) async {
    final prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("JwtToken");
    final http.Response response = await http.get(
      BaseUrl.storebyid(id), 
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwtToken
      }
    );
    if (response.statusCode == 200) {
      Store rs = new Store.fromJson(jsonDecode(response.body));
      return rs;
    } else {
      throw Exception('Fail to get store by id');
    }
  }

  Future<String> fetchNeedSurveyStoresMap() async {
    final prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("JwtToken");
    final http.Response response = await http.get(
      BaseUrl.needsurveystoremap,
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

  Future<bool> checkStoreLocation(LatLng point) async {
    final prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("JwtToken");
    String str = point.longitude.toString() + '%20' + point.latitude.toString();
    final http.Response response = await http.get(
      BaseUrl.storevalidmapbylocation(str),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwtToken
      },
    ); 
    if (response.statusCode == 200) {
      bool rs = jsonDecode(response.body);
      return rs;
    } else {
      return null;
    }
  }
} 